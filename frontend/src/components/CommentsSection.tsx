// src/components/CommentsSection.tsx
import { useState, useEffect } from 'react';
import { addInspectionComment, getInspectionComments } from '../api/inspectionComments';
import type { InspectionComment } from '../api/inspectionComments';

interface CommentsSectionProps {
  inspectionId: string;
}

export default function CommentsSection({ inspectionId }: CommentsSectionProps) {
  const [comments, setComments] = useState<InspectionComment[]>([]);
  const [newComment, setNewComment] = useState('');
  const [author, setAuthor] = useState('admin'); // Default author - could come from auth context
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitError, setSubmitError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [loadError, setLoadError] = useState<string | null>(null);

  // Load comments on component mount
  useEffect(() => {
    loadComments();
  }, [inspectionId]);

  const loadComments = async () => {
    try {
      setLoading(true);
      setLoadError(null);
      const commentsData = await getInspectionComments(inspectionId);
      setComments(commentsData);
    } catch (e: any) {
      setLoadError(e?.message || 'Failed to load comments');
    } finally {
      setLoading(false);
    }
  };

  const handleSubmitComment = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!newComment.trim()) {
      setSubmitError('Please enter a comment');
      return;
    }

    try {
      setIsSubmitting(true);
      setSubmitError(null);
      
      await addInspectionComment({
        inspectionId,
        commentText: newComment.trim(),
        author: author.trim()
      });
      
      setNewComment('');
      await loadComments(); // Reload comments
    } catch (e: any) {
      setSubmitError(e?.message || 'Failed to add comment');
    } finally {
      setIsSubmitting(false);
    }
  };

  const formatDateTime = (dateStr: string) => {
    const date = new Date(dateStr);
    return date.toLocaleString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  const getTimeAgo = (dateStr: string) => {
    const now = new Date();
    const date = new Date(dateStr);
    const diffInHours = (now.getTime() - date.getTime()) / (1000 * 60 * 60);
    
    if (diffInHours < 1) {
      const diffInMinutes = Math.floor(diffInHours * 60);
      return `${diffInMinutes} minute${diffInMinutes !== 1 ? 's' : ''} ago`;
    } else if (diffInHours < 24) {
      const hours = Math.floor(diffInHours);
      return `${hours} hour${hours !== 1 ? 's' : ''} ago`;
    } else {
      const days = Math.floor(diffInHours / 24);
      return `${days} day${days !== 1 ? 's' : ''} ago`;
    }
  };

  return (
    <div className="comments-section" style={{
      borderRadius: '12px',
      boxShadow: 'var(--shadow-sm)',
      padding: '20px',
      marginTop: '24px'
    }}>
      <h3 className="comments-header" style={{ 
        margin: '0 0 20px 0', 
        fontSize: '18px'
      }}>
        💬 Comments ({comments.length})
      </h3>

      {/* Add New Comment Form */}
      <form onSubmit={handleSubmitComment} style={{ marginBottom: '24px' }}>
        <div style={{ marginBottom: '12px' }}>
          <input
            type="text"
            placeholder="Your name"
            value={author}
            onChange={(e) => setAuthor(e.target.value)}
            style={{
              width: '200px',
              padding: '8px 12px',
              border: '1px solid var(--border-light)',
              borderRadius: '6px',
              fontSize: '14px',
              marginBottom: '8px',
              background: 'var(--bg-input)',
              color: 'var(--text-primary)'
            }}
          />
        </div>
        <textarea
          placeholder="Add a comment..."
          value={newComment}
          onChange={(e) => setNewComment(e.target.value)}
          rows={3}
          className="comment-input"
          style={{
            width: '100%',
            padding: '12px',
            borderRadius: '6px',
            fontSize: '14px',
            lineHeight: '1.5',
            resize: 'vertical',
            fontFamily: 'inherit'
          }}
        />
        
        {submitError && (
          <div style={{ 
            marginTop: '8px', 
            color: '#ef4444', 
            fontSize: '13px',
            display: 'flex',
            alignItems: 'center',
            gap: '4px'
          }}>
            ❌ {submitError}
          </div>
        )}
        
        <div style={{ marginTop: '12px' }}>
          <button
            type="submit"
            disabled={isSubmitting || !newComment.trim()}
            style={{
              padding: '10px 20px',
              borderRadius: '6px',
              border: 'none',
              background: (isSubmitting || !newComment.trim()) ? '#9ca3af' : 'linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%)',
              color: 'white',
              fontSize: '14px',
              fontWeight: '600',
              cursor: (isSubmitting || !newComment.trim()) ? 'not-allowed' : 'pointer',
              display: 'flex',
              alignItems: 'center',
              gap: '6px'
            }}
          >
            {isSubmitting ? '💾 Adding...' : '💬 Add Comment'}
          </button>
        </div>
      </form>

      {/* Comments List */}
      <div>
        {loading && (
          <div style={{ 
            textAlign: 'center', 
            color: 'var(--text-secondary)', 
            fontSize: '14px',
            padding: '20px'
          }}>
            Loading comments...
          </div>
        )}
        
        {loadError && (
          <div style={{ 
            color: '#ef4444', 
            fontSize: '14px',
            padding: '12px',
            background: 'rgba(239, 68, 68, 0.1)',
            border: '1px solid rgba(239, 68, 68, 0.3)',
            borderRadius: '6px'
          }}>
            ❌ {loadError}
          </div>
        )}
        
        {!loading && !loadError && comments.length === 0 && (
          <div className="no-comments" style={{ 
            textAlign: 'center', 
            fontSize: '14px',
            padding: '40px 20px'
          }}>
            No comments yet. Be the first to add a comment!
          </div>
        )}
        
        {comments.map((comment) => (
          <div
            key={comment.id}
            style={{
              border: '1px solid var(--border-light)',
              borderRadius: '8px',
              padding: '16px',
              marginBottom: '12px',
              background: 'var(--bg-tertiary)'
            }}
          >
            <div style={{
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'center',
              marginBottom: '8px'
            }}>
              <div style={{
                display: 'flex',
                alignItems: 'center',
                gap: '8px'
              }}>
                <span style={{
                  fontWeight: '600',
                  color: 'var(--text-primary)',
                  fontSize: '14px'
                }}>
                  👤 {comment.author}
                </span>
                <span style={{
                  color: 'var(--text-secondary)',
                  fontSize: '12px'
                }}>
                  {getTimeAgo(comment.createdAt)}
                </span>
              </div>
              <span style={{
                color: 'var(--text-tertiary)',
                fontSize: '11px'
              }}>
                {formatDateTime(comment.createdAt)}
              </span>
            </div>
            <div style={{
              color: 'var(--text-primary)',
              fontSize: '14px',
              lineHeight: '1.5',
              whiteSpace: 'pre-wrap'
            }}>
              {comment.commentText}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}