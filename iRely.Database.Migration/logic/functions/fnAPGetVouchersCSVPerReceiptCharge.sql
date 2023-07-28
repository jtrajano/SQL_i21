--liquibase formatted sql

-- changeset Von:fnAPGetVouchersCSVPerReceiptCharge.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnAPGetVouchersCSVPerReceiptCharge]
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

INSERT INTO @table
SELECT 
	intInventoryReceiptChargeId, intItemId
	,STUFF(
            (
                SELECT  ', ' + b.strBillId
                FROM	tblAPBill b INNER JOIN tblAPBillDetail bd
                            ON b.intBillId = bd.intBillId
                WHERE	bd.intInventoryReceiptChargeId IS NOT NULL
						AND bd.intInventoryReceiptChargeId = billDetail.intInventoryReceiptChargeId AND ISNULL(bd.intItemId,-1) = ISNULL(billDetail.intItemId,-1)
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
AND billDetail.intInventoryReceiptChargeId IS NOT NULL
AND billDetail.intInventoryReceiptChargeId = @intId
AND billDetail.intItemId = @intItemId
GROUP BY billDetail.intInventoryReceiptChargeId, billDetail.intItemId

RETURN;

END



