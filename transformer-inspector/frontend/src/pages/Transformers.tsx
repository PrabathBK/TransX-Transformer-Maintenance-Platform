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
import { AddTransformerDialog } from '@/components/transformers/AddTransformerDialog';
import { apiService } from '@/services/api';
import { Transformer } from '@/types/transformer';
import { 
  Star, 
  Plus, 
  Search,
  Filter,
  Eye,
  Edit,
  Trash2,
  MoreHorizontal
} from 'lucide-react';
import { 
  DropdownMenu, 
  DropdownMenuContent, 
  DropdownMenuItem, 
  DropdownMenuTrigger 
} from '@/components/ui/dropdown-menu';

export default function Transformers() {
  const [transformers, setTransformers] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [showAddDialog, setShowAddDialog] = useState(false);

  useEffect(() => {
    loadTransformers();
    // eslint-disable-next-line
  }, []);

  const loadTransformers = async () => {
    setLoading(true);
    try {
      // Call backend without pagination
      const response: Transformer[] | { content: Transformer[] } = await apiService.getTransformers();
      // If response is array, use directly; if object, use .content
      if (Array.isArray(response)) {
        setTransformers(response);
      } else {
        setTransformers(response.content || []);
      }
    } catch (error) {
      console.error('Failed to load transformers:', error);
    } finally {
      setLoading(false);
    }
  };

  // Star toggle logic is kept for future, but backend does not provide isStarred field in response
  const handleStarToggle = async (id: string) => {
    // No-op or implement if backend supports starring
  };

  const handleDelete = async (id: string) => {
    if (window.confirm('Are you sure you want to delete this transformer?')) {
      try {
        await apiService.deleteTransformer(id);
        // Reload after delete
        loadTransformers();
      } catch (error) {
        console.error('Failed to delete transformer:', error);
      }
    }
  };

  // Map backend fields to UI fields
  const filteredTransformers = transformers.filter(transformer =>
    (transformer.code?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      transformer.region?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      transformer.poleNo?.toLowerCase().includes(searchTerm.toLowerCase()))
  );

  if (loading) {
    return (
      <DashboardLayout>
        <div className="flex items-center justify-center h-64">
          <div className="animate-pulse text-muted-foreground">Loading transformers...</div>
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
            <h1 className="text-3xl font-bold">Transformers</h1>
            <p className="text-muted-foreground mt-2">Manage all transformer assets and their details</p>
          </div>
          <div className="flex items-center gap-3">
            <Button variant="outline" className="gap-2">
              <Filter className="w-4 h-4" />
              Filter
            </Button>
            <Button onClick={() => setShowAddDialog(true)} className="gap-2 bg-gradient-primary shadow-primary">
              <Plus className="w-4 h-4" />
              Add Transformer
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
              <Button variant="outline">All Regions</Button>
              <Button variant="outline">All Types</Button>
              <Button variant="ghost" className="text-primary">Reset filters</Button>
            </div>
          </CardContent>
        </Card>

        {/* Transformers Table */}
        <Card className="bg-gradient-surface border-border">
          <CardHeader>
            <CardTitle className="flex items-center justify-between">
              <span>Transformers</span>
              <Badge variant="secondary" className="bg-primary/20 text-primary border-primary/30">
                {filteredTransformers.length} transformers
              </Badge>
            </CardTitle>
          </CardHeader>
          <CardContent>
            <Table>
              <TableHeader>
                <TableRow className="border-border">
                  {/* Star column removed, backend does not provide isStarred */}
                  <TableHead>Transformer No.</TableHead>
                  <TableHead>Pole No.</TableHead>
                  <TableHead>Region</TableHead>
                  <TableHead>Type</TableHead>
                  <TableHead>Location</TableHead>
                  <TableHead>Capacity (KVA)</TableHead>
                  <TableHead className="w-16">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredTransformers.map((transformer) => (
                  <TableRow key={transformer.id} className="border-border">
                    {/* Star column removed */}
                    <TableCell className="font-medium">{transformer.code}</TableCell>
                    <TableCell>{transformer.poleNo}</TableCell>
                    <TableCell>{transformer.region}</TableCell>
                    <TableCell>
                      <Badge 
                        variant="secondary"
                        className={transformer.type === 'Bulk' 
                          ? 'bg-accent/20 text-accent border-accent/30' 
                          : 'bg-success/20 text-success border-success/30'
                        }
                      >
                        {transformer.type}
                      </Badge>
                    </TableCell>
                    <TableCell className="max-w-[200px] truncate">{transformer.locationDetails || transformer.location}</TableCell>
                    <TableCell>{transformer.capacityKVA}</TableCell>
                    <TableCell>
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <Button variant="ghost" size="icon" className="w-8 h-8">
                            <MoreHorizontal className="w-4 h-4" />
                          </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end" className="bg-popover border-border">
                          <DropdownMenuItem className="flex items-center gap-2">
                            <Eye className="w-4 h-4" />
                            View Details
                          </DropdownMenuItem>
                          <DropdownMenuItem className="flex items-center gap-2">
                            <Edit className="w-4 h-4" />
                            Edit
                          </DropdownMenuItem>
                          <DropdownMenuItem 
                            className="flex items-center gap-2 text-destructive"
                            onClick={() => handleDelete(transformer.id)}
                          >
                            <Trash2 className="w-4 h-4" />
                            Delete
                          </DropdownMenuItem>
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
            {/* No pagination controls */}
          </CardContent>
        </Card>
      </div>

      <AddTransformerDialog 
        open={showAddDialog} 
        onOpenChange={setShowAddDialog}
        onSuccess={loadTransformers}
      />
    </DashboardLayout>
  );
}