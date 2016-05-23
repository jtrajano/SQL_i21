CREATE PROCEDURE [AP Import].[test if non-existent user is allowed to import]
AS

DECLARE @valid BIT;

EXEC [tSQLt].FakeTable 'dbo.tblAPImportVoucherLog', @Identity = 1

EXEC [AP].DropConstraints 'tblSMUserSecurity'
EXEC [AP].[Fake tblSMUserSecurity records];

--Non existent user should not allow to do the importing
EXEC uspAPValidateVoucherImport @UserId = 2, @DateFrom = NULL, @DateTo = NULL, @isValid = @valid OUTPUT
EXEC tSQLt.AssertEquals @valid, 0, 'Import process allowed the non-existent user.'
