CREATE PROCEDURE [AP Import].[test uspAPImportVoucherBackUpAPIVCMST with duplicate]
AS

DECLARE @count_tblAPapivcmst INT
DECLARE @count_tblAPaphglmst INT
DECLARE @wrongInvoiceNumber BIT = 0

--FAKE TABLE TO BE USE
EXEC [tSQLt].FakeTable 'dbo.tblAPapivcmst', @Identity = 1
EXEC [tSQLt].FakeTable 'dbo.tblAPaphglmst', @Identity = 1
EXEC [tSQLt].FakeTable 'dbo.apivcmst', @Identity = 1
EXEC [tSQLt].FakeTable 'dbo.aphglmst', @Identity = 1

--CREATE FAKE DATA
EXEC [AP].[Fake apivcmst records];

--Reimport using date parameter
EXEC [dbo].[uspAPImportVoucherBackUpAPIVCMST] @DateFrom = NULL , @DateTo = NULL

SET @count_tblAPapivcmst = (SELECT COUNT(*) FROM dbo.tblAPapivcmst)
SET @count_tblAPaphglmst = (SELECT COUNT(*) FROM dbo.tblAPaphglmst)

EXEC tSQLt.AssertEquals @count_tblAPapivcmst, 2, 'Invalid record count inserted in tblAPapivcmst for same import record.'
EXEC tSQLt.AssertEquals @count_tblAPaphglmst, 2, 'Invalid record count inserted in tblAPaphglmst for same import record.'

SELECT
	@wrongInvoiceNumber = CASE WHEN A.apivc_ivc_no NOT LIKE '%-DUP' THEN 1 ELSE 0 END
FROM tblAPapivcmst A

EXEC tSQLt.AssertEquals @wrongInvoiceNumber, 1, 'Back up record for duplicate do not contain -DUP'

SELECT
	@wrongInvoiceNumber = CASE WHEN A.apivc_ivc_no NOT LIKE '%-DUP' THEN 1 ELSE 0 END
FROM apivcmst A

EXEC tSQLt.AssertEquals @wrongInvoiceNumber, 1, 'Reinserted back up record for duplicate do not contain -DUP'
