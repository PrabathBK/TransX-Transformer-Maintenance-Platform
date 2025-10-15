# FR3.1 Testing Guide - Interactive Annotation Tools

## 🎯 Quick Start Testing

### Step 1: Verify Services Running
```bash
# Check frontend
curl http://localhost:5173

# Check backend
curl http://localhost:8080/api/transformers

# Check ML service
curl http://localhost:5001/health
```

### Step 2: Open Application
1. Navigate to: `http://localhost:5173`
2. Click "Inspections" in navigation
3. Select any existing inspection (or create new one)

---

## 🧪 Test Scenarios

### **TEST 1: View Existing Annotations with Comments**

**Expected Behavior:**
- Annotations list shows on right side
- Each annotation card displays:
  - Class name (e.g., "Faulty") with color
  - Source indicator (🤖 AI or 👤 Manual)
  - Confidence percentage
  - Bounding box coordinates
  - Version number (v1, v2, etc.)
  - If annotation has comments: 📝 Note section with text
  - Button: "Add Note" (if no comment) or "Edit Note" (if has comment)

**Visual Check:**
```
┌─────────────────────────────────────┐
│ Faulty                      v2      │  ← Class name + version
│ 🤖 AI Detection · 72% confidence    │  ← Source + confidence
│ BBox: (324, 264) → (457, 390)       │  ← Coordinates
│                                     │
│ ✓ Approved                          │  ← Status (if applicable)
│                                     │
│ ────────────────────────────────── │  ← Separator line
│ 📝 Note:                            │  ← Comment label
│ ┌─────────────────────────────────┐ │
│ │ This shows overheating pattern  │ │  ← Comment text
│ └─────────────────────────────────┘ │
│                                     │
│ [ 📝 Edit Note ]                    │  ← Edit button
└─────────────────────────────────────┘
```

---

### **TEST 2: Add Comment to Annotation Without Comments**

**Steps:**
1. Find annotation card without comment (only "Add Note" button visible)
2. Click "📝 Add Note" button
3. ✅ Textarea should expand
4. Type test comment: "This is a test comment for annotation validation"
5. Click "💾 Save Note" button
6. ✅ Button should show "💾 Saving..." briefly
7. ✅ Textarea should collapse
8. ✅ Comment should now display in gray box
9. ✅ Button should change to "📝 Edit Note"

**What to Check:**
- [ ] Textarea expands when clicking "Add Note"
- [ ] Can type in textarea
- [ ] Save button is clickable and not disabled
- [ ] "Saving..." state appears briefly
- [ ] Comment displays after save
- [ ] Button text changes to "Edit Note"
- [ ] No error messages appear

---

### **TEST 3: Edit Existing Comment**

**Steps:**
1. Find annotation with existing comment
2. Click "📝 Edit Note" button
3. ✅ Textarea should expand with current comment pre-filled
4. Modify comment text: Add " - Updated at [current time]"
5. Click "💾 Save Note"
6. ✅ Updated comment should display
7. ✅ Version number should increment (v2 → v3)

**What to Check:**
- [ ] Existing comment loads in textarea
- [ ] Can modify text
- [ ] Save updates the comment
- [ ] Version increments
- [ ] No duplicate comments appear

---

### **TEST 4: Cancel Comment Edit**

**Steps:**
1. Click "📝 Edit Note" on any annotation
2. Modify the comment text
3. Click "Cancel" button
4. ✅ Textarea should collapse
5. ✅ Original comment should remain unchanged
6. ✅ Version number should NOT increment

**What to Check:**
- [ ] Cancel button works
- [ ] Changes are discarded
- [ ] Original text preserved
- [ ] No new version created
- [ ] No API call made (check Network tab)

---

### **TEST 5: Clear/Delete Comment**

**Steps:**
1. Click "📝 Edit Note" on annotation with comment
2. Clear all text from textarea (make it empty)
3. Click "💾 Save Note"
4. ✅ Comment section should disappear
5. ✅ Button should change to "📝 Add Note"
6. ✅ Version should increment

**What to Check:**
- [ ] Empty comment removes display
- [ ] Button changes to "Add Note"
- [ ] Can add new comment afterwards
- [ ] Version increments even with empty comment

