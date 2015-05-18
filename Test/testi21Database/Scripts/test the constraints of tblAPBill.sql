--Since some of the constraints were just newly added, adding it requires to fix some data
--and causing it to not actually add in on the table definition
--with this test, we will know that the constraint should exists
CREATE PROCEDURE testi21Database.[test the constraints of tblAPBill]
AS
BEGIN
	--Primary Key [PK_dbo.tblAPBill]
	IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='PK_dbo.tblAPBill')
	EXEC tSQLt.Fail 'Primary key on tblAPBill does not exists'
	--Foreign key to tblAPBillBatch
	IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='FK_dbo.tblAPBill_dbo.tblAPBillBatch_intBillBatchId')
	EXEC tSQLt.Fail 'Foreign key to tblAPBillBatch on tblAPBill does not exists'
	--Foreign key to tblSMTerm
	IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='FK_dbo.tblAPBill_dbo.tblSMTerm_intTermId')
	EXEC tSQLt.Fail 'Foreign key to tblSMTerm on tblAPBill does not exists'
	--Foreign key to tblEntity
	IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='FK_dbo.tblAPBill_dbo.tblEntity_intEntityId')
	EXEC tSQLt.Fail 'Foreign key to tblEntity on tblAPBill does not exists'
END