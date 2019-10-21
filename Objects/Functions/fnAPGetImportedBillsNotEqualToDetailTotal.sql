CREATE FUNCTION fnAPGetImportedBillsNotEqualToDetailTotal()
RETURNS @ReturnData TABLE
   (
    intBillId     INT,
    strBillId   NVARCHAR(200),
    strVendorOrderNumber   NVARCHAR(200),
    i21Total  DECIMAL(18,6),
    i21DetailTotal  DECIMAL(18,6),
    ysnPosted BIT
   )
AS
BEGIN

	INSERT @ReturnData
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
				--Get all imported bills and paid in i21
				SELECT 
				A.intBillId
				,A.strBillId
				,A.strVendorOrderNumber
				,A.dblTotal i21Total
				,B.dblTotal i21DetailTotal
				,ysnPosted
				FROM tblAPBill A
					LEFT JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
				WHERE 
				A.ysnOrigin = 1 --from Origin and posted in origin
				) ImportedBills
		GROUP BY 
		intBillId
		,strBillId
		,strVendorOrderNumber
		,i21Total
		,ysnPosted
		) Summary
	WHERE i21Total <> i21DetailTotal --Verify if total and detail total are equal

RETURN;

END