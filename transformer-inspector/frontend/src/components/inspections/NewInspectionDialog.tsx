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
import { Calendar } from '@/components/ui/calendar';
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover';
import { apiService } from '@/services/api';
import { Transformer } from '@/types/transformer';
import { useToast } from '@/hooks/use-toast';
import { format } from 'date-fns';
import { Calendar as CalendarIcon, Clock } from 'lucide-react';
import { cn } from '@/lib/utils';

interface NewInspectionDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  transformers: Transformer[];
  onSuccess: () => void;
}

interface FormData {
  transformerId: string;
  inspectedDate: Date;
  inspectedBy: string;
  time: string;
}

export function NewInspectionDialog({ 
  open, 
  onOpenChange, 
  transformers, 
  onSuccess 
}: NewInspectionDialogProps) {
  const [loading, setLoading] = useState(false);
  const [selectedDate, setSelectedDate] = useState<Date>();
  const [selectedTime, setSelectedTime] = useState<string>('');
  const { toast } = useToast();
  const { register, handleSubmit, reset, setValue, watch, formState: { errors } } = useForm<FormData>();

  const onSubmit = async (data: FormData) => {
    if (!selectedDate) {
      toast({
        title: "Error",
        description: "Please select an inspection date",
        variant: "destructive",
      });
      return;
    }

    if (!selectedTime) {
      toast({
        title: "Error",
        description: "Please select an inspection time",
        variant: "destructive",
      });
      return;
    }

    setLoading(true);
    try {
      // Combine date and time
      const [hours, minutes] = selectedTime.split(':');
      const inspectionDateTime = new Date(selectedDate);
      inspectionDateTime.setHours(parseInt(hours), parseInt(minutes));

      await apiService.createInspection({
        transformerId: data.transformerId,
        inspectedDate: inspectionDateTime.toISOString(),
        status: 'Pending',
        inspectedBy: data.inspectedBy,
        thermalImages: [],
      });

      toast({
        title: "Success",
        description: "Inspection scheduled successfully",
      });
      
      reset();
      setSelectedDate(undefined);
      setSelectedTime('');
      onOpenChange(false);
      onSuccess();
    } catch (error) {
      console.error('Failed to create inspection:', error);
      toast({
        title: "Error",
        description: "Failed to schedule inspection. Please try again.",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  const timeOptions = [
    '07:00', '07:30', '08:00', '08:30', '09:00', '09:30',
    '10:00', '10:30', '11:00', '11:30', '12:00', '12:30',
    '13:00', '13:30', '14:00', '14:30', '15:00', '15:30',
    '16:00', '16:30', '17:00', '17:30', '18:00'
  ];

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="bg-card border-border max-w-md">
        <DialogHeader>
          <DialogTitle className="text-xl font-semibold">New Inspection</DialogTitle>
        </DialogHeader>
        
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="transformerId">Transformer No</Label>
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
            {errors.transformerId && (
              <p className="text-destructive text-sm">Transformer selection is required</p>
            )}
          </div>

          <div className="space-y-2">
            <Label>Date of Inspection</Label>
            <Popover>
              <PopoverTrigger asChild>
                <Button
                  variant="outline"
                  className={cn(
                    "w-full justify-start text-left font-normal bg-background",
                    !selectedDate && "text-muted-foreground"
                  )}
                >
                  <CalendarIcon className="mr-2 h-4 w-4" />
                  {selectedDate ? format(selectedDate, "PPP") : "Pick a date"}
                </Button>
              </PopoverTrigger>
              <PopoverContent className="w-auto p-0 bg-popover border-border" align="start">
                <Calendar
                  mode="single"
                  selected={selectedDate}
                  onSelect={setSelectedDate}
                  initialFocus
                  className="bg-popover"
                />
              </PopoverContent>
            </Popover>
          </div>

          <div className="space-y-2">
            <Label>Time</Label>
            <Select onValueChange={setSelectedTime}>
              <SelectTrigger className="bg-background">
                <SelectValue placeholder="Select Time" />
              </SelectTrigger>
              <SelectContent className="bg-popover border-border">
                {timeOptions.map((time) => (
                  <SelectItem key={time} value={time}>
                    {time}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          <div className="space-y-2">
            <Label htmlFor="inspectedBy">Inspected By</Label>
            <Input
              id="inspectedBy"
              placeholder="Inspector ID or Name"
              className="bg-background"
              {...register('inspectedBy', { required: 'Inspector information is required' })}
            />
            {errors.inspectedBy && (
              <p className="text-destructive text-sm">{errors.inspectedBy.message}</p>
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
              {loading ? 'Creating...' : 'Confirm'}
            </Button>
          </div>
        </form>
      </DialogContent>
    </Dialog>
  );
}