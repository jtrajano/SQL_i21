CREATE PROCEDURE [dbo].[uspAPValidateImportedVouchers]
	@UserId INT,
	@logKey NVARCHAR(100),
	@isValid INT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @log TABLE
(
	[strDescription] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    [intEntityId] INT NOT NULL, 
    [dtmDate] DATETIME NOT NULL
)

--GET THOSE VOUCHERS WHERE TOTAL DETAIL IS NOT EQUAL TO TOTAL HEADER
INSERT INTO @log
SELECT 
	strBillId + ' total do not matched.', @UserId, GETDATE(), 1, 0
FROM (
	SELECT 
	intBillId
	,strBillId
	,strVendorOrderNumber
	,i21Total
	,SUM(i21DetailTotal) i21DetailTotal
	,ysnPosted
	FROM (
			SELECT 
			C.intBillId
			,C.strBillId
			,C.strVendorOrderNumber
			,C.dblTotal i21Total
			,ISNULL(B.dblTotal,0) i21DetailTotal
			,C.ysnPosted
			FROM tmp_apivcmstImport A
			INNER JOIN tblAPapivcmst A2 ON A.intBackupId = A2.intId
			INNER JOIN tblAPBill C ON A2.intBillId = C.intBillId
				LEFT JOIN tblAPBillDetail B ON C.intBillId = B.intBillId
			) ImportedBills
	GROUP BY 
	intBillId
	,strBillId
	,strVendorOrderNumber
	,i21Total
	,ysnPosted
	) Summary
WHERE i21Total <> i21DetailTotal --Verify if total and detail total are equal

INSERT INTO tblAPImportValidationLog
(
	[strDescription], 
    [intEntityId], 
	[strLogKey],
    [dtmDate]
)
SELECT * FROM @log

IF EXISTS(SELECT 1 FROM @log) SET @isValid = 0;
ELSE SET @isValid = 1