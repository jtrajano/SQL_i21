CREATE PROCEDURE testi21Database.[test the constraints of tblAPVendor]
AS
BEGIN

	--Primary Key 
	IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='PK_dbo.tblAPVendor')
	EXEC tSQLt.Fail 'Primary key on tblAPVendor does not exists'
	--Unique key strVendorId to tblAPVendor
	IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='UK_strVendorId')
	EXEC tSQLt.Fail 'Unique key strVendorId to tblAPVendor on tblAPVendor does not exists'
	--Unique key intVendorId to tblAPVendor
	IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='UK_intVendorId')
	EXEC tSQLt.Fail 'Unique key intVendorId to tblAPVendor on tblAPVendor does not exists'
	--Foreign key to tblEntity
	IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='FK_dbo.tblAPVendor_dbo.tblEntities_intEntityId')
	EXEC tSQLt.Fail 'Foreign key to tblAPVendor on tblEntity does not exists'

END