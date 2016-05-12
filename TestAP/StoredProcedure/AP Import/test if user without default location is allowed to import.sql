CREATE PROCEDURE [AP Import].[test if user without default location is allowed to import]
AS

DECLARE @valid BIT;

EXEC [tSQLt].FakeTable 'dbo.tblAPImportVoucherLog', @Identity = 1

EXEC [AP].DropConstraints 'tblSMCompanyLocation'
EXEC [AP].[Fake tblSMCompanyLocation records];
UPDATE A
	SET A.intCompanyLocationId = NULL
FROM tblSMUserSecurity A
EXEC uspAPValidateVoucherImport @UserId = 1, @DateFrom = NULL, @DateTo = NULL, @isValid = @valid OUTPUT
EXEC tSQLt.AssertEquals @valid, 0, 'Import process allowed the user to have no default location.'