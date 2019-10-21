CREATE FUNCTION [dbo].[fnAPGetVouchersCSVPerLoad]
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
	intLoadDetailId, intItemId
	,STUFF(
            (
                SELECT  ', ' + b.strBillId
                FROM	tblAPBill b INNER JOIN tblAPBillDetail bd
                            ON b.intBillId = bd.intBillId
                WHERE	bd.intLoadDetailId = billDetail.intLoadDetailId AND ISNULL(bd.intItemId,-1) = ISNULL(billDetail.intItemId,-1)
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
AND billDetail.intLoadDetailId IS NOT NULL
AND billDetail.intLoadDetailId = @intId
AND billDetail.intItemId = @intItemId
GROUP BY billDetail.intLoadDetailId, billDetail.intItemId

RETURN;

END

GO