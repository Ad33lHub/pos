<?php
require_once __DIR__ . '/../config/database.php';

class User {
    private $conn;
    private $table_name = "users";
    
    public function __construct() {
        $this->conn = Database::getInstance()->getConnection();
    }
    
    // Create new user
    public function create($name, $email, $password) {
        // Check if email already exists
        if ($this->emailExists($email)) {
            return [
                'success' => false,
                'message' => 'Email already exists'
            ];
        }
        
        $query = "INSERT INTO " . $this->table_name . " 
                  (name, email, password) 
                  VALUES (:name, :email, :password)";
        
        $stmt = $this->conn->prepare($query);
        
        // Hash password
        $hashed_password = password_hash($password, PASSWORD_BCRYPT);
        
        // Bind parameters
        $stmt->bindParam(':name', $name);
        $stmt->bindParam(':email', $email);
        $stmt->bindParam(':password', $hashed_password);
        
        if ($stmt->execute()) {
            return [
                'success' => true,
                'message' => 'User created successfully',
                'user_id' => $this->conn->lastInsertId()
            ];
        }
        
        return [
            'success' => false,
            'message' => 'Failed to create user'
        ];
    }
    
    // Get user by email
    public function getUserByEmail($email) {
        $query = "SELECT id, name, email, password, created_at 
                  FROM " . $this->table_name . " 
                  WHERE email = :email 
                  LIMIT 1";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':email', $email);
        $stmt->execute();
        
        return $stmt->fetch();
    }
    
    // Check if email exists
    public function emailExists($email) {
        $query = "SELECT id FROM " . $this->table_name . " 
                  WHERE email = :email 
                  LIMIT 1";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':email', $email);
        $stmt->execute();
        
        return $stmt->rowCount() > 0;
    }
    
    // Verify password
    public function verifyPassword($password, $hashed_password) {
        return password_verify($password, $hashed_password);
    }
}
?>
