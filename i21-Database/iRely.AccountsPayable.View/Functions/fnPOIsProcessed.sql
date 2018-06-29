CREATE FUNCTION [dbo].[fnPOIsProcessed]
(
	@poDetailId INT
)
RETURNS BIT
AS
BEGIN
	DECLARE @processed BIT = 0;

	IF(EXISTS(SELECT 1 FROM tblICInventoryReceipt A
					INNER JOIN tblICInventoryReceiptItem B ON A.intInventoryReceiptId = B.intInventoryReceiptId
					INNER JOIN tblPOPurchaseDetail C ON B.intLineNo = C.intPurchaseDetailId AND B.intOrderId = C.intPurchaseId
					WHERE A.strReceiptType = 'Purchase Order'
					AND C.intPurchaseDetailId = @poDetailId))
	BEGIN
		SET @processed = 1
	END

	RETURN @processed;
END
