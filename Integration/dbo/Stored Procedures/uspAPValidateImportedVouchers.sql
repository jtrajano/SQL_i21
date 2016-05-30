CREATE PROCEDURE [dbo].[uspAPValidateImportedVouchers]
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

--GET THOSE VOUCHERS WHERE TOTAL DETAIL IS NOT EQUAL TO TOTAL HEADER
SELECT 
* 
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
			WHERE C.ysnOrigin = 1 --from Origin and posted in origin
			) ImportedBills
	GROUP BY 
	intBillId
	,strBillId
	,strVendorOrderNumber
	,i21Total
	,ysnPosted
	) Summary
WHERE i21Total <> i21DetailTotal --Verify if total and detail total are equal