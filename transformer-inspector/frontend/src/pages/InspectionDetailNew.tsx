// // src/pages/InspectionDetailNew.tsx
// import { useState, useEffect, useRef } from 'react';
// import { useParams, useNavigate } from 'react-router-dom';
// import AnnotationCanvas from '../components/AnnotationCanvas';
// import AnnotationToolbar from '../components/AnnotationToolbar';
// import AnnotationLegend from '../components/AnnotationLegend';
// import NotesSection from '../components/NotesSection';
// import CommentsSection from '../components/CommentsSection';
// import FileDrop from '../components/FileDrop';
// import {
//   getInspection,
//   detectAnomalies,
//   uploadInspectionImage,
//   updateInspectionStatus,
//   uploadAnnotatedImage,
//   removeInspectionImage,
// } from '../api/inspections';
// import { getAnnotationsByInspection, saveAnnotation, approveAnnotation, rejectAnnotation, deleteAnnotation } from '../api/annotations';
// import { uploadImage, listImages } from '../api/images';
// import type { ThermalImage } from '../api/images';
// import type { Inspection } from '../api/inspections';
// import type { Annotation } from '../api/annotations';

// export default function InspectionDetailNew() {
//   const { id } = useParams();
//   const nav = useNavigate();

//   const [inspection, setInspection] = useState<Inspection | null>(null);
//   const [annotations, setAnnotations] = useState<Annotation[]>([]);
//   const [baselineImage, setBaselineImage] = useState<ThermalImage | null>(null);
//   const [loading, setLoading] = useState(false);
//   const [error, setError] = useState<string | null>(null);
  
//   // Annotation canvas state
//   const [mode, setMode] = useState<'view' | 'edit' | 'draw'>('view');
//   const [selectedClass, setSelectedClass] = useState('Faulty');
//   const [isDetecting, setIsDetecting] = useState(false);
  
//   // Image upload state
//   const [selectedFile, setSelectedFile] = useState<File | null>(null);
//   const [uploading, setUploading] = useState(false);
//   const [uploadError, setUploadError] = useState<string | null>(null);
//   const [removingImage, setRemovingImage] = useState(false);
  
//   // Inspection completion state
//   const [isCompleting, setIsCompleting] = useState(false);
  
//   // Canvas capture state
//   const captureCanvasRef = useRef<(() => string | null) | null>(null);
//   const [isCanvasReady, setIsCanvasReady] = useState(false);
//   const [isSavingImage, setIsSavingImage] = useState(false);



//   const getClassId = (className: string): number => {
//     const classMap: Record<string, number> = {
//       'Faulty': 1,
//       'faulty_loose_joint': 2,
//       'faulty_point_overload': 3,
//       'potential_faulty': 4,
//     };
//     return classMap[className] || 1;
//   };

//   // Load inspection and annotations
//   useEffect(() => {
//     if (!id) return;
//     loadData();
//   }, [id]);

//   async function loadData() {
//     if (!id) return;
    
//     try {
//       setLoading(true);
//       setError(null);
      
//       const [inspectionData, annotationsData] = await Promise.all([
//         getInspection(id),
//         getAnnotationsByInspection(id)
//       ]);
      
//       setInspection(inspectionData);
//       setAnnotations(annotationsData);
      
//       // Load baseline image for the transformer
//       if (inspectionData.transformerId) {
//         await loadBaselineImage(inspectionData.transformerId, inspectionData.weatherCondition);
//       }
//     } catch (e: any) {
//       setError(e?.message || 'Failed to load data');
//     } finally {
//       setLoading(false);
//     }
//   }
  
//   async function loadBaselineImage(transformerId: string, weatherCondition?: string | null) {
//     try {
//       const response = await listImages({ transformerId, type: 'BASELINE', page: 0, size: 10 });
//       const baselineImages = response.content || [];
      
//       // Try to find a baseline image matching the weather condition first
//       let selectedBaseline = null;
//       if (weatherCondition) {
//         selectedBaseline = baselineImages.find(img => 
//           img.envCondition === weatherCondition
//         );
//       }
      
//       // If no matching weather condition, use the most recent baseline image
//       if (!selectedBaseline && baselineImages.length > 0) {
//         selectedBaseline = baselineImages.sort((a, b) => 
//           new Date(b.uploadedAt).getTime() - new Date(a.uploadedAt).getTime()
//         )[0];
//       }
      
//       setBaselineImage(selectedBaseline || null);
//     } catch (e: any) {
//       console.error('Failed to load baseline image:', e);
//       setBaselineImage(null);
//     }
//   }

//   async function handleDetectAnomalies() {
//     if (!id) return;
    
//     // Validate that inspection exists and has an image uploaded
//     if (!inspection || !inspection.inspectionImageId) {
//       alert('⚠️ Please upload an inspection image before detecting anomalies.');
//       return;
//     }
    
//     try {
//       setIsDetecting(true);
//       const result = await detectAnomalies(id);
      
//       // Refresh annotations, inspection data, and baseline image
//       const [updatedAnnotations, updatedInspection] = await Promise.all([
//         getAnnotationsByInspection(id),
//         getInspection(id)
//       ]);
      
//       setAnnotations(updatedAnnotations);
//       setInspection(updatedInspection);
      
//       // Refresh baseline image as well
//       if (updatedInspection.transformerId) {
//         await loadBaselineImage(updatedInspection.transformerId, updatedInspection.weatherCondition);
//       }
      
//       alert(`Detection complete! Found ${result.detections?.length || 0} anomalies.`);
//     } catch (e: any) {
//       alert('Detection failed: ' + (e?.message || 'Unknown error'));
//     } finally {
//       setIsDetecting(false);
//     }
//   }

//   // async function handleAnnotationCreate(bbox: { x1: number; y1: number; x2: number; y2: number }) {
//   //   if (!id) return;
    
//   //   // Map className to classId (matches backend enum/constants)
//   //   const getClassId = (className: string): number => {
//   //     const classMap: Record<string, number> = {
//   //       'Faulty': 1,
//   //       'faulty_loose_joint': 2, 
//   //       'faulty_point_overload': 3,
//   //       'potential_faulty': 4,
//   //     };
//   //     return classMap[className] || 1;
//   //   };
    
//   //   try {
//   //     const annotationRequest = {
//   //       inspectionId: id,
//   //       bbox: {
//   //         x1: Math.round(bbox.x1),
//   //         y1: Math.round(bbox.y1), 
//   //         x2: Math.round(bbox.x2),
//   //         y2: Math.round(bbox.y2),
//   //       },
//   //       classId: getClassId(selectedClass),
//   //       className: selectedClass,
//   //       confidence: 1.0,
//   //       source: 'human' as const,
//   //       userId: 'current-user@example.com', // TODO: Get from auth context
//   //     };
      
//   //     console.log('Creating annotation with request:', annotationRequest);
      
//   //     await saveAnnotation(annotationRequest);
      
//   //     await loadData();
//   //   } catch (e: any) {
//   //     console.error('Annotation creation error:', e);
//   //     alert('Failed to create annotation: ' + (e?.message || 'Unknown error'));
//   //   }
//   // }
//   async function handleAnnotationCreate(bbox: { x1: number; y1: number; x2: number; y2: number }) {
//     if (!id) return;

//     // Map className to classId (matches backend enum/constants)
    

//     try {
//       // calculate new annotation number (sequential)
//       const nextNumber = annotations.length + 1;

//       // calculate size in pixels
//       const width = Math.abs(bbox.x2 - bbox.x1);
//       const height = Math.abs(bbox.y2 - bbox.y1);
//       const sizePx = width * height;

//       // build request object with new fields
//       const annotationRequest = {
//         inspectionId: id,
//         bbox: {
//           x1: Math.round(bbox.x1),
//           y1: Math.round(bbox.y1),
//           x2: Math.round(bbox.x2),
//           y2: Math.round(bbox.y2),
//         },
//         classId: getClassId(selectedClass),
//         className: selectedClass,
//         confidence: 1.0,
//         source: 'human' as const,
//         userId: 'current-user@example.com', // TODO: Get from auth context

//         // -------- NEW FIELDS --------
//         annotationNumber: nextNumber,
//         sizePx: sizePx,
//         severityScore: null, // placeholder, can be updated later
//         flagged: false,      // default not flagged
//       };

//       console.log('Creating annotation with request:', annotationRequest);

//       await saveAnnotation(annotationRequest);
//       await loadData();
//     } catch (e: any) {
//       console.error('Annotation creation error:', e);
//       alert('Failed to create annotation: ' + (e?.message || 'Unknown error'));
//     }
//   }


//   // async function handleAnnotationUpdate(annotation: Annotation) {
//   //   // Map className to classId (matches backend enum/constants)
//   //   const getClassId = (className: string): number => {
//   //     const classMap: Record<string, number> = {
//   //       'Faulty': 1,
//   //       'faulty_loose_joint': 2, 
//   //       'faulty_point_overload': 3,
//   //       'potential_faulty': 4,
//   //     };
//   //     return classMap[className] || 1;
//   //   };
    