---

### **TEST 6: Long Comment Handling**

**Steps:**
1. Click "Add Note" or "Edit Note"
2. Paste long text (500+ characters):
   ```
   This is a very long comment to test how the UI handles extensive text. 
   The comment field should properly wrap text and the textarea should expand 
   vertically since it has vertical resize enabled. We're testing edge cases 
   here to ensure the UI remains usable even with lengthy annotations. 
   Engineers might need to add detailed observations about thermal anomalies, 
   including temperature readings, environmental conditions, inspection dates, 
   maintenance history, and recommendations for future actions. All of this 
   should be stored and displayed properly without breaking the layout.
   ```
3. Click "💾 Save Note"
4. ✅ Long comment should display in gray box
5. ✅ Box should wrap text properly
6. ✅ No horizontal scroll
7. ✅ Layout should not break

**What to Check:**
- [ ] Long text wraps properly
- [ ] No overflow outside container
- [ ] Textarea is resizable vertically
- [ ] Save works with long text
- [ ] Display is readable

---

### **TEST 7: Comments on AI vs Human Annotations**

**Scenario A: AI Annotation**
1. Find annotation with source = 🤖 AI Detection
2. Add comment: "AI detection looks accurate"
3. Click "Approve" button
4. ✅ Comment should be preserved
5. ✅ Status should change to "✓ Approved"
6. ✅ Comment still editable

**Scenario B: Human Annotation**
1. Switch to "Draw" mode
2. Draw new bounding box
3. Annotation created with source = 👤 Manual
4. Add comment: "Manual annotation for missed hotspot"
5. ✅ Comment saves successfully
6. ✅ Comment displays in card

**What to Check:**
- [ ] Comments work on both AI and human annotations
- [ ] Comments preserved through approve/reject actions
- [ ] Can edit comments on approved annotations
- [ ] Comment field shows on all annotation types

---

### **TEST 8: Multiple Annotations with Comments**

**Steps:**
1. Add comments to 3-5 different annotations
2. Use different comment text for each
3. Scroll through annotations list
4. ✅ Each annotation shows its own comment
5. ✅ No comment mixing between annotations
6. ✅ All comments persist after page refresh

**What to Check:**
- [ ] Each annotation has independent comment
- [ ] No cross-contamination of comments
- [ ] Comments load correctly after refresh
- [ ] Edit button appears on all annotations with comments

---

### **TEST 9: Page Refresh Persistence**

**Steps:**
1. Add comment to annotation: "Test persistence"
2. Refresh the browser page (F5 or Cmd+R)
3. ✅ Comment should still be visible
4. ✅ Version number unchanged
5. ✅ All metadata intact

**What to Check:**
- [ ] Comments survive page refresh
- [ ] No data loss
- [ ] Version numbers consistent
- [ ] All annotations reload correctly

---

### **TEST 10: Comment During Edit Mode**

**Steps:**
1. Switch canvas to "Edit" mode
2. Select an annotation (click on it)
3. Move the annotation box
4. Add/edit comment on the same annotation
5. ✅ Both operations should work
6. ✅ Version should increment for comment change

**What to Check:**
- [ ] Can edit comments while in edit mode
- [ ] Moving annotation and editing comment are independent
- [ ] Both create separate version entries
- [ ] No conflicts between operations

---

## 🔍 Visual Verification Checklist

### **UI Elements Present:**
- [ ] 📝 "Add Note" button on annotations without comments
- [ ] 📝 "Edit Note" button on annotations with comments
- [ ] Textarea appears when adding/editing
- [ ] 💾 "Save Note" button in editor
- [ ] "Cancel" button in editor
- [ ] Gray box displaying comments
- [ ] Top border separator above comment section

