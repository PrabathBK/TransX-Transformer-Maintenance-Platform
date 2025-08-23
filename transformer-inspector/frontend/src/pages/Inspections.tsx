import { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { 
  Table, 
  TableBody, 
  TableCell, 
  TableHead, 
  TableHeader, 
  TableRow 
} from '@/components/ui/table';
import { DashboardLayout } from '@/components/layout/DashboardLayout';
import { NewInspectionDialog } from '@/components/inspections/NewInspectionDialog';
import { apiService } from '@/services/api';
import { Inspection, Transformer } from '@/types/transformer';
import { 
  Plus, 
  Search,
  Filter,
  Eye,
  Calendar,
  Clock
} from 'lucide-react';
import { format } from 'date-fns';

export default function Inspections() {
  const [inspections, setInspections] = useState<Inspection[]>([]);
  const [transformers, setTransformers] = useState<Transformer[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [showAddDialog, setShowAddDialog] = useState(false);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      const [inspectionData, transformerData] = await Promise.all([
        apiService.getInspections(),
        apiService.getTransformers()
      ]);
      setInspections(inspectionData);
      setTransformers(transformerData);
    } catch (error) {
      console.error('Failed to load inspections:', error);
    } finally {
      setLoading(false);
    }
  };

  const getTransformerDetails = (transformerId: string) => {
    return transformers.find(t => t.id === transformerId);
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'Completed':
        return 'bg-success/20 text-success border-success/30';
      case 'In Progress':
        return 'bg-accent/20 text-accent border-accent/30';
      case 'Pending':
        return 'bg-warning/20 text-warning border-warning/30';
      default:
        return 'bg-muted/20 text-muted-foreground border-muted/30';
    }
  };

  const filteredInspections = inspections.filter(inspection => {
    const transformer = getTransformerDetails(inspection.transformerId);
    return (
      inspection.inspectionNo.toLowerCase().includes(searchTerm.toLowerCase()) ||
      (transformer && transformer.transformerNo.toLowerCase().includes(searchTerm.toLowerCase()))
    );
  });

  if (loading) {
    return (
      <DashboardLayout>
        <div className="flex items-center justify-center h-64">
          <div className="animate-pulse text-muted-foreground">Loading inspections...</div>
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
            <h1 className="text-3xl font-bold">All Inspections</h1>
            <p className="text-muted-foreground mt-2">Monitor thermal imaging inspections and maintenance schedules</p>
          </div>
          <div className="flex items-center gap-3">
            <Button variant="outline" className="gap-2">
              <Filter className="w-4 h-4" />
              Filter
            </Button>
            <Button onClick={() => setShowAddDialog(true)} className="gap-2 bg-gradient-primary shadow-primary">
              <Plus className="w-4 h-4" />
              Add Inspection
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
                  placeholder="Search Transformer"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="pl-10 bg-background"
                />
              </div>
              <Button variant="outline">All Time</Button>
              <Button variant="ghost" className="text-primary">Reset Filters</Button>
            </div>
          </CardContent>
        </Card>

        {/* Inspections Table */}
        <Card className="bg-gradient-surface border-border">
          <CardHeader>
            <CardTitle className="flex items-center justify-between">
              <span>Inspections</span>
              <div className="flex items-center gap-4">
                <Button variant="ghost" className="gap-2 text-accent">
                  <Calendar className="w-4 h-4" />
                  Transformers
                </Button>
                <Button variant="ghost" className="gap-2 text-primary">
                  <Clock className="w-4 h-4" />
                  Inspections
                </Button>
              </div>
            </CardTitle>
          </CardHeader>
          <CardContent>
            <Table>
              <TableHeader>
                <TableRow className="border-border">
                  <TableHead>Transformer No.</TableHead>
                  <TableHead>Inspection No</TableHead>
                  <TableHead>Inspected Date</TableHead>
                  <TableHead>Maintenance Date</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead className="w-16">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredInspections.map((inspection) => {
                  const transformer = getTransformerDetails(inspection.transformerId);
                  return (
                    <TableRow key={inspection.id} className="border-border">
                      <TableCell className="font-medium">
                        {transformer?.transformerNo || 'Unknown'}
                      </TableCell>
                      <TableCell>{inspection.inspectionNo}</TableCell>
                      <TableCell>
                        {format(new Date(inspection.inspectedDate), 'dd MMM, yyyy HH:mm')}
                      </TableCell>
                      <TableCell>
                        {inspection.maintenanceDate 
                          ? format(new Date(inspection.maintenanceDate), 'dd MMM, yyyy HH:mm')
                          : '-'
                        }
                      </TableCell>
                      <TableCell>
                        <Badge 
                          variant="secondary"
                          className={getStatusColor(inspection.status)}
                        >
                          {inspection.status}
                        </Badge>
                      </TableCell>
                      <TableCell>
                        <Button variant="ghost" size="sm" className="gap-2 text-primary">
                          <Eye className="w-4 h-4" />
                          View
                        </Button>
                      </TableCell>
                    </TableRow>
                  );
                })}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      </div>

      <NewInspectionDialog 
        open={showAddDialog} 
        onOpenChange={setShowAddDialog}
        transformers={transformers}
        onSuccess={loadData}
      />
    </DashboardLayout>
  );
}