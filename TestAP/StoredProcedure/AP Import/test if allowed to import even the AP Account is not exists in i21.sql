CREATE PROCEDURE [AP Import].[test if allowed to import even the AP Account is not exists in i21]
AS

DECLARE @valid BIT;

EXEC [tSQLt].FakeTable 'dbo.tblAPImportVoucherLog', @Identity = 1

--INSERT RECORDS FOR USER
EXEC [AP].DropConstraints 'tblSMUserSecurity'
EXEC [AP].[Fake tblSMUserSecurity records];

--INSERT RECORDS FOR COMPANY LOCATION
EXEC [AP].DropConstraints 'tblSMCompanyLocation'
EXEC [AP].[Fake tblSMCompanyLocation records];

--DROP FIRST THE CONSTRAINTS BEFORE FAKING TO REMOVE DEPENDENCIES
EXEC [AP].DropConstraints 'tblGLAccount'
EXEC [tSQLt].FakeTable 'dbo.tblGLAccount', @Identity = 1

EXEC [AP].DropConstraints 'apcbkmst_origin'
EXEC [AP].[Fake apcbkmst records]

EXEC uspAPValidateVoucherImport @UserId = 1, @DateFrom = NULL, @DateTo = NULL, @isValid = @valid OUTPUT
EXEC tSQLt.AssertEquals @valid, 0, 'Import process allowed import voucher even if the AP account in i21 is missing.'
