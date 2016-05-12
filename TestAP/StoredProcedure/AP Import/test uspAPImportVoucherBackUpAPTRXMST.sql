CREATE PROCEDURE [AP Import].[test uspAPImportVoucherBackUpAPTRXMST]
AS

--FAKE TABLE TO BE USE
EXEC [tSQLt].FakeTable 'dbo.tblAPaptrxmst', @Identity = 1
EXEC [tSQLt].FakeTable 'dbo.tblAPapeglmst', @Identity = 1
EXEC [tSQLt].FakeTable 'dbo.apivcmst', @Identity = 1
EXEC [tSQLt].FakeTable 'dbo.aphglmst', @Identity = 1

--CREATE FAKE DATA
EXEC [AP].[Fake aptrxmst records];

--CHECK IF PASSING NULL TO PARAMETER WILL IMPORT ALL
EXEC [dbo].[uspAPImportVoucherBackUpAPTRXMST] @DateFrom = NULL, @DateTo = NULL

DECLARE @count_tblAPaptrxmst INT = (SELECT COUNT(*) FROM dbo.tblAPaptrxmst)
DECLARE @count_tblAPapeglmst INT = (SELECT COUNT(*) FROM dbo.tblAPapeglmst)
DECLARE @count_apivcmst INT = (SELECT COUNT(*) FROM dbo.apivcmst)
DECLARE @count_aphglmst INT = (SELECT COUNT(*) FROM dbo.aphglmst)
DECLARE @validateRecordInserted INT, @validateRecordInsertedAPIVCMST INT;
DECLARE @zeroAmount CHAR(18)
DECLARE @wrongInfoInAPIVCMST CHAR(18)

EXEC tSQLt.AssertEquals @count_tblAPaptrxmst, 2, 'Invalid record count inserted in tblAPaptrxmst'
EXEC tSQLt.AssertEquals @count_tblAPapeglmst, 2, 'Invalid record count inserted in tblAPapeglmst'
EXEC tSQLt.AssertEquals @count_apivcmst, 2, 'Invalid record count inserted in apivcmst'
EXEC tSQLt.AssertEquals @count_aphglmst, 2, 'Invalid record count inserted in aphglmst'

--VALIDATE IF HEADER AND DETAIL HAVE SAME INFORMATION FOR BACK UP RECORDS
SELECT 
	@validateRecordInserted = COUNT(*) 
FROM tblAPaptrxmst A
INNER JOIN tblAPapeglmst B 
	ON A.aptrx_vnd_no = B.apegl_vnd_no
	AND A.aptrx_ivc_no = B.apegl_ivc_no

EXEC tSQLt.AssertEquals @validateRecordInserted, 2, 'Mismatch header and detail of back up records'

--VALIDATE IF HEADER AND DETAIL HAVE SAME INFORMATION FOR REINSERTED RECORDS
SELECT 
	@validateRecordInsertedAPIVCMST = COUNT(*) 
FROM apivcmst A
INNER JOIN aphglmst B 
	ON A.apivc_vnd_no = B.aphgl_vnd_no
	AND A.apivc_ivc_no = B.aphgl_ivc_no

EXEC tSQLt.AssertEquals @validateRecordInsertedAPIVCMST, 2, 'Mismatch header and detail of back up records in apivcmst'

--VALIDATE IF INFORMATION INSERTED IN APIVCMST WERE CORRECT
SELECT
	@wrongInfoInAPIVCMST = A.apivc_ivc_no
FROM apivcmst A
WHERE A.[apivc_status_ind] != 'R' OR A.[apivc_comment] != 'Imported Origin Bill - i21 Rec'

EXEC tSQLt.AssertEquals @wrongInfoInAPIVCMST, NULL, 'Wrong information inserted in apivcmst'

--VALIDATE IF ZERO AMOUNT VOUCHER WAS NOT IMPORTED
SELECT
	@zeroAmount = A.aptrx_ivc_no
FROM tblAPaptrxmst A
WHERE A.[aptrx_orig_amt] = 0

EXEC tSQLt.AssertEquals @zeroAmount, NULL, 'Zero amount has been imported'
