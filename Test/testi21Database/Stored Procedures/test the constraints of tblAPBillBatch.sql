CREATE PROCEDURE testi21Database.[test the constraints of tblAPBillBatch]
AS
BEGIN

	--Primary Key 
	IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='PK_dbo.tblAPBillBatches')
	EXEC tSQLt.Fail 'Primary key on tblAPBillBatch does not exists'
	--Foreign key to tblEntity
	IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='FK_dbo.tblAPBillBatch_dbo.tblEMEntity_intEntityId')
	EXEC tSQLt.Fail 'Foreign key to tblEMEntity on tblAPBillBatch does not exists'

END