//   //   try {
//   //     console.log('Updating annotation with ID:', annotation.id, 'for version creation');
      
//   //     await saveAnnotation({
//   //       id: annotation.id, // Include ID for version creation
//   //       inspectionId: annotation.inspectionId,
//   //       bbox: annotation.bbox,
//   //       classId: getClassId(annotation.className),
//   //       className: annotation.className,
//   //       confidence: annotation.confidence,
//   //       source: annotation.source,
//   //       userId: 'current-user@example.com',
//   //     });
      
//   //     await loadData();
//   //   } catch (e: any) {
//   //     alert('Failed to update annotation: ' + (e?.message || 'Unknown error'));
//   //   }
//   // }

//   // async function handleAnnotationDelete(annotationId: string) {
//   //   if (!confirm('Delete this annotation?')) return;
    
//   //   try {
//   //     await deleteAnnotation(annotationId, 'current-user@example.com');
//   //     await loadData();
//   //   } catch (e: any) {
//   //     alert('Failed to delete annotation: ' + (e?.message || 'Unknown error'));
//   //   }
//   // }



//   function handleAnnotationUpdate(annotation: Annotation) {
//     // Recalculate size locally
//     const width = Math.abs(annotation.bbox.x2 - annotation.bbox.x1);
//     const height = Math.abs(annotation.bbox.y2 - annotation.bbox.y1);
//     const sizePx = width * height;
  
//     const updated = {
//       ...annotation,
//       sizePx,
//       severityScore: annotation.severityScore ?? null,
//       flagged: annotation.flagged ?? false,
//     };
  
//     setAnnotations((prev) =>
//       prev.map((ann) => (ann.id === updated.id ? updated : ann))
//     );
  
//     console.log("Locally updated annotation:", updated);
//   }
  

//   async function handleApprove(annotationId: string) {
//     try {
//       await approveAnnotation(annotationId, 'current-user@example.com');
//       await loadData();
//     } catch (e: any) {
//       alert('Failed to approve: ' + (e?.message || 'Unknown error'));
//     }
//   }

//   async function handleReject(annotationId: string) {
//     try {
//       await rejectAnnotation(annotationId, 'current-user@example.com', 'User rejected this annotation');
//       await loadData();
//     } catch (e: any) {
//       alert('Failed to reject: ' + (e?.message || 'Unknown error'));
//     }
//   }


//   function handleAnnotationDelete(annotationId: string) {
//     if (!confirm('Delete this annotation?')) return;
  
//     // Just remove locally from state
//     setAnnotations((prev) => prev.filter((ann) => ann.id !== annotationId));
  
//     console.log("Locally deleted annotation:", annotationId);
//   }
  

//   // Zoom control functions - will be set by canvas component
//   const [zoomFunctions, setZoomFunctions] = useState<{
//     zoomIn: () => void;
//     zoomOut: () => void;
//     resetView: () => void;
//   } | null>(null);

//   const handleZoomIn = () => {
//     zoomFunctions?.zoomIn();
//   };

//   const handleZoomOut = () => {
//     zoomFunctions?.zoomOut();
//   };

//   const handleResetView = () => {
//     zoomFunctions?.resetView();
//   };

//   const handleZoomChange = (zoomIn: () => void, zoomOut: () => void, resetView: () => void) => {
//     setZoomFunctions({ zoomIn, zoomOut, resetView });
//   };

//   async function handleImageUpload(file: File) {
//     if (!inspection) return;
    
//     try {
//       setUploading(true);
//       setUploadError(null);
      
//       // Upload image to server
//       const uploadedImage = await uploadImage({
//         transformerId: inspection.transformerId,
//         type: 'INSPECTION',
//         uploader: inspection.inspectedBy || 'unknown',
//         file,
//         inspectionId: inspection.id,
//       });
      
//       // Link image to inspection
//       await uploadInspectionImage(inspection.id, uploadedImage.id);
      
//       // Reload inspection data
//       await loadData();
      
//       setSelectedFile(null);
//       alert('Image uploaded successfully! You can now trigger detection.');
//     } catch (e: any) {
//       setUploadError(e?.message || 'Upload failed');
//     } finally {
//       setUploading(false);
//     }
//   }

//   async function handleRemoveImage() {
//     if (!inspection) return;
    
//     if (!window.confirm('Are you sure you want to remove the uploaded image? This will also clear any existing annotations.')) {
//       return;
//     }
    
//     try {
//       setRemovingImage(true);
      
//       // Remove image from inspection
//       await removeInspectionImage(inspection.id);
      
//       // Reload inspection data to reflect changes
//       await loadData();
      
//       alert('✅ Image removed successfully. You can now upload a new image.');
//     } catch (e: any) {
//       console.error('Error removing image:', e);
//       alert(`❌ Failed to remove image: ${e?.message || 'Unknown error'}`);
//     } finally {
//       setRemovingImage(false);
//     }
//   }

//   const handleCaptureReady = (captureFunc: () => string | null) => {
//     console.log('Capture function received:', typeof captureFunc);
//     captureCanvasRef.current = captureFunc;
//     setIsCanvasReady(true);
//   };

//   // async function handleSaveAnnotatedImage() {
//   //   console.log('handleSaveAnnotatedImage called');
//   //   console.log('inspection:', inspection);
//   //   console.log('captureCanvasRef.current:', captureCanvasRef.current);
//   //   console.log('captureCanvas type:', typeof captureCanvasRef.current);
    
//   //   if (!inspection) {
//   //     alert('No inspection available');
//   //     return;
//   //   }
    
//   //   if (!captureCanvasRef.current) {
//   //     alert('Canvas capture function not ready. Please wait for the image to load completely.');
//   //     return;
//   //   }
    
//   //   if (typeof captureCanvasRef.current !== 'function') {
//   //     alert('Canvas capture is not a function. Please refresh the page and try again.');
//   //     return;
//   //   }
    
//   //   try {
//   //     setIsSavingImage(true);
      
//   //     console.log('Calling captureCanvas function...');
//   //     // Capture canvas as base64 data URL
//   //     const dataUrl = captureCanvasRef.current();
//   //     console.log('Capture result:', dataUrl ? 'Success' : 'Failed');
      
//   //     if (!dataUrl) {
//   //       alert('Failed to capture annotated image. Please ensure the image is fully loaded.');
//   //       return;
//   //     }
      
//   //     // Convert base64 to blob
//   //     const response = await fetch(dataUrl);
//   //     const blob = await response.blob();
      
//   //     // Create file from blob
//   //     const file = new File([blob], `annotated_${inspection.inspectionNumber}_${Date.now()}.png`, { type: 'image/png' });
      
//   //     // Upload annotated image
//   //     const uploadedImage = await uploadImage({
//   //       transformerId: inspection.transformerId,
//   //       type: 'INSPECTION',
//   //       uploader: inspection.inspectedBy || 'system',
//   //       file,
//   //       inspectionId: inspection.id,
//   //     });
      
//   //     // Update inspection with annotated image
//   //     await uploadAnnotatedImage(inspection.id, uploadedImage.id);
      
//   //     // Reload data to show updated image
//   //     await loadData();
      
//   //     alert('✅ Annotated image saved! This image will now appear on the transformer page.');
//   //   } catch (e: any) {
//   //     alert('Failed to save annotated image: ' + (e?.message || 'Unknown error'));
//   //   } finally {
//   //     setIsSavingImage(false);
//   //   }
//   // }
//   async function handleSaveAnnotatedImage() {
//     if (!inspection) {
//       alert('No inspection available');
//       return;
//     }
  
//     if (!captureCanvasRef.current || typeof captureCanvasRef.current !== 'function') {
//       alert('Canvas capture function not ready. Please wait for the image to load completely.');
//       return;
//     }
  
//     try {
//       setIsSavingImage(true);
  
//       // ---- Existing image capture logic ----
//       const dataUrl = captureCanvasRef.current();
//       if (!dataUrl) {
//         alert('Failed to capture annotated image. Please ensure the image is fully loaded.');
//         return;
//       }
  
//       const response = await fetch(dataUrl);
//       const blob = await response.blob();
//       const file = new File([blob], `annotated_${inspection.inspectionNumber}_${Date.now()}.png`, { type: 'image/png' });
  
//       const uploadedImage = await uploadImage({
//         transformerId: inspection.transformerId,
//         type: 'INSPECTION',
//         uploader: inspection.inspectedBy || 'system',
//         file,
//         inspectionId: inspection.id,
//       });
  
//       await uploadAnnotatedImage(inspection.id, uploadedImage.id);
  
