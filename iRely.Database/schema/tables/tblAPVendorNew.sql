--liquibase formatted sql

--changeset Von:tblAPVendor.0
--comment: SM-1001
CREATE TABLE tblAPVendorNew (
    id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    age INT
);

--changeset Von:Insert.tblAPVendor.1
--comment: SM-1001
INSERT INTO tblAPVendorNew (id, name, age) VALUES (1, 'Von', 30);
INSERT INTO tblAPVendorNew (id, name, age) VALUES (2, 'Von2', 30);
INSERT INTO tblAPVendorNew (id, name, age) VALUES (3, 'Von3', 30);
INSERT INTO tblAPVendorNew (id, name, age) VALUES (4, 'Von4', 30);