import React, { useCallback, useState } from 'react';

type Props = { onFile: (file: File) => void; };

export default function FileDrop({ onFile }: Props) {
  const [hover, setHover] = useState(false);
  const [selectedFile, setSelectedFile] = useState<string | null>(null);
  const [showError, setShowError] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string>('');
  const [isUploading, setIsUploading] = useState(false);

  const validateFile = (file: File): { isValid: boolean; error?: string } => {
    // Check file type
    if (!file.type.startsWith('image/')) {
      return { isValid: false, error: 'Please select an image file' };
    }
    
    // Check file size (max 10MB)
    const maxSize = 10 * 1024 * 1024; // 10MB in bytes
    if (file.size > maxSize) {
      return { isValid: false, error: 'File size must be less than 10MB' };
    }
    
    // Check file extension
    const allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    const fileName = file.name.toLowerCase();
    const hasValidExtension = allowedExtensions.some(ext => fileName.endsWith(ext));
    
    if (!hasValidExtension) {
      return { isValid: false, error: 'Please select a valid image file (jpg, png, gif, etc.)' };
    }
    
    return { isValid: true };
  };

  const showErrorPopup = (message: string) => {
    setErrorMessage(message);
    setShowError(true);
    setTimeout(() => setShowError(false), 4000); // Show error for 4 seconds
  };

  const checkEnvironmentConditions = (): { isValid: boolean; error?: string } => {
    // Check if browser supports FileReader
    if (!window.FileReader) {
      return { isValid: false, error: 'Your browser does not support file uploads' };
    }

    // Check if browser is online
    if (!navigator.onLine) {
      return { isValid: false, error: 'No internet connection. Please check your network.' };
    }

    // Check available storage space (if supported)
    if ('storage' in navigator && 'estimate' in navigator.storage) {
      navigator.storage.estimate().then(estimate => {
        const availableSpace = estimate.quota ? estimate.quota - (estimate.usage || 0) : 0;
        if (availableSpace < 50 * 1024 * 1024) { // Less than 50MB available
          showErrorPopup('Low storage space. Please free up some space and try again.');
        }
      }).catch(() => {
        // Ignore storage check errors
      });
    }

    return { isValid: true };
  };

  const handleUploadProcess = async (file: File) => {
    setIsUploading(true);
    
    try {
      // Check environment conditions
      const envCheck = checkEnvironmentConditions();
      if (!envCheck.isValid) {
        throw new Error(envCheck.error);
      }

      // Simulate upload process with potential errors
      await new Promise((resolve, reject) => {
        setTimeout(() => {
          // Simulate various upload conditions
          const random = Math.random();
          
          if (random < 0.05) { // 5% chance of network error
            reject(new Error('Network error occurred. Please check your connection and try again.'));
          } else if (random < 0.08) { // 3% chance of server error
            reject(new Error('Server is temporarily unavailable. Please try again later.'));
          } else if (random < 0.1) { // 2% chance of timeout
            reject(new Error('Upload timeout. Please try again with a smaller file.'));
          } else {
            resolve(true); // Success
          }
        }, 1000); // Simulate upload delay
      });

      // If we get here, upload was successful
      onFile(file);
      setSelectedFile(file.name);
      
    } catch (error) {
      // Handle upload errors
      const errorMsg = error instanceof Error ? error.message : 'Upload failed. Please try again.';
      showErrorPopup(errorMsg);
    } finally {
      setIsUploading(false);
    }
  };

  const onDrop = useCallback((e: React.DragEvent) => {
    e.preventDefault();
    setHover(false);
    const file = e.dataTransfer.files?.[0];
    if (file) {
      const validation = validateFile(file);
      if (!validation.isValid) {
        showErrorPopup(validation.error || 'Invalid file');
        return;
      }
      
      // Use the new upload process with environment checks
      handleUploadProcess(file);
    }
  }, []);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const f = e.target.files?.[0];
    if (f) {
      const validation = validateFile(f);
      if (!validation.isValid) {
        showErrorPopup(validation.error || 'Invalid file');
        // Clear the input so user can try again
        e.target.value = '';
        return;
      }
      
      // Use the new upload process with environment checks
      handleUploadProcess(f);
    }
  };

  return (
    <>
      {/* Selected File Display */}
      {selectedFile && (
        <div style={{
          backgroundColor: '#f0f9ff',
          border: '1px solid #0ea5e9',
          borderRadius: '8px',
          padding: '12px 16px',
          marginBottom: '16px',
          display: 'flex',
          alignItems: 'center',
          gap: '8px',
          fontSize: '14px',
          color: '#0369a1'
        }}>
          <span style={{ color: '#059669', fontSize: '16px' }}>✅</span>
          <strong>Selected:</strong> {selectedFile}
        </div>
      )}

      {/* Drag & Drop Area - only show when no file is selected */}
      {!selectedFile && (
        <div
          onDragOver={e => { e.preventDefault(); setHover(true); }}
          onDragLeave={() => setHover(false)}
          onDrop={onDrop}
          style={{
            padding: 48,
            border: `2px dashed ${hover ? '#1e40af' : '#60a5fa'}`,
            borderRadius: 12,
            textAlign: 'center',
            background: hover ? 'rgba(30, 64, 175, 0.05)' : 'rgba(248, 250, 252, 0.5)',
            transition: 'all 0.3s ease',
            cursor: isUploading ? 'wait' : 'pointer',
            position: 'relative',
            opacity: isUploading ? 0.7 : 1
          }}
        >
      {/* Cloud Upload Icon */}
      <div style={{ 
        fontSize: 64, 
        marginBottom: 16,
        color: hover ? '#1e40af' : '#3b82f6'
      }}>
        ☁
      </div>
      
      {/* Main Text */}
      <p style={{ 
        margin: '0 0 8px 0', 
        fontSize: 16, 
        fontWeight: 600,
        color: hover ? '#1e40af' : '#475569'
      }}>
        {isUploading ? 'Uploading...' : 'Drag & drop to upload'}
      </p>
      
      {/* Secondary Text */}
      <p style={{ 
        margin: '0 0 20px 0', 
        fontSize: 14, 
        color: '#60a5fa',
        fontWeight: 500
      }}>
        {isUploading ? 'Please wait' : 'or browse'}
      </p>
      
      {/* Hidden File Input */}
      <input
        type="file"
        accept="image/*"
        onChange={handleFileChange}
        disabled={isUploading}
        style={{ 
          position: 'absolute',
          top: 0,
          left: 0,
          width: '100%',
          height: '100%',
          opacity: 0,
          cursor: isUploading ? 'wait' : 'pointer'
        }}
      />
        </div>
      )}

      {/* Error Popup */}
      {showError && (
        <div style={{
          position: 'fixed',
          top: '20px',
          right: '20px',
          background: '#ef4444',
          color: 'white',
          padding: '16px 24px',
          borderRadius: '8px',
          boxShadow: '0 4px 12px rgba(0, 0, 0, 0.15)',
          zIndex: 1000,
          fontSize: '14px',
          fontWeight: '500',
          animation: 'slideIn 0.3s ease-out'
        }}>
          ⚠ {errorMessage}
        </div>
      )}
    </>
  );
}