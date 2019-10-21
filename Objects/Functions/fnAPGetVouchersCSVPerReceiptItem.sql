CREATE FUNCTION fnAPGetVouchersCSVPerReceiptItem
(
	@intId INT,
	@intItemId INT
)
RETURNS @table TABLE
(
	intId INT,
	intItemId INT,
	strVoucherIds NVARCHAR(MAX)
)
AS
BEGIN

--ALLOW TO SELECT RECORDS IF intItemId = NULL
--TO AVOID ISNULL(field,-1)
--SET ANSI_NULLS OFF 

INSERT INTO @table
SELECT 
	intInventoryReceiptItemId, intItemId
	,STUFF
	(
		(
			SELECT  ', ' + b.strBillId
			FROM	tblAPBill b INNER JOIN tblAPBillDetail bd
						ON b.intBillId = bd.intBillId
			WHERE	bd.intInventoryReceiptItemId IS NOT NULL
					AND bd.intInventoryReceiptItemId = billDetail.intInventoryReceiptItemId AND ISNULL(bd.intItemId,-1) = ISNULL(billDetail.intItemId,-1)
					AND b.ysnPosted =1 
			GROUP BY b.strBillId, bd.intInventoryReceiptItemId, bd.intItemId
			FOR xml path('')
		)
	, 1
	, 1
	, ''
	)
FROM	tblAPBill bill INNER JOIN tblAPBillDetail billDetail
                    ON bill.intBillId = billDetail.intBillId
WHERE 
	bill.ysnPosted = 1
AND billDetail.intInventoryReceiptItemId IS NOT NULL
GROUP BY billDetail.intInventoryReceiptItemId, billDetail.intItemId

RETURN;

END

GO