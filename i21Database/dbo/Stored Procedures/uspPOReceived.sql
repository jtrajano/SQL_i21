CREATE PROCEDURE [dbo].[uspPOReceived]
	@receiptItemId INT
AS
BEGIN

	DECLARE @purchaseId INT, @lineNo INT, @itemId INT;
	DECLARE @purchaseOrderNumber NVARCHAR(50), @strItemNo NVARCHAR(50);
	DECLARE @posted BIT;
	DECLARE @receivedNum DECIMAL(18,6);

	SELECT
		B.intSourceId
		,B.intLineNo
		,B.dblReceived
		,B.intItemId
		,A.ysnPosted
	INTO #tmpReceivedPOItems
	FROM tblICInventoryReceipt A
		LEFT JOIN tblICInventoryReceiptItem B ON A.intInventoryReceiptId = B.intInventoryReceiptId
	WHERE A.intInventoryReceiptId = @receiptItemId
		
	SELECT TOP 1 @purchaseId = intSourceId, @posted = ysnPosted FROM #tmpReceivedPOItems
	SELECT @purchaseOrderNumber = strPurchaseOrderNumber FROM tblPOPurchase WHERE intPurchaseId = @purchaseId

	--Validate
	IF(NOT EXISTS(SELECT 1 FROM tblPOPurchase WHERE intPurchaseId = @purchaseId))
	BEGIN
		RAISERROR(51033, 11, 1, @purchaseOrderNumber); --Not Exists
		RETURN;
	END

	IF(EXISTS(SELECT TOP 1 intLineNo FROM #tmpReceivedPOItems
				WHERE NOT EXISTS
				(
					SELECT intItemId FROM tblPOPurchaseDetail WHERE intPurchaseId = @purchaseId AND intItemId = @itemId 
					AND intPurchaseDetailId = intLineNo
				)
			)
		)
	BEGIN
		RAISERROR(51034, 11, 1); --PO item not exists
		RETURN;
	END

	IF(EXISTS(SELECT 1 FROM tblPOPurchaseDetail A 
				INNER JOIN #tmpReceivedPOItems B 
				ON A.intPurchaseDetailId = B.intLineNo AND A.intItemId = B.intItemId
		WHERE intPurchaseId = @purchaseId AND (dblQtyReceived + B.dblReceived) > dblQtyOrdered))
	BEGIN
		RAISERROR(51035, 11, 1); --received item exceeds
		RETURN;
	END

	UPDATE A
		SET dblQtyReceived = CASE WHEN @posted = 1 
								THEN (dblQtyReceived + B.dblReceived) 
							ELSE (dblQtyReceived - B.dblReceived) END
	FROM tblPOPurchaseDetail A
		INNER JOIN #tmpReceivedPOItems B ON A.intItemId = B.intItemId AND A.intPurchaseDetailId = B.intSourceId
	WHERE intPurchaseId = @purchaseId
	--AND intPurchaseDetailId IN (SELECT intLineNo FROM #tmpReceivedPOItems)

	UPDATE A
		SET intOrderStatusId = CASE WHEN (SELECT SUM(dblQtyReceived) FROM tblPOPurchaseDetail WHERE intPurchaseId = @purchaseId) 
											= (SELECT SUM(dblQtyOrdered) FROM tblPOPurchaseDetail WHERE intPurchaseId = @purchaseId)
									THEN 3 ELSE 2 END
	FROM tblPOPurchase A
	WHERE intPurchaseId = @purchaseId

END
