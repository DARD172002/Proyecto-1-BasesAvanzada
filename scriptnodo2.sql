
--scrip de creacion de la base de datos nodo2
CREATE DATABASE GlobalInventoryDBExample;
go
use GlobalInventoryDBExample
go

-- TABLA DE REGIONES
CREATE TABLE Regions
(
    ID_Region INT PRIMARY KEY IDENTITY(1,1),
    Name_Region NVARCHAR(100) NOT NULL,
    Country NVARCHAR(100) NOT NULL
);
-- TABLA USUARIOS
CREATE TABLE Users(
    ID_User INT PRIMARY KEY IDENTITY(1,1),
    Name_User NVARCHAR(100) NOT NULL, 
    Email  NVARCHAR(100) NOT NULL,
    Password_User NVARCHAR(100) NOT NULL
);

-- TABLA DE PEDIDOS
CREATE TABLE Orders(
    ID_Order INT PRIMARY KEY IDENTITY(1,1),
    ID_User INT NOT NULL,
    ID_Region INT NOT NULL,
    State_Order NVARCHAR(100) NOT NULL,
    Date_Order DATE NOT NULL
)

-- TABLA DE INVENTORY
CREATE TABLE Inventory(
    ID_Region INT NOT NULL,
    ID_Product INT NOT NULL,
    Amount INT NOT NULL,
    PRIMARY KEY (ID_Product,ID_Region)

);
 
 -- TABLE DE PRODUCT

CREATE TABLE Product(
    ID_Product INT PRIMARY KEY IDENTITY(1,1),
    Name_Product NVARCHAR(100) NOT NULL,
    Price INT NOT NULL
)

-- TABLA DE PRODUCT_ORDER

CREATE TABLE Product_Order(
    ID_Product INT NOT NULL,
    ID_Order INT NOT NULL,
    Amount INT NOT NULL,
    PRIMARY KEY(ID_Order,ID_Product)
)
go
ALTER TABLE Inventory ADD CONSTRAINT FK_ID_Region FOREIGN KEY(ID_Region) REFERENCES Regions(ID_Region);
ALTER TABLE Inventory ADD CONSTRAINT FK_ID_Product FOREIGN KEY(ID_Product) REFERENCES  Product(ID_Product);
ALTER TABLE Orders ADD CONSTRAINT FK_ID_User FOREIGN KEY(ID_User) REFERENCES Users(ID_User);
ALTER TABLE Product_Order ADD CONSTRAINT FK_Product_Order_ID_Product FOREIGN KEY(ID_Product) REFERENCES Product(ID_Product);
ALTER TABLE Product_Order  ADD CONSTRAINT FK_Product_Order_ID_Order FOREIGN KEY (ID_Order) REFERENCES Orders(ID_Order);
ALTER TABLE Orders ADD CONSTRAINT FK_Orders_ID_Region FOREIGN KEY(ID_Region) REFERENCES  Regions(ID_Region)

-- LLENANDO LA BASE DE DATOS
INSERT INTO Regions (Name_Region, Country)
VALUES 
('North America', 'USA'),
('Europe', 'France'),
('Asia', 'India'),
('South America', 'Brazil'),
('Africa', 'South Africa');

DECLARE @i INT = 1;

WHILE @i <= 10000
BEGIN
    INSERT INTO Users (Name_User, Email, Password_User)
    VALUES (
        CONCAT('User', @i),
        CONCAT('user', @i, '@example.com'),
        CONCAT('password', @i)
    );
    SET @i = @i + 1;
END;


SET @i = 1;

WHILE @i <= 10000
BEGIN
    INSERT INTO Product (Name_Product, Price)
    VALUES (
        CONCAT('Product', @i),
        (@i * 10) % 500 + 10 -- Precio secuencial y válido entre 10 y 500
    );
    SET @i = @i + 1;
END;



SET @i = 1;
WHILE @i <= 10000
BEGIN
    INSERT INTO Orders (ID_User, ID_Region, State_Order, Date_Order)
    VALUES (
        @i % 10000 + 1, -- Usuario asociado secuencialmente
        @i % 5 + 1, -- Región secuencial entre 1 y 5 
        CASE (@i % 3)
            WHEN 0 THEN 'Pending'
            WHEN 1 THEN 'Completed'
            ELSE 'Cancelled'
        END,
        DATEADD(DAY, -@i % 365, '2024-12-31') -- Fechas secuenciales dentro del último año
    );
    SET @i = @i + 1;
END;


SET @i = 1;

WHILE @i <= 10000
BEGIN
    INSERT INTO Inventory (ID_Region, ID_Product, Amount)
    VALUES (
        @i % 5 + 1, -- Región secuencial entre 1 y 5
        @i % 10000 + 1, -- Producto secuencial entre 1 y 10000
        (@i % 100 + 1) -- Cantidad secuencial entre 1 y 100
    );
    SET @i = @i + 1;
END;


SET @i = 1;

WHILE @i <= 10000
BEGIN
    INSERT INTO Product_Order (ID_Product, ID_Order, Amount)
    VALUES (
        @i % 10000 + 1, -- Producto secuencial entre 1 y 10000
        @i % 10000 + 1, -- Pedido secuencial entre 1 y 10000
        (@i % 10 + 1) -- Cantidad secuencial entre 1 y 10
    );
    SET @i = @i + 1;
END;




go
-- Fragmentacion horizontal por region Tabla Inventory
DELETE FROM Inventory WHERE ID_Region NOT IN (4,5);


-- Fragmentacion vertical 
Alter table Users drop COLUMN Name_User
ALter table Users drop COLUMN Email


