import { useState } from 'react';
import { useForm } from 'react-hook-form';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { 
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Textarea } from '@/components/ui/textarea';
import { apiService } from '@/services/api';
import { Transformer } from '@/types/transformer';
import { useToast } from '@/hooks/use-toast';

interface AddTransformerDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onSuccess: () => void;
}

interface FormData {
  transformerNo: string;
  poleNo: string;
  region: string;
  type: 'Bulk' | 'Distribution';
  locationDetails: string;
}

export function AddTransformerDialog({ open, onOpenChange, onSuccess }: AddTransformerDialogProps) {
  const [loading, setLoading] = useState(false);
  const { toast } = useToast();
  const { register, handleSubmit, reset, setValue, watch, formState: { errors } } = useForm<FormData>();

  const onSubmit = async (data: FormData) => {
    setLoading(true);
    try {
      await apiService.createTransformer(data);
      toast({
        title: "Success",
        description: "Transformer added successfully",
      });
      reset();
      onOpenChange(false);
      onSuccess();
    } catch (error) {
      console.error('Failed to create transformer:', error);
      toast({
        title: "Error",
        description: "Failed to add transformer. Please try again.",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  const regions = [
    'Nugegoda',
    'Maharagama',
    'Colombo',
    'Kandy',
    'Galle',
    'Matara',
    'Jaffna',
    'Batticaloa'
  ];

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="bg-card border-border max-w-md">
        <DialogHeader>
          <DialogTitle className="text-xl font-semibold">Add Transformer</DialogTitle>
        </DialogHeader>
        
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="region">Region</Label>
            <Select onValueChange={(value) => setValue('region', value)}>
              <SelectTrigger className="bg-background">
                <SelectValue placeholder="Select Region" />
              </SelectTrigger>
              <SelectContent className="bg-popover border-border">
                {regions.map((region) => (
                  <SelectItem key={region} value={region}>
                    {region}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
            {errors.region && (
              <p className="text-destructive text-sm">Region is required</p>
            )}
          </div>

          <div className="space-y-2">
            <Label htmlFor="transformerNo">Transformer No</Label>
            <Input
              id="transformerNo"
              placeholder="e.g., AZ-8890"
              className="bg-background"
              {...register('transformerNo', { required: 'Transformer number is required' })}
            />
            {errors.transformerNo && (
              <p className="text-destructive text-sm">{errors.transformerNo.message}</p>
            )}
          </div>

          <div className="space-y-2">
            <Label htmlFor="poleNo">Pole No</Label>
            <Input
              id="poleNo"
              placeholder="e.g., EN-122-A"
              className="bg-background"
              {...register('poleNo', { required: 'Pole number is required' })}
            />
            {errors.poleNo && (
              <p className="text-destructive text-sm">{errors.poleNo.message}</p>
            )}
          </div>

          <div className="space-y-2">
            <Label htmlFor="type">Type</Label>
            <Select onValueChange={(value: 'Bulk' | 'Distribution') => setValue('type', value)}>
              <SelectTrigger className="bg-background">
                <SelectValue placeholder="Select Type" />
              </SelectTrigger>
              <SelectContent className="bg-popover border-border">
                <SelectItem value="Bulk">Bulk</SelectItem>
                <SelectItem value="Distribution">Distribution</SelectItem>
              </SelectContent>
            </Select>
            {errors.type && (
              <p className="text-destructive text-sm">Type is required</p>
            )}
          </div>

          <div className="space-y-2">
            <Label htmlFor="locationDetails">Location Details</Label>
            <Textarea
              id="locationDetails"
              placeholder="Detailed location information..."
              className="bg-background"
              {...register('locationDetails', { required: 'Location details are required' })}
            />
            {errors.locationDetails && (
              <p className="text-destructive text-sm">{errors.locationDetails.message}</p>
            )}
          </div>

          <div className="flex gap-3 pt-4">
            <Button 
              type="button" 
              variant="outline" 
              onClick={() => onOpenChange(false)}
              className="flex-1"
            >
              Cancel
            </Button>
            <Button 
              type="submit" 
              disabled={loading}
              className="flex-1 bg-gradient-primary shadow-primary"
            >
              {loading ? 'Adding...' : 'Confirm'}
            </Button>
          </div>
        </form>
      </DialogContent>
    </Dialog>
  );
}