CREATE PROCEDURE [AP Import].[test if allowed to import even the AP Account is not exists in i21]
AS

DECLARE @valid BIT;

EXEC [tSQLt].FakeTable 'dbo.tblAPImportVoucherLog', @Identity = 1
EXEC [tSQLt].FakeTable 'dbo.tblGLAccount', @Identity = 1
EXEC [AP].[Fake apcbkmst records]

EXEC uspAPValidateVoucherImport @UserId = 1, @DateFrom = NULL, @DateTo = NULL, @isValid = @valid OUTPUT
EXEC tSQLt.AssertEquals @valid, 0, 'Import process allowed import voucher even if the AP account in i21 is missing.'
