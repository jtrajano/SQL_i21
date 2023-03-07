CREATE FUNCTION [dbo].[fnGRSettlementMiscCharges]
(
	@intBillId INT
)
RETURNS @tbl TABLE (
	intBillDetailItemId INT
	,intBillDetailOtherChargeItemId INT
	,intTypeId INT
	,ysnShow BIT
	,ysnStage BIT
)
AS
BEGIN
INSERT INTO @tbl
SELECT * FROM (
SELECT intBillDetailItemId = BD_ITEM.intBillDetailId
	,intBillDetailOtherChargeItemId = BD_MISC.intBillDetailId
	,intTypeId = CASE 
		WHEN BD_ITEM.intInventoryReceiptItemId IS NOT NULL AND BD_ITEM.intContractDetailId IS NULL THEN 1 --SPOT
		WHEN BD_ITEM.intInventoryReceiptItemId IS NOT NULL AND BD_ITEM.intContractDetailId IS NOT NULL THEN 2 --CONTRACT
		WHEN BD_ITEM.intCustomerStorageId IS NOT NULL THEN 3 --SETTLE STORAGE
		ELSE 4
	END
	,ysnShow = CASE 
		WHEN BD_ITEM.intInventoryReceiptItemId IS NOT NULL AND BD_ITEM.intContractDetailId IS NOT NULL THEN CASE WHEN BD_MISC.ysnStage = 0 AND BD_MISC.intSettleStorageId IS NULL THEN 0 ELSE 1 END --CONTRACT
		ELSE 0
	END
	,BD_MISC.ysnStage
FROM tblAPBillDetail BD_ITEM
INNER JOIN tblICItem IC
	ON IC.intItemId = BD_ITEM.intItemId
		AND IC.strType = 'Inventory'
INNER JOIN tblAPBillDetail BD_MISC
	ON BD_MISC.intBillId = BD_ITEM.intBillId
		AND BD_MISC.intItemId IS NULL
WHERE BD_ITEM.intBillId = @intBillId
) A

UPDATE A
SET ysnShow = CASE
				WHEN C.rowNum = 1 THEN 1
				ELSE A.ysnShow
			END

--SELECT A.*,B.*,C.*
FROM @tbl A
LEFT JOIN (
	SELECT intBillDetailOtherChargeItemId
		,intBillDetailItemId
		,rowNum = ROW_NUMBER() OVER (PARTITION BY intBillDetailOtherChargeItemId ORDER BY intBillDetailItemId ASC)
	FROM @tbl
	WHERE intTypeId IN (2,3)
		AND ysnStage = 0
) C ON C.intBillDetailOtherChargeItemId = A.intBillDetailOtherChargeItemId
	AND C.intBillDetailItemId = A.intBillDetailItemId

--SELECT * FROM @tbl

RETURN;
END