//       // ---- NEW: Save all annotations to backend ----
//       // for (const ann of annotations) {
//       //   await saveAnnotation({
//       //     id: ann.id,
//       //     inspectionId: ann.inspectionId,
//       //     bbox: ann.bbox,
//       //     classId: ann.classId,
//       //     className: ann.className,
//       //     confidence: ann.confidence,
//       //     source: ann.source,
//       //     userId: 'current-user@example.com',
  
//       //     // extended fields
//       //     annotationNumber: ann.annotationNumber,
//       //     sizePx: ann.sizePx,
//       //     severityScore: ann.severityScore,
//       //     flagged: ann.flagged,
//       //   });
//       // }
//       for (const ann of annotations) {
//         await saveAnnotation({
//           id: ann.id,
//           inspectionId: ann.inspectionId,
//           bbox: ann.bbox,
//           classId: ann.classId || getClassId(ann.className),  //
//           className: ann.className,
//           confidence: ann.confidence,
//           source: ann.source,
//           userId: 'current-user@example.com',
      
//           // extended fields
//           annotationNumber: ann.annotationNumber,
//           sizePx: ann.sizePx,
//           severityScore: ann.severityScore,
//           flagged: ann.flagged,
//         });
//       }
      
  
//       await loadData();
//       alert('✅ Annotated image & annotations saved successfully!');
//     } catch (e: any) {
//       alert('Failed to save: ' + (e?.message || 'Unknown error'));
//     } finally {
//       setIsSavingImage(false);
//     }
//   }
  


//   async function handleCompleteInspection() {
//     if (!inspection) return;
    
//     try {
//       setIsCompleting(true);
      
//       // Update inspection status to COMPLETED
//       await updateInspectionStatus(inspection.id, 'COMPLETED');
      
//       // Show success message
//       alert('Inspection completed successfully! Redirecting to transformer page...');
      
//       // Navigate to transformer detail page with reliable navigation
//       window.location.href = `/transformers/${inspection.transformerId}`;
//     } catch (e: any) {
//       alert('Failed to complete inspection: ' + (e?.message || 'Unknown error'));
//     } finally {
//       setIsCompleting(false);
//     }
//   }

//   if (loading) {
//     return (
//       <div className="page-container">
//         <div className="loading-message">Loading inspection...</div>
//       </div>
//     );
//   }

//   if (error) {
//     return (
//       <div className="page-container">
//         <div className="error-message">{error}</div>
//         <button onClick={() => window.location.href = '/inspections'} className="primary-button">
//           Back to Inspections
//         </button>
//       </div>
//     );
//   }

//   if (!inspection) {
//     return (
//       <div className="page-container">
//         <div className="error-message">Inspection not found</div>
//         <button onClick={() => window.location.href = '/inspections'} className="primary-button">
//           Back to Inspections
//         </button>
//       </div>
//     );
//   }

//   // Use original image URL for editing annotations, fall back to current inspection image
//   const imageUrl = inspection.originalInspectionImageUrl || inspection.inspectionImageUrl || 'https://via.placeholder.com/800x600?text=No+Image';

//   return (
//     <div className="page-container">
//       {/* Header */}
//       <div style={{
//         display: 'flex',
//         alignItems: 'center',
//         justifyContent: 'space-between',
//         marginBottom: '24px',
//         padding: '20px',
//         background: 'linear-gradient(135deg, #1e40af 0%, #3b82f6 100%)',
//         borderRadius: '12px',
//         boxShadow: '0 4px 12px rgba(30, 64, 175, 0.2)',
//         border: 'none'
//       }}>
//         <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
//           <button 
//             onClick={() => {
//               // Force navigation with page refresh for reliability
//               window.location.href = '/inspections';
//             }} 
//             style={{
//               background: 'rgba(255, 255, 255, 0.2)',
//               border: '1px solid rgba(255, 255, 255, 0.3)',
//               color: 'white',
//               fontSize: '14px',
//               cursor: 'pointer',
//               padding: '8px 12px',
//               borderRadius: '6px',
//               display: 'flex',
//               alignItems: 'center',
//               gap: '6px',
//               transition: 'all 0.2s',
//               backdropFilter: 'blur(10px)'
//             }}
//             onMouseEnter={(e) => {
//               e.currentTarget.style.background = 'rgba(255, 255, 255, 0.3)';
//             }}
//             onMouseLeave={(e) => {
//               e.currentTarget.style.background = 'rgba(255, 255, 255, 0.2)';
//             }}
//           >
//             ← Back
//           </button>
//           <div>
//             <h1 style={{ 
//               margin: 0, 
//               fontSize: '20px', 
//               fontWeight: '600', 
//               color: 'white' 
//             }}>
//               Inspection {inspection.inspectionNumber}
//             </h1>
//             <div style={{ color: 'rgba(255, 255, 255, 0.8)', fontSize: '14px', marginTop: '2px' }}>
//               {inspection.transformerCode} • {inspection.weatherCondition || 'Weather N/A'}
//             </div>
//           </div>
//         </div>
//         <div style={{
//           padding: '6px 12px',
//           background: 'rgba(255, 255, 255, 0.9)',
//           color: inspection.status === 'COMPLETED' ? '#166534' : inspection.status === 'IN_PROGRESS' ? '#92400e' : '#374151',
//           borderRadius: '6px',
//           fontSize: '13px',
//           fontWeight: '600',
//           boxShadow: '0 2px 4px rgba(0, 0, 0, 0.1)'
//         }}>
//           {inspection.status.replace('_', ' ')}
//         </div>
//       </div>

//       {/* Side-by-side Image Comparison */}
//       {(baselineImage || inspection.baselineImageUrl || inspection.inspectionImageUrl || inspection.originalInspectionImageUrl) && (
//         <div style={{ marginBottom: 24 }}>
//           <h3 style={{ margin: '0 0 16px 0', fontSize: '18px', fontWeight: '600', color: '#1f2937' }}>
//             Thermal Image Comparison
//           </h3>
//           <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16 }}>
//             <ImageBox 
//               title="Baseline" 
//               imageUrl={baselineImage?.publicUrl || inspection.baselineImageUrl}
//               timestamp={baselineImage?.uploadedAt}
//             />
//             <ImageBox 
//               title="Inspection" 
//               imageUrl={inspection.inspectionImageUrl || inspection.originalInspectionImageUrl}
//               timestamp={inspection.inspectedAt}
//             />
//           </div>
//         </div>
//       )}

//       {/* Main Content */}
//       <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: '24px' }}>
//         {/* Left: Annotation Canvas */}
//         <div>
//           <AnnotationToolbar
//             mode={mode}
//             onModeChange={setMode}
//             selectedClass={selectedClass}
//             onClassChange={setSelectedClass}
//             onZoomIn={handleZoomIn}
//             onZoomOut={handleZoomOut}
//             onResetView={handleResetView}
//             onDetectAnomalies={handleDetectAnomalies}
//             isDetecting={isDetecting}
//           />

//           {/* Image Upload Section */}
//           {!inspection.inspectionImageId && (
//             <div style={{
//               marginBottom: '16px',
//               padding: '20px',
//               background: 'white',
//               border: '2px dashed #d1d5db',
//               borderRadius: '12px',
//               textAlign: 'center',
//             }}>
//               <div style={{ marginBottom: '16px', color: '#374151', fontWeight: '600', fontSize: '16px' }}>
//                 📸 Upload Thermal Image
//               </div>
//               <div style={{ marginBottom: '16px', color: '#6b7280', fontSize: '14px' }}>
//                 Upload an inspection image to start annotation and detection
//               </div>
//               <FileDrop onFile={setSelectedFile} />
//               {selectedFile && (
//                 <div style={{ marginTop: '16px', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '12px' }}>
//                   <span style={{ fontSize: '14px', color: '#374151', fontWeight: '500' }}>
//                     📎 {selectedFile.name}
//                   </span>
//                   <button
//                     onClick={() => handleImageUpload(selectedFile)}
//                     disabled={uploading}
//                     style={{
//                       background: uploading ? '#9ca3af' : '#3b82f6',
//                       color: 'white',
//                       border: 'none',
//                       borderRadius: '8px',
//                       padding: '12px 24px',
//                       fontSize: '14px',
//                       fontWeight: '600',
//                       cursor: uploading ? 'not-allowed' : 'pointer',
//                     }}
//                   >
//                     {uploading ? 'Uploading...' : 'Upload Image'}
//                   </button>
//                 </div>
//               )}
//               {uploadError && (
//                 <div style={{ marginTop: '12px', color: '#dc2626', fontSize: '14px' }}>
//                   ❌ {uploadError}
//                 </div>
//               )}
//             </div>
//           )}

