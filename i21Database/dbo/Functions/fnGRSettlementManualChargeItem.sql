CREATE FUNCTION [dbo].[fnGRSettlementManualChargeItem]
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
SELECT intBillDetailItemId = BD.intBillDetailId
	,intBillDetailOtherChargeItemId = BD2.intBillDetailId
	,intTypeId = CASE 
		WHEN BD.intInventoryReceiptItemId IS NOT NULL AND BD.intContractDetailId IS NULL THEN 1 --SPOT
		WHEN BD.intInventoryReceiptItemId IS NOT NULL AND BD.intContractDetailId IS NOT NULL THEN 2 --CONTRACT
		WHEN BD.intCustomerStorageId IS NOT NULL THEN 3 --SETTLE STORAGE
		ELSE 4
	END
	,ysnShow = CASE 
		WHEN BD.intInventoryReceiptItemId IS NOT NULL AND BD.intContractDetailId IS NOT NULL THEN CASE WHEN BD2.ysnStage = 0 AND BD2.intSettleStorageId IS NULL THEN 0 ELSE 1 END --CONTRACT
		ELSE 0
	END
	,BD2.ysnStage
FROM tblAPBillDetail BD
INNER JOIN tblICItem IC
	ON IC.intItemId = BD.intItemId
		AND IC.strType = 'Inventory'
LEFT JOIN (
			tblAPBillDetail BD2
			LEFT JOIN tblICItem IC2
				ON IC2.intItemId = BD2.intItemId
					AND IC2.strType = 'Other Charge'
	)	
	ON BD2.intBillId = BD.intBillId
		AND isnull(BD2.intInventoryReceiptItemId, isnull(BD.intInventoryReceiptItemId, 0)) = isnull(BD.intInventoryReceiptItemId, 0)
		AND (ISNULL(BD2.intLinkingId, 0) = ISNULL(BD.intLinkingId, 0) OR ISNULL(BD2.intLinkingId,-90) = -90)
		AND ISNULL(BD2.intItemId,0) <> BD.intItemId
WHERE BD.intBillId = @intBillId
) A

UPDATE A
SET ysnShow = CASE 
				WHEN B.ysnStage = 1 AND B.intTypeId = 2 THEN 1
				WHEN C.rowNum = 1 THEN 1
				ELSE A.ysnShow
			END

--SELECT A.*,B.*,C.*
FROM @tbl A
INNER JOIN (
	SELECT DISTINCT * FROM @tbl
) B ON B.intBillDetailOtherChargeItemId = A.intBillDetailOtherChargeItemId
LEFT JOIN (
	SELECT intBillDetailOtherChargeItemId
		,intBillDetailItemId
		,rowNum = ROW_NUMBER() OVER (PARTITION BY intBillDetailOtherChargeItemId ORDER BY intBillDetailItemId ASC)
	FROM @tbl
	WHERE intTypeId IN (2,3)
		AND ysnStage = 0
		AND NOT EXISTS(SELECT 1 FROM @tbl WHERE intTypeId = 1)
) C ON C.intBillDetailOtherChargeItemId = A.intBillDetailOtherChargeItemId
	AND C.intBillDetailItemId = A.intBillDetailItemId

--SELECT * FROM @tbl

RETURN;
END