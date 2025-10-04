import React, { useEffect, useState } from "react";
import { getAnnotationsByInspection } from "../api/annotations";

interface BBox {
  x1: number;
  y1: number;
  x2: number;
  y2: number;
}

interface AnnotationHistoryItem {
  id: string;
  annotation_number?: number;
  class_name?: string;
  source: string;
  action_type: string;
  created_by: string;
  created_at: string;
  bbox?: BBox;
  area?: number;
  confidence?: number;
  version?: number;
}

interface Props {
  inspectionId: string;
}

const HistoryList: React.FC<Props> = ({ inspectionId }) => {
  const [history, setHistory] = useState<AnnotationHistoryItem[]>([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    async function load() {
      setLoading(true);
      try {
        const data = await getAnnotationsByInspection(inspectionId);
        setHistory(data || []);
      } catch (err) {
        console.error("Failed to load history", err);
        setHistory([]);
      } finally {
        setLoading(false);
      }
    }
    if (inspectionId) load();
  }, [inspectionId]);

  if (loading) {
    return <div>Loading annotation history...</div>;
  }

  if (!history || history.length === 0) {
    return (
      <div
        style={{
          padding: "1rem",
          borderRadius: "8px",
          background: "#f9fafb",
          border: "1px solid #e5e7eb",
          textAlign: "center",
          color: "#6b7280",
          fontSize: "14px",
          fontStyle: "italic",
        }}
      >
        No saved annotations yet.
      </div>
    );
  }

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "12px" }}>
      {history.map((item, idx) => {
        const colorMap: Record<string, string> = {
          Faulty: "#ef4444",
          faulty_loose_joint: "#22c55e",
          faulty_point_overload: "#3b82f6",
          potential_faulty: "#eab308",
        };
        const color = colorMap[item.class_name || ""] || "#6b7280";

        return (
          <div
            key={item.id}
            style={{
              border: `2px solid ${color}`,
              borderRadius: "8px",
              padding: "12px",
              background: `${color}11`,
            }}
          >
            {/* Header */}
            <div
              style={{
                display: "flex",
                justifyContent: "space-between",
                marginBottom: "8px",
              }}
            >
              <div>
                <div
                  style={{ fontWeight: "600", fontSize: "14px", color }}
                >
                  #{item.annotation_number ?? idx + 1} ·{" "}
                  {item.class_name || "Unknown"}
                </div>
                <div
                  style={{
                    fontSize: "12px",
                    color: "#6b7280",
                    marginTop: "2px",
                  }}
                >
                  {item.source === "ai" ? "🤖 AI Detection" : "👤 Manual"} ·{" "}
                  {item.action_type} ·{" "}
                  {item.confidence ? `${item.confidence}% confidence` : ""}
                </div>
              </div>
              <div
                style={{
                  fontSize: "11px",
                  color: "#6b7280",
                  background: "white",
                  padding: "2px 6px",
                  borderRadius: "4px",
                }}
              >
                v{item.version ?? "?"}
              </div>
            </div>

            {/* BBox + Size */}
            {item.bbox && (
              <div
                style={{
                  fontSize: "12px",
                  color: "#6b7280",
                  marginBottom: "6px",
                }}
                >
                <b>BBox:</b> ({item.bbox.x1}, {item.bbox.y1}) → ({item.bbox.x2}, {item.bbox.y2})
                <br />
                <b>Size:</b> {Math.abs(item.bbox.x2 - item.bbox.x1) * Math.abs(item.bbox.y2 - item.bbox.y1)} 
              </div>
            )}
            {item.area && (
              <div
                style={{
                  fontSize: "12px",
                  color: "#6b7280",
                  marginBottom: "6px",
                }}
              >
                <b>Area:</b> {item.area} px²
              </div>
            )}

            {/* Time */}
            <div style={{ fontSize: "12px", color: "#6b7280" }}>
            <b>Time:</b>{" "}
            {(item.created_at || item.createdAt)
            ? new Date(item.created_at || item.createdAt).toLocaleString("en-US", {
                  dateStyle: "short",
                  timeStyle: "short",
            })
            : "N/A"}

            </div>
          </div>
        );
      })}
    </div>
  );
};

export default HistoryList;
