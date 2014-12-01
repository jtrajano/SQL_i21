CREATE PROCEDURE [testi21Database].[test the account id constraints of AP tables]
AS
BEGIN
	IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='FK_dbo.tblAPBillBatch_dbo.tblGLAccount_intAccountId')
	EXEC tSQLt.Fail 'Account Id FK on tblAPBillBatch does not exists'
	IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='FK_dbo.tblAPBill_dbo.tblGLAccount_intAccountId')
	EXEC tSQLt.Fail 'Account Id FK on tblAPBill does not exists'
	IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='FK_tblAPBillDetail_tblGLAccount')
	EXEC tSQLt.Fail 'Account Id FK on tblAPBillDetail does not exists'
	IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='FK_tblAPPayment_tblGLAccount')
	EXEC tSQLt.Fail 'Account Id FK on tblAPPayment does not exists'
	IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='FK_tblAPPaymentDetail_tblGLAccount')
	EXEC tSQLt.Fail 'Account Id FK on tblAPPaymentDetail does not exists'
	IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='FK_tblAPVendor_tblGLAccount')
	EXEC tSQLt.Fail 'Account Id FK on tblAPVendor (Expense) does not exists'
	IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='FK_dbo.tblPOPurchase_dbo.tblGLAccount_intAccountId')
	EXEC tSQLt.Fail 'Account Id FK on tblPOPurchase (Expense) does not exists'
	IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='FK_dbo.tblPOPurchaseDetail_dbo.tblGLAccount_intAccountId')
	EXEC tSQLt.Fail 'Account Id FK on tblPOPurchaseDetail (Expense) does not exists'
END