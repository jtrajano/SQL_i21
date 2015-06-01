CREATE PROCEDURE [dbo].[test the item id constraints on AP tables]
AS
BEGIN

	IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='FK_tblAPBillDetail_tblICItem')
	EXEC tSQLt.Fail 'Item Id FK on tblAPBillDetail does not exists'
	IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='FK_tblPOPurchaseDetail_tblICItem')
	EXEC tSQLt.Fail 'Item Id FK on tblPOPurchaseDetail does not exists'

END