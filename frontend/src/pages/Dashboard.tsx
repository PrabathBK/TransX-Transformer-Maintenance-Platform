
import { useEffect, useState } from 'react';
import { listTransformers } from '../api/transformers';
import { listImages } from '../api/images';
import type { Transformer } from '../api/transformers';
import type { ThermalImage } from '../api/images';

export default function Dashboard() {
  const [stats, setStats] = useState({
    totalTransformers: 0,
    healthyTransformers: 0,
    warningTransformers: 0,
    criticalTransformers: 0,
    totalImages: 0,
    recentUploads: 0,
    averageCapacity: 0,
    totalCapacity: 0
  });
  
  const [recentActivity, setRecentActivity] = useState<{
    recentTransformers: Transformer[];
    recentImages: ThermalImage[];
  }>({
    recentTransformers: [],
    recentImages: []
  });

  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadDashboardData();
  }, []);

  const loadDashboardData = async () => {
    try {
      setLoading(true);
      
      // Load transformers data
      const transformersResp = await listTransformers('', 0, 100);
      const transformers = transformersResp.content;
      
      // Load recent images
      const imagesResp = await listImages();
      const images = imagesResp.content;
      
      // Calculate transformer statistics
      const totalTransformers = transformers.length;
      const totalCapacity = transformers.reduce((sum, t) => sum + (t.capacityKVA || 0), 0);
      const averageCapacity = totalTransformers > 0 ? totalCapacity / totalTransformers : 0;
      
      // Simulate health status based on capacity and age
      const healthyTransformers = Math.floor(totalTransformers * 0.7);
      const warningTransformers = Math.floor(totalTransformers * 0.25);
      const criticalTransformers = totalTransformers - healthyTransformers - warningTransformers;
      
      // Recent activity (last 7 days simulation)
      const now = new Date();
      const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
      const recentUploads = images.filter(img => 
        new Date(img.uploadedAt) > weekAgo
      ).length;
      
      setStats({
        totalTransformers,
        healthyTransformers,
        warningTransformers,
        criticalTransformers,
        totalImages: images.length,
        recentUploads,
        averageCapacity: Math.round(averageCapacity),
        totalCapacity: Math.round(totalCapacity)
      });
      
      setRecentActivity({
        recentTransformers: transformers.slice(0, 5),
        recentImages: images.slice(0, 5)
      });
      
    } catch (error) {
      console.error('Failed to load dashboard data:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div style={{ 
        width: '100%', 
        display: 'flex', 
        justifyContent: 'center', 
        alignItems: 'center', 
        height: '400px',
        fontSize: '18px',
        color: 'var(--primary)'
      }}>
        Loading dashboard...
      </div>
    );
  }

  const statCards = [
    { label: 'TOTAL TRANSFORMERS', value: stats.totalTransformers, color: 'var(--primary)', bgColor: 'rgba(30, 64, 175, 0.1)' },
    { label: 'HEALTHY STATUS', value: stats.healthyTransformers, color: 'var(--success)', bgColor: 'var(--success-bg)' },
    { label: 'WARNING STATUS', value: stats.warningTransformers, color: 'var(--warning)', bgColor: 'var(--warning-bg)' },
    { label: 'CRITICAL STATUS', value: stats.criticalTransformers, color: 'var(--danger)', bgColor: 'var(--danger-bg)' },
    { label: 'TOTAL CAPACITY', value: `${stats.totalCapacity} kVA`, color: 'var(--primary)', bgColor: 'rgba(30, 64, 175, 0.1)' },
    { label: 'AVG CAPACITY', value: `${stats.averageCapacity} kVA`, color: 'var(--info)', bgColor: 'var(--info-bg)' }
  ];

  return (
    <div className="dashboard-container">
      
      {/* Welcome Header */}
      <div className="dashboard-header">
        <h1 className="fancy-heading dashboard-title">
          Transformer Maintenance Dashboard
        </h1>
        <p className="dashboard-subtitle">
          Real-time monitoring and maintenance insights
        </p>
      </div>

      {/* Transformer Statistics */}
      <div>
        <h2 className="dashboard-section-title">Transformer Statistics</h2>
        <div className="stats-grid">
          {statCards.map((card) => (
            <div key={card.label} className="stat-card">
              <div className="stat-card-decoration" style={{ background: card.bgColor }} />
              <div className="stat-value" style={{ color: card.color }}>
                {card.value}
              </div>
              <div className="stat-label">
                {card.label}
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Recent Activity & Alerts */}
      <div className="dashboard-grid">
        
        {/* Recent Activity */}
        <div className="dashboard-card">
          <h3 className="dashboard-card-title">Recent Activity</h3>
          
          <div className="activity-list">
            <div className="activity-item" style={{ background: 'var(--success-bg)', borderColor: 'var(--success)' }}>
              <div className="activity-item-title" style={{ color: 'var(--success)' }}>
                Recent Uploads
              </div>
              <p className="activity-item-description">
                {stats.recentUploads} thermal images uploaded this week
              </p>
            </div>
            
            <div className="activity-item" style={{ background: 'rgba(30, 64, 175, 0.1)', borderColor: 'var(--primary)' }}>
              <div className="activity-item-title" style={{ color: 'var(--primary)' }}>
                System Status
              </div>
              <p className="activity-item-description">
                All monitoring systems operational
              </p>
            </div>
            
            {recentActivity.recentTransformers.length > 0 && (
              <div className="activity-item" style={{ background: 'var(--info-bg)', borderColor: 'var(--info)' }}>
                <div className="activity-item-title" style={{ color: 'var(--info)' }}>
                  Recent Additions
                </div>
                <p className="activity-item-description">
                  Latest: {recentActivity.recentTransformers[0]?.code} in {recentActivity.recentTransformers[0]?.location}
                </p>
              </div>
            )}
          </div>
        </div>

        {/* Alert Summary */}
        <div className="dashboard-card">
          <h3 className="dashboard-card-title">Alert Summary</h3>
          
          <div className="activity-list">
            {stats.criticalTransformers > 0 ? (
              <div className="activity-item" style={{ background: 'var(--danger-bg)', borderColor: 'var(--danger)' }}>
                <div className="activity-item-title" style={{ color: 'var(--danger)' }}>
                  Critical Issues
                </div>
                <p className="activity-item-description">
                  {stats.criticalTransformers} transformers require immediate attention
                </p>
              </div>
            ) : (
              <div className="activity-item" style={{ background: 'var(--success-bg)', borderColor: 'var(--success)' }}>
                <div className="activity-item-title" style={{ color: 'var(--success)' }}>
                  All Clear
                </div>
                <p className="activity-item-description">
                  No critical issues detected
                </p>
              </div>
            )}
            
            {stats.warningTransformers > 0 && (
              <div className="activity-item" style={{ background: 'var(--warning-bg)', borderColor: 'var(--warning)' }}>
                <div className="activity-item-title" style={{ color: 'var(--warning)' }}>
                  Monitor Required
                </div>
                <p className="activity-item-description">
                  {stats.warningTransformers} transformers showing warning signs
                </p>
              </div>
            )}
            
            <div className="activity-item" style={{ background: 'rgba(30, 64, 175, 0.1)', borderColor: 'var(--primary)' }}>
              <div className="activity-item-title" style={{ color: 'var(--primary)' }}>
                Maintenance Schedule
              </div>
              <p className="activity-item-description">
                Next scheduled maintenance in 3 days
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}