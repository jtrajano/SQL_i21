CREATE PROCEDURE [AP Import].[test uspAPImportVoucherAPTRXMST]
AS

EXEC [AP].[Fake aptrxmst records];

--FAKE TABLE TO BE USE
EXEC [tSQLt].FakeTable 'dbo.tblAPaptrxmst', @Identity = 1
EXEC [tSQLt].FakeTable 'dbo.tblAPapeglmst', @Identity = 1
EXEC [tSQLt].FakeTable 'dbo.apivcmst', @Identity = 1
EXEC [tSQLt].FakeTable 'dbo.aphglmst', @Identity = 1

--CHECK IF PASSING NULL TO PARAMETER WILL IMPORT ALL
EXEC [dbo].[uspAPImportVoucherBackUpAPTRXMST] @DateFrom = NULL, @DateTo = NULL

DECLARE @count_aptrxmst INT = (SELECT COUNT(*) FROM dbo.aptrxmst)
DECLARE @count_apeglmst INT = (SELECT COUNT(*) FROM dbo.apeglmst)
DECLARE @count_apivcmst INT = (SELECT COUNT(*) FROM dbo.apivcmst)
DECLARE @count_aphglmst INT = (SELECT COUNT(*) FROM dbo.aphglmst)

EXEC tSQLt.AssertEquals @count_aptrxmst, 2, 'Invalid record count inserted in aptrxmst'
EXEC tSQLt.AssertEquals @count_apeglmst, 2, 'Invalid record count inserted in apeglmst'
EXEC tSQLt.AssertEquals @count_apivcmst, 2, 'Invalid record count inserted in apivcmst'
EXEC tSQLt.AssertEquals @count_aphglmst, 2, 'Invalid record count inserted in aphglmst'