//           {/* Remove Image Section - Show when image is uploaded but no annotations exist */}
//           {inspection.inspectionImageId && annotations.length === 0 && (
//             <div style={{
//               marginBottom: '16px',
//               padding: '16px',
//               background: '#fef3c7',
//               border: '1px solid #fbbf24',
//               borderRadius: '12px',
//               display: 'flex',
//               alignItems: 'center',
//               justifyContent: 'space-between',
//             }}>
//               <div>
//                 <div style={{ color: '#92400e', fontWeight: '600', fontSize: '14px', marginBottom: '4px' }}>
//                   Inspection Image Uploaded
//                 </div>
//                 <div style={{ color: '#a16207', fontSize: '13px' }}>
//                   Want to upload a different image? You can remove this one and upload a new one.
//                 </div>
//               </div>
//               <button
//                 onClick={handleRemoveImage}
//                 disabled={removingImage}
//                 style={{
//                   background: removingImage ? '#9ca3af' : '#dc2626',
//                   color: 'white',
//                   border: 'none',
//                   borderRadius: '8px',
//                   padding: '8px 16px',
//                   fontSize: '13px',
//                   fontWeight: '600',
//                   cursor: removingImage ? 'not-allowed' : 'pointer',
//                   display: 'flex',
//                   alignItems: 'center',
//                   gap: '6px',
//                 }}
//               >
//                 {removingImage ? (
//                   <>
//                     <span style={{ fontSize: '12px' }}>⏳</span>
//                     Removing...
//                   </>
//                 ) : (
//                   <>
//                     <span style={{ fontSize: '12px' }}>🗑️</span>
//                     Remove Image
//                   </>
//                 )}
//               </button>
//             </div>
//           )}

//           <AnnotationCanvas
//             imageUrl={imageUrl}
//             annotations={annotations}
//             mode={mode}
//             selectedClass={selectedClass}
//             onAnnotationCreate={handleAnnotationCreate}
//             onAnnotationUpdate={handleAnnotationUpdate}
//             onAnnotationDelete={handleAnnotationDelete}
//             onCaptureReady={handleCaptureReady}
//             onZoomChange={handleZoomChange}
//           />

//           {/* Quick Help */}
//           <div style={{
//             marginTop: '16px',
//             padding: '10px 16px',
//             background: '#f8fafc',
//             border: '1px solid #e2e8f0',
//             borderRadius: '8px',
//             fontSize: '13px',
//             color: '#64748b'
//           }}>
//             <div style={{ display: 'flex', gap: '20px', flexWrap: 'wrap' }}>
//               <span><strong>View:</strong> Drag to pan, scroll to zoom</span>
//               <span><strong>Edit:</strong> Click to select, drag corners to resize</span>
//               <span><strong>Draw:</strong> Click and drag to create</span>
//             </div>
//           </div>

//           {/* Comments Section */}
//           <CommentsSection inspectionId={inspection.id} />
//         </div>

//         {/* Right: Annotations List */}
//         <div>
//           <div style={{
//             background: 'white',
//             borderRadius: '12px',
//             boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
//             padding: '20px',
//           }}>
//             <h2 style={{ margin: '0 0 16px 0', fontSize: '18px', fontWeight: '600' }}>
//               Annotations ({annotations.length})
//             </h2>

//             {annotations.length === 0 && (
//               <div style={{ 
//                 textAlign: 'center', 
//                 padding: '40px 20px', 
//                 color: '#6b7280',
//                 fontSize: '14px'
//               }}>
//                 No annotations yet. Click "Detect Anomalies" or draw manually.
//               </div>
//             )}

//             <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
//               {annotations.map((ann) => (
//                 <AnnotationCard
//                   key={ann.id}
//                   annotation={ann}
//                   onApprove={() => handleApprove(ann.id)}
//                   onReject={() => handleReject(ann.id)}
//                   onDelete={() => handleAnnotationDelete(ann.id)}
//                 />
//               ))}
//             </div>
//           </div>

//           {/* Fault Types Legend */}
//           <AnnotationLegend layout="vertical" />

//           {/* Inspector Notes */}
//           <NotesSection 
//             inspectionId={inspection.id}
//             initialNotes={inspection.notes || ''}
//             onNotesUpdate={() => loadData()}
//           />

//           {/* Save Annotated Image Button */}
//           {inspection.status !== 'COMPLETED' && annotations.length > 0 && (
//             <div style={{
//               background: 'white',
//               borderRadius: '12px',
//               boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
//               padding: '20px',
//               marginTop: '16px',
//               textAlign: 'center'
//             }}>
//               <h3 style={{ margin: '0 0 12px 0', fontSize: '16px', fontWeight: '600', color: '#3b82f6' }}>
//                 💾 Save Annotated Image
//               </h3>
//               <p style={{ fontSize: '14px', color: '#6b7280', lineHeight: '1.6', marginBottom: '16px' }}>
//                 Save the current image with annotations to display on the transformer page. You can do this multiple times as you make changes.
//               </p>
//               <button
//                 onClick={handleSaveAnnotatedImage}
//                 disabled={isSavingImage || !inspection.inspectionImageId || !isCanvasReady}
//                 style={{
//                   background: (isSavingImage || !isCanvasReady) ? '#94a3b8' : 'linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%)',
//                   color: 'white',
//                   border: 'none',
//                   borderRadius: '10px',
//                   padding: '14px 28px',
//                   fontSize: '16px',
//                   fontWeight: '600',
//                   cursor: (isSavingImage || !inspection.inspectionImageId || !isCanvasReady) ? 'not-allowed' : 'pointer',
//                   boxShadow: '0 4px 12px rgba(59, 130, 246, 0.3)',
//                   minWidth: '160px',
//                   opacity: (!inspection.inspectionImageId || !isCanvasReady) ? 0.6 : 1
//                 }}
//               >
//                 {isSavingImage ? '⏳ Saving...' : !isCanvasReady ? '⏳ Loading...' : '💾 Save Image'}
//               </button>
//               {!inspection.inspectionImageId && (
//                 <p style={{ fontSize: '12px', color: '#ef4444', marginTop: '8px' }}>
//                   Please upload an inspection image first
//                 </p>
//               )}
//               {inspection.inspectionImageId && !isCanvasReady && (
//                 <p style={{ fontSize: '12px', color: '#f59e0b', marginTop: '8px' }}>
//                   Canvas is loading, please wait...
//                 </p>
//               )}
//             </div>
//           )}

//           {/* Complete Inspection Button */}
//           {inspection.status !== 'COMPLETED' && (
//             <div style={{
//               background: 'white',
//               borderRadius: '12px',
//               boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
//               padding: '20px',
//               marginTop: '16px',
//               textAlign: 'center'
//             }}>
//               <h3 style={{ margin: '0 0 12px 0', fontSize: '16px', fontWeight: '600', color: '#059669' }}>
//                 ✅ Finish Inspection
//               </h3>
//               <p style={{ fontSize: '14px', color: '#6b7280', lineHeight: '1.6', marginBottom: '16px' }}>
//                 Click Done when you have finished editing annotations. This will mark the inspection as complete and display the results on the transformer page.
//               </p>
//               <button
//                 onClick={handleCompleteInspection}
//                 disabled={isCompleting || !inspection.inspectionImageId}
//                 style={{
//                   background: isCompleting ? '#94a3b8' : 'linear-gradient(135deg, #059669 0%, #10b981 100%)',
//                   color: 'white',
//                   border: 'none',
//                   borderRadius: '10px',
//                   padding: '14px 28px',
//                   fontSize: '16px',
//                   fontWeight: '600',
//                   cursor: isCompleting || !inspection.inspectionImageId ? 'not-allowed' : 'pointer',
//                   boxShadow: '0 4px 12px rgba(5, 150, 105, 0.3)',
//                   minWidth: '140px',
//                   opacity: !inspection.inspectionImageId ? 0.6 : 1
//                 }}
//               >
//                 {isCompleting ? '⏳ Finishing...' : 'Done'}
//               </button>
//               {!inspection.inspectionImageId && (
//                 <p style={{ fontSize: '12px', color: '#ef4444', marginTop: '8px' }}>
//                   Please upload an inspection image first
//                 </p>
//               )}
//             </div>
//           )}

//           {inspection.status === 'COMPLETED' && (
//             <div style={{
//               background: 'white',
//               borderRadius: '12px',
//               boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
//               padding: '20px',
//               marginTop: '16px',
//               textAlign: 'center',
//               border: '2px solid #10b981'
//             }}>
//               <h3 style={{ margin: '0 0 8px 0', fontSize: '16px', fontWeight: '600', color: '#059669' }}>
//                 ✅ Inspection Completed
//               </h3>
//               <p style={{ fontSize: '14px', color: '#6b7280', marginBottom: '12px' }}>
//                 This inspection has been marked as complete.
//               </p>
//               <button
//                 onClick={() => nav(`/transformers/${inspection.transformerId}`)}
//                 style={{
//                   background: 'linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%)',
//                   color: 'white',
//                   border: 'none',
//                   borderRadius: '8px',
//                   padding: '10px 20px',
//                   fontSize: '14px',
//                   fontWeight: '600',
//                   cursor: 'pointer',
//                   boxShadow: '0 2px 8px rgba(59, 130, 246, 0.2)'
//                 }}
//               >
//                 View on Transformer Page
//               </button>
//             </div>
//           )}
//         </div>
//       </div>
//     </div>
//   );
// }

