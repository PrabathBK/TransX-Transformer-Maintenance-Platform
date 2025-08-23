import { useState, useRef } from 'react';
import { useForm } from 'react-hook-form';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Label } from '@/components/ui/label';
import { 
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Progress } from '@/components/ui/progress';
import { apiService } from '@/services/api';
import { Transformer } from '@/types/transformer';
import { useToast } from '@/hooks/use-toast';
import { 
  Upload, 
  FileImage, 
  X,
  Cloud,
  CloudRain,
  Sun
} from 'lucide-react';

interface ThermalImageUploadProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  transformers: Transformer[];
  onSuccess: () => void;
}

interface FormData {
  transformerId: string;
  type: 'Baseline' | 'Maintenance';
  environmentalCondition?: 'Sunny' | 'Cloudy' | 'Rainy';
}

export function ThermalImageUpload({ 
  open, 
  onOpenChange, 
  transformers, 
  onSuccess 
}: ThermalImageUploadProps) {
  const [loading, setLoading] = useState(false);
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [uploadProgress, setUploadProgress] = useState(0);
  const [dragOver, setDragOver] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const { toast } = useToast();
  const { setValue, watch, reset } = useForm<FormData>();

  const watchedValues = watch();

  const onSubmit = async () => {
    if (!selectedFile) {
      toast({
        title: "Error",
        description: "Please select a thermal image file",
        variant: "destructive",
      });
      return;
    }

    if (!watchedValues.transformerId || !watchedValues.type) {
      toast({
        title: "Error", 
        description: "Please fill in all required fields",
        variant: "destructive",
      });
      return;
    }

    setLoading(true);
    setUploadProgress(0);

    try {
      // Simulate upload progress
      const progressInterval = setInterval(() => {
        setUploadProgress(prev => {
          if (prev >= 90) {
            clearInterval(progressInterval);
            return 90;
          }
          return prev + 10;
        });
      }, 200);

      await apiService.uploadThermalImage(
        watchedValues.transformerId,
        selectedFile,
        watchedValues.type,
        watchedValues.environmentalCondition
      );

      clearInterval(progressInterval);
      setUploadProgress(100);

      toast({
        title: "Success",
        description: "Thermal image uploaded successfully",
      });

      // Reset form
      reset();
      setSelectedFile(null);
      setUploadProgress(0);
      onOpenChange(false);
      onSuccess();
    } catch (error) {
      console.error('Failed to upload thermal image:', error);
      toast({
        title: "Error",
        description: "Failed to upload thermal image. Please try again.",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  const handleFileSelect = (file: File) => {
    if (file.type.startsWith('image/')) {
      setSelectedFile(file);
    } else {
      toast({
        title: "Error",
        description: "Please select a valid image file",
        variant: "destructive",
      });
    }
  };

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    setDragOver(false);
    const files = e.dataTransfer.files;
    if (files[0]) {
      handleFileSelect(files[0]);
    }
  };

  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault();
    setDragOver(true);
  };

  const handleDragLeave = (e: React.DragEvent) => {
    e.preventDefault();
    setDragOver(false);
  };

  const weatherIcons = {
    Sunny: Sun,
    Cloudy: Cloud,
    Rainy: CloudRain,
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="bg-card border-border max-w-lg">
        <DialogHeader>
          <DialogTitle className="text-xl font-semibold">Upload Thermal Image</DialogTitle>
        </DialogHeader>
        
        <div className="space-y-6">
          {/* File Upload Area */}
          <div
            className={`
              relative border-2 border-dashed rounded-lg p-8 text-center transition-colors
              ${dragOver ? 'border-primary bg-primary/10' : 'border-border bg-background/50'}
              ${selectedFile ? 'border-success bg-success/10' : ''}
            `}
            onDrop={handleDrop}
            onDragOver={handleDragOver}
            onDragLeave={handleDragLeave}
          >
            {selectedFile ? (
              <div className="space-y-2">
                <FileImage className="w-8 h-8 text-success mx-auto" />
                <p className="font-medium">{selectedFile.name}</p>
                <p className="text-sm text-muted-foreground">
                  {Math.round(selectedFile.size / 1024)} KB
                </p>
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={() => setSelectedFile(null)}
                  className="absolute top-2 right-2"
                >
                  <X className="w-4 h-4" />
                </Button>
              </div>
            ) : (
              <div className="space-y-4">
                <Upload className="w-12 h-12 text-muted-foreground mx-auto" />
                <div>
                  <p className="text-lg font-medium">Drop thermal image here</p>
                  <p className="text-sm text-muted-foreground">or click to browse files</p>
                </div>
                <Button
                  variant="outline"
                  onClick={() => fileInputRef.current?.click()}
                  className="mx-auto"
                >
                  Browse Files
                </Button>
              </div>
            )}
            
            <input
              ref={fileInputRef}
              type="file"
              accept="image/*"
              onChange={(e) => e.target.files?.[0] && handleFileSelect(e.target.files[0])}
              className="hidden"
            />
          </div>

          {/* Upload Progress */}
          {loading && (
            <div className="space-y-2">
              <div className="flex justify-between text-sm">
                <span>Uploading...</span>
                <span>{uploadProgress}%</span>
              </div>
              <Progress value={uploadProgress} className="h-2" />
            </div>
          )}

          {/* Form Fields */}
          <div className="space-y-4">
            <div className="space-y-2">
              <Label>Transformer</Label>
              <Select onValueChange={(value) => setValue('transformerId', value)}>
                <SelectTrigger className="bg-background">
                  <SelectValue placeholder="Select Transformer" />
                </SelectTrigger>
                <SelectContent className="bg-popover border-border">
                  {transformers.map((transformer) => (
                    <SelectItem key={transformer.id} value={transformer.id}>
                      {transformer.transformerNo} - {transformer.region}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-2">
              <Label>Image Type</Label>
              <Select onValueChange={(value: 'Baseline' | 'Maintenance') => setValue('type', value)}>
                <SelectTrigger className="bg-background">
                  <SelectValue placeholder="Select Type" />
                </SelectTrigger>
                <SelectContent className="bg-popover border-border">
                  <SelectItem value="Baseline">Baseline</SelectItem>
                  <SelectItem value="Maintenance">Maintenance</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-2">
              <Label>Weather Condition</Label>
              <div className="grid grid-cols-3 gap-2">
                {(['Sunny', 'Cloudy', 'Rainy'] as const).map((condition) => {
                  const Icon = weatherIcons[condition];
                  const isSelected = watchedValues.environmentalCondition === condition;
                  
                  return (
                    <Button
                      key={condition}
                      type="button"
                      variant={isSelected ? "default" : "outline"}
                      onClick={() => setValue('environmentalCondition', condition)}
                      className={`flex flex-col items-center gap-2 h-auto py-3 ${
                        isSelected ? 'bg-primary text-primary-foreground' : ''
                      }`}
                    >
                      <Icon className="w-5 h-5" />
                      <span className="text-sm">{condition}</span>
                    </Button>
                  );
                })}
              </div>
            </div>
          </div>

          {/* Action Buttons */}
          <div className="flex gap-3 pt-4">
            <Button 
              type="button" 
              variant="outline" 
              onClick={() => onOpenChange(false)}
              className="flex-1"
              disabled={loading}
            >
              Cancel
            </Button>
            <Button 
              onClick={onSubmit} 
              disabled={loading || !selectedFile}
              className="flex-1 bg-gradient-primary shadow-primary"
            >
              {loading ? 'Uploading...' : 'Upload thermal Image'}
            </Button>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  );
}