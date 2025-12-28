-- Add missing tables for RigCheck

-- Components table (if not exists)
CREATE TABLE IF NOT EXISTS components (
    id VARCHAR(12) PRIMARY KEY,
    category VARCHAR(20) NOT NULL,
    brand VARCHAR(100),
    model VARCHAR(200),
    specs JSON NOT NULL,
    raw_name TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_category CHECK (category IN ('cpu', 'motherboard', 'gpu', 'ram', 'storage', 'psu', 'case', 'cooler')),
    INDEX idx_category (category),
    INDEX idx_brand (brand),
    FULLTEXT INDEX idx_search (raw_name)
) ENGINE=InnoDB;

-- Prices table
CREATE TABLE IF NOT EXISTS prices (
    id INT AUTO_INCREMENT PRIMARY KEY,
    component_id VARCHAR(12) NOT NULL,
    source VARCHAR(50) NOT NULL,
    price_bdt DECIMAL(10, 2) NOT NULL,
    url TEXT,
    availability VARCHAR(20) DEFAULT 'in_stock',
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_availability CHECK (availability IN ('in_stock', 'out_of_stock', 'pre_order')),
    UNIQUE KEY unique_price (component_id, source, url(255)),
    INDEX idx_component (component_id),
    INDEX idx_source (source),
    INDEX idx_price (price_bdt),
    
    FOREIGN KEY (component_id) REFERENCES components(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Builds table
CREATE TABLE IF NOT EXISTS builds (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    cpu_id VARCHAR(12),
    motherboard_id VARCHAR(12),
    gpu_id VARCHAR(12),
    ram_id VARCHAR(12),
    storage_id VARCHAR(12),
    psu_id VARCHAR(12),
    case_id VARCHAR(12),
    cooler_id VARCHAR(12),
    total_price DECIMAL(10, 2),
    is_public BOOLEAN DEFAULT FALSE,
    is_complete BOOLEAN DEFAULT FALSE,
    is_featured BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_user (user_id),
    INDEX idx_public (is_public),
    INDEX idx_featured (is_featured),
    INDEX idx_created (created_at),
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (cpu_id) REFERENCES components(id) ON DELETE SET NULL,
    FOREIGN KEY (motherboard_id) REFERENCES components(id) ON DELETE SET NULL,
    FOREIGN KEY (gpu_id) REFERENCES components(id) ON DELETE SET NULL,
    FOREIGN KEY (ram_id) REFERENCES components(id) ON DELETE SET NULL,
    FOREIGN KEY (storage_id) REFERENCES components(id) ON DELETE SET NULL,
    FOREIGN KEY (psu_id) REFERENCES components(id) ON DELETE SET NULL,
    FOREIGN KEY (case_id) REFERENCES components(id) ON DELETE SET NULL,
    FOREIGN KEY (cooler_id) REFERENCES components(id) ON DELETE SET NULL
) ENGINE=InnoDB;
