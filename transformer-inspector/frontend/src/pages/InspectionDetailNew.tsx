// src/pages/InspectionDetailNew.tsx
import { useState, useEffect, useRef } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import AnnotationCanvas from '../components/AnnotationCanvas';
import AnnotationToolbar from '../components/AnnotationToolbar';
import AnnotationLegend from '../components/AnnotationLegend';
import NotesSection from '../components/NotesSection';
import CommentsSection from '../components/CommentsSection';
import FileDrop from '../components/FileDrop';
import InspectionHistoryList from '../components/InspectionHistoryList';
import {
  getInspection,
  detectAnomalies,
  uploadInspectionImage,
  updateInspectionStatus,
  uploadAnnotatedImage,
  removeInspectionImage,
} from '../api/inspections';
import { getAnnotationsByInspection, saveAnnotation, approveAnnotation, rejectAnnotation, deleteAnnotation, exportFeedback, exportFeedbackCSV } from '../api/annotations';
import { uploadImage, listImages } from '../api/images';
import type { ThermalImage } from '../api/images';
import type { Inspection } from '../api/inspections';
import type { Annotation } from '../api/annotations';

export default function InspectionDetailNew() {
  const { id } = useParams();
  const nav = useNavigate();

  const [inspection, setInspection] = useState<Inspection | null>(null);
  const [annotations, setAnnotations] = useState<Annotation[]>([]);
  const [baselineImage, setBaselineImage] = useState<ThermalImage | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  
  // Annotation canvas state
  const [mode, setMode] = useState<'view' | 'edit' | 'draw'>('view');
  const [selectedClass, setSelectedClass] = useState('Faulty');
  const [isDetecting, setIsDetecting] = useState(false);
  
  // Image upload state
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [uploading, setUploading] = useState(false);
  const [uploadError, setUploadError] = useState<string | null>(null);
  const [removingImage, setRemovingImage] = useState(false);
  
  // Inspection completion state
  const [isCompleting, setIsCompleting] = useState(false);
  
  // Canvas capture state
  const captureCanvasRef = useRef<(() => string | null) | null>(null);
  const [isCanvasReady, setIsCanvasReady] = useState(false);
  const [isSavingImage, setIsSavingImage] = useState(false);
  
  // Threshold modal state
  const [showThresholdModal, setShowThresholdModal] = useState(false);
  const [threshold, setThreshold] = useState(50); // Default threshold value (0-100)
  
  // Feedback export state (FR3.3)
  const [isExportingFeedback, setIsExportingFeedback] = useState(false);

  // Add this with other state declarations at the top of the component
  const [commentsExpanded, setCommentsExpanded] = useState(true);
  const [historyExpanded, setHistoryExpanded] = useState(true);
  
  // Load inspection and annotations
  useEffect(() => {
    if (!id) return;
    loadData();
  }, [id]);

  async function loadData() {
    if (!id) return;
    
    try {
      setLoading(true);
      setError(null);
      
      const [inspectionData, annotationsData] = await Promise.all([
        getInspection(id),
        getAnnotationsByInspection(id)
      ]);
      
      setInspection(inspectionData);
      setAnnotations(annotationsData);
      
      // Load baseline image for the transformer
      if (inspectionData.transformerId) {
        await loadBaselineImage(inspectionData.transformerId, inspectionData.weatherCondition);
      }
    } catch (e: any) {
      setError(e?.message || 'Failed to load data');
    } finally {
      setLoading(false);
    }
  }




  
  async function loadBaselineImage(transformerId: string, weatherCondition?: string | null) {
    try {
      const response = await listImages({ transformerId, type: 'BASELINE', page: 0, size: 10 });
      const baselineImages = response.content || [];
      
      // Try to find a baseline image matching the weather condition first
      let selectedBaseline = null;
      if (weatherCondition) {
        selectedBaseline = baselineImages.find(img => 
          img.envCondition === weatherCondition
        );
      }
      
      // If no matching weather condition, use the most recent baseline image
      if (!selectedBaseline && baselineImages.length > 0) {
        selectedBaseline = baselineImages.sort((a, b) => 
          new Date(b.uploadedAt).getTime() - new Date(a.uploadedAt).getTime()
        )[0];
      }
      
      setBaselineImage(selectedBaseline || null);
    } catch (e: any) {
      console.error('Failed to load baseline image:', e);
      setBaselineImage(null);
    }
  }

  async function handleDetectAnomalies() {
    if (!id) return;
    
    // Validate that inspection exists and has an image uploaded
    if (!inspection || !inspection.inspectionImageId) {
      alert('⚠️ Please upload an inspection image before detecting anomalies.');
      return;
    }
    
    // Check if baseline image exists
    if (!baselineImage && !inspection.baselineImageUrl) {
      alert('⚠️ No baseline image found for comparison. Please upload a baseline image for this transformer first.');
      return;
    }
    
    // Open threshold modal instead of directly calling detection
    setShowThresholdModal(true);
  }

  async function handleDetectWithThreshold() {
    if (!id) return;
    
    try {
      setIsDetecting(true);
      setShowThresholdModal(false);
      
      // Convert threshold from 0-100 to 0.0-1.0 range expected by backend
      const normalizedThreshold = threshold / 100;
      
      const result = await detectAnomalies(id, normalizedThreshold);
      
      // Refresh annotations, inspection data, and baseline image
      const [updatedAnnotations, updatedInspection] = await Promise.all([
        getAnnotationsByInspection(id),
        getInspection(id)
      ]);
      
      setAnnotations(updatedAnnotations);
      setInspection(updatedInspection);
      
      // Refresh baseline image as well
      if (updatedInspection.transformerId) {
        await loadBaselineImage(updatedInspection.transformerId, updatedInspection.weatherCondition);
      }
      
      alert(`✅ Detection complete! Found ${result.detections?.length || 0} anomalies with threshold ${threshold}%.`);
    } catch (e: any) {
      alert('❌ Detection failed: ' + (e?.message || 'Unknown error'));
    } finally {
      setIsDetecting(false);
    }
  }

  async function handleAnnotationCreate(bbox: { x1: number; y1: number; x2: number; y2: number }) {
    if (!id) return;
    
    // Map className to classId (matches backend enum/constants)
    const getClassId = (className: string): number => {
      const classMap: Record<string, number> = {
        'Faulty': 1,
        'faulty_loose_joint': 2, 
        'faulty_point_overload': 3,
        'potential_faulty': 4,
      };
      return classMap[className] || 1;
    };
    
    try {
      const annotationRequest = {
        inspectionId: id,
        bbox: {
          x1: Math.round(bbox.x1),
          y1: Math.round(bbox.y1), 
          x2: Math.round(bbox.x2),
          y2: Math.round(bbox.y2),
        },
        classId: getClassId(selectedClass),
        className: selectedClass,
        confidence: 1.0,
        source: 'human' as const,
        userId: 'current-user@example.com', // TODO: Get from auth context
      };
      
      console.log('Creating annotation with request:', annotationRequest);
      
      await saveAnnotation(annotationRequest);
      
      await loadData();
    } catch (e: any) {
      console.error('Annotation creation error:', e);
      alert('Failed to create annotation: ' + (e?.message || 'Unknown error'));
    }
  }

  async function handleAnnotationUpdate(annotation: Annotation) {
    // Map className to classId (matches backend enum/constants)
    const getClassId = (className: string): number => {
      const classMap: Record<string, number> = {
        'Faulty': 1,
        'faulty_loose_joint': 2, 
        'faulty_point_overload': 3,
        'potential_faulty': 4,
      };
      return classMap[className] || 1;
    };
    
    try {
      console.log('Updating annotation with ID:', annotation.id, 'for version creation');
      
      await saveAnnotation({
        id: annotation.id, // Include ID for version creation
        inspectionId: annotation.inspectionId,
        bbox: annotation.bbox,
        classId: getClassId(annotation.className),
        className: annotation.className,
        confidence: annotation.confidence,
        source: annotation.source,
        userId: 'current-user@example.com',
      });
      
      await loadData();
    } catch (e: any) {
      alert('Failed to update annotation: ' + (e?.message || 'Unknown error'));
    }
  }

  async function handleAnnotationDelete(annotationId: string) {
    if (!confirm('Delete this annotation?')) return;
    
    try {
      await deleteAnnotation(annotationId, 'current-user@example.com');
      await loadData();
    } catch (e: any) {
      alert('Failed to delete annotation: ' + (e?.message || 'Unknown error'));
    }
  }

  async function handleUpdateComment(annotationId: string, comments: string) {
    try {
      // Find the annotation to update
      const annotation = annotations.find(a => a.id === annotationId);
      if (!annotation) {
        throw new Error('Annotation not found');
      }

      // Map className to classId
      const getClassId = (className: string): number => {
        const classMap: Record<string, number> = {
          'Faulty': 1,
          'faulty_loose_joint': 2,
          'faulty_point_overload': 3,
          'potential_faulty': 4,
        };
        return classMap[className] || 1;
      };

      // Update annotation with new comments
      await saveAnnotation({
        id: annotation.id,
        inspectionId: annotation.inspectionId,
        bbox: annotation.bbox,
        classId: getClassId(annotation.className),
        className: annotation.className,
        confidence: annotation.confidence,
        source: annotation.source,
        userId: 'current-user@example.com',
        comments: comments
      });

      await loadData();
    } catch (e: any) {
      alert('Failed to update comment: ' + (e?.message || 'Unknown error'));
      throw e;
    }
  }

  async function handleApprove(annotationId: string) {
    try {
      await approveAnnotation(annotationId, 'current-user@example.com');
      await loadData();
    } catch (e: any) {
      alert('Failed to approve: ' + (e?.message || 'Unknown error'));
    }
  }

  async function handleReject(annotationId: string) {
    try {
      await rejectAnnotation(annotationId, 'current-user@example.com', 'User rejected this annotation');
      await loadData();
    } catch (e: any) {
      alert('Failed to reject: ' + (e?.message || 'Unknown error'));
    }
  }

  // Zoom control functions - will be set by canvas component
  const [zoomFunctions, setZoomFunctions] = useState<{
    zoomIn: () => void;
    zoomOut: () => void;
    resetView: () => void;
  } | null>(null);

  const handleZoomIn = () => {
    zoomFunctions?.zoomIn();
  };

  const handleZoomOut = () => {
    zoomFunctions?.zoomOut();
  };

  const handleResetView = () => {
    zoomFunctions?.resetView();
  };

  const handleZoomChange = (zoomIn: () => void, zoomOut: () => void, resetView: () => void) => {
    setZoomFunctions({ zoomIn, zoomOut, resetView });
  };

  async function handleImageUpload(file: File) {
    if (!inspection) return;
    
    try {
      setUploading(true);
      setUploadError(null);
      
      // Upload image to server
      const uploadedImage = await uploadImage({
        transformerId: inspection.transformerId,
        type: 'INSPECTION',
        uploader: inspection.inspectedBy || 'unknown',
        file,
        inspectionId: inspection.id,
      });
      
      // Link image to inspection
      await uploadInspectionImage(inspection.id, uploadedImage.id);
      
      // Reload inspection data
      await loadData();
      
      setSelectedFile(null);
      alert('Image uploaded successfully! You can now trigger detection.');
    } catch (e: any) {
      setUploadError(e?.message || 'Upload failed');
    } finally {
      setUploading(false);
    }
  }

  async function handleRemoveImage() {
    if (!inspection) return;
    
    const hasAnnotations = annotations.length > 0;
    const confirmMessage = hasAnnotations 
      ? `⚠️ Are you sure you want to remove the uploaded image?\n\nThis will permanently delete:\n• The current inspection image\n• All ${annotations.length} annotation${annotations.length > 1 ? 's' : ''}\n\nThis action cannot be undone.`
      : 'Are you sure you want to remove the uploaded image? You can upload a new one afterwards.';
    
    if (!window.confirm(confirmMessage)) {
      return;
    }
    
    try {
      setRemovingImage(true);
      
      // Remove image from inspection
      await removeInspectionImage(inspection.id);
      
      // Reload inspection data to reflect changes
      await loadData();
      
      const successMessage = hasAnnotations
        ? '✅ Image and all annotations removed successfully. You can now upload a new image.'
        : '✅ Image removed successfully. You can now upload a new image.';
      
      alert(successMessage);
    } catch (e: any) {
      console.error('Error removing image:', e);
      alert(`❌ Failed to remove image: ${e?.message || 'Unknown error'}`);
    } finally {
      setRemovingImage(false);
    }
  }

  const handleCaptureReady = (captureFunc: () => string | null) => {
    console.log('Capture function received:', typeof captureFunc);
    captureCanvasRef.current = captureFunc;
    setIsCanvasReady(true);
  };

  async function handleSaveAnnotatedImage() {
    console.log('handleSaveAnnotatedImage called');
    console.log('inspection:', inspection);
    console.log('captureCanvasRef.current:', captureCanvasRef.current);
    console.log('captureCanvas type:', typeof captureCanvasRef.current);
    
    if (!inspection) {
      alert('No inspection available');
      return;
    }
    
    if (!captureCanvasRef.current) {
      alert('Canvas capture function not ready. Please wait for the image to load completely.');
      return;
    }
    
    if (typeof captureCanvasRef.current !== 'function') {
      alert('Canvas capture is not a function. Please refresh the page and try again.');
      return;
    }
    
    try {
      setIsSavingImage(true);
      
      console.log('Calling captureCanvas function...');
      // Capture canvas as base64 data URL
      const dataUrl = captureCanvasRef.current();
      console.log('Capture result:', dataUrl ? 'Success' : 'Failed');
      
      if (!dataUrl) {
        alert('Failed to capture annotated image. Please ensure the image is fully loaded.');
        return;
      }
      
      // Convert base64 to blob
      const response = await fetch(dataUrl);
      const blob = await response.blob();
      
      // Create file from blob
      const file = new File([blob], `annotated_${inspection.inspectionNumber}_${Date.now()}.png`, { type: 'image/png' });
      
      // Upload annotated image
      const uploadedImage = await uploadImage({
        transformerId: inspection.transformerId,
        type: 'INSPECTION',
        uploader: inspection.inspectedBy || 'system',
        file,
        inspectionId: inspection.id,
      });
      
      // Update inspection with annotated image
      await uploadAnnotatedImage(inspection.id, uploadedImage.id);
      
      // Reload data to show updated image
      await loadData();
      
      alert('✅ Annotated image saved! This image will now appear on the transformer page.');
    } catch (e: any) {
      alert('Failed to save annotated image: ' + (e?.message || 'Unknown error'));
    } finally {
      setIsSavingImage(false);
    }
  }

  async function handleCompleteInspection() {
    if (!inspection) return;
    
    try {
      setIsCompleting(true);
      
      // Update inspection status to COMPLETED
      await updateInspectionStatus(inspection.id, 'COMPLETED');
      
      // Show success message
      alert('Inspection completed successfully! Redirecting to transformer page...');
      
      // Navigate to transformer detail page with reliable navigation
      window.location.href = `/transformers/${inspection.transformerId}`;
    } catch (e: any) {
      alert('Failed to complete inspection: ' + (e?.message || 'Unknown error'));
    } finally {
      setIsCompleting(false);
    }
  }

  /**
   * Export feedback and send to ML service for model fine-tuning (FR3.3)
   */
  async function handleExportFeedback() {
    if (!id) return;

    try {
      setIsExportingFeedback(true);

      // 1. Export feedback data (JSON format)
      const feedbackData = await exportFeedback(id);
      
      // 2. Download JSON file
      const jsonBlob = new Blob([JSON.stringify(feedbackData, null, 2)], { type: 'application/json' });
      const jsonUrl = URL.createObjectURL(jsonBlob);
      const jsonLink = document.createElement('a');
      jsonLink.href = jsonUrl;
      jsonLink.download = `feedback_${inspection?.inspectionNumber || id}.json`;
      document.body.appendChild(jsonLink);
      jsonLink.click();
      document.body.removeChild(jsonLink);
      URL.revokeObjectURL(jsonUrl);

      // 3. Download CSV file
      exportFeedbackCSV(id);

      // 4. Send to Flask ML service
      const mlServiceUrl = import.meta.env.VITE_ML_SERVICE_URL || 'http://localhost:5001';
      const response = await fetch(`${mlServiceUrl}/api/feedback/upload`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(feedbackData),
      });

      if (!response.ok) {
        throw new Error(`ML service returned ${response.status}`);
      }

      const result = await response.json();
      
      alert(`✅ Feedback exported successfully!\n\n` +
            `Summary:\n` +
            `- AI Detections: ${result.summary?.totalAiDetections || 0}\n` +
            `- Human Annotations: ${result.summary?.totalHumanAnnotations || 0}\n` +
            `- Approved: ${result.summary?.approved || 0}\n` +
            `- Rejected: ${result.summary?.rejected || 0}\n\n` +
            `Files downloaded to your Downloads folder\n` +
            `Data sent to ML service for fine-tuning\n\n` +
            `Note: The ML model can now be fine-tuned using this feedback data.`);
      
    } catch (e: any) {
      console.error('Feedback export error:', e);
      alert(`⚠️ Feedback export partially completed.\n\n` +
            `Files may have been downloaded, but failed to send to ML service:\n` +
            `${e?.message || 'Unknown error'}\n\n` +
            `Check console for details.`);
    } finally {
      setIsExportingFeedback(false);
    }
  }

  if (loading) {
    return (
      <div className="page-container">
        <div className="loading-message">Loading inspection...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="page-container">
        <div className="error-message">{error}</div>
        <button onClick={() => window.location.href = '/inspections'} className="primary-button">
          Back to Inspections
        </button>
      </div>
    );
  }

  if (!inspection) {
    return (
      <div className="page-container">
        <div className="error-message">Inspection not found</div>
        <button onClick={() => window.location.href = '/inspections'} className="primary-button">
          Back to Inspections
        </button>
      </div>
    );
  }

  // Use original image URL for editing annotations, fall back to current inspection image
  const imageUrl = inspection.originalInspectionImageUrl || inspection.inspectionImageUrl || 'https://via.placeholder.com/800x600?text=No+Image';

  return (
    <div className="inspection-detail">
      {/* Header */}
      <div style={{
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        marginBottom: '24px',
        padding: '20px',
        background: 'linear-gradient(135deg, #1e40af 0%, #3b82f6 100%)',
        borderRadius: '12px',
        boxShadow: '0 4px 12px rgba(30, 64, 175, 0.2)',
        border: 'none'
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
          <button 
            onClick={() => {
              // Force navigation with page refresh for reliability
              window.location.href = '/inspections';
            }} 
            style={{
              background: 'rgba(255, 255, 255, 0.2)',
              border: '1px solid rgba(255, 255, 255, 0.3)',
              color: 'white',
              fontSize: '14px',
              cursor: 'pointer',
              padding: '8px 12px',
              borderRadius: '6px',
              display: 'flex',
              alignItems: 'center',
              gap: '6px',
              transition: 'all 0.2s',
              backdropFilter: 'blur(10px)'
            }}
            onMouseEnter={(e) => {
              e.currentTarget.style.background = 'rgba(255, 255, 255, 0.3)';
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.background = 'rgba(255, 255, 255, 0.2)';
            }}
          >
            ← Back
          </button>
          <div>
            <h1 style={{ 
              margin: 0, 
              fontSize: '20px', 
              fontWeight: '600', 
              color: 'white' 
            }}>
              Inspection {inspection.inspectionNumber}
            </h1>
            <div style={{ color: 'rgba(255, 255, 255, 0.8)', fontSize: '14px', marginTop: '2px' }}>
              {inspection.transformerCode} • {inspection.weatherCondition || 'Weather N/A'}
            </div>
          </div>
        </div>
        <div style={{
          padding: '6px 12px',
          background: 'rgba(255, 255, 255, 0.9)',
          color: inspection.status === 'COMPLETED' ? '#166534' : inspection.status === 'IN_PROGRESS' ? '#92400e' : '#374151',
          borderRadius: '6px',
          fontSize: '13px',
          fontWeight: '600',
          boxShadow: '0 2px 4px rgba(0, 0, 0, 0.1)'
        }}>
          {inspection.status.replace('_', ' ')}
        </div>
      </div>

      {/* Add Side-by-Side Image Comparison here - after header, before main content grid */}
      <div style={{
        display: 'grid',
        gridTemplateColumns: '1fr 1fr',
        gap: '24px',
        padding: '24px',
        paddingTop: '0'
      }}>
        <ImageBox 
          title="Baseline Image" 
          imageUrl={baselineImage?.publicUrl || inspection.baselineImageUrl} 
          timestamp={baselineImage?.uploadedAt || inspection.createdAt}
        />
        <ImageBox 
          title="Inspection Image" 
          imageUrl={inspection.inspectionImageUrl} 
          timestamp={inspection.inspectedAt || inspection.createdAt}
        />
      </div>

      {/* Main Content Grid */}
      <div style={{
        display: 'grid',
        gridTemplateColumns: '2fr 1fr',
        gap: '24px',
        padding: '24px'
      }}>
        {/* Left Column */}
        <div>
          {/* Annotation Toolbar */}
          <AnnotationToolbar
            mode={mode}
            onModeChange={setMode}
            selectedClass={selectedClass}
            onClassChange={setSelectedClass}
            onZoomIn={handleZoomIn}
            onZoomOut={handleZoomOut}
            onResetView={handleResetView}
            onDetectAnomalies={handleDetectAnomalies}
            isDetecting={isDetecting}
          />

          {/* Image Upload Section */}
          {!inspection.inspectionImageId && (
            <div style={{
              marginBottom: '16px',
              padding: '20px',
              background: 'white',
              border: '2px dashed #d1d5db',
              borderRadius: '12px',
              textAlign: 'center',
            }}>
              <div style={{ marginBottom: '16px', color: '#374151', fontWeight: '600', fontSize: '16px' }}>
                📸 Upload Thermal Image
              </div>
              <div style={{ marginBottom: '16px', color: '#6b7280', fontSize: '14px' }}>
                Upload an inspection image to start annotation and detection
              </div>
              <FileDrop onFile={setSelectedFile} />
              {selectedFile && (
                <div style={{ marginTop: '16px', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '12px' }}>
                  <span style={{ fontSize: '14px', color: '#374151', fontWeight: '500' }}>
                    📎 {selectedFile.name}
                  </span>
                  <button
                    onClick={() => handleImageUpload(selectedFile)}
                    disabled={uploading}
                    style={{
                      background: uploading ? '#9ca3af' : '#3b82f6',
                      color: 'white',
                      border: 'none',
                      borderRadius: '8px',
                      padding: '12px 24px',
                      fontSize: '14px',
                      fontWeight: '600',
                      cursor: uploading ? 'not-allowed' : 'pointer',
                    }}
                  >
                    {uploading ? 'Uploading...' : 'Upload Image'}
                  </button>
                </div>
              )}
              {uploadError && (
                <div style={{ marginTop: '12px', color: '#dc2626', fontSize: '14px' }}>
                  ❌ {uploadError}
                </div>
              )}
            </div>
          )}

          {/* Remove Image Section - Show when image is uploaded */}
          {inspection.inspectionImageId && (
            <div style={{
              marginBottom: '16px',
              padding: '16px',
              background: annotations.length > 0 ? '#fef2f2' : '#fef3c7',
              border: `1px solid ${annotations.length > 0 ? '#fca5a5' : '#fbbf24'}`,
              borderRadius: '12px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
            }}>
              <div>
                <div style={{ 
                  color: annotations.length > 0 ? '#dc2626' : '#92400e', 
                  fontWeight: '600', 
                  fontSize: '14px', 
                  marginBottom: '4px' 
                }}>
                  Inspection Image
                </div>
                <div style={{ 
                  color: annotations.length > 0 ? '#b91c1c' : '#a16207', 
                  fontSize: '13px' 
                }}>
                  {annotations.length > 0 
                    ? `⚠️ Warning: Removing this image will delete ${annotations.length} annotation${annotations.length > 1 ? 's' : ''}.`
                    : 'Want to upload a different image? You can remove this one and upload a new one.'
                  }
                </div>
              </div>
              <button
                onClick={handleRemoveImage}
                disabled={removingImage}
                style={{
                  background: removingImage ? '#9ca3af' : '#dc2626',
                  color: 'white',
                  border: 'none',
                  borderRadius: '8px',
                  padding: '8px 16px',
                  fontSize: '13px',
                  fontWeight: '600',
                  cursor: removingImage ? 'not-allowed' : 'pointer',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '6px',
                }}
              >
                {removingImage ? (
                  <>
                    <span style={{ fontSize: '12px' }}>⏳</span>
                    Removing...
                  </>
                ) : (
                  <>
                    <span style={{ fontSize: '12px' }}>🗑️</span>
                    Remove Image
                  </>
                )}
              </button>
            </div>
          )}

          {/* Annotation Canvas */}
          <AnnotationCanvas
            imageUrl={imageUrl}
            annotations={annotations}
            mode={mode}
            selectedClass={selectedClass}
            onAnnotationCreate={handleAnnotationCreate}
            onAnnotationUpdate={handleAnnotationUpdate}
            onAnnotationDelete={handleAnnotationDelete}
            onCaptureReady={handleCaptureReady}
            onZoomChange={handleZoomChange}
          />

          {/* Quick Help */}
          <div style={{
            marginTop: '16px',
            padding: '10px 16px',
            background: '#f8fafc',
            border: '1px solid #e2e8f0',
            borderRadius: '8px',
            fontSize: '13px',
            color: '#64748b'
          }}>
            <div style={{ display: 'flex', gap: '20px', flexWrap: 'wrap' }}>
              <span><strong>View:</strong> Drag to pan, scroll to zoom</span>
              <span><strong>Edit:</strong> Click to select, drag corners to resize</span>
              <span><strong>Draw:</strong> Click and drag to create</span>
            </div>
          </div>

          {/* Action Buttons Bar */}
          <div style={{
            marginTop: '16px',
            border: '2px solid #e5e7eb',
            borderRadius: '12px',
            padding: '16px',
            height: '80px',
            display: 'flex',
            gap: '12px',
            alignItems: 'center',
            justifyContent: 'space-between',
            background: 'white'
          }}>
            {inspection.status !== 'COMPLETED' ? (
              <>
                {/* Save Image Button */}
                <button
                  onClick={handleSaveAnnotatedImage}
                  disabled={isSavingImage || !inspection.inspectionImageId || !isCanvasReady}
                  style={{
                    flex: '1',
                    minWidth: '200px',
                    background: (isSavingImage || !isCanvasReady) ? '#94a3b8' : 'linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%)',
                    color: 'white',
                    border: 'none',
                    borderRadius: '10px',
                    padding: '12px 20px',
                    fontSize: '15px',
                    fontWeight: '600',
                    cursor: (isSavingImage || !inspection.inspectionImageId || !isCanvasReady) ? 'not-allowed' : 'pointer',
                    boxShadow: '0 4px 12px rgba(59, 130, 246, 0.3)'
                  }}
                >
                  {isSavingImage ? '⏳ Saving...' : !isCanvasReady ? '⏳ Loading...' : '💾 Save Image'}
                </button>

                {/* Complete Inspection Button */}
                <button
                  onClick={handleCompleteInspection}
                  disabled={isCompleting || !inspection.inspectionImageId}
                  style={{
                    flex: '1',
                    minWidth: '200px',
                    background: isCompleting ? '#94a3b8' : 'linear-gradient(135deg, #059669 0%, #10b981 100%)',
                    color: 'white',
                    border: 'none',
                    borderRadius: '10px',
                    padding: '12px 20px',
                    fontSize: '15px',
                    fontWeight: '600',
                    cursor: isCompleting || !inspection.inspectionImageId ? 'not-allowed' : 'pointer',
                    boxShadow: '0 4px 12px rgba(5, 150, 105, 0.3)'
                  }}
                >
                  {isCompleting ? '⏳ Processing...' : '✅ Done'}
                </button>

                {/* Finetune Button */}
                <button
                  onClick={handleExportFeedback}
                  disabled={isExportingFeedback}
                  style={{
                    flex: '1',
                    minWidth: '200px',
                    background: isExportingFeedback ? '#94a3b8' : 'linear-gradient(135deg, #8b5cf6 0%, #7c3aed 100%)',
                    color: 'white',
                    border: 'none',
                    borderRadius: '10px',
                    padding: '12px 20px',
                    fontSize: '15px',
                    fontWeight: '600',
                    cursor: isExportingFeedback ? 'not-allowed' : 'pointer',
                    boxShadow: '0 4px 12px rgba(139, 92, 246, 0.3)'
                  }}
                >
                  {isExportingFeedback ? '⏳ Exporting...' : '🤖 Finetune'}
                </button>
              </>
            ) : (
              // Show completion message and button when completed
              <div style={{
                width: '100%',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                background: '#ecfdf5',
                border: '2px solid #10b981',
                borderRadius: '10px',
                padding: '16px 24px'
              }}>
                <div>
                  <h3 style={{ 
                    margin: '0 0 4px 0', 
                    fontSize: '16px', 
                    fontWeight: '600', 
                    color: '#059669'
                  }}>
                    ✅ Inspection Completed
                  </h3>
                  <p style={{ 
                    margin: 0,
                    fontSize: '14px', 
                    color: '#047857'
                  }}>
                    This inspection has been marked as complete.
                  </p>
                </div>

                <button
                  onClick={() => nav(`/transformers/${inspection.transformerId}`)}
                  style={{
                    background: '#2563eb',
                    color: 'white',
                    border: 'none',
                    borderRadius: '8px',
                    padding: '10px 20px',
                    fontSize: '14px',
                    fontWeight: '800',
                    cursor: 'pointer',
                    display: 'flex',
                    alignItems: 'center',
                    gap: '6px'
                  }}
                >
                  🏠 View on Transformer Page
                </button>
              </div>
            )}
          </div>

          {/* Inspection History - MOVED HERE */}
          <div style={{
            background: 'white',
            borderRadius: '12px',
            boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
            padding: '20px',
            marginTop: '16px'
          }}>
            <div 
              style={{ 
                display: 'flex', 
                justifyContent: 'space-between', 
                alignItems: 'center',
                cursor: 'pointer',
                userSelect: 'none',
                marginBottom: '16px'
              }}
              onClick={() => setHistoryExpanded(!historyExpanded)}
            >
              <h2 style={{ margin: '0', fontSize: '18px', fontWeight: '600' }}>
                📋 Inspection History
              </h2>
              <span style={{ 
                transform: historyExpanded ? 'rotate(180deg)' : 'rotate(0deg)',
                transition: 'transform 0.2s ease'
              }}>
                ▼
              </span>
            </div>
            
            {historyExpanded && (
              <div style={{ 
                height: '550px',
                overflowY: 'auto',
                overflowX: 'hidden',
                paddingRight: '8px',
                scrollbarWidth: 'thin',
                scrollbarColor: '#cbd5e1 #f1f5f9'
              }}>
                {inspection && (
                  <InspectionHistoryList inspectionId={inspection.id} />
                )}
              </div>
            )}
          </div>
        </div>

        {/* Right Column */}
        <div>
          {/* Annotations List */}
          <div style={{
            background: 'white',
            borderRadius: '12px',
            boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
            padding: '20px',
            display: 'flex',
            flexDirection: 'column',
          }}>
            <h2 style={{ margin: '0 0 16px 0', fontSize: '18px', fontWeight: '600' }}>
              Annotations ({annotations.length})
            </h2>

            <div style={{ 
              height: '575px',
              overflowY: 'auto',
              overflowX: 'hidden',
              paddingRight: '8px',
              scrollbarWidth: 'thin',
              scrollbarColor: '#cbd5e1 #f1f5f9',
              display: 'flex',
              flexDirection: 'column',
              gap: '12px',
            }}>
              {annotations.length === 0 ? (
                <div style={{ 
                  textAlign: 'center', 
                  padding: '40px 20px', 
                  color: '#6b7280',
                  fontSize: '14px'
                }}>
                  No annotations yet. Click "Detect Anomalies" or draw manually.
                </div>
              ) : 
                annotations.map((ann) => (
                  <AnnotationCard
                    key={ann.id}
                    annotation={ann}
                    onApprove={() => handleApprove(ann.id)}
                    onReject={() => handleReject(ann.id)}
                    onDelete={() => handleAnnotationDelete(ann.id)}
                    onUpdateComment={handleUpdateComment}
                  />
                ))
              }
            </div>
          </div>

          {/* Fault Types Legend */}
          <AnnotationLegend layout="vertical" />

          {/* Inspector Notes */}
          <NotesSection 
            inspectionId={inspection.id}
            initialNotes={inspection.notes || ''}
            onNotesUpdate={() => loadData()}
          />

          {/* Comments Section with fixed height and scroll */}
          <div style={{
            background: 'white',
            borderRadius: '12px',
            boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
            padding: '20px',
            marginTop: '16px'
          }}>
            <div 
              style={{ 
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'center',
                cursor: 'pointer',
                userSelect: 'none',
                marginBottom: '16px'
              }}
              onClick={() => setCommentsExpanded(!commentsExpanded)}
            >
              <h2 style={{ margin: '0', fontSize: '18px', fontWeight: '600' }}>
                💬 Comments
              </h2>
              <span style={{ 
                transform: commentsExpanded ? 'rotate(180deg)' : 'rotate(0deg)',
                transition: 'transform 0.2s ease'
              }}>
                ▼
              </span>
            </div>
            
            {commentsExpanded && (
              <div style={{ 
                height: '560px',
                overflowY: 'auto',
                overflowX: 'hidden',
                paddingRight: '8px',
                scrollbarWidth: 'thin',
                scrollbarColor: '#cbd5e1 #f1f5f9'
              }}>
                <CommentsSection inspectionId={inspection.id} />
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Threshold Modal */}
      {showThresholdModal && (
        <div style={{
          position: 'fixed',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          backgroundColor: 'rgba(0, 0, 0, 0.5)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          zIndex: 1000,
        }}>
          <div style={{
            backgroundColor: 'white',
            borderRadius: '16px',
            padding: '24px',
            minWidth: '400px',
            boxShadow: '0 10px 25px rgba(0, 0, 0, 0.2)',
          }}>
            <h3 style={{ 
              margin: '0 0 16px 0', 
              fontSize: '20px', 
              fontWeight: '600',
              color: '#1f2937'
            }}>
              Configure Anomaly Detection
            </h3>
            
            <div style={{ marginBottom: '20px' }}>
              <p style={{ 
                fontSize: '14px', 
                color: '#6b7280', 
                marginBottom: '16px' 
              }}>
                Set the detection threshold.
                Lower values detect more anomalies, higher values are more selective.
              </p>
              
              <label style={{ 
                display: 'block', 
                fontSize: '14px', 
                fontWeight: '600', 
                color: '#374151',
                marginBottom: '8px'
              }}>
                Threshold Value (0-100)
              </label>
              
              <input
                type="range"
                min="0"
                max="100"
                value={threshold}
                onChange={(e) => setThreshold(Number(e.target.value))}
                style={{
                  width: '100%',
                  height: '8px',
                  borderRadius: '4px',
                  background: `linear-gradient(to right, #ef4444 0%, #eab308 50%, #22c55e 100%)`,
                  outline: 'none',
                  marginBottom: '12px'
                }}
              />
              
              <div style={{ 
                display: 'flex', 
                justifyContent: 'space-between',
                fontSize: '12px',
                color: '#6b7280',
                marginBottom: '8px'
              }}>
                <span>More Sensitive</span>
                <span style={{ 
                  fontSize: '16px', 
                  fontWeight: '700', 
                  color: '#1f2937' 
                }}>
                  {threshold}%
                </span>
                <span>More Selective</span>
              </div>
              
              <div style={{ 
                fontSize: '13px', 
                color: '#374151',
                padding: '8px 12px',
                backgroundColor: '#f3f4f6',
                borderRadius: '6px'
              }}>
                💡 <strong>Recommended:</strong> Start with 50% for balanced detection, 
                adjust based on results.
              </div>
            </div>
            
            <div style={{ 
              display: 'flex', 
              gap: '12px', 
              justifyContent: 'flex-end' 
            }}>
              <button
                onClick={() => setShowThresholdModal(false)}
                disabled={isDetecting}
                style={{
                  padding: '10px 20px',
                  border: '1px solid #d1d5db',
                  borderRadius: '8px',
                  background: 'white',
                  color: '#374151',
                  fontSize: '14px',
                  fontWeight: '600',
                  cursor: isDetecting ? 'not-allowed' : 'pointer',
                  opacity: isDetecting ? 0.6 : 1
                }}
              >
                Cancel
              </button>
              
              <button
                onClick={handleDetectWithThreshold}
                disabled={isDetecting}
                style={{
                  padding: '10px 20px',
                  border: 'none',
                  borderRadius: '8px',
                  background: isDetecting 
                    ? '#9ca3b8' 
                    : 'linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%)',
                  color: 'white',
                  fontSize: '14px',
                  fontWeight: '600',
                  cursor: isDetecting ? 'not-allowed' : 'pointer',
                  boxShadow: isDetecting ? 'none' : '0 2px 8px rgba(59, 130, 246, 0.2)',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '8px'
                }}
              >
                {isDetecting ? (
                  <>
                    <span style={{ fontSize: '12px' }}>⏳</span>
                    Detecting...
                  </>
                ) : (
                  <>
                    <span style={{ fontSize: '12px' }}></span>
                    Start Detection
                  </>
                )}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

interface AnnotationCardProps {
  annotation: Annotation;
  onApprove: () => void;
  onReject: () => void;
  onDelete: () => void;
  onUpdateComment: (annotationId: string, comments: string) => void;
}

function AnnotationCard({ annotation, onApprove, onReject, onDelete, onUpdateComment }: AnnotationCardProps) {
  const [showCommentInput, setShowCommentInput] = useState(false);
  const [commentText, setCommentText] = useState(annotation.comments || '');
  const [isSavingComment, setIsSavingComment] = useState(false);
  
  const CLASS_COLORS: Record<string, string> = {
    'Faulty': '#ef4444',           // RED
    'faulty_loose_joint': '#22c55e', // GREEN  
    'faulty_point_overload': '#3b82f6', // BLUE
    'potential_faulty': '#f59e0b',  // ORANGE/YELLOW
  };

  const color = CLASS_COLORS[annotation.className] || '#6b7280';
  
  const handleSaveComment = async () => {
    setIsSavingComment(true);
    try {
      await onUpdateComment(annotation.id, commentText);
      setShowCommentInput(false);
    } catch (error) {
      console.error('Failed to save comment:', error);
    } finally {
      setIsSavingComment(false);
    }
  };

  return (
    <div style={{
      border: `2px solid ${color}`,
      borderRadius: '8px',
      padding: '12px',
      background: `${color}11`,
    }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'start', marginBottom: '8px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          {/* Box Number Badge */}
          {annotation.boxNumber && (
            <div style={{
              width: '24px',
              height: '24px',
              borderRadius: '50%',
              background: color,
              color: 'white',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontSize: '12px',
              fontWeight: 'bold',
              flexShrink: 0,
              border: '2px solid white',
              boxShadow: '0 2px 4px rgba(0,0,0,0.2)'
            }}>
              {annotation.boxNumber}
            </div>
          )}
          
          <div>
            <div style={{ fontWeight: '600', fontSize: '14px', color: color }}>
              {annotation.className}
            </div>
            <div style={{ fontSize: '12px', color: '#6b7280', marginTop: '2px' }}>
              {annotation.source === 'ai' ? '🤖 AI Detection' : '👤 Manual'}
              {' · '}
              {Math.round(annotation.confidence * 100)}% confidence
            </div>
          </div>
        </div>
        
        <div style={{
          fontSize: '11px',
          color: '#6b7280',
          background: 'white',
          padding: '2px 6px',
          borderRadius: '4px'
        }}>
          v{annotation.version}
        </div>
      </div>

      <div style={{ fontSize: '12px', color: '#6b7280', marginBottom: '8px' }}>
        BBox: ({Math.round(annotation.bbox.x1)}, {Math.round(annotation.bbox.y1)}) → 
        ({Math.round(annotation.bbox.x2)}, {Math.round(annotation.bbox.y2)})
      </div>

      {/* Metadata Information */}
      <div style={{
        fontSize: '11px',
        color: '#6b7280',
        background: '#f9fafb',
        padding: '8px',
        borderRadius: '4px',
        marginBottom: '12px',
        lineHeight: '1.6'
      }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '4px' }}>
          <span>👤 Created by:</span>
          <span style={{ fontWeight: '600', color: '#374151' }}>{annotation.createdBy || 'System'}</span>
        </div>
        <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '4px' }}>
          <span>🕒 Created:</span>
          <span style={{ fontWeight: '600', color: '#374151' }}>
            {new Date(annotation.createdAt).toLocaleString('en-US', { 
              month: 'short', 
              day: 'numeric', 
              hour: '2-digit', 
              minute: '2-digit' 
            })}
          </span>
        </div>
        {annotation.modifiedBy && annotation.modifiedAt && (
          <>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '4px' }}>
              <span>✏️ Modified by:</span>
              <span style={{ fontWeight: '600', color: '#374151' }}>{annotation.modifiedBy}</span>
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between' }}>
              <span>🕒 Modified:</span>
              <span style={{ fontWeight: '600', color: '#374151' }}>
                {new Date(annotation.modifiedAt).toLocaleString('en-US', { 
                  month: 'short', 
                  day: 'numeric', 
                  hour: '2-digit', 
                  minute: '2-digit' 
                })}
              </span>
            </div>
          </>
        )}
        {annotation.actionType && annotation.actionType !== 'created' && (
          <div style={{ 
            marginTop: '6px', 
            paddingTop: '6px', 
            borderTop: '1px solid #e5e7eb',
            display: 'flex',
            justifyContent: 'space-between'
          }}>
            <span>📋 Action:</span>
            <span style={{ 
              fontWeight: '600', 
              color: annotation.actionType === 'approved' ? '#16a34a' : 
                     annotation.actionType === 'rejected' ? '#dc2626' : 
                     annotation.actionType === 'edited' ? '#3b82f6' : '#6b7280',
              textTransform: 'capitalize'
            }}>
              {annotation.actionType}
            </span>
          </div>
        )}
      </div>

      {annotation.source === 'ai' && annotation.actionType === 'created' && (
        <div style={{ display: 'flex', gap: '8px' }}>
          <button
            onClick={onApprove}
            style={{
              flex: 1,
              padding: '6px',
              border: 'none',
              borderRadius: '6px',
              background: '#22c55e',
              color: 'white',
              fontSize: '12px',
              fontWeight: '600',
              cursor: 'pointer'
            }}
          >
            ✓ Approve
          </button>
          <button
            onClick={onReject}
            style={{
              flex: 1,
              padding: '6px',
              border: 'none',
              borderRadius: '6px',
              background: '#ef4444',
              color: 'white',
              fontSize: '12px',
              fontWeight: '600',
              cursor: 'pointer'
            }}
          >
            ✗ Reject
          </button>
        </div>
      )}

      {annotation.source === 'human' && (
        <button
          onClick={onDelete}
          style={{
            width: '100%',
            padding: '6px',
            border: 'none',
            borderRadius: '6px',
            background: '#ef4444',
            color: 'white',
            fontSize: '12px',
            fontWeight: '600',
            cursor: 'pointer'
          }}
        >
          🗑️ Delete
        </button>
      )}

      {annotation.actionType === 'approved' && (
        <div style={{
          marginTop: '8px',
          padding: '6px',
          background: '#dcfce7',
          color: '#16a34a',
          borderRadius: '4px',
          fontSize: '12px',
          fontWeight: '600',
          textAlign: 'center'
        }}>
          ✓ Approved
        </div>
      )}

      {annotation.actionType === 'rejected' && (
        <div style={{
          marginTop: '8px',
          padding: '6px',
          background: '#fee2e2',
          color: '#dc2626',
          borderRadius: '4px',
          fontSize: '12px',
          fontWeight: '600',
          textAlign: 'center'
        }}>
          ✗ Rejected
        </div>
      )}

      {/* Comments Section */}
      <div style={{ marginTop: '12px', paddingTop: '12px', borderTop: '1px solid #e5e7eb' }}>
        {annotation.comments && !showCommentInput && (
          <div style={{
            background: '#f9fafb',
            padding: '8px',
            borderRadius: '4px',
            marginBottom: '8px'
          }}>
            <div style={{ fontSize: '11px', color: '#6b7280', marginBottom: '4px', fontWeight: '600' }}>
              📝 Note:
            </div>
            <div style={{ fontSize: '12px', color: '#374151', lineHeight: '1.5' }}>
              {annotation.comments}
            </div>
          </div>
        )}

        {showCommentInput ? (
          <div>
            <textarea
              value={commentText}
              onChange={(e) => setCommentText(e.target.value)}
              placeholder="Add a note about this annotation..."
              style={{
                width: '100%',
                minHeight: '60px',
                padding: '8px',
                border: '1px solid #d1d5db',
                borderRadius: '4px',
                fontSize: '12px',
                fontFamily: 'inherit',
                resize: 'vertical',
                marginBottom: '8px'
              }}
            />
            <div style={{ display: 'flex', gap: '6px' }}>
              <button
                onClick={handleSaveComment}
                disabled={isSavingComment}
                style={{
                  flex: 1,
                  padding: '6px',
                  border: 'none',
                  borderRadius: '4px',
                  background: isSavingComment ? '#9ca3b8' : '#3b82f6',
                  color: 'white',
                  fontSize: '11px',
                  fontWeight: '600',
                  cursor: isSavingComment ? 'not-allowed' : 'pointer'
                }}
              >
                {isSavingComment ? '💾 Saving...' : '💾 Save Note'}
              </button>
              <button
                onClick={() => {
                  setShowCommentInput(false);
                  setCommentText(annotation.comments || '');
                }}
                disabled={isSavingComment}
                style={{
                  flex: 1,
                  padding: '6px',
                  border: '1px solid #d1d5db',
                  borderRadius: '4px',
                  background: 'white',
                  color: '#6b7280',
                  fontSize: '11px',
                  fontWeight: '600',
                  cursor: isSavingComment ? 'not-allowed' : 'pointer'
                }}
              >
                Cancel
              </button>
            </div>
          </div>
        ) : (
          <button
            onClick={() => setShowCommentInput(true)}
            style={{
              width: '100%',
              padding: '6px',
              border: '1px solid #d1d5db',
              borderRadius: '4px',
              background: 'white',
              color: '#6b7280',
              fontSize: '11px',
              fontWeight: '600',
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '4px'
            }}
          >
            📝 {annotation.comments ? 'Edit Note' : 'Add Note'}
          </button>
        )}
      </div>
    </div>
  );
}

// ImageBox component for side-by-side comparison
function ImageBox({ title, imageUrl, timestamp }: { title: string; imageUrl: string | null | undefined; timestamp: string | null | undefined }) {
  return (
    <div style={{ 
      background: '#fff', 
      border: '1px solid #e5e7eb', 
      borderRadius: 12, 
      padding: 16,
      boxShadow: '0 2px 8px rgba(0, 0, 0, 0.05)'
    }}>
      <div style={{ 
        display: 'flex', 
        justifyContent: 'space-between', 
        alignItems: 'center',
        marginBottom: 12 
      }}>
        <div style={{ 
          fontWeight: 600, 
          fontSize: '16px',
          color: '#1f2937'
        }}>
          {title}
        </div>
        {timestamp && (
          <div style={{ 
            fontSize: 12, 
            color: '#6b7280',
            background: '#f3f4f6',
            padding: '4px 8px',
            borderRadius: '4px'
          }}>
            {new Date(timestamp).toLocaleString()}
          </div>
        )}
      </div>
      <div style={{ 
        height: 280, 
        display: 'flex', 
        alignItems: 'center', 
        justifyContent: 'center', 
        background: 'linear-gradient(135deg, #0f172a 0%, #1e293b 100%)', 
        borderRadius: 8,
        border: '2px solid #334155'
      }}>
        {imageUrl ? (
          <img 
            src={imageUrl} 
            alt={`${title} thermal image`}
            style={{ 
              maxHeight: '100%', 
              maxWidth: '100%', 
              objectFit: 'contain',
              borderRadius: '4px'
            }} 
          />
        ) : (
          <div style={{ 
            color: '#94a3b8',
            textAlign: 'center',
            fontSize: '14px',
            fontWeight: '500'
          }}>
            <div style={{ fontSize: '32px', marginBottom: '8px' }}>📷</div>
            <div>No {title.toLowerCase()} image</div>
          </div>
        )}
      </div>
    </div>
  );
}