// interface AnnotationCardProps {
//   annotation: Annotation;
//   onApprove: () => void;
//   onReject: () => void;
//   onDelete: () => void;
// }

// function AnnotationCard({ annotation, onApprove, onReject, onDelete }: AnnotationCardProps) {
//   const CLASS_COLORS: Record<string, string> = {
//     'Faulty': '#ef4444',
//     'faulty_loose_joint': '#22c55e',
//     'faulty_point_overload': '#3b82f6',
//     'potential_faulty': '#eab308',
//   };

//   const color = CLASS_COLORS[annotation.className] || '#6b7280';

//   return (
//     <div style={{
//       border: `2px solid ${color}`,
//       borderRadius: '8px',
//       padding: '12px',
//       background: `${color}11`,
//     }}>
//       <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'start', marginBottom: '8px' }}>
//         <div>
//           <div style={{ fontWeight: '600', fontSize: '14px', color: color }}>
//             {annotation.className}
//           </div>
//           <div style={{ fontSize: '12px', color: '#6b7280', marginTop: '2px' }}>
//             {annotation.source === 'ai' ? ' AI Detection' : '👤 Manual'}
//             {' · '}
//             {Math.round(annotation.confidence * 100)}% confidence
//           </div>
//         </div>
//         <div style={{
//           fontSize: '11px',
//           color: '#6b7280',
//           background: 'white',
//           padding: '2px 6px',
//           borderRadius: '4px'
//         }}>
//           v{annotation.version}
//         </div>
//       </div>

//       <div style={{ fontSize: '12px', color: '#6b7280', marginBottom: '12px' }}>
//         BBox: ({Math.round(annotation.bbox.x1)}, {Math.round(annotation.bbox.y1)}) → 
//         ({Math.round(annotation.bbox.x2)}, {Math.round(annotation.bbox.y2)})
//       </div>

//       {annotation.source === 'ai' && annotation.actionType === 'created' && (
//         <div style={{ display: 'flex', gap: '8px' }}>
//           <button
//             onClick={onApprove}
//             style={{
//               flex: 1,
//               padding: '6px',
//               border: 'none',
//               borderRadius: '6px',
//               background: '#22c55e',
//               color: 'white',
//               fontSize: '12px',
//               fontWeight: '600',
//               cursor: 'pointer'
//             }}
//           >
//             ✓ Approve
//           </button>
//           <button
//             onClick={onReject}
//             style={{
//               flex: 1,
//               padding: '6px',
//               border: 'none',
//               borderRadius: '6px',
//               background: '#ef4444',
//               color: 'white',
//               fontSize: '12px',
//               fontWeight: '600',
//               cursor: 'pointer'
//             }}
//           >
//             ✗ Reject
//           </button>
//         </div>
//       )}

//       {annotation.source === 'human' && (
//         <button
//           onClick={onDelete}
//           style={{
//             width: '100%',
//             padding: '6px',
//             border: 'none',
//             borderRadius: '6px',
//             background: '#ef4444',
//             color: 'white',
//             fontSize: '12px',
//             fontWeight: '600',
//             cursor: 'pointer'
//           }}
//         >
//           🗑️ Delete
//         </button>
//       )}

//       {annotation.actionType === 'approved' && (
//         <div style={{
//           marginTop: '8px',
//           padding: '6px',
//           background: '#dcfce7',
//           color: '#16a34a',
//           borderRadius: '4px',
//           fontSize: '12px',
//           fontWeight: '600',
//           textAlign: 'center'
//         }}>
//           ✓ Approved
//         </div>
//       )}

//       {annotation.actionType === 'rejected' && (
//         <div style={{
//           marginTop: '8px',
//           padding: '6px',
//           background: '#fee2e2',
//           color: '#dc2626',
//           borderRadius: '4px',
//           fontSize: '12px',
//           fontWeight: '600',
//           textAlign: 'center'
//         }}>
//           ✗ Rejected
//         </div>
//       )}
//     </div>
//   );
// }

// // ImageBox component for side-by-side comparison
// function ImageBox({ title, imageUrl, timestamp }: { title: string; imageUrl: string | null | undefined; timestamp: string | null | undefined }) {
//   return (
//     <div style={{ 
//       background: '#fff', 
//       border: '1px solid #e5e7eb', 
//       borderRadius: 12, 
//       padding: 16,
//       boxShadow: '0 2px 8px rgba(0, 0, 0, 0.05)'
//     }}>
//       <div style={{ 
//         display: 'flex', 
//         justifyContent: 'space-between', 
//         alignItems: 'center',
//         marginBottom: 12 
//       }}>
//         <div style={{ 
//           fontWeight: 600, 
//           fontSize: '16px',
//           color: '#1f2937'
//         }}>
//           {title}
//         </div>
//         {timestamp && (
//           <div style={{ 
//             fontSize: 12, 
//             color: '#6b7280',
//             background: '#f3f4f6',
//             padding: '4px 8px',
//             borderRadius: '4px'
//           }}>
//             {new Date(timestamp).toLocaleString()}
//           </div>
//         )}
//       </div>
//       <div style={{ 
//         height: 280, 
//         display: 'flex', 
//         alignItems: 'center', 
//         justifyContent: 'center', 
//         background: 'linear-gradient(135deg, #0f172a 0%, #1e293b 100%)', 
//         borderRadius: 8,
//         border: '2px solid #334155'
//       }}>
//         {imageUrl ? (
//           <img 
//             src={imageUrl} 
//             alt={`${title} thermal image`}
//             style={{ 
//               maxHeight: '100%', 
//               maxWidth: '100%', 
//               objectFit: 'contain',
//               borderRadius: '4px'
//             }} 
//           />
//         ) : (
//           <div style={{ 
//             color: '#94a3b8',
//             textAlign: 'center',
//             fontSize: '14px',
//             fontWeight: '500'
//           }}>
//             <div style={{ fontSize: '32px', marginBottom: '8px' }}>📷</div>
//             <div>No {title.toLowerCase()} image</div>
//           </div>
//         )}
//       </div>
//     </div>
//   );
// }


// src/pages/InspectionDetailNew.tsx
import { useState, useEffect, useRef } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import AnnotationCanvas from '../components/AnnotationCanvas';
import AnnotationToolbar from '../components/AnnotationToolbar';
import AnnotationLegend from '../components/AnnotationLegend';
import NotesSection from '../components/NotesSection';
import CommentsSection from '../components/CommentsSection';
import FileDrop from '../components/FileDrop';
import {
  getInspection,
  detectAnomalies,
  uploadInspectionImage,
  updateInspectionStatus,
  uploadAnnotatedImage,
  removeInspectionImage,
} from '../api/inspections';
import {
  getAnnotationsByInspection,
  saveAnnotation,
  approveAnnotation,
  rejectAnnotation,
} from '../api/annotations';

import { uploadImage, listImages } from '../api/images';
import type { ThermalImage } from '../api/images';
import type { Inspection } from '../api/inspections';
import type { Annotation } from '../api/annotations';
import HistoryList from "../components/HistoryList";


