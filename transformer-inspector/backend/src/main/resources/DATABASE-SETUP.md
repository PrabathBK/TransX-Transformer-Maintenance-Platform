# Database Setup (MySQL)

The backend is configured to use **MySQL** instead of the in-memory H2 database.

## Prerequisites
- MySQL installed locally (e.g., MySQL 8.x)
- Database created: `en3350_db`
- User credentials set (update in `application.properties` if needed)

## Configuration

Update `backend/src/main/resources/application.properties`:

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/en3350_db
spring.datasource.username=root
spring.datasource.password=YOUR_PASSWORD
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.database-platform=org.hibernate.dialect.MySQL8Dialect
