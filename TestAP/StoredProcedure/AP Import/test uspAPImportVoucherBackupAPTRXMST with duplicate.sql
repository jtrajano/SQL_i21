CREATE PROCEDURE [AP Import].[test uspAPImportVoucherBackupAPTRXMST with duplicate]
AS

DECLARE @count_tblAPaptrxmst INT
DECLARE @count_tblAPapeglmst INT
DECLARE @wrongInvoiceNumber BIT = 0

--FAKE TABLE TO BE USE
EXEC [tSQLt].FakeTable 'dbo.tblAPaptrxmst', @Identity = 1
EXEC [tSQLt].FakeTable 'dbo.tblAPapeglmst', @Identity = 1
EXEC [tSQLt].FakeTable 'dbo.aptrxmst', @Identity = 1
EXEC [tSQLt].FakeTable 'dbo.apeglmst', @Identity = 1
EXEC [tSQLt].FakeTable 'dbo.apivcmst', @Identity = 1
EXEC [tSQLt].FakeTable 'dbo.aphglmst', @Identity = 1

--CREATE FAKE DATA
EXEC [AP].[Fake aptrxmst records];

--Reimport using date parameter
EXEC [dbo].[uspAPImportVoucherBackUpAPTRXMST] @DateFrom = '2/19/2016', @DateTo = '2/20/2016'

SET @count_tblAPaptrxmst = (SELECT COUNT(*) FROM dbo.tblAPaptrxmst)
SET @count_tblAPapeglmst = (SELECT COUNT(*) FROM dbo.tblAPapeglmst)

EXEC tSQLt.AssertEquals @count_tblAPaptrxmst, 1, 'Invalid record count inserted in tblAPaptrxmst for same import record.'
EXEC tSQLt.AssertEquals @count_tblAPapeglmst, 1, 'Invalid record count inserted in tblAPapeglmst for same import record.'

SELECT
	@wrongInvoiceNumber = CASE WHEN A.aptrx_ivc_no NOT LIKE '%-DUP' THEN 1 ELSE 0 END
FROM tblAPaptrxmst A

EXEC tSQLt.AssertEquals @wrongInvoiceNumber, 1, 'Back up record for duplicate do not contain -DUP'

SELECT
	@wrongInvoiceNumber = CASE WHEN A.apivc_ivc_no NOT LIKE '%-DUP' THEN 1 ELSE 0 END
FROM apivcmst A

EXEC tSQLt.AssertEquals @wrongInvoiceNumber, 1, 'Reinserted back up record for duplicate do not contain -DUP'