export default function InspectionDetailNew() {
  const { id } = useParams();
  const nav = useNavigate();

  const [inspection, setInspection] = useState<Inspection | null>(null);
  const [annotations, setAnnotations] = useState<Annotation[]>([]); // sidebar (current session only)
  const [history, setHistory] = useState<Annotation[]>([]);        // all saved annotations
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

  // ---- shared helper for classId everywhere ----
  const getClassId = (className: string): number => {
    const classMap: Record<string, number> = {
      Faulty: 1,
      faulty_loose_joint: 2,
      faulty_point_overload: 3,
      potential_faulty: 4,
    };
    return classMap[className] ?? 1;
  };

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
        getAnnotationsByInspection(id),
      ]);

      setInspection(inspectionData);
      setAnnotations(annotationsData);

      // Load baseline image for the transformer
      if (inspectionData.transformerId) {
        await loadBaselineImage(
          inspectionData.transformerId,
          inspectionData.weatherCondition
        );
      }
    } catch (e: any) {
      setError(e?.message || 'Failed to load data');
    } finally {
      setLoading(false);
    }
  }

  async function loadBaselineImage(
    transformerId: string,
    weatherCondition?: string | null
  ) {
    try {
      const response = await listImages({
        transformerId,
        type: 'BASELINE',
        page: 0,
        size: 10,
      });
      const baselineImages = response.content || [];

      // Try to find a baseline image matching the weather condition first
      let selectedBaseline = null as ThermalImage | null;
      if (weatherCondition) {
        selectedBaseline = baselineImages.find(
          (img) => img.envCondition === weatherCondition
        ) as ThermalImage | null;
      }

      // If no matching weather condition, use the most recent baseline image
      if (!selectedBaseline && baselineImages.length > 0) {
        selectedBaseline = baselineImages.sort(
          (a, b) =>
            new Date(b.uploadedAt).getTime() -
            new Date(a.uploadedAt).getTime()
        )[0] as ThermalImage;
      }

      setBaselineImage(selectedBaseline || null);
    } catch (e: any) {
      console.error('Failed to load baseline image:', e);
      setBaselineImage(null);
    }
  }

  async function handleDetectAnomalies() {
    if (!id) return;

    if (!inspection || !inspection.inspectionImageId) {
      alert('⚠️ Please upload an inspection image before detecting anomalies.');
      return;
    }

    try {
      setIsDetecting(true);
      const result = await detectAnomalies(id);

      // Refresh annotations, inspection data, and baseline image
      const [updatedAnnotations, updatedInspection] = await Promise.all([
        getAnnotationsByInspection(id),
        getInspection(id),
      ]);

      setAnnotations(updatedAnnotations);
      setInspection(updatedInspection);

      if (updatedInspection.transformerId) {
        await loadBaselineImage(
          updatedInspection.transformerId,
          updatedInspection.weatherCondition
        );
      }

      alert(
        `Detection complete! Found ${result.detections?.length || 0} anomalies.`
      );
    } catch (e: any) {
      alert('Detection failed: ' + (e?.message || 'Unknown error'));
    } finally {
      setIsDetecting(false);
    }
  }

  
  // CREATE — local only (not hitting backend yet)
  function handleAnnotationCreate(bbox: { x1: number; y1: number; x2: number; y2: number }) {
    if (!inspection) return;
  
    const nextNumber = annotations.length + 1;
    const width = Math.abs(bbox.x2 - bbox.x1);
    const height = Math.abs(bbox.y2 - bbox.y1);
    const sizePx = width * height;
  
    const newAnnotation: Annotation & { isTemporary?: boolean } = {
      id: crypto.randomUUID(), // temp ID
      inspectionId: inspection.id,
      bbox,
      classId: getClassId(selectedClass),
      className: selectedClass,
      confidence: 1.0,
      source: "human",
      actionType: "created",
      createdBy: "current-user@example.com",
      createdAt: new Date().toISOString(),
      modifiedBy: null,
      modifiedAt: null,
      parentAnnotationId: null,
      isActive: true,
      comments: "",
  
      // ---------- new fields ----------
      annotationNumber: nextNumber,
      sizePx: sizePx,
      severityScore: null,
      flagged: false,
  
      // ---------- mark as local-only ----------
      isTemporary: true,
    };
  
    setAnnotations((prev) => [...prev, newAnnotation]);
  }
  


  // UPDATE — local only (staged until Save Annotated Image)
  function handleAnnotationUpdate(annotation: Annotation) {
    const width = Math.abs(annotation.bbox.x2 - annotation.bbox.x1);
    const height = Math.abs(annotation.bbox.y2 - annotation.bbox.y1);
    const sizePx = width * height;

    const updated: Annotation = {
      ...annotation,
      sizePx,
      severityScore: (annotation as any).severityScore ?? null,
      flagged: (annotation as any).flagged ?? false,
    };

    setAnnotations((prev) =>
      prev.map((ann) => (ann.id === updated.id ? updated : ann))
    );
  }

  // DELETE — local only (staged until Save Annotated Image)
  function handleAnnotationDelete(annotationId: string) {
    const ann = annotations.find((a) => a.id === annotationId);
    if (!ann) return;
  
    if (ann.isTemporary) {
      // Local only delete
      setAnnotations((prev) => prev.filter((a) => a.id !== annotationId));
    } else {
      // Persisted annotation → delete in DB
      if (!confirm("Delete this annotation?")) return;
      deleteAnnotation(annotationId, "current-user@example.com")
        .then(() => loadData())
        .catch((e) =>
          alert("Failed to delete annotation: " + (e?.message || "Unknown error"))
        );
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
      await rejectAnnotation(
        annotationId,
        'current-user@example.com',
        'User rejected this annotation'
      );
      await loadData();
    } catch (e: any) {
      alert('Failed to reject: ' + (e?.message || 'Unknown error'));
    }
  }

  // Zoom control functions - set by canvas
  const [zoomFunctions, setZoomFunctions] = useState<{
    zoomIn: () => void;
    zoomOut: () => void;
    resetView: () => void;
  } | null>(null);

  const handleZoomIn = () => zoomFunctions?.zoomIn();
  const handleZoomOut = () => zoomFunctions?.zoomOut();
  const handleResetView = () => zoomFunctions?.resetView();
  const handleZoomChange = (
    zoomIn: () => void,
    zoomOut: () => void,
    resetView: () => void
  ) => setZoomFunctions({ zoomIn, zoomOut, resetView });

  async function handleImageUpload(file: File) {
    if (!inspection) return;

    try {
      setUploading(true);
      setUploadError(null);

      const uploadedImage = await uploadImage({
        transformerId: inspection.transformerId,
        type: 'INSPECTION',
        uploader: inspection.inspectedBy || 'unknown',
        file,
        inspectionId: inspection.id,
      });

      await uploadInspectionImage(inspection.id, uploadedImage.id);
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

    if (
      !window.confirm(
        'Are you sure you want to remove the uploaded image? This will also clear any existing annotations.'
      )
    ) {
      return;
    }

    try {
      setRemovingImage(true);
      await removeInspectionImage(inspection.id);
      await loadData();
      alert('✅ Image removed successfully. You can now upload a new image.');
    } catch (e: any) {
      console.error('Error removing image:', e);
      alert(`❌ Failed to remove image: ${e?.message || 'Unknown error'}`);
    } finally {
      setRemovingImage(false);
    }
  }

  const handleCaptureReady = (captureFunc: () => string | null) => {
    captureCanvasRef.current = captureFunc;
    setIsCanvasReady(true);
  };


 
  // SAVE — persists annotated image AND current annotations

  async function handleSaveAnnotatedImage() {
    if (!inspection) {
      alert("No inspection available");
      return;
    }


    if (!captureCanvasRef.current || typeof captureCanvasRef.current !== "function") {
      alert("Canvas capture function not ready. Please wait for the image to load completely.");

      return;
    }

    try {
      setIsSavingImage(true);


      // capture + upload image (same as before)...
      const dataUrl = captureCanvasRef.current();
      if (!dataUrl) {
        alert("Failed to capture annotated image.");
        return;
      }

      const response = await fetch(dataUrl);
      const blob = await response.blob();
      const file = new File([blob], `annotated_${inspection.inspectionNumber}_${Date.now()}.png`, { type: "image/png" });


      const uploadedImage = await uploadImage({
        transformerId: inspection.transformerId,
        type: "INSPECTION",
        uploader: inspection.inspectedBy || "system",
        file,
        inspectionId: inspection.id,
      });

      await uploadAnnotatedImage(inspection.id, uploadedImage.id);


      // Persist ALL annotations
      for (const ann of annotations) {
        await saveAnnotation({
          id: ann.isTemporary ? undefined : ann.id, // only include ID if persisted
          inspectionId: ann.inspectionId,
          bbox: ann.bbox,
          classId: (ann as any).classId ?? getClassId(ann.className),
          className: ann.className,
          confidence: ann.confidence,
          source: ann.source,

          userId: ann.createdBy || "current-user@example.com",
          annotationNumber: ann.annotationNumber,
          sizePx: ann.sizePx,
          severityScore: ann.severityScore,
          flagged: ann.flagged,
        });
      }

      await loadData();

      setAnnotations([]); //  this clears the sidebar (only current ones)
      alert("Annotated image & annotations saved successfully!");

    } catch (e: any) {
      alert("Failed to save: " + (e?.message || "Unknown error"));
    } finally {
      setIsSavingImage(false);
    }
  }


  async function handleCompleteInspection() {
    if (!inspection) return;

    try {
      setIsCompleting(true);
      await updateInspectionStatus(inspection.id, 'COMPLETED');
      alert('Inspection completed successfully! Redirecting to transformer page...');
      window.location.href = `/transformers/${inspection.transformerId}`;
    } catch (e: any) {
      alert('Failed to complete inspection: ' + (e?.message || 'Unknown error'));
    } finally {
      setIsCompleting(false);
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
        <button
          onClick={() => (window.location.href = '/inspections')}
          className="primary-button"
        >
          Back to Inspections
        </button>
      </div>
    );
  }

  if (!inspection) {
    return (
      <div className="page-container">
        <div className="error-message">Inspection not found</div>
        <button
          onClick={() => (window.location.href = '/inspections')}
          className="primary-button"
        >
          Back to Inspections
        </button>
      </div>
    );
  }

  // Use original image URL for editing annotations, fall back to current inspection image
  const imageUrl =
    inspection.originalInspectionImageUrl ||
    inspection.inspectionImageUrl ||
    'https://via.placeholder.com/800x600?text=No+Image';

  return (
    <div className="page-container">
      {/* Header */}
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          marginBottom: '24px',
          padding: '20px',
          background: 'linear-gradient(135deg, #1e40af 0%, #3b82f6 100%)',
          borderRadius: '12px',
          boxShadow: '0 4px 12px rgba(30, 64, 175, 0.2)',
          border: 'none',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
          <button
            onClick={() => {
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
              backdropFilter: 'blur(10px)',
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
            <h1
              style={{
                margin: 0,
                fontSize: '20px',
                fontWeight: '600',
                color: 'white',
              }}
            >
              Inspection {inspection.inspectionNumber}
            </h1>
            <div
              style={{
                color: 'rgba(255, 255, 255, 0.8)',
                fontSize: '14px',
                marginTop: '2px',
              }}
            >
              {inspection.transformerCode} •{' '}
              {inspection.weatherCondition || 'Weather N/A'}
            </div>
          </div>
        </div>
        <div
          style={{
            padding: '6px 12px',
            background: 'rgba(255, 255, 255, 0.9)',
            color:
              inspection.status === 'COMPLETED'
                ? '#166534'
                : inspection.status === 'IN_PROGRESS'
                ? '#92400e'
                : '#374151',
            borderRadius: '6px',
            fontSize: '13px',
            fontWeight: '600',
            boxShadow: '0 2px 4px rgba(0, 0, 0, 0.1)',
          }}
        >
          {inspection.status.replace('_', ' ')}
        </div>
      </div>

      {/* Side-by-side Image Comparison */}
      {(baselineImage ||
        inspection.baselineImageUrl ||
        inspection.inspectionImageUrl ||
        inspection.originalInspectionImageUrl) && (
        <div style={{ marginBottom: 24 }}>
          <h3
            style={{
              margin: '0 0 16px 0',
              fontSize: '18px',
              fontWeight: '600',
              color: '#1f2937',
            }}
          >
            Thermal Image Comparison
          </h3>
          <div
            style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16 }}
          >
            <ImageBox
              title="Baseline"
              imageUrl={baselineImage?.publicUrl || inspection.baselineImageUrl}
              timestamp={baselineImage?.uploadedAt}
            />
            <ImageBox
              title="Inspection"
              imageUrl={
                inspection.inspectionImageUrl ||
                inspection.originalInspectionImageUrl
              }
              timestamp={inspection.inspectedAt}
            />
          </div>
        </div>
      )}

      {/* Main Content */}
      <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: '24px' }}>
        {/* Left: Annotation Canvas */}
        <div>
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
            <div
              style={{
                marginBottom: '16px',
                padding: '20px',
                background: 'white',
                border: '2px dashed #d1d5db',
                borderRadius: '12px',
                textAlign: 'center',
              }}
            >
              <div
                style={{
                  marginBottom: '16px',
                  color: '#374151',
                  fontWeight: '600',
                  fontSize: '16px',
                }}
              >
                📸 Upload Thermal Image
              </div>
              <div
                style={{ marginBottom: '16px', color: '#6b7280', fontSize: '14px' }}
              >
                Upload an inspection image to start annotation and detection
              </div>
              <FileDrop onFile={setSelectedFile} />
              {selectedFile && (
                <div
                  style={{
                    marginTop: '16px',
                    display: 'flex',
                    flexDirection: 'column',
                    alignItems: 'center',
                    gap: '12px',
                  }}
                >
                  <span
                    style={{
                      fontSize: '14px',
                      color: '#374151',
                      fontWeight: '500',
                    }}
                  >
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

          {/* Remove Image Section - Show when image is uploaded but no annotations exist */}
          {inspection.inspectionImageId && annotations.length === 0 && (
            <div
              style={{
                marginBottom: '16px',
                padding: '16px',
                background: '#fef3c7',
                border: '1px solid #fbbf24',
                borderRadius: '12px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
              }}
            >
              <div>
                <div
                  style={{
                    color: '#92400e',
                    fontWeight: '600',
                    fontSize: '14px',
                    marginBottom: '4px',
                  }}
                >
                  Inspection Image Uploaded
                </div>
                <div style={{ color: '#a16207', fontSize: '13px' }}>
                  Want to upload a different image? You can remove this one and upload a new one.
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
          <div
            style={{
              marginTop: '16px',
              padding: '10px 16px',
              background: '#f8fafc',
              border: '1px solid #e2e8f0',
              borderRadius: '8px',
              fontSize: '13px',
              color: '#64748b',
            }}
          >
            <div style={{ display: 'flex', gap: '20px', flexWrap: 'wrap' }}>
              <span>
                <strong>View:</strong> Drag to pan, scroll to zoom
              </span>
              <span>
                <strong>Edit:</strong> Click to select, drag corners to resize
              </span>
              <span>
                <strong>Draw:</strong> Click and drag to create
              </span>
            </div>
          </div>
          <div
            style={{
              marginTop: "20px",
              background: "white",
              borderRadius: "12px",
              boxShadow: "0 2px 8px rgba(0,0,0,0.1)",
              padding: "20px",
            }}
          >
            <h2 style={{ margin: "0 0 16px 0", fontSize: "18px", fontWeight: "600" }}>
              Annotation History
            </h2>

            {inspection && (
              <HistoryList inspectionId={inspection.id} />
            )}
          </div>
          {/* Comments Section */}
          <CommentsSection inspectionId={inspection.id} />
        </div>

        {/* Right: Annotations List */}
        <div>
          <div
            style={{
              background: 'white',
              borderRadius: '12px',
              boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
              padding: '20px',
            }}
          >
            <h2 style={{ margin: '0 0 16px 0', fontSize: '18px', fontWeight: '600' }}>
              Annotations ({annotations.length})
            </h2>

            {annotations.length === 0 && (
              <div
                style={{
                  textAlign: 'center',
                  padding: '40px 20px',
                  color: '#6b7280',
                  fontSize: '14px',
                }}
              >
                No annotations yet. Click "Detect Anomalies" or draw manually.
              </div>
            )}

            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
              {annotations.map((ann) => (
                <AnnotationCard
                  key={ann.id}
                  annotation={ann}
                  onApprove={() => handleApprove(ann.id)}
                  onReject={() => handleReject(ann.id)}
                  onDelete={() => handleAnnotationDelete(ann.id)}
                />
              ))}
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

          {/* Save Annotated Image Button */}
          {inspection.status !== 'COMPLETED' && annotations.length > 0 && (
            <div
              style={{
                background: 'white',
                borderRadius: '12px',
                boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
                padding: '20px',
                marginTop: '16px',
                textAlign: 'center',
              }}
            >
              <h3
                style={{
                  margin: '0 0 12px 0',
                  fontSize: '16px',
                  fontWeight: '600',
                  color: '#3b82f6',
                }}
              >

                Save Annotated Data
              </h3>
              <p
                style={{
                  fontSize: '14px',
                  color: '#6b7280',
                  lineHeight: '1.6',
                  marginBottom: '16px',
                }}
              >
                Save the current image with annotations to display on the transformer page. You
                can do this multiple times as you make changes.
              </p>
              <button
                onClick={handleSaveAnnotatedImage}
                disabled={isSavingImage || !inspection.inspectionImageId || !isCanvasReady}
                style={{
                  background:
                    isSavingImage || !isCanvasReady
                      ? '#94a3b8'
                      : 'linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%)',
                  color: 'white',
                  border: 'none',
                  borderRadius: '10px',
                  padding: '14px 28px',
                  fontSize: '16px',
                  fontWeight: '600',
                  cursor:
                    isSavingImage || !inspection.inspectionImageId || !isCanvasReady
                      ? 'not-allowed'
                      : 'pointer',
                  boxShadow: '0 4px 12px rgba(59, 130, 246, 0.3)',
                  minWidth: '160px',
                  opacity: !inspection.inspectionImageId || !isCanvasReady ? 0.6 : 1,
                }}
              >
                {isSavingImage ? '⏳ Saving...' : !isCanvasReady ? '⏳ Loading...' : 'Save'}
              </button>
              {!inspection.inspectionImageId && (
                <p style={{ fontSize: '12px', color: '#ef4444', marginTop: '8px' }}>
                  Please upload an inspection image first
                </p>
              )}
              {inspection.inspectionImageId && !isCanvasReady && (
                <p style={{ fontSize: '12px', color: '#f59e0b', marginTop: '8px' }}>
                  Canvas is loading, please wait...
                </p>
              )}
            </div>
          )}

          {/* Complete Inspection Button */}
          {inspection.status !== 'COMPLETED' && (
            <div
              style={{
                background: 'white',
                borderRadius: '12px',
                boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
                padding: '20px',
                marginTop: '16px',
                textAlign: 'center',
              }}
            >
              <h3
                style={{
                  margin: '0 0 12px 0',
                  fontSize: '16px',
                  fontWeight: '600',
                  color: '#059669',
                }}
              >
                ✅ Finish Inspection
              </h3>
              <p
                style={{
                  fontSize: '14px',
                  color: '#6b7280',
                  lineHeight: '1.6',
                  marginBottom: '16px',
                }}
              >
                Click Done when you have finished editing annotations. This will mark the
                inspection as complete and display the results on the transformer page.
              </p>
              <button
                onClick={handleCompleteInspection}
                disabled={isCompleting || !inspection.inspectionImageId}
                style={{
                  background: isCompleting
                    ? '#94a3b8'
                    : 'linear-gradient(135deg, #059669 0%, #10b981 100%)',
                  color: 'white',
                  border: 'none',
                  borderRadius: '10px',
                  padding: '14px 28px',
                  fontSize: '16px',
                  fontWeight: '600',
                  cursor: isCompleting || !inspection.inspectionImageId ? 'not-allowed' : 'pointer',
                  boxShadow: '0 4px 12px rgba(5, 150, 105, 0.3)',
                  minWidth: '140px',
                  opacity: !inspection.inspectionImageId ? 0.6 : 1,
                }}
              >

                {isCompleting ? '⏳ Finishing...' : 'Complete Inspection'}
              </button>
              {!inspection.inspectionImageId && (
                <p style={{ fontSize: '12px', color: '#ef4444', marginTop: '8px' }}>
                  Please upload an inspection image first
                </p>
              )}
            </div>
          )}

          {inspection.status === 'COMPLETED' && (
            <div
              style={{
                background: 'white',
                borderRadius: '12px',
                boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
                padding: '20px',
                marginTop: '16px',
                textAlign: 'center',
                border: '2px solid #10b981',
              }}
            >
              <h3
                style={{
                  margin: '0 0 8px 0',
                  fontSize: '16px',
                  fontWeight: '600',
                  color: '#059669',
                }}
              >
                ✅ Inspection Completed
              </h3>
              <p style={{ fontSize: '14px', color: '#6b7280', marginBottom: '12px' }}>
                This inspection has been marked as complete.
              </p>
              <button
                onClick={() => nav(`/transformers/${inspection.transformerId}`)}
                style={{
                  background: 'linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%)',
                  color: 'white',
                  border: 'none',
                  borderRadius: '8px',
                  padding: '10px 20px',
                  fontSize: '14px',
                  fontWeight: '600',
                  cursor: 'pointer',
                  boxShadow: '0 2px 8px rgba(59, 130, 246, 0.2)',
                }}
              >
                View on Transformer Page
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

interface AnnotationCardProps {
  annotation: Annotation;
  onApprove: () => void;
  onReject: () => void;
  onDelete: () => void;
  index: number;
}

function AnnotationCard({ annotation, onApprove, onReject, onDelete, index }: AnnotationCardProps) {
  const CLASS_COLORS: Record<string, string> = {
    Faulty: '#ef4444',
    faulty_loose_joint: '#22c55e',
    faulty_point_overload: '#3b82f6',
    potential_faulty: '#eab308',
  };

  const color = CLASS_COLORS[annotation.className] || '#6b7280';

  // compute area + number
  const width = Math.abs(annotation.bbox.x2 - annotation.bbox.x1);
  const height = Math.abs(annotation.bbox.y2 - annotation.bbox.y1);
  const area = width * height;
  const number = annotation.annotationNumber ?? index + 1;

  return (
    <div
      style={{
        border: `2px solid ${color}`,
        borderRadius: '8px',
        padding: '12px',
        background: `${color}11`,
      }}
    >
      {/* Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '8px' }}>
        <div>
          <div style={{ fontWeight: '600', fontSize: '14px', color }}>

            #{number} · {annotation.className || "Unknown"}
          </div>
          <div style={{ fontSize: '12px', color: '#6b7280', marginTop: '2px' }}>
            {annotation.source === 'ai' ? '🤖 AI Detection' : '👤 Manual'} ·{' '}
            by {annotation.createdBy || "Unknown"} ·{' '}
            {Math.round((annotation.confidence ?? 1) * 100)}% confidence
          </div>
        </div>
        <div
          style={{
            fontSize: '11px',
            color: '#6b7280',
            background: 'white',
            padding: '2px 6px',
            borderRadius: '4px',
          }}
        >
          v{annotation.version}
        </div>
      </div>


      {/* BBox + Area */}
      <div style={{ fontSize: '12px', color: '#6b7280', marginBottom: '8px' }}>
        BBox: ({Math.round(annotation.bbox.x1)}, {Math.round(annotation.bbox.y1)}) → (
        {Math.round(annotation.bbox.x2)}, {Math.round(annotation.bbox.y2)})
        <br />

        Area: {area} px²
      </div>

      {/* Flag status */}
      {annotation.flagged && (
        <div
          style={{
            marginBottom: '8px',
            padding: '4px 8px',
            background: '#fef3c7',
            color: '#92400e',
            borderRadius: '4px',
            fontSize: '12px',
            fontWeight: '600',
          }}
        >
          ⚠️ Flagged
        </div>
      )}

      {/* Approve / Reject for AI */}
      {annotation.source === 'ai' && annotation.actionType === 'created' && (
        <div style={{ display: 'flex', gap: '8px' }}>
          <button onClick={onApprove} style={{ flex: 1, padding: '6px', borderRadius: '6px', background: '#22c55e', color: 'white', fontSize: '12px', fontWeight: '600' }}>
            ✓ Approve
          </button>
          <button onClick={onReject} style={{ flex: 1, padding: '6px', borderRadius: '6px', background: '#ef4444', color: 'white', fontSize: '12px', fontWeight: '600' }}>
>>>>>>> Stashed changes
            ✗ Reject
          </button>
        </div>
      )}


      {/* Delete for manual */}
      {annotation.source === 'human' && (
        <button
          onClick={onDelete}
          style={{
            width: '100%',
            padding: '6px',
            marginTop: '6px',
            border: 'none',
            borderRadius: '6px',
            background: '#ef4444',
            color: 'white',
            fontSize: '12px',
            fontWeight: '600',
            cursor: 'pointer',
          }}
        >
          🗑️ Delete
        </button>
      )}

      {/* Status badges */}
      {annotation.actionType === 'approved' && (
        <div style={{ marginTop: '8px', padding: '6px', background: '#dcfce7', color: '#16a34a', borderRadius: '4px', fontSize: '12px', fontWeight: '600', textAlign: 'center' }}>
          ✓ Approved
        </div>
      )}
      {annotation.actionType === 'rejected' && (
        <div style={{ marginTop: '8px', padding: '6px', background: '#fee2e2', color: '#dc2626', borderRadius: '4px', fontSize: '12px', fontWeight: '600', textAlign: 'center' }}>
          ✗ Rejected
        </div>
      )}
    </div>
  );
}






function ImageBox({
  title,
  imageUrl,
  timestamp,
}: {
  title: string;
  imageUrl: string | null | undefined;
  timestamp: string | null | undefined;
}) {
  return (
    <div
      style={{
        background: '#fff',
        border: '1px solid #e5e7eb',
        borderRadius: 12,
        padding: 16,
        boxShadow: '0 2px 8px rgba(0, 0, 0, 0.05)',
      }}
    >
      <div
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          marginBottom: 12,
        }}
      >
        <div style={{ fontWeight: 600, fontSize: '16px', color: '#1f2937' }}>{title}</div>
        {timestamp && (
          <div
            style={{
              fontSize: 12,
              color: '#6b7280',
              background: '#f3f4f6',
              padding: '4px 8px',
              borderRadius: '4px',
            }}
          >
            {new Date(timestamp).toLocaleString()}
          </div>
        )}
      </div>
      <div
        style={{
          height: 280,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          background: 'linear-gradient(135deg, #0f172a 0%, #1e293b 100%)',
          borderRadius: 8,
          border: '2px solid #334155',
        }}
      >
        {imageUrl ? (
          <img
            src={imageUrl}
            alt={`${title} thermal image`}
            style={{
              maxHeight: '100%',
              maxWidth: '100%',
              objectFit: 'contain',
              borderRadius: '4px',
            }}
          />
        ) : (
          <div
            style={{
              color: '#94a3b8',
              textAlign: 'center',
              fontSize: '14px',
              fontWeight: '500',
            }}
          >
            <div style={{ fontSize: '32px', marginBottom: '8px' }}>📷</div>
            <div>No {title.toLowerCase()} image</div>
          </div>
        )}
      </div>
    </div>
  );
}

