// import React, { useEffect, useState } from "react";
// import { getAnnotationsByInspection } from "../api/annotations";

// interface BBox {
//   x1: number;
//   y1: number;
//   x2: number;
//   y2: number;
// }

// interface AnnotationHistoryItem {
//   id: string;
//   annotation_number?: number;
//   class_name?: string;
//   source: string;
//   action_type: string;
//   created_by: string;
//   created_at: string;
//   bbox?: BBox;
//   area?: number;
//   confidence?: number;
//   version?: number;
// }

// interface Props {
//   inspectionId: string;
// }

// const HistoryList: React.FC<Props> = ({ inspectionId }) => {
//   const [history, setHistory] = useState<AnnotationHistoryItem[]>([]);
//   const [loading, setLoading] = useState(false);

//   useEffect(() => {
//     async function load() {
//       setLoading(true);
//       try {
//         const data = await getAnnotationsByInspection(inspectionId);
//         setHistory(data || []);
//       } catch (err) {
//         console.error("Failed to load history", err);
//         setHistory([]);
//       } finally {
//         setLoading(false);
//       }
//     }
//     if (inspectionId) load();
//   }, [inspectionId]);

//   if (loading) {
//     return <div>Loading annotation history...</div>;
//   }

//   if (!history || history.length === 0) {
//     return (
//       <div
//         style={{
//           padding: "1rem",
//           borderRadius: "8px",
//           background: "#f9fafb",
//           border: "1px solid #e5e7eb",
//           textAlign: "center",
//           color: "#6b7280",
//           fontSize: "14px",
//           fontStyle: "italic",
//         }}
//       >
//         No saved annotations yet.
//       </div>
//     );
//   }

//   return (
//     <div style={{ display: "flex", flexDirection: "column", gap: "12px" }}>
//       {history.map((item, idx) => {
//         const colorMap: Record<string, string> = {
//           Faulty: "#ef4444",
//           faulty_loose_joint: "#22c55e",
//           faulty_point_overload: "#3b82f6",
//           potential_faulty: "#eab308",
//         };
//         const color = colorMap[item.class_name || ""] || "#6b7280";

//         return (
//           <div
//             key={item.id}
//             style={{
//               border: `2px solid ${color}`,
//               borderRadius: "8px",
//               padding: "12px",
//               background: `${color}11`,
//             }}
//           >
//             {/* Header */}
//             <div
//               style={{
//                 display: "flex",
//                 justifyContent: "space-between",
//                 marginBottom: "8px",
//               }}
//             >
//               <div>
//                 <div
//                   style={{ fontWeight: "600", fontSize: "14px", color }}
//                 >
//                   #{item.annotation_number ?? idx + 1} ·{" "}
//                   {item.class_name || "Unknown"}
//                 </div>
//                 <div
//                   style={{
//                     fontSize: "12px",
//                     color: "#6b7280",
//                     marginTop: "2px",
//                   }}
//                 >
//                   {item.source === "ai" ? "🤖 AI Detection" : "👤 Manual"} ·{" "}
//                   {item.action_type} ·{" "}
//                   {item.confidence ? `${item.confidence}% confidence` : ""}
//                 </div>
//               </div>
//               <div
//                 style={{
//                   fontSize: "11px",
//                   color: "#6b7280",
//                   background: "white",
//                   padding: "2px 6px",
//                   borderRadius: "4px",
//                 }}
//               >
//                 v{item.version ?? "?"}
//               </div>
//             </div>

//             {/* BBox + Area */}
//             {item.bbox && (
//               <div
//                 style={{
//                   fontSize: "12px",
//                   color: "#6b7280",
//                   marginBottom: "6px",
//                 }}
//               >
//                 <b>BBox:</b> ({item.bbox.x1}, {item.bbox.y1}) → ({item.bbox.x2},{" "}
//                 {item.bbox.y2})
//               </div>
//             )}
//             {item.area && (
//               <div
//                 style={{
//                   fontSize: "12px",
//                   color: "#6b7280",
//                   marginBottom: "6px",
//                 }}
//               >
//                 <b>Area:</b> {item.area} px²
//               </div>
//             )}

//             {/* Time */}
//             <div style={{ fontSize: "12px", color: "#6b7280" }}>
//               <b>Time:</b>{" "}
//               {new Date(item.created_at).toLocaleString("en-US", {
//                 dateStyle: "short",
//                 timeStyle: "short",
//               })}
//             </div>
//           </div>
//         );
//       })}
//     </div>
//   );
// };

// export default HistoryList;

import React from "react";
import type { Annotation } from "../api/annotations";

interface Props {
  history: Annotation[] | undefined;
}

const HistoryList: React.FC<Props> = ({ history }) => {
  if (!history || history.length === 0) {
    return (
      <div
        style={{
          padding: "1rem",
          borderRadius: "8px",
          background: "#fff",
          border: "1px solid #e5e7eb",
          boxShadow: "0 1px 2px rgba(0,0,0,0.05)",
          fontStyle: "italic",
          color: "#6b7280",
        }}
      >
        No saved annotations yet.
      </div>
    );
  }

  const areaFromBbox = (b?: { x1: number; y1: number; x2: number; y2: number }) => {
    if (!b) return null;
    const w = Math.abs(b.x2 - b.x1);
    const h = Math.abs(b.y2 - b.y1);
    return Math.max(0, Math.round(w * h));
  };

  return (
    <div style={{ display: "grid", gap: "0.75rem" }}>
      {history.map((item) => {
        const area = areaFromBbox(item.bbox as any);
        return (
          <div
            key={item.id}
            style={{
              background: "#fff",
              border: "1px solid #e5e7eb",
              borderRadius: "8px",
              padding: "0.75rem 1rem",
              boxShadow: "0 1px 2px rgba(0,0,0,0.05)",
            }}
          >
            <div style={{ display: "flex", justifyContent: "space-between", marginBottom: "0.25rem" }}>
              <div style={{ fontWeight: 600, fontSize: "0.95rem" }}>
                #{item.annotationNumber ?? "NaN"} · {item.className || "Unknown"}{" "}
                {item.confidence != null ? `${Math.round(item.confidence * 100)}% confidence` : ""}
              </div>
              <div
                style={{
                  background: "#f3f4f6",
                  borderRadius: "6px",
                  padding: "2px 6px",
                  fontSize: "0.75rem",
                }}
              >
                v{item.version ?? "?"}
              </div>
            </div>

            <div style={{ fontSize: "0.85rem", color: "#4b5563" }}>
              <div>{item.source === "ai" ? "🤖 AI Detection" : "👤 Manual"} · {item.actionType}</div>
              {item.bbox && (
                <div>
                  <b>BBox:</b> ({Math.round(item.bbox.x1)}, {Math.round(item.bbox.y1)}) → (
                  {Math.round(item.bbox.x2)}, {Math.round(item.bbox.y2)})
                </div>
              )}
              <div><b>Area:</b> {area !== null ? `${area} px²` : "N/A px²"}</div>
              <div>
                <b>Time:</b>{" "}
                {item.createdAt
                  ? new Date(item.createdAt).toLocaleString("en-US", { dateStyle: "short", timeStyle: "short" })
                  : "Unknown"}
              </div>
            </div>
          </div>
        );
      })}
    </div>
  );
};

export default HistoryList;
