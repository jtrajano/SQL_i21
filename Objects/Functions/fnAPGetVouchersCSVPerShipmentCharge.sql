CREATE FUNCTION [dbo].[fnAPGetVouchersCSVPerShipmentCharge]
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
	intInventoryShipmentChargeId, intItemId
	,STUFF(
            (
                SELECT  ', ' + b.strBillId
                FROM	tblAPBill b INNER JOIN tblAPBillDetail bd
                            ON b.intBillId = bd.intBillId
                WHERE	bd.intInventoryShipmentChargeId IS NOT NULL
						AND bd.intInventoryShipmentChargeId = billDetail.intInventoryShipmentChargeId AND ISNULL(bd.intItemId,-1) = ISNULL(billDetail.intItemId,-1)
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
AND billDetail.intInventoryShipmentChargeId IS NOT NULL
AND billDetail.intInventoryShipmentChargeId = @intId
AND billDetail.intItemId = @intItemId
GROUP BY billDetail.intInventoryShipmentChargeId, billDetail.intItemId

RETURN;

END

GO