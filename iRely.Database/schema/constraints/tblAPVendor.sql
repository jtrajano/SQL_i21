--liquibase formatted sql

--changeset Von:tblAPVendor-C.1
-- comment: FRM-3333
ALTER TABLE tblAPVendor
ADD CONSTRAINT FK_tblAPVendor_tblAPVendorNew
FOREIGN KEY (intSomethingId4) REFERENCES tblAPVendorNew(id);