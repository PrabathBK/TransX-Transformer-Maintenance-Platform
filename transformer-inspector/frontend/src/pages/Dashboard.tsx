import { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { DashboardLayout } from '@/components/layout/DashboardLayout';
import { apiService } from '@/services/api';
import { Transformer, Inspection } from '@/types/transformer';
import { 
  Zap, 
  Camera, 
  AlertTriangle, 
  CheckCircle, 
  Clock,
  TrendingUp,
  Filter,
  Plus
} from 'lucide-react';
import { Link } from 'react-router-dom';

export default function Dashboard() {
  const [transformers, setTransformers] = useState<Transformer[]>([]);
  const [inspections, setInspections] = useState<Inspection[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadData = async () => {
      try {
        const [transformerData, inspectionData] = await Promise.all([
          apiService.getTransformers(),
          apiService.getInspections()
        ]);
        setTransformers(transformerData);
        setInspections(inspectionData);
      } catch (error) {
        console.error('Failed to load dashboard data:', error);
      } finally {
        setLoading(false);
      }
    };

    loadData();
  }, []);

  const stats = {
    totalTransformers: transformers.length,
    activeInspections: inspections.filter(i => i.status === 'In Progress').length,
    completedInspections: inspections.filter(i => i.status === 'Completed').length,
    pendingInspections: inspections.filter(i => i.status === 'Pending').length,
  };

  const recentActivity = [
    {
      id: 1,
      type: 'alert',
      title: 'Temperature Threshold Exceeded',
      description: 'Transformer AZ-8070 in Nugegoda has exceeded temperature threshold (105°C). Immediate action required.',
      time: '25-04:32 AM',
      icon: AlertTriangle,
      color: 'text-warning'
    },
    {
      id: 2,
      type: 'success',
      title: 'Maintenance Completed',
      description: 'Scheduled maintenance for Transformer AZ-5678 in Nugegoda has been completed successfully. All parameters normal.',
      time: '24, 2025-04:32 AM',
      icon: CheckCircle,
      color: 'text-success'
    },
    {
      id: 3,
      type: 'warning',
      title: 'Unusual Vibration Detected',
      description: 'Warning: Unusual Vibration Detected',
      time: '2 hours ago',
      icon: AlertTriangle,
      color: 'text-warning'
    }
  ];

  if (loading) {
    return (
      <DashboardLayout>
        <div className="flex items-center justify-center h-64">
          <div className="animate-pulse text-muted-foreground">Loading dashboard...</div>
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
            <h1 className="text-3xl font-bold">Transformer</h1>
            <p className="text-muted-foreground mt-2">Monitor and manage transformer health across all regions</p>
          </div>
          <div className="flex items-center gap-3">
            <Button variant="outline" className="gap-2">
              <Filter className="w-4 h-4" />
              Filter
            </Button>
            <Link to="/transformers/new">
              <Button className="gap-2 bg-gradient-primary shadow-primary">
                <Plus className="w-4 h-4" />
                New Inspection
              </Button>
            </Link>
          </div>
        </div>

        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <Card className="bg-gradient-surface border-border">
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-muted-foreground">Total Transformers</p>
                  <p className="text-2xl font-bold">{stats.totalTransformers}</p>
                </div>
                <div className="w-12 h-12 bg-primary/20 rounded-xl flex items-center justify-center">
                  <Zap className="w-6 h-6 text-primary" />
                </div>
              </div>
              <div className="mt-4 flex items-center gap-2">
                <Badge variant="secondary" className="text-xs bg-success/20 text-success border-success/30">
                  1428 Active
                </Badge>
              </div>
            </CardContent>
          </Card>

          <Card className="bg-gradient-surface border-border">
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-muted-foreground">Active Inspections</p>
                  <p className="text-2xl font-bold">{stats.activeInspections}</p>
                </div>
                <div className="w-12 h-12 bg-accent/20 rounded-xl flex items-center justify-center">
                  <Camera className="w-6 h-6 text-accent" />
                </div>
              </div>
              <div className="mt-4 flex items-center gap-2">
                <Badge variant="secondary" className="text-xs bg-accent/20 text-accent border-accent/30">
                  59 In Progress
                </Badge>
              </div>
            </CardContent>
          </Card>

          <Card className="bg-gradient-surface border-border">
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-muted-foreground">Pending</p>
                  <p className="text-2xl font-bold">{stats.pendingInspections}</p>
                </div>
                <div className="w-12 h-12 bg-warning/20 rounded-xl flex items-center justify-center">
                  <Clock className="w-6 h-6 text-warning" />
                </div>
              </div>
              <div className="mt-4 flex items-center gap-2">
                <Badge variant="secondary" className="text-xs bg-warning/20 text-warning border-warning/30">
                  8 Overdue
                </Badge>
              </div>
            </CardContent>
          </Card>

          <Card className="bg-gradient-surface border-border">
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-muted-foreground">Efficiency</p>
                  <p className="text-2xl font-bold">94.2%</p>
                </div>
                <div className="w-12 h-12 bg-success/20 rounded-xl flex items-center justify-center">
                  <TrendingUp className="w-6 h-6 text-success" />
                </div>
              </div>
              <div className="mt-4 flex items-center gap-2">
                <Badge variant="secondary" className="text-xs bg-success/20 text-success border-success/30">
                  +2.1% this month
                </Badge>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Recent Activity */}
        <Card className="bg-gradient-surface border-border">
          <CardHeader>
            <CardTitle className="flex items-center justify-between">
              Recent Activity
              <Button variant="ghost" size="sm">View All</Button>
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            {recentActivity.map((activity) => {
              const Icon = activity.icon;
              return (
                <div key={activity.id} className="flex items-start gap-4 p-4 rounded-lg bg-background/50 border border-border/50">
                  <div className={`w-10 h-10 rounded-lg bg-background border border-border flex items-center justify-center ${activity.color}`}>
                    <Icon className="w-5 h-5" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <h4 className="font-medium text-foreground">{activity.title}</h4>
                    <p className="text-sm text-muted-foreground mt-1">{activity.description}</p>
                    <p className="text-xs text-muted-foreground/70 mt-2">{activity.time}</p>
                  </div>
                </div>
              );
            })}
          </CardContent>
        </Card>
      </div>
    </DashboardLayout>
  );
}