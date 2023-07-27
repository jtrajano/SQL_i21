--liquibase formatted sql

--changeset Von:tblAPVendor.1
--comment: FRM-1001
ALTER TABLE tblAPVendor
ADD intNewId INT,
    strVendorNew VARCHAR(100);

--changeset Von:tblAPVendor.2
--comment: FRM-1001
ALTER TABLE tblAPVendor
ADD intSomethingId2 INT,
    strVendorSomething2 VARCHAR(100);

--changeset Kenneth:tblAPVendor.3
--comment: TM-1001
ALTER TABLE tblAPVendor
ADD intSomethingId3 INT,
    strVendorSomething3 VARCHAR(100);

--changeset Kenneth:tblAPVendor.4
--comment: TM-1002
ALTER TABLE tblAPVendor
ADD intSomethingId4 INT;

--changeset Feb:tblAPVendor.5
--comment: IC-1001
ALTER TABLE tblAPVendor
ALTER COLUMN strVendorSomething3 VARCHAR(200);

--changeset Feb:tblAPVendor.6
--comment: IC-1002
ALTER TABLE tblAPVendor
ADD intSomethingId5 INT;

--changeset Feb:tblAPVendor.7
--comment: IC-1002
ALTER TABLE tblAPVendor
ADD intSomethingId6 INT;