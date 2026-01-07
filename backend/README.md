# Smart POS Backend API

PHP REST API backend for Smart POS & Inventory Management App.

## Setup Instructions

1. **Database Setup**
   ```bash
   # Import the database schema
   mysql -u root -p < database/schema.sql
   ```

2. **Configuration**
   - Update database credentials in `config/database.php` if needed
   - Default credentials: username=root, password=(empty)

3. **Deploy**
   - Copy the `backend` folder to your web server (XAMPP, WAMP, or any PHP server)
   - Ensure the folder is accessible via HTTP

## API Endpoints

### Authentication

#### Signup
- **URL**: `POST /api/auth/signup.php`
- **Body**:
  ```json
  {
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123"
  }
  ```

#### Login
- **URL**: `POST /api/auth/login.php`
- **Body**:
  ```json
  {
    "email": "john@example.com",
    "password": "password123"
  }
  ```

## Testing

Use Postman or any API client to test the endpoints.

**Base URL**: `http://localhost/pos/backend`
