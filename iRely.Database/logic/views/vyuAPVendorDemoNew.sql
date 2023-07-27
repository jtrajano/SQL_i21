--liquibase formatted sql

-- changeset Von:vyuAPVendorDemoNew.1 runOnChange:true
-- comment: FRM-2222
CREATE OR ALTER VIEW vyuAPVendorDemoNew AS
SELECT id, name, age, 1 as a
FROM vyuAPVendorDemoSuper

