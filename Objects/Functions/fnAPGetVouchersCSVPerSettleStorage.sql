CREATE FUNCTION [dbo].[fnAPGetVouchersCSVPerSettleStorage]
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

SET ANSI_NULLS OFF 

INSERT INTO @table
SELECT 
	intCustomerStorageId, intItemId
	,STUFF(
            (
                SELECT  ', ' + b.strBillId
                FROM	tblAPBill b INNER JOIN tblAPBillDetail bd
                            ON b.intBillId = bd.intBillId
                WHERE	bd.intCustomerStorageId = billDetail.intCustomerStorageId AND ISNULL(bd.intItemId,-1) = ISNULL(billDetail.intItemId,-1)
                        AND b.ysnPosted =1 
                GROUP BY b.strBillId
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
AND billDetail.intCustomerStorageId IS NOT NULL
AND billDetail.intCustomerStorageId = @intId
AND billDetail.intItemId = @intItemId
GROUP BY billDetail.intCustomerStorageId, billDetail.intItemId

RETURN;

END

GO