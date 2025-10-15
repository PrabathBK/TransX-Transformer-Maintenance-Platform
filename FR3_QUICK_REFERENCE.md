# FR3.1 & FR3.2 - Quick Reference Card

## ✅ Implementation Status

### FR3.1: Interactive Annotation Tools ✅ COMPLETE
- [x] Resize existing markers (Konva Transformer)
- [x] Reposition existing markers (Drag & drop)
- [x] Delete markers (Delete key + buttons)
- [x] Add new markers (Draw mode)
- [x] Track annotation type (created/edited/deleted/approved/rejected)
- [x] Track optional comments/notes
- [x] Track timestamps (createdAt, modifiedAt)
- [x] Track user IDs (createdBy, modifiedBy)

### FR3.2: Metadata and Annotation Persistence ✅ COMPLETE
- [x] All changes captured and saved in backend
- [x] User ID metadata stored and displayed
- [x] Timestamp metadata stored and displayed
- [x] Image ID association (via inspection)
- [x] Transformer ID association (via inspection)
- [x] Action type tracking and display
- [x] Metadata shown in UI with box numbers
- [x] Automatic reload when revisited

---

## 🎨 UI Features

### Annotation Card Layout
```
┌─────────────────────────────────────────┐
│ ① Faulty                         v2     │ ← Box number + Version
│   🤖 AI Detection · 85% confidence      │
│                                         │
│ BBox: (60, 260) → (287, 603)           │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 👤 Created by: AI-YOLOv8           │ │ ← Metadata box
│ │ 🕒 Created: Oct 15, 10:30 AM       │ │
│ │ ✏️ Modified by: inspector@...      │ │
│ │ 🕒 Modified: Oct 15, 2:45 PM       │ │
│ │ ────────────────────────────────── │ │
│ │ 📋 Action: Approved                │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ✓ Approved                             │
│                                         │
│ ─────────────────────────────────────  │
│ 📝 Note:                               │
│ ┌───────────────────────────────────┐ │
│ │ Overheating detected on phase     │ │
│ └───────────────────────────────────┘ │
│                                         │
│ [ 📝 Edit Note ]                       │
└─────────────────────────────────────────┘
```

---

## 🔧 Quick Actions

### Create Annotation
1. Switch to "Draw" mode
2. Click and drag on canvas
3. Release to create
4. ✅ Saved with metadata automatically

### Edit Annotation
1. Switch to "Edit" mode
2. Click annotation to select
3. Drag corners to resize
4. Drag box to move
5. ✅ New version created with metadata

### Delete Annotation
- Press Delete key (when selected), OR
- Click "🗑️ Delete" button
- ✅ Soft deleted, metadata preserved

### Add Comment
1. Click "📝 Add Note" button
2. Type in textarea
3. Click "💾 Save Note"
4. ✅ Creates new version with comment

### Approve/Reject (AI annotations only)
- Click "✓ Approve" or "✗ Reject"
- ✅ Updates action type and metadata

---

## 📊 Metadata Tracked

| Field | When | Where Displayed |
|-------|------|-----------------|
| **Box Number** | Creation | Badge + Canvas |
| **Version** | Creation/Edit | Header badge (v1, v2) |
| **Source** | Creation | Label (🤖 AI / 👤 Manual) |
| **Created By** | Creation | Metadata box |
| **Created At** | Creation | Metadata box |
| **Modified By** | Edit/Approve/Reject | Metadata box |
| **Modified At** | Edit/Approve/Reject | Metadata box |
| **Action Type** | All actions | Metadata box (color-coded) |
| **Comments** | Optional | Comment section |

---

## 🎯 Color Coding

### Fault Types
- 🔴 **Faulty** - Red (#ef4444)
- 🟢 **Loose Joint** - Green (#22c55e)
- 🔵 **Point Overload** - Blue (#3b82f6)
- 🟡 **Potential Faulty** - Orange (#f59e0b)

### Action Types
- 🟢 **Approved** - Green
- 🔴 **Rejected** - Red
- 🔵 **Edited** - Blue
- ⚪ **Created** - Gray

---

## 🧪 Quick Test Checklist

- [ ] Box numbers display in cards
- [ ] Box numbers match canvas
- [ ] Created metadata shows
- [ ] Modified metadata shows (after edit)
- [ ] Action type displays correctly
- [ ] Comments can be added
- [ ] Comments can be edited
- [ ] Version increments on edit
- [ ] Page refresh preserves data
- [ ] Navigate away and back works

---

## 🐛 Troubleshooting

**Box number not showing?**
- Check annotation has `boxNumber` field
- Verify annotation is not old (created before feature)
- Try creating new annotation

**Metadata not displaying?**
- Check browser console for errors
- Verify annotation has `createdBy` and `createdAt`
- Refresh page to reload data

**Comments not saving?**
- Check network tab for API errors
- Verify backend is running
- Check `onUpdateComment` prop is passed

---

## 📞 API Quick Reference

```bash
# Get annotations
GET /api/annotations?inspectionId={id}

# Create/Update annotation
POST /api/annotations
{
  "inspectionId": "uuid",
  "bbox": { "x1": 60, "y1": 260, "x2": 287, "y2": 603 },
  "className": "Faulty",
  "confidence": 0.85,
  "source": "human",
  "userId": "user@example.com",
  "comments": "Optional comment"
}

# Delete annotation
DELETE /api/annotations/{id}?userId=user@example.com

# Approve annotation
POST /api/annotations/{id}/approve?userId=user@example.com

# Reject annotation
POST /api/annotations/{id}/reject
{ "userId": "user@example.com", "reason": "Reason text" }
```

---

## ✨ Key Features

1. **Version Control** - Every edit creates new version
2. **Soft Delete** - Deleted annotations preserved in history
3. **Auto-save** - No manual save button needed
4. **Real-time UI** - Updates after every action
5. **Metadata Tracking** - Complete audit trail
6. **Box Numbering** - Sequential numbering per inspection
7. **Comments** - Optional notes on any annotation
8. **User Tracking** - Who created/modified what and when

---

**Status:** FR3.1 ✅ | FR3.2 ✅ | FR3.3 ⏳  
**Next:** Implement Feedback Export (FR3.3)
