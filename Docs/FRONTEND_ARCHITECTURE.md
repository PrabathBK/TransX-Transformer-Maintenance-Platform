# Frontend Architecture Guide - TransX Platform
### Teaching Guide for Phase 5: React + TypeScript Frontend (4-6 days)

---

## 📚 Table of Contents
1. [What is the Frontend?](#1-what-is-the-frontend)
2. [Technology Stack](#2-technology-stack)
3. [Project Structure](#3-project-structure)
4. [Core Concepts](#4-core-concepts)
5. [Component Architecture](#5-component-architecture)
6. [State Management](#6-state-management)
7. [API Integration](#7-api-integration)
8. [Routing & Navigation](#8-routing--navigation)
9. [Interactive Annotation Canvas](#9-interactive-annotation-canvas)
10. [Request Flow Examples](#10-request-flow-examples)
11. [Hands-On Examples](#11-hands-on-examples)
12. [Teaching Session Plan](#12-teaching-session-plan)

---

## 1. What is the Frontend?

### 🎯 Purpose
The frontend is the **user interface layer** of TransX that runs in the web browser, providing inspectors with an interactive platform to manage transformers, conduct inspections, and annotate thermal images.

### 🔑 Key Responsibilities
- **Display Data**: Show transformers, inspections, and images
- **User Interaction**: Forms, buttons, clicks, drawing annotations
- **API Communication**: Fetch/send data to Spring Boot backend
- **Real-time Updates**: Reflect changes immediately
- **Image Annotation**: Interactive bounding box drawing with Konva.js

### 🌟 Real-World Analogy
Think of the TransX platform as a **hospital**:
- **Frontend (React)** = Hospital reception, examination rooms, and medical equipment screens
- **Backend (Spring Boot)** = Hospital administration and patient management system
- **ML Service (Flask)** = Radiology department with X-ray analysis
- **Database (MySQL)** = Central medical records storage

The frontend is what doctors (inspectors) interact with daily, but it relies on the backend for data and the ML service for diagnostics.

---

## 2. Technology Stack

### Core Technologies

```
┌─────────────────────────────────────────────────────────┐
│                  FRONTEND TECH STACK                     │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ⚛️  UI Library:        React 19.1.1                    │
│  📘 Type System:        TypeScript 5.8.3                │
│  🚀 Build Tool:         Vite 7.1.0                      │
│  🧭 Routing:            React Router DOM 7.8.0          │
│  🌐 HTTP Client:        Axios 1.12.2                    │
│  🎨 Canvas Library:     Konva 10.0.2 + React-Konva      │
│  📋 Form Handling:      React Hook Form 7.62.0          │
│  ✅ Validation:         Zod 4.0.17                      │
│  🎨 Styling:            CSS (custom)                    │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### Why These Technologies?

#### React
- **Component-Based**: Reusable UI pieces (like Lego blocks)
- **Virtual DOM**: Fast updates without full page refresh
- **Declarative**: Describe what UI should look like, React handles updates
- **Large Ecosystem**: Tons of libraries and community support

#### TypeScript
- **Type Safety**: Catch errors before runtime
- **Better IntelliSense**: IDE autocomplete and documentation
- **Refactoring**: Rename variables/functions safely
- **Self-Documenting**: Types describe data structure

#### Vite
- **Lightning Fast**: Hot Module Replacement (HMR) in milliseconds
- **Modern**: Native ES modules, optimized builds
- **Simple Config**: Works out of the box

#### React Router
- **Client-Side Routing**: Navigate without page reload
- **Nested Routes**: Layout with multiple child pages
- **URL Parameters**: `/transformers/:id` → extract ID

#### Konva
- **Canvas Drawing**: High-performance 2D graphics
- **Interactive Shapes**: Drag, resize, transform boxes
- **Event Handling**: Click, mouse move, drag events
- **Export**: Save canvas as image

---

## 3. Project Structure

### 3.1 Directory Layout

```
frontend/
├── public/                    # Static assets
├── src/
│   ├── main.tsx              # Application entry point
│   ├── App.tsx               # Root component with routing
│   ├── index.css             # Global styles
│   ├── App.css               # App-specific styles
│   │
│   ├── api/                  # Backend API client
│   │   ├── client.ts         # Base HTTP client (fetch wrapper)
│   │   ├── transformers.ts   # Transformer CRUD operations
│   │   ├── inspections.ts    # Inspection operations
│   │   ├── annotations.ts    # Annotation operations
│   │   ├── images.ts         # Image upload/retrieval
│   │   ├── history.ts        # Inspection history
│   │   └── inspectionComments.ts  # Comments
│   │
│   ├── components/           # Reusable UI components
│   │   ├── Layout.tsx        # Main layout with sidebar
│   │   ├── AnnotationCanvas.tsx    # Interactive canvas
│   │   ├── AnnotationToolbar.tsx   # Drawing controls
│   │   ├── AnnotationLegend.tsx    # Class color legend
│   │   ├── NotesSection.tsx        # Notes editor
│   │   ├── CommentsSection.tsx     # Comments list
│   │   ├── FileDrop.tsx            # Drag-and-drop upload
│   │   ├── InspectionHistoryList.tsx  # History timeline
│   │   ├── Table.tsx               # Data table
│   │   ├── Modal.tsx               # Dialog/popup
│   │   ├── Input.tsx               # Form input
│   │   ├── Select.tsx              # Dropdown select
│   │   └── ErrorBoundary.tsx       # Error handling
│   │
│   └── pages/                # Route components (full pages)
│       ├── Dashboard.tsx           # Homepage
│       ├── TransformersList.tsx    # List all transformers
│       ├── TransformerDetail.tsx   # Single transformer view
│       ├── TransformerForm.tsx     # Create/edit transformer
│       ├── InspectionsList.tsx     # List all inspections
│       ├── InspectionDetailNew.tsx # Inspection annotation page
│       ├── ImagesList.tsx          # Image gallery
│       └── ImageUpload.tsx         # Upload images
│
├── package.json              # Dependencies
├── tsconfig.json             # TypeScript config
├── vite.config.ts            # Vite build config
└── index.html                # HTML entry point
```

### 3.2 Component vs Page

**Component** = Reusable UI piece (button, input, card)
```tsx
// components/Button.tsx
export default function Button({ label, onClick }) {
  return <button onClick={onClick}>{label}</button>;
}
```

**Page** = Full route view (uses components)
```tsx
// pages/TransformersList.tsx
export default function TransformersList() {
  return (
    <div>
      <h1>Transformers</h1>
      <Table data={transformers} />
      <Button label="Add New" onClick={handleAdd} />
    </div>
  );
}
```

---

## 4. Core Concepts

### 4.1 What is React?

React is a **JavaScript library** for building user interfaces using **components**.

**Traditional Web Development**:
```html
<!-- HTML -->
<div id="counter">0</div>
<button onclick="increment()">+</button>

<script>
  let count = 0;
  function increment() {
    count++;
    document.getElementById('counter').innerText = count;
  }
</script>
```
❌ Problem: Manual DOM manipulation, hard to maintain

**React Way**:
```tsx
function Counter() {
  const [count, setCount] = useState(0);
  
  return (
    <div>
      <div>{count}</div>
      <button onClick={() => setCount(count + 1)}>+</button>
    </div>
  );
}
```
✅ React handles DOM updates automatically!

### 4.2 Components

**Component** = Independent, reusable piece of UI

```tsx
// Function Component (modern React)
function Welcome({ name }) {
  return <h1>Hello, {name}!</h1>;
}

// Usage
<Welcome name="John" />  // Renders: <h1>Hello, John!</h1>
```

### 4.3 Props (Properties)

**Props** = Data passed from parent to child (read-only)

```tsx
// Parent
<Button label="Save" color="blue" onClick={handleSave} />

// Child Component
function Button({ label, color, onClick }) {
  return (
    <button 
      style={{ backgroundColor: color }} 
      onClick={onClick}
    >
      {label}
    </button>
  );
}
```

### 4.4 State

**State** = Component's internal data that can change

```tsx
import { useState } from 'react';

function Counter() {
  // Declare state variable
  const [count, setCount] = useState(0);  // Initial value: 0
  
  // Update state
  const increment = () => setCount(count + 1);
  
  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={increment}>+1</button>
    </div>
  );
}
```

**State Flow**:
```
User clicks button
       ↓
setCount(count + 1) called
       ↓
State updated
       ↓
React re-renders component
       ↓
UI shows new count
```

### 4.5 Effects (Side Effects)

**useEffect** = Run code when component mounts or state changes

```tsx
import { useEffect, useState } from 'react';

function TransformerDetail({ id }) {
  const [transformer, setTransformer] = useState(null);
  
  // Fetch data when component mounts or id changes
  useEffect(() => {
    async function loadData() {
      const data = await getTransformer(id);
      setTransformer(data);
    }
    loadData();
  }, [id]);  // Re-run when id changes
  
  if (!transformer) return <div>Loading...</div>;
  
  return <div>{transformer.code}</div>;
}
```

### 4.6 TypeScript Integration

**Type-Safe Props**:
```tsx
// Define prop types
interface ButtonProps {
  label: string;
  onClick: () => void;
  disabled?: boolean;  // Optional
}

// Use in component
function Button({ label, onClick, disabled = false }: ButtonProps) {
  return (
    <button onClick={onClick} disabled={disabled}>
      {label}
    </button>
  );
}

// TypeScript ensures correct usage
<Button label="Save" onClick={handleSave} />        // ✅ OK
<Button label={123} onClick={handleSave} />         // ❌ Error: label must be string
<Button label="Save" />                             // ❌ Error: onClick required
```

---

## 5. Component Architecture

### 5.1 TransX Component Hierarchy

```
┌─────────────────────────────────────────────────────────────┐
│                         App.tsx                              │
│                   (BrowserRouter + Routes)                   │
└────────────────────────────┬────────────────────────────────┘
                             │
                             ▼
              ┌──────────────────────────────┐
              │       Layout.tsx             │
              │  (Sidebar + Outlet)          │
              └──────────┬───────────────────┘
                         │
         ┌───────────────┼───────────────┬──────────────┐
         │               │               │              │
         ▼               ▼               ▼              ▼
   ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐
   │Dashboard │   │Transformers   │Inspections   │Settings  │
   │  Page    │   │   List    │   │   List   │   │  Page    │
   └──────────┘   └─────┬────┘   └─────┬────┘   └──────────┘
                        │               │
                        ▼               ▼
                  ┌──────────┐    ┌──────────┐
                  │Transformer│   │Inspection │
                  │  Detail  │    │  Detail  │
                  └──────────┘    └─────┬────┘
                                        │
                  ┌─────────────────────┼─────────────────┐
                  │                     │                 │
                  ▼                     ▼                 ▼
          ┌──────────────┐     ┌──────────────┐  ┌──────────────┐
          │ Annotation   │     │  Annotation  │  │   Notes      │
          │   Canvas     │     │   Toolbar    │  │  Section     │
          └──────────────┘     └──────────────┘  └──────────────┘
```

### 5.2 Layout Component (Sidebar Pattern)

```tsx
// components/Layout.tsx
import { Outlet, Link } from 'react-router-dom';

export default function Layout() {
  return (
    <div style={{ display: 'flex' }}>
      {/* Sidebar */}
      <nav style={{ width: 250, background: '#1f2937', color: 'white' }}>
        <h2>TransX</h2>
        <ul>
          <li><Link to="/">Dashboard</Link></li>
          <li><Link to="/transformers">Transformers</Link></li>
          <li><Link to="/inspections">Inspections</Link></li>
          <li><Link to="/settings">Settings</Link></li>
        </ul>
      </nav>
      
      {/* Main Content Area */}
      <main style={{ flex: 1, padding: 24 }}>
        <Outlet />  {/* Child routes render here */}
      </main>
    </div>
  );
}
```

**Visual Layout**:
```
┌──────────────────────────────────────────────────┐
│                 TransX Platform                  │
├────────────┬─────────────────────────────────────┤
│            │                                      │
│ Sidebar    │        Main Content Area            │
│            │                                      │
│ • Dashboard│   ┌──────────────────────────┐     │
│ • Transformers   │                          │     │
│ • Inspections    │   Page Component         │     │
│ • Settings │   │   (rendered by Outlet)   │     │
│            │   │                          │     │
│            │   └──────────────────────────┘     │
│            │                                      │
└────────────┴─────────────────────────────────────┘
```

### 5.3 Table Component (Reusable)

```tsx
// components/Table.tsx
interface Column<T> {
  key: keyof T;
  label: string;
  render?: (value: any, row: T) => React.ReactNode;
}

interface TableProps<T> {
  data: T[];
  columns: Column<T>[];
  onRowClick?: (row: T) => void;
}

export default function Table<T>({ data, columns, onRowClick }: TableProps<T>) {
  return (
    <table>
      <thead>
        <tr>
          {columns.map(col => (
            <th key={String(col.key)}>{col.label}</th>
          ))}
        </tr>
      </thead>
      <tbody>
        {data.map((row, idx) => (
          <tr key={idx} onClick={() => onRowClick?.(row)}>
            {columns.map(col => (
              <td key={String(col.key)}>
                {col.render 
                  ? col.render(row[col.key], row)
                  : String(row[col.key])
                }
              </td>
            ))}
          </tr>
        ))}
      </tbody>
    </table>
  );
}
```

**Usage**:
```tsx
const columns = [
  { key: 'code', label: 'Transformer No.' },
  { key: 'location', label: 'Location' },
  { 
    key: 'capacityKVA', 
    label: 'Capacity',
    render: (value) => `${value} kVA`
  }
];

<Table 
  data={transformers} 
  columns={columns}
  onRowClick={(row) => navigate(`/transformers/${row.id}`)}
/>
```

---

## 6. State Management

### 6.1 Local State (useState)

For component-specific data:
```tsx
function TransformersList() {
  const [transformers, setTransformers] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  
  useEffect(() => {
    async function loadData() {
      setLoading(true);
      try {
        const data = await listTransformers();
        setTransformers(data.content);
      } catch (e) {
        setError(e.message);
      } finally {
        setLoading(false);
      }
    }
    loadData();
  }, []);
  
  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;
  
  return <Table data={transformers} />;
}
```

### 6.2 State Patterns in TransX

#### Pattern 1: Data Fetching
```tsx
// Standard pattern for loading data
const [data, setData] = useState<Type[]>([]);
const [loading, setLoading] = useState(false);
const [error, setError] = useState<string | null>(null);

useEffect(() => {
  async function load() {
    setLoading(true);
    setError(null);
    try {
      const result = await apiCall();
      setData(result);
    } catch (e: any) {
      setError(e.message);
    } finally {
      setLoading(false);
    }
  }
  load();
}, [dependencies]);
```

#### Pattern 2: Form State
```tsx
const [formData, setFormData] = useState({
  code: '',
  location: '',
  capacityKVA: 0
});

const handleChange = (field: string, value: any) => {
  setFormData(prev => ({
    ...prev,
    [field]: value
  }));
};

const handleSubmit = async () => {
  await createTransformer(formData);
  navigate('/transformers');
};
```

#### Pattern 3: Canvas State (Annotation)
```tsx
const [mode, setMode] = useState<'view' | 'edit' | 'draw'>('view');
const [selectedId, setSelectedId] = useState<string | null>(null);
const [annotations, setAnnotations] = useState<Annotation[]>([]);

// Switch to draw mode
const startDrawing = () => setMode('draw');

// Add new annotation
const handleAnnotationCreate = (bbox) => {
  const newAnnotation = { id: uuid(), bbox, className: selectedClass };
  setAnnotations([...annotations, newAnnotation]);
  setMode('view');
};
```

---

## 7. API Integration

### 7.1 API Client Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   API CLIENT LAYER                       │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  api/client.ts                                          │
│  ┌────────────────────────────────────────────┐        │
│  │  export async function api<T>(             │        │
│  │    path: string,                           │        │
│  │    init?: RequestInit                      │        │
│  │  ): Promise<T> {                           │        │
│  │    const url = `${API_BASE}${path}`;       │        │
│  │    const res = await fetch(url, init);     │        │
│  │    // Handle errors, parse JSON            │        │
│  │    return json;                            │        │
│  │  }                                         │        │
│  └────────────────────────────────────────────┘        │
│                        │                                 │
│         ┌──────────────┼──────────────┬────────────┐   │
│         │              │              │            │   │
│         ▼              ▼              ▼            ▼   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐
│  │transformers │ inspections│ annotations│ │  images  │
│  │    .ts   │  │    .ts   │  │    .ts   │  │   .ts    │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### 7.2 Base Client (client.ts)

```typescript
// src/api/client.ts
export const API_BASE = 
  import.meta.env.VITE_API_BASE || 'http://localhost:8080';

export async function api<T>(
  path: string, 
  init?: RequestInit
): Promise<T> {
  const url = `${API_BASE}${path}`;
  
  const res = await fetch(url, init).catch(err => {
    throw new Error(`Network error: ${err.message}`);
  });
  
  const text = await res.text();
  const isJson = res.headers
    .get('content-type')
    ?.includes('application/json');
  
  if (!res.ok) {
    throw new Error(text || `HTTP ${res.status}`);
  }
  
  if (!text) return undefined as unknown as T;
  return isJson ? JSON.parse(text) : text as unknown as T;
}
```

### 7.3 Resource-Specific Clients

```typescript
// src/api/transformers.ts
import { api } from './client';

export type Transformer = {
  id: string;
  code: string;
  location: string;
  capacityKVA: number;
  region?: string | null;
};

export async function listTransformers(q = '', page = 0, size = 10) {
  const qs = new URLSearchParams({ 
    q, 
    page: String(page), 
    size: String(size) 
  });
  return api<PageResp<Transformer>>(`/api/transformers?${qs}`);
}

export async function getTransformer(id: string) {
  return api<Transformer>(`/api/transformers/${id}`);
}

export async function createTransformer(body: CreateTransformerBody) {
  return api<Transformer>(`/api/transformers`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body)
  });
}

export async function deleteTransformer(id: string) {
  return api<void>(`/api/transformers/${id}`, { 
    method: 'DELETE' 
  });
}
```

### 7.4 TypeScript Types for API

```typescript
// Exact match with backend DTOs
export type Annotation = {
  id: string;
  inspectionId: string;
  bbox: BoundingBox;
  className: string;
  confidence: number;
  source: 'ai' | 'human';
  status: 'PENDING' | 'APPROVED' | 'REJECTED';
  version?: number;
  createdAt: string;
  updatedAt: string;
};

export type BoundingBox = {
  x1: number;
  y1: number;
  x2: number;
  y2: number;
};

export type SaveAnnotationRequest = {
  id?: string;
  inspectionId: string;
  bbox: BoundingBox;
  className: string;
  confidence?: number;
  source?: 'ai' | 'human';
  userId?: string;
};
```

---

## 8. Routing & Navigation

### 8.1 React Router Setup

```tsx
// App.tsx
import { BrowserRouter, Routes, Route } from 'react-router-dom';

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        {/* Layout wrapper */}
        <Route element={<Layout />}>
          <Route path="/" element={<Dashboard />} />
          <Route path="/transformers" element={<TransformersList />} />
          <Route path="/transformers/:id" element={<TransformerDetail />} />
          <Route path="/inspections" element={<InspectionsList />} />
          <Route path="/inspections/:id" element={<InspectionDetailNew />} />
          <Route path="*" element={<div>Not found</div>} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}
```

### 8.2 Navigation Hooks

```tsx
import { useNavigate, useParams } from 'react-router-dom';

function TransformerDetail() {
  const { id } = useParams();  // Get URL parameter
  const navigate = useNavigate();  // Programmatic navigation
  
  const handleDelete = async () => {
    await deleteTransformer(id!);
    navigate('/transformers');  // Redirect after delete
  };
  
  return (
    <div>
      <h1>Transformer {id}</h1>
      <button onClick={handleDelete}>Delete</button>
    </div>
  );
}
```

### 8.3 Routing Patterns

```
URL Pattern              Component            Params
──────────────────────   ──────────────────   ────────────
/                        Dashboard            -
/transformers            TransformersList     -
/transformers/:id        TransformerDetail    id
/transformers/new        TransformerForm      -
/inspections             InspectionsList      -
/inspections/:id         InspectionDetailNew  id
```

---

## 9. Interactive Annotation Canvas

### 9.1 Konva.js Overview

**Konva** = JavaScript 2D canvas library for drawing and interaction

```
┌──────────────────────────────────────────────────────┐
│               KONVA ARCHITECTURE                      │
├──────────────────────────────────────────────────────┤
│                                                       │
│  Stage (Container)                                   │
│  ┌────────────────────────────────────────────────┐ │
│  │                                                 │ │
│  │  Layer 1 (Background Image)                    │ │
│  │  ┌──────────────────────────────────────────┐  │ │
│  │  │  <Image src={thermalImage} />            │  │ │
│  │  └──────────────────────────────────────────┘  │ │
│  │                                                 │ │
│  │  Layer 2 (Annotations)                         │ │
│  │  ┌──────────────────────────────────────────┐  │ │
│  │  │  <Rect x={100} y={50} width={200} ... /> │  │ │
│  │  │  <Rect x={300} y={200} width={150} ...   │  │ │
│  │  │  <Text text="Faulty" ... />               │  │ │
│  │  └──────────────────────────────────────────┘  │ │
│  │                                                 │ │
│  │  Layer 3 (Transformer - for resize handles)   │ │
│  │  ┌──────────────────────────────────────────┐  │ │
│  │  │  <Transformer nodes={[selectedRect]} />   │  │ │
│  │  └──────────────────────────────────────────┘  │ │
│  │                                                 │ │
│  └────────────────────────────────────────────────┘ │
│                                                       │
└──────────────────────────────────────────────────────┘
```

### 9.2 AnnotationCanvas Component

```tsx
// components/AnnotationCanvas.tsx
import { Stage, Layer, Image as KonvaImage, Rect, Text } from 'react-konva';

interface AnnotationCanvasProps {
  imageUrl: string;
  annotations: Annotation[];
  mode: 'view' | 'edit' | 'draw';
  onAnnotationCreate?: (bbox: BoundingBox) => void;
}

export default function AnnotationCanvas({
  imageUrl,
  annotations,
  mode,
  onAnnotationCreate
}: AnnotationCanvasProps) {
  const [image, setImage] = useState<HTMLImageElement | null>(null);
  const [isDrawing, setIsDrawing] = useState(false);
  const [newBox, setNewBox] = useState<Box | null>(null);
  
  // Load image
  useEffect(() => {
    const img = new window.Image();
    img.src = imageUrl;
    img.onload = () => setImage(img);
  }, [imageUrl]);
  
  // Handle mouse down (start drawing)
  const handleMouseDown = (e: any) => {
    if (mode !== 'draw') return;
    
    const pos = e.target.getStage().getPointerPosition();
    setIsDrawing(true);
    setNewBox({ x: pos.x, y: pos.y, width: 0, height: 0 });
  };
  
  // Handle mouse move (update box size)
  const handleMouseMove = (e: any) => {
    if (!isDrawing || !newBox) return;
    
    const pos = e.target.getStage().getPointerPosition();
    setNewBox({
      ...newBox,
      width: pos.x - newBox.x,
      height: pos.y - newBox.y
    });
  };
  
  // Handle mouse up (finish drawing)
  const handleMouseUp = () => {
    if (!isDrawing || !newBox) return;
    
    setIsDrawing(false);
    
    // Create annotation
    const bbox = {
      x1: newBox.x,
      y1: newBox.y,
      x2: newBox.x + newBox.width,
      y2: newBox.y + newBox.height
    };
    onAnnotationCreate?.(bbox);
    setNewBox(null);
  };
  
  return (
    <Stage
      width={800}
      height={600}
      onMouseDown={handleMouseDown}
      onMouseMove={handleMouseMove}
      onMouseUp={handleMouseUp}
    >
      {/* Background Image */}
      <Layer>
        {image && <KonvaImage image={image} />}
      </Layer>
      
      {/* Annotations */}
      <Layer>
        {annotations.map(ann => (
          <Fragment key={ann.id}>
            <Rect
              x={ann.bbox.x1}
              y={ann.bbox.y1}
              width={ann.bbox.x2 - ann.bbox.x1}
              height={ann.bbox.y2 - ann.bbox.y1}
              stroke={getColor(ann.className)}
              strokeWidth={2}
              fill="transparent"
            />
            <Text
              x={ann.bbox.x1}
              y={ann.bbox.y1 - 20}
              text={`${ann.className} (${(ann.confidence * 100).toFixed(0)}%)`}
              fill={getColor(ann.className)}
            />
          </Fragment>
        ))}
        
        {/* New box being drawn */}
        {newBox && (
          <Rect
            x={newBox.x}
            y={newBox.y}
            width={newBox.width}
            height={newBox.height}
            stroke="#00ff00"
            strokeWidth={2}
            fill="transparent"
            dash={[5, 5]}
          />
        )}
      </Layer>
    </Stage>
  );
}
```

### 9.3 Canvas Modes

```
┌───────────────────────────────────────────────────────┐
│             ANNOTATION CANVAS MODES                    │
├───────────────────────────────────────────────────────┤
│                                                        │
│  VIEW MODE                                            │
│  • Display annotations (read-only)                    │
│  • Click to select                                    │
│  • No editing                                         │
│                                                        │
│  EDIT MODE                                            │
│  • Click annotation to select                         │
│  • Drag to move                                       │
│  • Resize handles appear                              │
│  • Delete key removes selected                        │
│                                                        │
│  DRAW MODE                                            │
│  • Click and drag to draw new box                     │
│  • Release to create annotation                       │
│  • Auto-switch to view mode after creation            │
│                                                        │
└───────────────────────────────────────────────────────┘
```

---

## 10. Request Flow Examples

### 10.1 Complete Inspection Workflow

```
┌──────────────────────────────────────────────────────────────┐
│        INSPECTION ANNOTATION WORKFLOW (FRONTEND)             │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  1. USER NAVIGATES TO INSPECTION                             │
│  ┌────────────────────────────────────────────┐             │
│  │ URL: /inspections/abc-123                  │             │
│  │ Component: InspectionDetailNew             │             │
│  └────────────────────────────────────────────┘             │
│                      │                                        │
│                      ▼                                        │
│  2. LOAD DATA (useEffect)                                    │
│  ┌────────────────────────────────────────────┐             │
│  │ const [inspection, setInspection] = ...    │             │
│  │ const [annotations, setAnnotations] = ...  │             │
│  │                                            │             │
│  │ useEffect(() => {                          │             │
│  │   Promise.all([                            │             │
│  │     getInspection(id),                     │             │
│  │     getAnnotationsByInspection(id)         │             │
│  │   ]).then(([insp, anns]) => {              │             │
│  │     setInspection(insp);                   │             │
│  │     setAnnotations(anns);                  │             │
│  │   });                                      │             │
│  │ }, [id]);                                  │             │
│  └────────────────────────────────────────────┘             │
│                      │                                        │
│                      ▼                                        │
│  3. RENDER UI                                                │
│  ┌────────────────────────────────────────────┐             │
│  │ <AnnotationCanvas                          │             │
│  │   imageUrl={inspection.inspectionImageUrl} │             │
│  │   annotations={annotations}                │             │
│  │   mode={mode}                              │             │
│  │ />                                         │             │
│  └────────────────────────────────────────────┘             │
│                      │                                        │
│                      ▼                                        │
│  4. USER CLICKS "DETECT ANOMALIES"                           │
│  ┌────────────────────────────────────────────┐             │
│  │ const handleDetect = async () => {         │             │
│  │   setIsDetecting(true);                    │             │
│  │   const result = await detectAnomalies(id);│             │
│  │   // Refresh annotations                   │             │
│  │   const newAnns = await                    │             │
│  │     getAnnotationsByInspection(id);        │             │
│  │   setAnnotations(newAnns);                 │             │
│  │   setIsDetecting(false);                   │             │
│  │ }                                          │             │
│  └────────────────────────────────────────────┘             │
│                      │                                        │
│                      ▼                                        │
│  5. AI ANNOTATIONS APPEAR ON CANVAS                          │
│  (Bounding boxes rendered by Konva)                          │
│                      │                                        │
│                      ▼                                        │
│  6. USER ADDS MISSED DETECTION                               │
│  ┌────────────────────────────────────────────┐             │
│  │ • Click "Draw" mode                        │             │
│  │ • Drag mouse to create box                 │             │
│  │ • onAnnotationCreate callback triggered    │             │
│  │                                            │             │
│  │ const handleCreate = async (bbox) => {     │             │
│  │   const newAnn = {                         │             │
│  │     inspectionId: id,                      │             │
│  │     bbox,                                  │             │
│  │     className: selectedClass,              │             │
│  │     source: 'human'                        │             │
│  │   };                                       │             │
│  │   await saveAnnotation(newAnn);            │             │
│  │   // Refresh list                          │             │
│  │   const updated = await                    │             │
│  │     getAnnotationsByInspection(id);        │             │
│  │   setAnnotations(updated);                 │             │
│  │ }                                          │             │
│  └────────────────────────────────────────────┘             │
│                      │                                        │
│                      ▼                                        │
│  7. USER APPROVES/REJECTS AI DETECTIONS                      │
│  ┌────────────────────────────────────────────┐             │
│  │ const handleApprove = async (annId) => {   │             │
│  │   await approveAnnotation(annId, userId);  │             │
│  │   // Refresh                               │             │
│  │   const updated = await                    │             │
│  │     getAnnotationsByInspection(id);        │             │
│  │   setAnnotations(updated);                 │             │
│  │ }                                          │             │
│  └────────────────────────────────────────────┘             │
│                      │                                        │
│                      ▼                                        │
│  8. EXPORT FEEDBACK FOR ML IMPROVEMENT                       │
│  ┌────────────────────────────────────────────┐             │
│  │ const handleExport = async () => {         │             │
│  │   const feedback = await                   │             │
│  │     exportFeedback(inspectionId);          │             │
│  │   // Send to ML service (backend handles)  │             │
│  │   alert('Feedback exported!');             │             │
│  │ }                                          │             │
│  └────────────────────────────────────────────┘             │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

### 10.2 File Upload Flow

```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│  FRONTEND   │         │   BACKEND   │         │  FILESYSTEM │
└──────┬──────┘         └──────┬──────┘         └──────┬──────┘
       │                       │                        │
       │ 1. User selects file  │                        │
       │    (FileDrop component)                        │
       │                       │                        │
       │ 2. POST /api/images   │                        │
       │    FormData {         │                        │
       │      file: blob       │                        │
       │      type: BASELINE   │                        │
       │    }                  │                        │
       ├──────────────────────►│                        │
       │                       │                        │
       │                       │ 3. Save to disk        │
       │                       │    /uploads/{uuid}/... │
       │                       ├───────────────────────►│
       │                       │                        │
       │                       │ 4. File saved          │
       │                       │◄───────────────────────┤
       │                       │                        │
       │                       │ 5. Create DB record    │
       │                       │    (ThermalImage)      │
       │                       │                        │
       │ 6. Return image ID    │                        │
       │    & URL              │                        │
       │◄──────────────────────┤                        │
       │                       │                        │
       │ 7. Display preview    │                        │
       │    <img src={url} />  │                        │
       │                       │                        │
```

**Code Example**:
```tsx
// FileDrop component
const handleFileSelect = async (file: File) => {
  setUploading(true);
  try {
    const formData = new FormData();
    formData.append('file', file);
    formData.append('type', 'BASELINE');
    formData.append('transformerId', transformerId);
    
    const response = await uploadImage(formData);
    setImageId(response.id);
    setImageUrl(response.url);
  } catch (e) {
    alert('Upload failed: ' + e.message);
  } finally {
    setUploading(false);
  }
};
```

---

## 11. Hands-On Examples

### Example 1: Simple Counter Component

```tsx
import { useState } from 'react';

function Counter() {
  const [count, setCount] = useState(0);
  
  return (
    <div>
      <h2>Counter: {count}</h2>
      <button onClick={() => setCount(count + 1)}>+</button>
      <button onClick={() => setCount(count - 1)}>-</button>
      <button onClick={() => setCount(0)}>Reset</button>
    </div>
  );
}
```

### Example 2: Fetch and Display Data

```tsx
import { useState, useEffect } from 'react';
import { listTransformers } from '../api/transformers';

function TransformersList() {
  const [transformers, setTransformers] = useState([]);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    async function load() {
      const data = await listTransformers();
      setTransformers(data.content);
      setLoading(false);
    }
    load();
  }, []);
  
  if (loading) return <div>Loading...</div>;
  
  return (
    <ul>
      {transformers.map(t => (
        <li key={t.id}>
          {t.code} - {t.location} ({t.capacityKVA} kVA)
        </li>
      ))}
    </ul>
  );
}
```

### Example 3: Form with Validation

```tsx
import { useState } from 'react';
import { createTransformer } from '../api/transformers';

function TransformerForm() {
  const [code, setCode] = useState('');
  const [location, setLocation] = useState('');
  const [capacity, setCapacity] = useState('');
  const [errors, setErrors] = useState<Record<string, string>>({});
  
  const validate = () => {
    const newErrors: Record<string, string> = {};
    
    if (!code) newErrors.code = 'Code is required';
    if (!location) newErrors.location = 'Location is required';
    if (!capacity || isNaN(Number(capacity))) {
      newErrors.capacity = 'Valid capacity required';
    }
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };
  
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!validate()) return;
    
    try {
      await createTransformer({
        code,
        location,
        capacityKVA: Number(capacity)
      });
      alert('Transformer created!');
    } catch (e: any) {
      alert('Error: ' + e.message);
    }
  };
  
  return (
    <form onSubmit={handleSubmit}>
      <div>
        <label>Code:</label>
        <input 
          value={code} 
          onChange={(e) => setCode(e.target.value)} 
        />
        {errors.code && <span style={{color: 'red'}}>{errors.code}</span>}
      </div>
      
      <div>
        <label>Location:</label>
        <input 
          value={location} 
          onChange={(e) => setLocation(e.target.value)} 
        />
        {errors.location && <span style={{color: 'red'}}>{errors.location}</span>}
      </div>
      
      <div>
        <label>Capacity (kVA):</label>
        <input 
          type="number"
          value={capacity} 
          onChange={(e) => setCapacity(e.target.value)} 
        />
        {errors.capacity && <span style={{color: 'red'}}>{errors.capacity}</span>}
      </div>
      
      <button type="submit">Create</button>
    </form>
  );
}
```

### Example 4: Modal Component

```tsx
interface ModalProps {
  isOpen: boolean;
  onClose: () => void;
  title: string;
  children: React.ReactNode;
}

function Modal({ isOpen, onClose, title, children }: ModalProps) {
  if (!isOpen) return null;
  
  return (
    <div style={{
      position: 'fixed',
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      backgroundColor: 'rgba(0,0,0,0.5)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center'
    }}>
      <div style={{
        backgroundColor: 'white',
        padding: 24,
        borderRadius: 8,
        minWidth: 400
      }}>
        <div style={{ display: 'flex', justifyContent: 'space-between' }}>
          <h2>{title}</h2>
          <button onClick={onClose}>×</button>
        </div>
        <div>{children}</div>
      </div>
    </div>
  );
}

// Usage
function App() {
  const [showModal, setShowModal] = useState(false);
  
  return (
    <div>
      <button onClick={() => setShowModal(true)}>Open Modal</button>
      
      <Modal 
        isOpen={showModal}
        onClose={() => setShowModal(false)}
        title="Confirm Action"
      >
        <p>Are you sure?</p>
        <button onClick={() => setShowModal(false)}>Cancel</button>
        <button onClick={handleConfirm}>Confirm</button>
      </Modal>
    </div>
  );
}
```

---

## 12. Teaching Session Plan

### 📅 Session 1: React Fundamentals (3 hours)

**Topics**:
- What is React and why use it?
- Components, props, and state
- JSX syntax and expressions
- Event handling
- Conditional rendering and lists

**Hands-On**:
- Create first React component
- Build counter with useState
- Render list of items
- Handle button clicks

**Exercises**:
1. Build a todo list (add, remove, toggle)
2. Create a simple calculator
3. Build a color picker component

---

### 📅 Session 2: TypeScript + React (3 hours)

**Topics**:
- TypeScript basics (types, interfaces)
- Typing props and state
- Type-safe event handlers
- Generic components
- API response types

**Hands-On**:
- Add types to Counter component
- Create typed form inputs
- Define API response interfaces
- Use generics for Table component

**Code Exercise**:
```tsx
// Type a reusable Card component
interface CardProps {
  title: string;
  subtitle?: string;
  onClick?: () => void;
  children: React.ReactNode;
}

function Card({ title, subtitle, onClick, children }: CardProps) {
  return (
    <div onClick={onClick} style={{ border: '1px solid #ccc', padding: 16 }}>
      <h3>{title}</h3>
      {subtitle && <p>{subtitle}</p>}
      <div>{children}</div>
    </div>
  );
}
```

---

### 📅 Session 3: Data Fetching & Effects (3 hours)

**Topics**:
- useEffect hook
- Async data loading
- Error handling
- Loading states
- Cleanup functions

**Hands-On**:
- Fetch transformers from API
- Display loading spinner
- Handle network errors
- Implement retry logic

**Real-World Example**:
```tsx
function TransformerDetail({ id }: { id: string }) {
  const [transformer, setTransformer] = useState<Transformer | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  
  useEffect(() => {
    let cancelled = false;
    
    async function load() {
      try {
        setLoading(true);
        setError(null);
        const data = await getTransformer(id);
        if (!cancelled) {
          setTransformer(data);
        }
      } catch (e: any) {
        if (!cancelled) {
          setError(e.message);
        }
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    }
    
    load();
    
    // Cleanup
    return () => {
      cancelled = true;
    };
  }, [id]);
  
  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;
  if (!transformer) return <div>Not found</div>;
  
  return <div>{transformer.code}</div>;
}
```

---

### 📅 Session 4: Routing & Navigation (2 hours)

**Topics**:
- React Router setup
- Route definition
- Navigation with Link and useNavigate
- URL parameters with useParams
- Nested routes

**Hands-On**:
- Set up routes for TransX
- Create Layout with sidebar
- Navigate between pages
- Extract URL parameters
- Programmatic navigation

**Exercise**:
Build a multi-page app with:
- Home page
- List page
- Detail page (with ID from URL)
- Form page
- 404 page

---

### 📅 Session 5: Konva Canvas & Annotations (4 hours)

**Topics**:
- What is Konva.js?
- Stage, Layer, and shapes
- Image rendering
- Mouse events (click, drag, move)
- Drawing rectangles dynamically
- Transforming shapes (resize, rotate)

**Hands-On**:
- Load thermal image on canvas
- Draw bounding boxes
- Implement drag to create box
- Add resize handles
- Export canvas as image

**Step-by-Step**:
1. Set up Stage and Layer
2. Load and display image
3. Draw static rectangles
4. Implement drawing mode
5. Add edit mode with Transformer
6. Export annotated image

---

### 📅 Session 6: Integration & Best Practices (3 hours)

**Topics**:
- Component composition patterns
- State lifting and prop drilling
- Custom hooks
- Error boundaries
- Performance optimization (React.memo, useMemo)
- Code organization

**Best Practices**:
1. Keep components small and focused
2. Extract reusable logic into custom hooks
3. Type everything with TypeScript
4. Handle loading and error states
5. Use meaningful variable names
6. Add comments for complex logic

**Real Project Review**:
- Walk through InspectionDetailNew.tsx
- Understand state management strategy
- Analyze API integration patterns
- Review AnnotationCanvas implementation

---

## 🎓 Summary

### Key Takeaways

1. **React Philosophy**: Build UIs with reusable components
2. **State Management**: useState for local state, useEffect for side effects
3. **TypeScript**: Type safety prevents bugs and improves developer experience
4. **API Integration**: Centralized API client with typed responses
5. **Routing**: React Router for multi-page SPA experience
6. **Canvas Interaction**: Konva.js for advanced 2D graphics and annotations

### TransX Frontend Architecture

```
┌────────────────────────────────────────────────────────────┐
│              TRANSX FRONTEND ARCHITECTURE                  │
├────────────────────────────────────────────────────────────┤
│                                                             │
│  📱 UI Layer                                               │
│     React Components (pages + components)                  │
│                                                             │
│  🔄 State Management Layer                                 │
│     useState + useEffect (local state per component)       │
│                                                             │
│  🌐 API Layer                                              │
│     Typed API clients (transformers, inspections, etc.)    │
│                                                             │
│  🎨 Canvas Layer                                           │
│     Konva.js for interactive annotation drawing            │
│                                                             │
│  🧭 Routing Layer                                          │
│     React Router for navigation                            │
│                                                             │
└────────────────────────────────────────────────────────────┘
```

### Component Hierarchy Recap

```
App (BrowserRouter)
 └─ Layout (Sidebar + Outlet)
     ├─ Dashboard
     ├─ TransformersList
     │   └─ TransformerDetail
     └─ InspectionsList
         └─ InspectionDetailNew
             ├─ AnnotationCanvas
             ├─ AnnotationToolbar
             ├─ AnnotationLegend
             ├─ NotesSection
             └─ CommentsSection
```

---

## 📚 Additional Resources

- **React Docs**: https://react.dev/
- **TypeScript**: https://www.typescriptlang.org/docs/
- **React Router**: https://reactrouter.com/
- **Konva.js**: https://konvajs.org/docs/
- **Vite**: https://vitejs.dev/

---

**End of Frontend Architecture Guide**
