--liquibase formatted sql

-- changeset Von:vyuAPVendorDemoSuper.1 runOnChange:true
-- comment: FRM-2222
CREATE OR ALTER VIEW vyuAPVendorDemoSuper AS
SELECT id, name, age, 1 as a
FROM tblAPVendorNew

