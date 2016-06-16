CREATE PROCEDURE [AP Import].[test uspAPImportVoucherBackUpAPIVCMST]
AS

--FAKE TABLE TO BE USE
EXEC [tSQLt].FakeTable 'dbo.tblAPapivcmst', @Identity = 1
EXEC [tSQLt].FakeTable 'dbo.tblAPaphglmst', @Identity = 1

--CREATE FAKE DATA
EXEC [AP].[Fake apivcmst records];

--CREATE FAKE PAYMENT
EXEC [AP].[Fake apchkmst records];

EXEC [dbo].[uspAPImportVoucherBackUpAPIVCMST] @DateFrom = NULL, @DateTo = NULL

--MAKE SURE THE PRIMARY KEY CONSTRAINT WOULD VALIDATED
EXEC tSQLt.ApplyConstraint 'dbo.tblAPapivcmst', '[k_tblAPapivcmst]'

DECLARE @count_tblAPapivcmst INT = (SELECT COUNT(*) FROM dbo.tblAPapivcmst)
DECLARE @count_tblAPaphglmst INT = (SELECT COUNT(*) FROM dbo.tblAPaphglmst)

EXEC tSQLt.AssertEquals @count_tblAPapivcmst, 2, 'Invalid record count inserted in tblAPaptrxmst'
EXEC tSQLt.AssertEquals @count_tblAPaphglmst, 2, 'Invalid record count inserted in tblAPapeglmst'