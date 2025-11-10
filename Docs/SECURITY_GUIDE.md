# Security Guide - TransX Platform
## Comprehensive Security Approach for Multi-Layer Architecture

---

## 📋 Table of Contents
1. [Security Overview](#security-overview)
2. [Layer-by-Layer Security](#layer-by-layer-security)
3. [Authentication & Authorization](#authentication--authorization)
4. [Data Protection](#data-protection)
5. [Network Security](#network-security)
6. [Application Security](#application-security)
7. [Implementation Roadmap](#implementation-roadmap)
8. [Security Checklist](#security-checklist)

---

## Security Overview

### Current Security Status
```
┌────────────────────────────────────────────────────────────┐
│              CURRENT SECURITY POSTURE                       │
├────────────────────────────────────────────────────────────┤
│ ✅ IMPLEMENTED:                                            │
│   • CORS configuration (limited origins)                   │
│   • JPA/Hibernate (SQL injection prevention)               │
│   • React XSS protection (automatic escaping)              │
│   • File type validation (image uploads)                   │
│   • Soft delete (data retention)                           │
│                                                             │
│ ⚠️  MISSING (Critical):                                    │
│   • No user authentication                                 │
│   • No authorization/access control                        │
│   • No HTTPS/TLS encryption                                │
│   • No API rate limiting                                   │
│   • No input validation (comprehensive)                    │
│   • No security headers                                    │
│   • No audit logging                                       │
│   • No secrets management                                  │
└────────────────────────────────────────────────────────────┘
```

### Security Threat Model

```
┌─────────────────────────────────────────────────────────────────┐
│                    THREAT LANDSCAPE                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  HIGH RISK:                                                     │
│  ┌──────────────────────────────────────────────────────┐     │
│  │ 1. Unauthorized Access                               │     │
│  │    → No authentication = anyone can access          │     │
│  │    → No authorization = anyone can delete data      │     │
│  │                                                       │     │
│  │ 2. Data Breach                                       │     │
│  │    → No encryption in transit (HTTP)                │     │
│  │    → Database credentials in plain text             │     │
│  │                                                       │     │
│  │ 3. Injection Attacks                                 │     │
│  │    → Limited input validation                        │     │
│  │    → File upload vulnerabilities                     │     │
│  └──────────────────────────────────────────────────────┘     │
│                                                                  │
│  MEDIUM RISK:                                                   │
│  ┌──────────────────────────────────────────────────────┐     │
│  │ 4. Session Hijacking                                 │     │
│  │    → No session management                           │     │
│  │                                                       │     │
│  │ 5. CSRF Attacks                                      │     │
│  │    → No CSRF tokens                                  │     │
│  │                                                       │     │
│  │ 6. Denial of Service (DoS)                          │     │
│  │    → No rate limiting                                │     │
│  │    → Large file uploads not restricted              │     │
│  └──────────────────────────────────────────────────────┘     │
│                                                                  │
│  LOW RISK:                                                      │
│  ┌──────────────────────────────────────────────────────┐     │
│  │ 7. XSS (Cross-Site Scripting)                       │     │
│  │    → React auto-escapes (already protected)         │     │
│  │                                                       │     │
│  │ 8. SQL Injection                                     │     │
│  │    → JPA/Hibernate (already protected)              │     │
│  └──────────────────────────────────────────────────────┘     │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Layer-by-Layer Security

### 1. Frontend Security (React + TypeScript)

#### 1.1 Authentication Integration

```typescript
// src/contexts/AuthContext.tsx
import { createContext, useContext, useState, useEffect } from 'react';

interface User {
  id: string;
  username: string;
  role: 'ADMIN' | 'INSPECTOR' | 'VIEWER';
  permissions: string[];
}

interface AuthContextType {
  user: User | null;
  login: (username: string, password: string) => Promise<void>;
  logout: () => void;
  isAuthenticated: boolean;
  hasPermission: (permission: string) => boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [token, setToken] = useState<string | null>(
    localStorage.getItem('token')
  );

  useEffect(() => {
    if (token) {
      // Validate token and load user
      validateToken(token).then(setUser).catch(() => {
        localStorage.removeItem('token');
        setToken(null);
      });
    }
  }, [token]);

  const login = async (username: string, password: string) => {
    const response = await fetch('http://localhost:8080/api/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ username, password })
    });

    if (!response.ok) throw new Error('Login failed');

    const { token, user } = await response.json();
    localStorage.setItem('token', token);
    setToken(token);
    setUser(user);
  };

  const logout = () => {
    localStorage.removeItem('token');
    setToken(null);
    setUser(null);
  };

  const hasPermission = (permission: string) => {
    return user?.permissions.includes(permission) ?? false;
  };

  return (
    <AuthContext.Provider value={{
      user,
      login,
      logout,
      isAuthenticated: !!user,
      hasPermission
    }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth must be used within AuthProvider');
  return context;
};
```

#### 1.2 Protected Routes

```typescript
// src/components/ProtectedRoute.tsx
import { Navigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

interface ProtectedRouteProps {
  children: React.ReactNode;
  requiredPermission?: string;
}

export default function ProtectedRoute({ 
  children, 
  requiredPermission 
}: ProtectedRouteProps) {
  const { isAuthenticated, hasPermission } = useAuth();

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  if (requiredPermission && !hasPermission(requiredPermission)) {
    return <Navigate to="/unauthorized" replace />;
  }

  return <>{children}</>;
}

// Usage in App.tsx
<Route element={<Layout />}>
  <Route path="/" element={<Dashboard />} />
  <Route 
    path="/transformers" 
    element={
      <ProtectedRoute requiredPermission="VIEW_TRANSFORMERS">
        <TransformersList />
      </ProtectedRoute>
    } 
  />
  <Route 
    path="/inspections/:id" 
    element={
      <ProtectedRoute requiredPermission="EDIT_INSPECTIONS">
        <InspectionDetailNew />
      </ProtectedRoute>
    } 
  />
</Route>
```

#### 1.3 Secure API Client

```typescript
// src/api/client.ts
export const API_BASE = import.meta.env.VITE_API_BASE || 'http://localhost:8080';

export async function api<T>(
  path: string, 
  init?: RequestInit
): Promise<T> {
  // Get token from localStorage
  const token = localStorage.getItem('token');
  
  const headers = new Headers(init?.headers);
  
  // Add authorization header
  if (token) {
    headers.set('Authorization', `Bearer ${token}`);
  }
  
  // Add CSRF token (if using cookie-based auth)
  const csrfToken = getCookie('XSRF-TOKEN');
  if (csrfToken) {
    headers.set('X-XSRF-TOKEN', csrfToken);
  }
  
  const url = `${API_BASE}${path}`;
  
  const res = await fetch(url, {
    ...init,
    headers,
    credentials: 'include' // Send cookies
  }).catch(err => {
    throw new Error(`Network error: ${err.message}`);
  });
  
  // Handle 401 Unauthorized
  if (res.status === 401) {
    localStorage.removeItem('token');
    window.location.href = '/login';
    throw new Error('Session expired');
  }
  
  // Handle 403 Forbidden
  if (res.status === 403) {
    throw new Error('Access denied');
  }
  
  const text = await res.text();
  const isJson = res.headers.get('content-type')?.includes('application/json');
  
  if (!res.ok) {
    throw new Error(text || `HTTP ${res.status}`);
  }
  
  if (!text) return undefined as unknown as T;
  return isJson ? JSON.parse(text) : text as unknown as T;
}

function getCookie(name: string): string | null {
  const match = document.cookie.match(new RegExp('(^| )' + name + '=([^;]+)'));
  return match ? match[2] : null;
}
```

#### 1.4 Input Sanitization

```typescript
// src/utils/sanitize.ts
import DOMPurify from 'dompurify';

/**
 * Sanitize HTML to prevent XSS
 */
export function sanitizeHtml(dirty: string): string {
  return DOMPurify.sanitize(dirty, {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'p', 'br'],
    ALLOWED_ATTR: []
  });
}

/**
 * Sanitize file names
 */
export function sanitizeFileName(fileName: string): string {
  return fileName
    .replace(/[^a-zA-Z0-9._-]/g, '_') // Replace special chars
    .replace(/\.{2,}/g, '.')          // Prevent directory traversal
    .substring(0, 255);               // Limit length
}

/**
 * Validate file type
 */
export function validateFileType(file: File, allowedTypes: string[]): boolean {
  const fileType = file.type;
  const fileExt = file.name.split('.').pop()?.toLowerCase();
  
  return allowedTypes.some(type => {
    if (type.includes('*')) {
      // image/* matches image/png, image/jpeg, etc.
      return fileType.startsWith(type.replace('*', ''));
    }
    return fileType === type || fileExt === type;
  });
}

/**
 * Validate file size
 */
export function validateFileSize(file: File, maxSizeMB: number): boolean {
  return file.size <= maxSizeMB * 1024 * 1024;
}

// Usage
const handleFileUpload = (file: File) => {
  if (!validateFileType(file, ['image/jpeg', 'image/png'])) {
    throw new Error('Only JPEG and PNG images allowed');
  }
  
  if (!validateFileSize(file, 10)) {
    throw new Error('File size must be less than 10MB');
  }
  
  const sanitizedName = sanitizeFileName(file.name);
  // Proceed with upload
};
```

#### 1.5 Content Security Policy

```html
<!-- index.html -->
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    
    <!-- Security Headers -->
    <meta http-equiv="Content-Security-Policy" 
          content="default-src 'self'; 
                   script-src 'self' 'unsafe-inline'; 
                   style-src 'self' 'unsafe-inline'; 
                   img-src 'self' data: http://localhost:8080; 
                   connect-src 'self' http://localhost:8080 http://localhost:5001;
                   font-src 'self';
                   object-src 'none';
                   base-uri 'self';
                   form-action 'self';">
    
    <meta http-equiv="X-Content-Type-Options" content="nosniff">
    <meta http-equiv="X-Frame-Options" content="DENY">
    <meta http-equiv="X-XSS-Protection" content="1; mode=block">
    <meta name="referrer" content="strict-origin-when-cross-origin">
    
    <title>TransX Platform</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
```

---

### 2. Backend Security (Spring Boot + Java)

#### 2.1 Spring Security Configuration

```java
// src/main/java/org/en3350/backend/config/SecurityConfig.java
package org.en3350.backend.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true)
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthFilter;
    private final JwtAuthenticationEntryPoint jwtAuthEntryPoint;

    public SecurityConfig(
        JwtAuthenticationFilter jwtAuthFilter,
        JwtAuthenticationEntryPoint jwtAuthEntryPoint
    ) {
        this.jwtAuthFilter = jwtAuthFilter;
        this.jwtAuthEntryPoint = jwtAuthEntryPoint;
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            // Disable CSRF for stateless API (use JWT)
            .csrf(csrf -> csrf.disable())
            
            // Configure CORS
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            
            // Configure authorization
            .authorizeHttpRequests(auth -> auth
                // Public endpoints
                .requestMatchers("/api/auth/**").permitAll()
                .requestMatchers("/api/health").permitAll()
                
                // Protected endpoints
                .requestMatchers("/api/transformers/**").hasAnyRole("ADMIN", "INSPECTOR", "VIEWER")
                .requestMatchers("/api/inspections/**").hasAnyRole("ADMIN", "INSPECTOR")
                .requestMatchers("/api/annotations/**").hasAnyRole("ADMIN", "INSPECTOR")
                .requestMatchers("/api/images/**").hasAnyRole("ADMIN", "INSPECTOR")
                
                // Admin only
                .requestMatchers("/api/users/**").hasRole("ADMIN")
                .requestMatchers("/api/admin/**").hasRole("ADMIN")
                
                // All other requests must be authenticated
                .anyRequest().authenticated()
            )
            
            // Stateless session (JWT-based)
            .sessionManagement(session -> session
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            )
            
            // Exception handling
            .exceptionHandling(ex -> ex
                .authenticationEntryPoint(jwtAuthEntryPoint)
            )
            
            // Add JWT filter
            .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);
        
        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(12); // Strong encryption
    }

    @Bean
    public AuthenticationManager authenticationManager(
        AuthenticationConfiguration config
    ) throws Exception {
        return config.getAuthenticationManager();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(Arrays.asList("http://localhost:5173"));
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(Arrays.asList("*"));
        configuration.setAllowCredentials(true);
        configuration.setMaxAge(3600L);
        
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
```

#### 2.2 JWT Authentication

```java
// src/main/java/org/en3350/backend/security/JwtTokenProvider.java
package org.en3350.backend.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.util.Date;

@Component
public class JwtTokenProvider {

    @Value("${app.jwt.secret}")
    private String jwtSecret;

    @Value("${app.jwt.expiration:86400000}") // 24 hours default
    private long jwtExpirationMs;

    public String generateToken(Authentication authentication) {
        UserPrincipal userPrincipal = (UserPrincipal) authentication.getPrincipal();
        
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + jwtExpirationMs);

        SecretKey key = Keys.hmacShaKeyFor(jwtSecret.getBytes());

        return Jwts.builder()
                .setSubject(userPrincipal.getId().toString())
                .claim("username", userPrincipal.getUsername())
                .claim("role", userPrincipal.getRole())
                .setIssuedAt(now)
                .setExpiration(expiryDate)
                .signWith(key, SignatureAlgorithm.HS512)
                .compact();
    }

    public String getUserIdFromToken(String token) {
        SecretKey key = Keys.hmacShaKeyFor(jwtSecret.getBytes());
        
        Claims claims = Jwts.parserBuilder()
                .setSigningKey(key)
                .build()
                .parseClaimsJws(token)
                .getBody();

        return claims.getSubject();
    }

    public boolean validateToken(String token) {
        try {
            SecretKey key = Keys.hmacShaKeyFor(jwtSecret.getBytes());
            Jwts.parserBuilder()
                    .setSigningKey(key)
                    .build()
                    .parseClaimsJws(token);
            return true;
        } catch (SecurityException ex) {
            // Invalid signature
        } catch (MalformedJwtException ex) {
            // Invalid token
        } catch (ExpiredJwtException ex) {
            // Expired token
        } catch (UnsupportedJwtException ex) {
            // Unsupported token
        } catch (IllegalArgumentException ex) {
            // Empty claims
        }
        return false;
    }
}
```

#### 2.3 Method-Level Security

```java
// src/main/java/org/en3350/backend/service/InspectionService.java
package org.en3350.backend.service;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class InspectionService {

    @PreAuthorize("hasAnyRole('ADMIN', 'INSPECTOR')")
    public Inspection createInspection(CreateInspectionDTO dto, String userId) {
        // Only ADMIN and INSPECTOR can create
        // ...
    }

    @PreAuthorize("hasAnyRole('ADMIN', 'INSPECTOR', 'VIEWER')")
    public Inspection getInspection(String id) {
        // Anyone authenticated can view
        // ...
    }

    @PreAuthorize("hasRole('ADMIN') or @inspectionSecurity.isOwner(#id, authentication.name)")
    public Inspection updateInspection(String id, UpdateInspectionDTO dto) {
        // Only ADMIN or the inspector who created it
        // ...
    }

    @PreAuthorize("hasRole('ADMIN')")
    public void deleteInspection(String id) {
        // Only ADMIN can delete
        // ...
    }
}

// Custom security expression
@Component("inspectionSecurity")
public class InspectionSecurityExpression {
    
    private final InspectionRepo inspectionRepo;
    
    public InspectionSecurityExpression(InspectionRepo inspectionRepo) {
        this.inspectionRepo = inspectionRepo;
    }
    
    public boolean isOwner(String inspectionId, String username) {
        return inspectionRepo.findById(inspectionId)
                .map(inspection -> inspection.getInspectedBy().equals(username))
                .orElse(false);
    }
}
```

#### 2.4 Input Validation

```java
// src/main/java/org/en3350/backend/api/dto/CreateTransformerDTO.java
package org.en3350.backend.api.dto;

import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class CreateTransformerDTO {

    @NotBlank(message = "Transformer code is required")
    @Size(min = 3, max = 50, message = "Code must be 3-50 characters")
    @Pattern(regexp = "^[A-Z0-9-]+$", message = "Code must contain only uppercase letters, numbers, and hyphens")
    private String code;

    @NotBlank(message = "Location is required")
    @Size(max = 255, message = "Location must not exceed 255 characters")
    private String location;

    @NotNull(message = "Capacity is required")
    @Min(value = 1, message = "Capacity must be at least 1 kVA")
    @Max(value = 10000, message = "Capacity must not exceed 10000 kVA")
    private Integer capacityKVA;

    @Size(max = 100, message = "Region must not exceed 100 characters")
    private String region;

    @Pattern(regexp = "^[A-Z0-9-]*$", message = "Pole number must contain only uppercase letters, numbers, and hyphens")
    @Size(max = 50, message = "Pole number must not exceed 50 characters")
    private String poleNo;
}

// Controller with validation
@RestController
@RequestMapping("/api/transformers")
@Validated
public class TransformerController {

    @PostMapping
    public ResponseEntity<Transformer> createTransformer(
            @Valid @RequestBody CreateTransformerDTO dto
    ) {
        // @Valid triggers validation
        Transformer transformer = transformerService.create(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(transformer);
    }
}
```

#### 2.5 Rate Limiting

```java
// src/main/java/org/en3350/backend/config/RateLimitConfig.java
package org.en3350.backend.config;

import io.github.bucket4j.Bandwidth;
import io.github.bucket4j.Bucket;
import io.github.bucket4j.Refill;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.time.Duration;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Configuration
public class RateLimitConfig {

    @Bean
    public Map<String, Bucket> rateLimitBuckets() {
        return new ConcurrentHashMap<>();
    }

    public Bucket resolveBucket(String key) {
        return rateLimitBuckets().computeIfAbsent(key, k -> createNewBucket());
    }

    private Bucket createNewBucket() {
        // 100 requests per minute per IP/user
        Bandwidth limit = Bandwidth.classic(100, Refill.intervally(100, Duration.ofMinutes(1)));
        return Bucket.builder()
                .addLimit(limit)
                .build();
    }
}

// Rate limit interceptor
@Component
public class RateLimitInterceptor implements HandlerInterceptor {

    private final RateLimitConfig rateLimitConfig;

    public RateLimitInterceptor(RateLimitConfig rateLimitConfig) {
        this.rateLimitConfig = rateLimitConfig;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        String key = getClientKey(request);
        Bucket bucket = rateLimitConfig.resolveBucket(key);

        if (bucket.tryConsume(1)) {
            return true;
        } else {
            response.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
            response.getWriter().write("Too many requests");
            return false;
        }
    }

    private String getClientKey(HttpServletRequest request) {
        // Use IP address or user ID
        String userId = (String) request.getAttribute("userId");
        return userId != null ? userId : request.getRemoteAddr();
    }
}
```

#### 2.6 Secure File Upload

```java
// src/main/java/org/en3350/backend/service/ThermalImageService.java
package org.en3350.backend.service;

import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

@Service
public class ThermalImageService {

    private static final List<String> ALLOWED_CONTENT_TYPES = Arrays.asList(
            "image/jpeg",
            "image/png",
            "image/jpg"
    );

    private static final List<String> ALLOWED_EXTENSIONS = Arrays.asList(
            "jpg", "jpeg", "png"
    );

    private static final long MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB

    @Value("${app.storage.root}")
    private String storageRoot;

    public ThermalImage uploadImage(MultipartFile file, String transformerId, ImageType type) {
        // 1. Validate file is not empty
        if (file.isEmpty()) {
            throw new IllegalArgumentException("File is empty");
        }

        // 2. Validate file size
        if (file.getSize() > MAX_FILE_SIZE) {
            throw new IllegalArgumentException("File size exceeds 10MB limit");
        }

        // 3. Validate content type
        String contentType = file.getContentType();
        if (!ALLOWED_CONTENT_TYPES.contains(contentType)) {
            throw new IllegalArgumentException("Invalid file type. Only JPEG and PNG allowed.");
        }

        // 4. Validate file extension
        String originalFilename = file.getOriginalFilename();
        if (originalFilename == null || !isValidExtension(originalFilename)) {
            throw new IllegalArgumentException("Invalid file extension");
        }

        // 5. Sanitize filename
        String sanitizedFilename = sanitizeFilename(originalFilename);

        // 6. Generate unique filename to prevent overwrites
        String uniqueFilename = UUID.randomUUID().toString() + "_" + sanitizedFilename;

        // 7. Create safe storage path
        Path uploadPath = Paths.get(storageRoot, transformerId, type.toString().toLowerCase());
        
        try {
            // Create directories if they don't exist
            Files.createDirectories(uploadPath);

            // 8. Validate path (prevent directory traversal)
            Path targetPath = uploadPath.resolve(uniqueFilename).normalize();
            if (!targetPath.startsWith(uploadPath)) {
                throw new SecurityException("Invalid file path");
            }

            // 9. Save file
            Files.copy(file.getInputStream(), targetPath);

            // 10. Verify file is actually an image (magic number check)
            if (!isValidImage(targetPath)) {
                Files.deleteIfExists(targetPath);
                throw new IllegalArgumentException("File is not a valid image");
            }

            // 11. Create database record
            ThermalImage image = new ThermalImage();
            image.setFileName(uniqueFilename);
            image.setFilePath(targetPath.toString());
            image.setFileSize(file.getSize());
            image.setType(type);
            // ... set other fields

            return thermalImageRepo.save(image);

        } catch (IOException e) {
            throw new RuntimeException("Failed to store file", e);
        }
    }

    private boolean isValidExtension(String filename) {
        String extension = filename.substring(filename.lastIndexOf(".") + 1).toLowerCase();
        return ALLOWED_EXTENSIONS.contains(extension);
    }

    private String sanitizeFilename(String filename) {
        // Remove path separators and special characters
        return filename
                .replaceAll("[^a-zA-Z0-9._-]", "_")
                .replaceAll("\\.{2,}", ".")
                .substring(0, Math.min(filename.length(), 255));
    }

    private boolean isValidImage(Path path) throws IOException {
        // Check magic numbers (file signatures)
        byte[] bytes = Files.readAllBytes(path);
        
        // JPEG magic number: FF D8 FF
        if (bytes.length >= 3 && 
            bytes[0] == (byte) 0xFF && 
            bytes[1] == (byte) 0xD8 && 
            bytes[2] == (byte) 0xFF) {
            return true;
        }
        
        // PNG magic number: 89 50 4E 47
        if (bytes.length >= 4 && 
            bytes[0] == (byte) 0x89 && 
            bytes[1] == (byte) 0x50 && 
            bytes[2] == (byte) 0x4E && 
            bytes[3] == (byte) 0x47) {
            return true;
        }
        
        return false;
    }
}
```

#### 2.7 Audit Logging

```java
// src/main/java/org/en3350/backend/audit/AuditLog.java
package org.en3350.backend.audit;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Entity
@Table(name = "audit_logs")
@Data
public class AuditLog {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private String userId;
    
    @Column(nullable = false)
    private String action; // CREATE, UPDATE, DELETE, VIEW, EXPORT
    
    @Column(nullable = false)
    private String entityType; // Transformer, Inspection, Annotation
    
    @Column(nullable = false)
    private String entityId;
    
    @Column(length = 1000)
    private String details;
    
    @Column(nullable = false)
    private String ipAddress;
    
    @Column(nullable = false)
    private LocalDateTime timestamp;
    
    @Column
    private Boolean success;
    
    @Column(length = 500)
    private String errorMessage;
}

// Audit aspect
@Aspect
@Component
public class AuditAspect {
    
    private final AuditLogRepository auditLogRepo;
    private final HttpServletRequest request;
    
    @Around("@annotation(auditable)")
    public Object auditMethod(ProceedingJoinPoint joinPoint, Auditable auditable) throws Throwable {
        AuditLog log = new AuditLog();
        log.setAction(auditable.action());
        log.setEntityType(auditable.entityType());
        log.setTimestamp(LocalDateTime.now());
        log.setIpAddress(request.getRemoteAddr());
        log.setUserId(SecurityContextHolder.getContext().getAuthentication().getName());
        
        try {
            Object result = joinPoint.proceed();
            log.setSuccess(true);
            return result;
        } catch (Exception e) {
            log.setSuccess(false);
            log.setErrorMessage(e.getMessage());
            throw e;
        } finally {
            auditLogRepo.save(log);
        }
    }
}

// Usage
@Auditable(action = "DELETE", entityType = "INSPECTION")
public void deleteInspection(String id) {
    // ...
}
```

---

### 3. ML Service Security (Flask + Python)

#### 3.1 API Key Authentication

```python
# ml-service/app.py
from functools import wraps
from flask import Flask, request, jsonify
import os

app = Flask(__name__)

# API Key from environment variable
API_KEY = os.getenv('ML_SERVICE_API_KEY', 'your-secret-api-key')

def require_api_key(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        # Check API key in header
        api_key = request.headers.get('X-API-Key')
        
        if not api_key:
            return jsonify({'error': 'API key required'}), 401
        
        if api_key != API_KEY:
            return jsonify({'error': 'Invalid API key'}), 403
        
        return f(*args, **kwargs)
    return decorated_function

@app.route('/api/detect', methods=['POST'])
@require_api_key
def detect_anomalies():
    # Protected endpoint
    pass
```

#### 3.2 Input Validation

```python
# ml-service/validators.py
import os
from pathlib import Path

ALLOWED_IMAGE_EXTENSIONS = {'.jpg', '.jpeg', '.png'}
MAX_IMAGE_SIZE_MB = 50
UPLOAD_BASE_PATH = Path('/path/to/uploads')

def validate_image_path(image_path: str) -> bool:
    """Validate image path to prevent directory traversal"""
    try:
        # Convert to Path object
        path = Path(image_path).resolve()
        
        # 1. Check if file exists
        if not path.exists():
            raise ValueError(f"Image file does not exist: {image_path}")
        
        # 2. Check if it's a file (not directory)
        if not path.is_file():
            raise ValueError(f"Path is not a file: {image_path}")
        
        # 3. Prevent directory traversal - ensure path is within upload directory
        if not str(path).startswith(str(UPLOAD_BASE_PATH.resolve())):
            raise ValueError(f"Invalid image path (outside upload directory): {image_path}")
        
        # 4. Check file extension
        if path.suffix.lower() not in ALLOWED_IMAGE_EXTENSIONS:
            raise ValueError(f"Invalid file extension: {path.suffix}")
        
        # 5. Check file size
        file_size_mb = path.stat().st_size / (1024 * 1024)
        if file_size_mb > MAX_IMAGE_SIZE_MB:
            raise ValueError(f"File too large: {file_size_mb:.2f}MB (max {MAX_IMAGE_SIZE_MB}MB)")
        
        return True
        
    except Exception as e:
        logger.error(f"Image path validation failed: {e}")
        raise

def validate_confidence_threshold(threshold: float) -> bool:
    """Validate confidence threshold"""
    if not isinstance(threshold, (int, float)):
        raise ValueError("Threshold must be a number")
    
    if not 0.0 <= threshold <= 1.0:
        raise ValueError("Threshold must be between 0.0 and 1.0")
    
    return True

# Usage in app.py
@app.route('/api/detect', methods=['POST'])
@require_api_key
def detect_anomalies():
    try:
        data = request.json
        
        # Validate inputs
        inspection_path = data.get('inspection_image_path')
        baseline_path = data.get('baseline_image_path')
        threshold = data.get('confidence_threshold', 0.25)
        
        validate_image_path(inspection_path)
        if baseline_path:
            validate_image_path(baseline_path)
        validate_confidence_threshold(threshold)
        
        # Proceed with detection
        # ...
        
    except ValueError as e:
        return jsonify({'error': str(e)}), 400
    except Exception as e:
        logger.error(f"Detection failed: {e}")
        return jsonify({'error': 'Internal server error'}), 500
```

#### 3.3 Rate Limiting

```python
# ml-service/rate_limit.py
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

limiter = Limiter(
    app=app,
    key_func=get_remote_address,
    default_limits=["200 per day", "50 per hour"],
    storage_uri="memory://"
)

@app.route('/api/detect', methods=['POST'])
@require_api_key
@limiter.limit("10 per minute")  # ML inference is expensive
def detect_anomalies():
    # Protected endpoint
    pass

@app.route('/api/feedback/upload', methods=['POST'])
@require_api_key
@limiter.limit("5 per hour")  # Training is very expensive
def upload_feedback():
    # Protected endpoint
    pass
```

---

### 4. Database Security (MySQL)

#### 4.1 Connection Security

```properties
# application.properties - SECURE CONFIGURATION

# Database connection with SSL
spring.datasource.url=jdbc:mysql://localhost:3306/en3350_db?useSSL=true&requireSSL=true&verifyServerCertificate=true
spring.datasource.username=${DB_USERNAME}  # From environment variable
spring.datasource.password=${DB_PASSWORD}  # From environment variable

# Connection pool security
spring.datasource.hikari.maximum-pool-size=10
spring.datasource.hikari.minimum-idle=2
spring.datasource.hikari.connection-timeout=30000
spring.datasource.hikari.idle-timeout=600000
spring.datasource.hikari.max-lifetime=1800000

# JPA security
spring.jpa.show-sql=false  # Don't log SQL in production
spring.jpa.properties.hibernate.format_sql=false
spring.jpa.open-in-view=false  # Prevent lazy loading issues
```

#### 4.2 Database User Permissions

```sql
-- Create separate users for different purposes

-- Application user (limited permissions)
CREATE USER 'transx_app'@'localhost' IDENTIFIED BY 'strong_password_here';
GRANT SELECT, INSERT, UPDATE ON en3350_db.* TO 'transx_app'@'localhost';
-- No DELETE permission - use soft delete only
-- No DROP, CREATE, ALTER permissions

-- Read-only user (for reporting)
CREATE USER 'transx_readonly'@'localhost' IDENTIFIED BY 'strong_password_here';
GRANT SELECT ON en3350_db.* TO 'transx_readonly'@'localhost';

-- Admin user (for migrations only)
CREATE USER 'transx_admin'@'localhost' IDENTIFIED BY 'strong_password_here';
GRANT ALL PRIVILEGES ON en3350_db.* TO 'transx_admin'@'localhost';

FLUSH PRIVILEGES;
```

#### 4.3 Encryption at Rest

```sql
-- Enable encryption for sensitive columns

-- For MySQL 8.0+, use transparent data encryption (TDE)
ALTER TABLE transformers ENCRYPTION='Y';
ALTER TABLE thermal_images ENCRYPTION='Y';
ALTER TABLE inspections ENCRYPTION='Y';
ALTER TABLE annotations ENCRYPTION='Y';

-- For application-level encryption (Java)
```

```java
// Encrypt sensitive data before storing
@Entity
public class User {
    
    @Column(nullable = false)
    private String username;
    
    @Column(nullable = false)
    @Convert(converter = AttributeEncryptor.class)
    private String email;  // Encrypted in database
    
    @Column(nullable = false)
    private String passwordHash;  // Already hashed with BCrypt
}

@Converter
public class AttributeEncryptor implements AttributeConverter<String, String> {
    
    @Value("${app.encryption.key}")
    private String encryptionKey;
    
    @Override
    public String convertToDatabaseColumn(String attribute) {
        // Encrypt using AES-256
        try {
            Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
            SecretKeySpec keySpec = new SecretKeySpec(encryptionKey.getBytes(), "AES");
            cipher.init(Cipher.ENCRYPT_MODE, keySpec);
            byte[] encrypted = cipher.doFinal(attribute.getBytes());
            return Base64.getEncoder().encodeToString(encrypted);
        } catch (Exception e) {
            throw new RuntimeException("Encryption failed", e);
        }
    }
    
    @Override
    public String convertToEntityAttribute(String dbData) {
        // Decrypt
        try {
            Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
            SecretKeySpec keySpec = new SecretKeySpec(encryptionKey.getBytes(), "AES");
            cipher.init(Cipher.DECRYPT_MODE, keySpec);
            byte[] decrypted = cipher.doFinal(Base64.getDecoder().decode(dbData));
            return new String(decrypted);
        } catch (Exception e) {
            throw new RuntimeException("Decryption failed", e);
        }
    }
}
```

---

### 5. Network Security

#### 5.1 HTTPS/TLS Configuration

```nginx
# Nginx reverse proxy configuration

server {
    listen 80;
    server_name transx.example.com;
    
    # Redirect all HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name transx.example.com;

    # SSL Certificate
    ssl_certificate /etc/ssl/certs/transx.crt;
    ssl_certificate_key /etc/ssl/private/transx.key;

    # Strong SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';" always;

    # Frontend static files
    location / {
        root /var/www/transx/frontend;
        try_files $uri $uri/ /index.html;
    }

    # Backend API
    location /api/ {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # ML Service (internal only - not exposed publicly)
    location /ml-api/ {
        # Only allow from backend server
        allow 127.0.0.1;
        deny all;
        
        proxy_pass http://localhost:5001/api/;
    }

    # Uploaded files
    location /uploads/ {
        # Prevent execution of uploaded files
        location ~ \.(php|jsp|asp|cgi)$ {
            deny all;
        }
        
        alias /var/transx/uploads/;
        
        # Force download for unknown types
        add_header Content-Disposition "attachment";
    }
}
```

#### 5.2 Firewall Rules

```bash
# UFW (Uncomplicated Firewall) configuration

# Default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH (restrict to specific IPs in production)
sudo ufw allow from 203.0.113.0/24 to any port 22

# Allow HTTP/HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Allow MySQL only from localhost
sudo ufw allow from 127.0.0.1 to any port 3306

# Backend port (internal only)
sudo ufw allow from 127.0.0.1 to any port 8080

# ML service port (internal only)
sudo ufw allow from 127.0.0.1 to any port 5001

# Enable firewall
sudo ufw enable
```

---

### 6. Secrets Management

#### 6.1 Environment Variables

```bash
# .env file (NEVER commit to Git)

# Database
DB_USERNAME=transx_app
DB_PASSWORD=your-strong-database-password-here
DB_HOST=localhost
DB_PORT=3306
DB_NAME=en3350_db

# JWT
JWT_SECRET=your-256-bit-secret-key-here-use-openssl-rand-base64-32
JWT_EXPIRATION=86400000

# Encryption
ENCRYPTION_KEY=your-aes-256-encryption-key-here

# ML Service
ML_SERVICE_URL=http://localhost:5001
ML_SERVICE_API_KEY=your-ml-api-key-here

# File Storage
STORAGE_ROOT=/var/transx/uploads

# CORS
ALLOWED_ORIGINS=https://transx.example.com

# Email (for notifications)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@example.com
SMTP_PASSWORD=your-email-password
```

```java
// application.properties - reference environment variables
spring.datasource.url=jdbc:mysql://${DB_HOST}:${DB_PORT}/${DB_NAME}
spring.datasource.username=${DB_USERNAME}
spring.datasource.password=${DB_PASSWORD}

app.jwt.secret=${JWT_SECRET}
app.jwt.expiration=${JWT_EXPIRATION}

app.storage.root=${STORAGE_ROOT}
app.cors.allowed-origins=${ALLOWED_ORIGINS}
```

#### 6.2 Secrets in Production

```yaml
# Docker Compose with secrets
version: '3.8'

services:
  backend:
    image: transx-backend:latest
    environment:
      DB_USERNAME_FILE: /run/secrets/db_username
      DB_PASSWORD_FILE: /run/secrets/db_password
      JWT_SECRET_FILE: /run/secrets/jwt_secret
    secrets:
      - db_username
      - db_password
      - jwt_secret

secrets:
  db_username:
    external: true
  db_password:
    external: true
  jwt_secret:
    external: true
```

---

## Implementation Roadmap

### Phase 1: Critical Security (Week 1-2)

```
Priority: HIGH - Implement immediately

1. Authentication & Authorization
   ├── Set up Spring Security
   ├── Implement JWT authentication
   ├── Create user management system
   ├── Add role-based access control
   └── Protect all API endpoints

2. HTTPS/TLS
   ├── Obtain SSL certificate
   ├── Configure Nginx reverse proxy
   ├── Force HTTPS redirect
   └── Update CORS for HTTPS

3. Input Validation
   ├── Add @Valid annotations to all DTOs
   ├── Validate file uploads (type, size, content)
   ├── Sanitize user inputs
   └── Add request body size limits

Estimated Time: 40-60 hours
```

### Phase 2: Data Protection (Week 3)

```
Priority: HIGH

1. Database Security
   ├── Create separate DB users with limited permissions
   ├── Enable SSL for MySQL connections
   ├── Store credentials in environment variables
   └── Enable encryption at rest (TDE)

2. Secrets Management
   ├── Move all secrets to environment variables
   ├── Set up secrets management (Vault/AWS Secrets Manager)
   ├── Rotate database passwords
   └── Generate strong JWT secret

3. Audit Logging
   ├── Implement audit log table
   ├── Add @Auditable aspect
   ├── Log all sensitive operations
   └── Set up log monitoring

Estimated Time: 20-30 hours
```

### Phase 3: Enhanced Security (Week 4)

```
Priority: MEDIUM

1. Rate Limiting
   ├── Add Bucket4j dependency
   ├── Implement rate limit interceptor
   ├── Configure limits per endpoint
   └── Add rate limit headers

2. Security Headers
   ├── Configure Content Security Policy
   ├── Add X-Frame-Options, X-XSS-Protection
   ├── Set up HSTS
   └── Configure referrer policy

3. ML Service Security
   ├── Add API key authentication
   ├── Implement rate limiting
   ├── Validate all input paths
   └── Restrict network access

Estimated Time: 15-20 hours
```

### Phase 4: Monitoring & Hardening (Week 5)

```
Priority: LOW

1. Security Monitoring
   ├── Set up intrusion detection
   ├── Configure log aggregation (ELK stack)
   ├── Add security alerts
   └── Implement anomaly detection

2. Penetration Testing
   ├── Run OWASP ZAP scan
   ├── Test for common vulnerabilities
   ├── Fix identified issues
   └── Document security posture

3. Compliance
   ├── GDPR compliance check
   ├── Create privacy policy
   ├── Implement data retention policy
   └── Add data export functionality

Estimated Time: 20-30 hours
```

---

## Security Checklist

### ✅ Pre-Deployment Checklist

```
Authentication & Authorization:
☐ Users must log in to access the system
☐ Passwords are hashed with BCrypt (cost factor ≥12)
☐ JWT tokens expire after reasonable time (24 hours)
☐ Role-based access control is enforced
☐ Session management is secure (stateless JWT)

Input Validation:
☐ All user inputs are validated (frontend + backend)
☐ File uploads are restricted (type, size, content)
☐ SQL injection is prevented (using JPA/prepared statements)
☐ XSS is prevented (React escapes output)
☐ Path traversal is prevented (file uploads)

Data Protection:
☐ HTTPS/TLS is enforced
☐ Database credentials are in environment variables
☐ JWT secret is strong and rotated regularly
☐ Sensitive data is encrypted in database
☐ Backups are encrypted

Network Security:
☐ Firewall is configured (UFW/iptables)
☐ Only necessary ports are open
☐ CORS is configured for specific origins only
☐ Rate limiting is implemented
☐ DDoS protection is in place

Application Security:
☐ Dependencies are up to date (no known vulnerabilities)
☐ Security headers are set (CSP, HSTS, etc.)
☐ Error messages don't leak sensitive info
☐ Audit logging is enabled
☐ Admin functions are restricted

File Security:
☐ Uploaded files are stored outside web root
☐ File extensions are validated
☐ File content (magic numbers) is verified
☐ Uploaded files cannot be executed
☐ File size limits are enforced

ML Service Security:
☐ ML API requires authentication
☐ Input paths are validated (no traversal)
☐ Rate limiting prevents abuse
☐ Model weights are protected
☐ Inference timeout is set
```

---

## Conclusion

### Security Implementation Priority

```
1. ⚠️  CRITICAL (Do First):
   • Authentication & Authorization
   • HTTPS/TLS
   • Input Validation
   • Secrets Management

2. ⚡ HIGH (Do Soon):
   • Database Security
   • Audit Logging
   • Rate Limiting
   • File Upload Security

3. 🔧 MEDIUM (Nice to Have):
   • Security Headers
   • ML Service Hardening
   • CSRF Protection
   • Session Management

4. 📊 LOW (Future):
   • Security Monitoring
   • Intrusion Detection
   • Penetration Testing
   • Compliance Audits
```

### Estimated Total Implementation Time
- **Phase 1 (Critical)**: 40-60 hours
- **Phase 2 (High)**: 20-30 hours
- **Phase 3 (Medium)**: 15-20 hours
- **Phase 4 (Low)**: 20-30 hours
- **Total**: 95-140 hours (12-18 working days)

### Resources
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Spring Security Documentation](https://spring.io/projects/spring-security)
- [JWT Best Practices](https://tools.ietf.org/html/rfc8725)
- [React Security](https://reactjs.org/docs/dom-elements.html#dangerouslysetinnerhtml)

---

**Last Updated**: October 26, 2025  
**Project**: TransX - Transformer Maintenance Platform  
**Security Level**: Currently LOW → Target: HIGH
