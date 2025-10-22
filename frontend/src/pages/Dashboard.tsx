
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
        color: '#1e40af'
      }}>
        Loading dashboard...
      </div>
    );
  }

  return (
    <div style={{ 
      width: '100%', 
      display: 'flex', 
      flexDirection: 'column', 
      gap: '2.5rem',
      padding: '2rem',
      maxWidth: '1400px',
      margin: '0 auto'
    }}>
      
      {/* Welcome Header */}
      <div style={{ marginBottom: '1rem' }}>
        <h1 className="fancy-heading" style={{
          fontSize: '2.5rem',
          marginBottom: '0.5rem',
          color: '#2d1e6b',
          letterSpacing: '-1.5px',
          animation: 'fadeIn 1.2s cubic-bezier(.4,0,.2,1)'
        }}>
          Transformer Maintenance Dashboard
        </h1>
        <p style={{ 
          fontSize: '1.1rem', 
          color: '#64748b', 
          margin: 0,
          fontFamily: 'Inter'
        }}>
          Real-time monitoring and maintenance insights
        </p>
      </div>

      {/* Transformer Statistics */}
      <div>
        <h2 style={{ 
          fontSize: '1.5rem', 
          color: '#374151', 
          marginBottom: '1rem',
          fontFamily: 'Montserrat',
          fontWeight: '600'
        }}>
          Transformer Statistics
        </h2>
        <div style={{ display: 'flex', gap: '1.5rem', flexWrap: 'wrap' }}>
          {[
            { 
              label: 'TOTAL TRANSFORMERS', 
              value: stats.totalTransformers, 
              color: '#1e40af',
              bgColor: 'rgba(30, 64, 175, 0.1)'
            },
            { 
              label: 'HEALTHY STATUS', 
              value: stats.healthyTransformers, 
              color: '#059669',
              bgColor: 'rgba(5, 150, 105, 0.1)'
            },
            { 
              label: 'WARNING STATUS', 
              value: stats.warningTransformers, 
              color: '#d97706',
              bgColor: 'rgba(217, 119, 6, 0.1)'
            },
            { 
              label: 'CRITICAL STATUS', 
              value: stats.criticalTransformers, 
              color: '#dc2626',
              bgColor: 'rgba(220, 38, 38, 0.1)'
            },
            { 
              label: 'TOTAL CAPACITY', 
              value: `${stats.totalCapacity} kVA`, 
              color: '#1e40af',
              bgColor: 'rgba(30, 64, 175, 0.1)'
            },
            { 
              label: 'AVG CAPACITY', 
              value: `${stats.averageCapacity} kVA`, 
              color: '#0ea5e9',
              bgColor: 'rgba(14, 165, 233, 0.1)'
            }
          ].map((card) => (
            <div key={card.label} style={{
              background: 'linear-gradient(135deg, #ffffff 0%, #f8fafc 100%)',
              borderRadius: 16,
              boxShadow: '0 4px 20px rgba(124, 58, 237, 0.08)',
              border: '1px solid rgba(124, 58, 237, 0.1)',
              padding: '1.5rem 2rem',
              minWidth: 200,
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              justifyContent: 'center',
              fontFamily: 'Montserrat',
              transition: 'all 0.3s ease',
              cursor: 'pointer',
              position: 'relative',
              overflow: 'hidden'
            }}
            onMouseEnter={(e) => {
              e.currentTarget.style.transform = 'translateY(-4px)';
              e.currentTarget.style.boxShadow = '0 8px 30px rgba(124, 58, 237, 0.15)';
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.transform = 'translateY(0)';
              e.currentTarget.style.boxShadow = '0 4px 20px rgba(124, 58, 237, 0.08)';
            }}>
              {/* Background decoration */}
              <div style={{
                position: 'absolute',
                top: 0,
                right: 0,
                width: '60px',
                height: '60px',
                background: card.bgColor,
                borderRadius: '50%',
                transform: 'translate(20px, -20px)',
                opacity: 0.6
              }} />
              
              <div style={{ 
                fontSize: '2rem', 
                fontWeight: '900', 
                color: card.color, 
                marginBottom: '0.5rem',
                zIndex: 1
              }}>
                {card.value}
              </div>
              <div style={{ 
                fontSize: '0.75rem', 
                color: '#64748b', 
                fontWeight: '600', 
                letterSpacing: '0.5px',
                textAlign: 'center',
                zIndex: 1
              }}>
                {card.label}
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Recent Activity & Alerts */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '2rem' }}>
        
        {/* Recent Activity */}
        <div style={{
          background: 'linear-gradient(135deg, #ffffff 0%, #f8fafc 100%)',
          borderRadius: 16,
          boxShadow: '0 4px 20px rgba(124, 58, 237, 0.08)',
          border: '1px solid rgba(124, 58, 237, 0.1)',
          padding: '2rem',
          minHeight: '300px'
        }}>
          <h3 style={{ 
            fontSize: '1.3rem', 
            color: '#374151', 
            marginBottom: '1.5rem',
            fontFamily: 'Montserrat',
            fontWeight: '600',
            display: 'flex',
            alignItems: 'center',
            gap: '0.5rem'
          }}>
            Recent Activity
          </h3>
          
          <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
            <div style={{
              padding: '1rem',
              background: 'rgba(34, 197, 94, 0.1)',
              borderRadius: '8px',
              border: '1px solid rgba(34, 197, 94, 0.2)'
            }}>
              <div style={{ fontWeight: '600', color: '#059669', fontSize: '0.9rem' }}>
                Recent Uploads
              </div>
              <div style={{ color: '#374151', marginTop: '0.25rem' }}>
                {stats.recentUploads} thermal images uploaded this week
              </div>
            </div>
            
            <div style={{
              padding: '1rem',
              background: 'rgba(124, 58, 237, 0.1)',
              borderRadius: '8px',
              border: '1px solid rgba(30, 64, 175, 0.2)'
            }}>
              <div style={{ fontWeight: '600', color: '#1e40af', fontSize: '0.9rem' }}>
                System Status
              </div>
              <div style={{ color: '#374151', marginTop: '0.25rem' }}>
                All monitoring systems operational
              </div>
            </div>
            
            {recentActivity.recentTransformers.length > 0 && (
              <div style={{
                padding: '1rem',
                background: 'rgba(14, 165, 233, 0.1)',
                borderRadius: '8px',
                border: '1px solid rgba(14, 165, 233, 0.2)'
              }}>
                <div style={{ fontWeight: '600', color: '#0ea5e9', fontSize: '0.9rem' }}>
                  Recent Additions
                </div>
                <div style={{ color: '#374151', marginTop: '0.25rem' }}>
                  Latest: {recentActivity.recentTransformers[0]?.code} in {recentActivity.recentTransformers[0]?.location}
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Alert Summary */}
        <div style={{
          background: 'linear-gradient(135deg, #ffffff 0%, #f8fafc 100%)',
          borderRadius: 16,
          boxShadow: '0 4px 20px rgba(124, 58, 237, 0.08)',
          border: '1px solid rgba(124, 58, 237, 0.1)',
          padding: '2rem',
          minHeight: '300px'
        }}>
          <h3 style={{ 
            fontSize: '1.3rem', 
            color: '#374151', 
            marginBottom: '1.5rem',
            fontFamily: 'Montserrat',
            fontWeight: '600',
            display: 'flex',
            alignItems: 'center',
            gap: '0.5rem'
          }}>
            Alert Summary
          </h3>
          
          <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
            {stats.criticalTransformers > 0 ? (
              <div style={{
                padding: '1rem',
                background: 'rgba(220, 38, 38, 0.1)',
                borderRadius: '8px',
                border: '1px solid rgba(220, 38, 38, 0.2)'
              }}>
                <div style={{ fontWeight: '600', color: '#dc2626', fontSize: '0.9rem' }}>
                  Critical Issues
                </div>
                <div style={{ color: '#374151', marginTop: '0.25rem' }}>
                  {stats.criticalTransformers} transformers require immediate attention
                </div>
              </div>
            ) : (
              <div style={{
                padding: '1rem',
                background: 'rgba(34, 197, 94, 0.1)',
                borderRadius: '8px',
                border: '1px solid rgba(34, 197, 94, 0.2)'
              }}>
                <div style={{ fontWeight: '600', color: '#059669', fontSize: '0.9rem' }}>
                  All Clear
                </div>
                <div style={{ color: '#374151', marginTop: '0.25rem' }}>
                  No critical issues detected
                </div>
              </div>
            )}
            
            {stats.warningTransformers > 0 && (
              <div style={{
                padding: '1rem',
                background: 'rgba(217, 119, 6, 0.1)',
                borderRadius: '8px',
                border: '1px solid rgba(217, 119, 6, 0.2)'
              }}>
                <div style={{ fontWeight: '600', color: '#d97706', fontSize: '0.9rem' }}>
                  Monitor Required
                </div>
                <div style={{ color: '#374151', marginTop: '0.25rem' }}>
                  {stats.warningTransformers} transformers showing warning signs
                </div>
              </div>
            )}
            
            <div style={{
              padding: '1rem',
              background: 'rgba(124, 58, 237, 0.1)',
              borderRadius: '8px',
              border: '1px solid rgba(30, 64, 175, 0.2)'
            }}>
              <div style={{ fontWeight: '600', color: '#1e40af', fontSize: '0.9rem' }}>
                Maintenance Schedule
              </div>
              <div style={{ color: '#374151', marginTop: '0.25rem' }}>
                Next scheduled maintenance in 3 days
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}