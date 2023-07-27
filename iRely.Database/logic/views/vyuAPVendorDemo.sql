--liquibase formatted sql

-- changeset Von:vyuAPVendorDemo.2 runOnChange:true
-- comment: AP-1234
CREATE OR ALTER VIEW vyuAPVendorDemo AS
SELECT id, name, age, 4 as a
FROM tblAPVendorNew

