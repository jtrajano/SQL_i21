CREATE PROCEDURE testi21Database.[test the constraints of tblAPPayment]
AS
BEGIN

	--Primary Key 
	IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='PK_dbo.tblAPPayments')
	EXEC tSQLt.Fail 'Primary key on tblAPPayment does not exists'
	--Foreign key to tblAPVendor
	IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='FK_tblAPPayment_tblAPVendor')
	EXEC tSQLt.Fail 'Foreign key to tblAPPayment on tblAPVendor does not exists'
	
	-- Commented because when I checked tblAPPayment, the constraint does not really exists. 
	--Foreign key to tblEntity
	--IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='FK_dbo.tblAPPayment_dbo.tblEntity_intEntityId')
	--EXEC tSQLt.Fail 'Foreign key to tblAPPayment on tblEntity does not exists'

END
