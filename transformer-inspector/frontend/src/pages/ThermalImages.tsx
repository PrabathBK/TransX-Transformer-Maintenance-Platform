import { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { DashboardLayout } from '@/components/layout/DashboardLayout';
import { ThermalImageUpload } from '@/components/thermal/ThermalImageUpload';
import { apiService } from '@/services/api';
import { ThermalImage, Transformer } from '@/types/transformer';
import { 
  Upload, 
  Search,
  Filter,
  Eye,
  Download,
  Image as ImageIcon
} from 'lucide-react';
import { format } from 'date-fns';

export default function ThermalImages() {
  const [images, setImages] = useState<ThermalImage[]>([]);
  const [transformers, setTransformers] = useState<Transformer[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [showUploadDialog, setShowUploadDialog] = useState(false);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      const [transformerData] = await Promise.all([
        apiService.getTransformers()
      ]);
      setTransformers(transformerData);
      
      // Load all thermal images for all transformers
      const allImages: ThermalImage[] = [];
      for (const transformer of transformerData) {
        const transformerImages = await apiService.getThermalImages(transformer.id);
        allImages.push(...transformerImages);
      }
      setImages(allImages);
    } catch (error) {
      console.error('Failed to load thermal images:', error);
    } finally {
      setLoading(false);
    }
  };

  const getTransformerDetails = (transformerId: string) => {
    return transformers.find(t => t.id === transformerId);
  };

  const getTypeColor = (type: string) => {
    switch (type) {
      case 'Baseline':
        return 'bg-primary/20 text-primary border-primary/30';
      case 'Maintenance':
        return 'bg-accent/20 text-accent border-accent/30';
      default:
        return 'bg-muted/20 text-muted-foreground border-muted/30';
    }
  };

  const getConditionColor = (condition?: string) => {
    switch (condition) {
      case 'Sunny':
        return 'bg-warning/20 text-warning border-warning/30';
      case 'Cloudy':
        return 'bg-muted/20 text-muted-foreground border-muted/30';
      case 'Rainy':
        return 'bg-accent/20 text-accent border-accent/30';
      default:
        return 'bg-muted/20 text-muted-foreground border-muted/30';
    }
  };

  const filteredImages = images.filter(image => {
    const transformer = getTransformerDetails(image.transformerId);
    return (
      (transformer && transformer.transformerNo.toLowerCase().includes(searchTerm.toLowerCase())) ||
      image.type.toLowerCase().includes(searchTerm.toLowerCase())
    );
  });

  if (loading) {
    return (
      <DashboardLayout>
        <div className="flex items-center justify-center h-64">
          <div className="animate-pulse text-muted-foreground">Loading thermal images...</div>
        </div>
      </DashboardLayout>
    );
  }

  return (
    <DashboardLayout>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold">Thermal Images</h1>
            <p className="text-muted-foreground mt-2">Manage thermal imaging data for transformer inspections</p>
          </div>
          <div className="flex items-center gap-3">
            <Button variant="outline" className="gap-2">
              <Filter className="w-4 h-4" />
              Filter
            </Button>
            <Button onClick={() => setShowUploadDialog(true)} className="gap-2 bg-gradient-primary shadow-primary">
              <Upload className="w-4 h-4" />
              Upload Image
            </Button>
          </div>
        </div>

        {/* Filters */}
        <Card className="bg-gradient-surface border-border">
          <CardContent className="p-6">
            <div className="flex items-center gap-4">
              <div className="relative flex-1 max-w-md">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground w-4 h-4" />
                <Input 
                  placeholder="Search by transformer or image type"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="pl-10 bg-background"
                />
              </div>
              <Button variant="outline">All Types</Button>
              <Button variant="outline">All Conditions</Button>
              <Button variant="ghost" className="text-primary">Reset filters</Button>
            </div>
          </CardContent>
        </Card>

        {/* Images Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredImages.map((image) => {
            const transformer = getTransformerDetails(image.transformerId);
            return (
              <Card key={image.id} className="bg-gradient-surface border-border overflow-hidden">
                <div className="relative h-48 bg-muted/20 flex items-center justify-center">
                  {image.imageUrl ? (
                    <img 
                      src={image.imageUrl} 
                      alt={`Thermal image for ${transformer?.transformerNo}`}
                      className="w-full h-full object-cover"
                    />
                  ) : (
                    <ImageIcon className="w-12 h-12 text-muted-foreground" />
                  )}
                  <div className="absolute top-3 left-3">
                    <Badge 
                      variant="secondary"
                      className={getTypeColor(image.type)}
                    >
                      {image.type}
                    </Badge>
                  </div>
                  {image.environmentalCondition && (
                    <div className="absolute top-3 right-3">
                      <Badge 
                        variant="secondary"
                        className={getConditionColor(image.environmentalCondition)}
                      >
                        {image.environmentalCondition}
                      </Badge>
                    </div>
                  )}
                </div>
                <CardContent className="p-4">
                  <div className="space-y-2">
                    <h3 className="font-semibold text-lg">
                      {transformer?.transformerNo || 'Unknown Transformer'}
                    </h3>
                    <p className="text-sm text-muted-foreground">
                      {transformer?.region} • {transformer?.poleNo}
                    </p>
                    <div className="flex items-center justify-between text-xs text-muted-foreground">
                      <span>Uploaded: {format(new Date(image.uploadDate), 'MMM dd, yyyy')}</span>
                      <span>By: {image.uploader}</span>
                    </div>
                    {image.metadata && (
                      <div className="text-xs text-muted-foreground">
                        {Math.round(image.metadata.fileSize / 1024)} KB • 
                        {image.metadata.dimensions.width}x{image.metadata.dimensions.height}
                      </div>
                    )}
                  </div>
                  <div className="flex gap-2 mt-4">
                    <Button variant="outline" size="sm" className="flex-1 gap-2">
                      <Eye className="w-4 h-4" />
                      View
                    </Button>
                    <Button variant="outline" size="sm" className="gap-2">
                      <Download className="w-4 h-4" />
                      Download
                    </Button>
                  </div>
                </CardContent>
              </Card>
            );
          })}
        </div>

        {filteredImages.length === 0 && (
          <Card className="bg-gradient-surface border-border">
            <CardContent className="p-12 text-center">
              <ImageIcon className="w-12 h-12 text-muted-foreground mx-auto mb-4" />
              <h3 className="text-lg font-semibold mb-2">No thermal images found</h3>
              <p className="text-muted-foreground mb-4">
                {searchTerm ? 'Try adjusting your search terms.' : 'Upload your first thermal image to get started.'}
              </p>
              {!searchTerm && (
                <Button onClick={() => setShowUploadDialog(true)} className="gap-2 bg-gradient-primary">
                  <Upload className="w-4 h-4" />
                  Upload Image
                </Button>
              )}
            </CardContent>
          </Card>
        )}
      </div>

      <ThermalImageUpload 
        open={showUploadDialog} 
        onOpenChange={setShowUploadDialog}
        transformers={transformers}
        onSuccess={loadData}
      />
    </DashboardLayout>
  );
}