### **Visual Styling:**
- [ ] Gray background (#f9fafb) for comment display
- [ ] Proper padding and spacing
- [ ] Buttons styled consistently with other buttons
- [ ] Comment text readable (good contrast)
- [ ] Responsive layout (no overflow)

### **Interaction Feedback:**
- [ ] Button hover effects work
- [ ] Cursor changes to pointer on buttons
- [ ] Loading state visible during save
- [ ] Buttons disabled during save operation
- [ ] No double-click issues

---

## 🐛 Common Issues & Solutions

### **Issue 1: Comment Not Saving**
**Symptoms:** Click save but comment doesn't appear
**Check:**
- Browser console for errors (F12)
- Network tab - is API call made?
- Backend logs - is request received?
**Solution:** Verify backend is running and API endpoint accessible

### **Issue 2: Button Not Responding**
**Symptoms:** Click "Add Note" but nothing happens
**Check:**
- Console errors
- Is `onUpdateComment` prop passed correctly?
**Solution:** Check AnnotationCard receives all required props

### **Issue 3: Comment Appears on Wrong Annotation**
**Symptoms:** Comment shows under different annotation
**Check:**
- Annotation IDs in API response
- `key` prop in map() function
**Solution:** Verify unique keys and correct ID mapping

### **Issue 4: Textarea Not Expanding**
**Symptoms:** Click button but textarea doesn't show
**Check:**
- `showCommentInput` state
- Console for React state errors
**Solution:** Verify useState is working properly

### **Issue 5: Version Not Incrementing**
**Symptoms:** Save comment but version stays same
**Check:**
- Backend AnnotationService.saveAnnotation() logic
- Database `version` column
**Solution:** Verify backend creates new version on update

---

## 📊 Browser DevTools Checks

### **Network Tab Verification**

When saving comment, check:
```
POST http://localhost:8080/api/annotations
Request Payload:
{
  "id": "annotation-uuid",
  "inspectionId": "inspection-uuid",
  "bbox": { "x1": 324, "y1": 264, "x2": 457, "y2": 390 },
  "classId": 1,
  "className": "Faulty",
  "confidence": 0.716,
  "source": "ai",
  "userId": "current-user@example.com",
  "comments": "Your comment text here"  ← Check this field
}

Response:
{
  "id": "new-version-uuid",
  "version": 2,  ← Should increment
  "comments": "Your comment text here",
  "modifiedAt": "2025-10-15T...",
  "modifiedBy": "current-user@example.com",
  ...
}
```

### **Console Tab**

Look for:
- ✅ "Creating new version X of annotation Y" (backend log)
- ✅ "Annotation updated successfully" (frontend log)
- ❌ No error messages
- ❌ No 404/500 HTTP errors

---

## ✅ Acceptance Criteria

**FR3.1 is complete when:**

- [x] ✅ Users can resize existing annotations
- [x] ✅ Users can reposition existing annotations
- [x] ✅ Users can delete annotations (Delete key + buttons)
- [x] ✅ Users can add new annotations (Draw mode)
- [x] ✅ Annotation type tracked (created/edited/deleted/approved/rejected)
- [x] ✅ **Comments/notes can be added to any annotation** ← NEW
- [x] ✅ **Comments can be edited after creation** ← NEW
- [x] ✅ **Comments persist across reloads** ← NEW
- [x] ✅ Timestamp tracked (createdAt, modifiedAt)
- [x] ✅ User ID tracked (createdBy, modifiedBy)
- [x] ✅ All changes auto-save (no manual save button needed)
- [x] ✅ UI is intuitive and user-friendly
- [x] ✅ Version control preserves history

---

## 📸 Screenshot Checklist

Take screenshots of:
1. ✅ Annotation card with comment displayed
2. ✅ Comment editor expanded (textarea visible)
3. ✅ Multiple annotations with different comments
4. ✅ Comment on AI-generated annotation
5. ✅ Comment on human-drawn annotation
6. ✅ Long comment wrapped properly
7. ✅ Empty state (no comment) with "Add Note" button

---

## 🚀 Next Steps After Testing

If all tests pass:
1. ✅ Mark FR3.1 as complete
2. ✅ Commit changes to git
3. ✅ Update project documentation
4. ✅ Move to FR3.3 (Feedback Export)

If issues found:
1. Document the issue
2. Check this guide for solutions
3. Debug using Browser DevTools
4. Fix and retest

---

## 📞 Support

If you encounter issues:
1. Check browser console (F12)
2. Check network tab for failed requests
3. Check backend logs
4. Verify all services are running
5. Try clearing browser cache
6. Restart services if needed

**Testing Status: Ready for QA** ✅
