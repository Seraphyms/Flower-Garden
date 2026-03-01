DROP DATABASE if exists flower_garden;
CREATE DATABASE if not exists flower_garden;
USE flower_garden;

DROP TABLE if exists bouquet;
DROP TABLE if exists users;
DROP TABLE if exists fleur;
DROP TABLE if exists famille;
DROP TABLE if exists fleurs_bouquet ;


CREATE TABLE if not exists famille (
	famille_id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(20),
    famille_description VARCHAR(255)
);

CREATE TABLE if not exists fleur (
	fleur_id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(20) NOT NULL,
    nom_scientifique VARCHAR(50),
    est_toxique BOOL,
    nombre_petales TINYINT UNSIGNED,
    
    famille_id INT NOT NULL,
    FOREIGN KEY (famille_id) REFERENCES famille(famille_id) ON DELETE CASCADE
);
-- Constraint petal number >= 1
ALTER TABLE fleur
ADD CONSTRAINT chk_nombre_petales CHECK (nombre_petales >= 1);

CREATE TABLE if not exists users (
    user_id INT AUTO_INCREMENT PRIMARY KEY, -- a remplacer par un GUID
    user_name VARCHAR(100) NOT NULL,
    user_email VARCHAR(100) NOT NULL UNIQUE,
    user_password VARCHAR(100), -- PAS le mot de passe, mais le HASH + SALT
    user_created DATETIME,
    user_role ENUM('ADMIN', 'USER') NOT NULL -- RBAC: role-based access control
);
-- constraint email respects email format
ALTER TABLE users
ADD CONSTRAINT chk_email_format CHECK (user_email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
-- regex explanation:
-- ^[A-Za-z0-9._%+-]+	: start with one or more allowed characters before the @
-- @					: must contain an @ symbol
-- [A-Za-z0-9.-]+       : domain name with allowed characters
-- \.                   : a dot before the domain extension
-- [A-Za-z]{2,}$        : domain extension with at least two letters

ALTER TABLE users MODIFY user_password VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE users MODIFY user_name VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;


CREATE TABLE if not exists bouquet (
	bouquet_id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(20),
    nombre_fleurs TINYINT UNSIGNED, -- nombre total de fleurs dans le bouquet
	user_id INT NOT NULL,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE if not exists fleurs_bouquet (
	fleurs_bouquet INT AUTO_INCREMENT PRIMARY KEY,
    quantite TINYINT UNSIGNED, -- nombre de fois que la fleur est dans le bouquet

    bouquet_id INT NOT NULL,
    fleur_id INT NOT NULL,

    FOREIGN KEY (bouquet_id) REFERENCES bouquet(bouquet_id) ON DELETE CASCADE,
    FOREIGN KEY (fleur_id) REFERENCES fleur(fleur_id) ON DELETE CASCADE
);


-- insert sample data
INSERT INTO famille (nom, famille_description) VALUES
    ('Rosaceae', 'Family of roses and related plants'),
    ('Asteraceae', 'Family of daisies and sunflowers'),
    ('Liliaceae', 'Family of lilies and related plants')
;

INSERT INTO fleur (nom, nom_scientifique, est_toxique, nombre_petales, famille_id) VALUES
    ('Rose', 'Rosa', FALSE, 32, 1),
    ('Daisy', 'Bellis perennis', FALSE, 34, 2),
    ('Lily', 'Lilium', TRUE, 6, 3)
;

INSERT INTO users (user_name, user_email, user_password, user_created, user_role) VALUES
    ('John Doe', 'john.doe@example.com', SHA2(CONCAT(now(), 'password123'), 224), now(), 'ADMIN'),
    ('Jane Smith', 'jane.smith@example.com', SHA2(CONCAT(now(), 'secretpass'), 224), now(), 'USER')
;

INSERT INTO bouquet (nom, nombre_fleurs, user_id) VALUES
    ('Spring Delight', 10, 1),
    ('Summer Breeze', 15, 2)
;

INSERT INTO fleurs_bouquet (quantite, bouquet_id, fleur_id) VALUES
    (5, 1, 1),  -- 5 Roses in Spring Delight
    (5, 1, 2),  -- 5 Daisies in Spring Delight
    (10, 2, 2), -- 10 Daisies in Summer Breeze
    (5, 2, 3)   -- 5 Lilies in Summer Breeze
;

-- remove bouquet 'Spring Delight'
-- DELETE FROM bouquet WHERE nom = 'Spring Delight';

-- update user role
-- UPDATE users SET user_role = 'ADMIN' WHERE user_email = 'jane.smith@example.com';