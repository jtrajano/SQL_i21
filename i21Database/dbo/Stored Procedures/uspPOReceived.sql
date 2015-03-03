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
		,B.dblOpenReceive
		,B.intItemId
		,A.ysnPosted
	INTO #tmpReceivedPOItems
	FROM tblICInventoryReceipt A
		LEFT JOIN tblICInventoryReceiptItem B ON A.intInventoryReceiptId = B.intInventoryReceiptId
	WHERE A.intInventoryReceiptId = @receiptItemId

	SELECT TOP 1 @posted = ysnPosted FROM #tmpReceivedPOItems

	--Validate if purchase order exists..
	SELECT
		TOP 1 @purchaseOrderNumber = strPurchaseOrderNumber
	FROM #tmpReceivedPOItems A
	OUTER APPLY 
	(
		SELECT strPurchaseOrderNumber FROM tblPOPurchase B WHERE A.intSourceId = B.intPurchaseId
	) PurchaseOrders
	WHERE PurchaseOrders.strPurchaseOrderNumber IS NULL

	IF(@purchaseOrderNumber <> NULL)
	BEGIN
		RAISERROR(51033, 11, 1); --Not Exists
		RETURN;
	END

	--Validate if item exists on PO
	SELECT 
		TOP 1 @strItemNo = (SELECT strItemNo FROM tblICItem WHERE intItemId = A.intItemId)
	FROM #tmpReceivedPOItems A
	OUTER APPLY 
	(
		SELECT intItemId FROM tblPOPurchaseDetail B WHERE A.intSourceId = B.intPurchaseId
		AND A.intItemId = B.intItemId AND A.intLineNo = B.intPurchaseDetailId
	) PurchaseOrderDetails
	WHERE PurchaseOrderDetails.intItemId IS NULL

	IF(@strItemNo <> NULL)
	BEGIN
		RAISERROR(51034, 11, 1); --PO item not exists
		RETURN;
	END

	IF(EXISTS(SELECT 1 FROM tblPOPurchaseDetail A 
				INNER JOIN #tmpReceivedPOItems B 
				ON A.intPurchaseDetailId = B.intLineNo AND A.intItemId = B.intItemId
		AND intPurchaseId = intSourceId AND (dblQtyReceived + B.dblOpenReceive) > dblQtyOrdered) AND @posted = 1)
	BEGIN
		RAISERROR(51035, 11, 1); --received item exceeds
		RETURN;
	END

	UPDATE A
		SET dblQtyReceived = CASE WHEN @posted = 1 
								THEN (dblQtyReceived + B.dblOpenReceive) 
							ELSE (dblQtyReceived - B.dblOpenReceive) END
	FROM tblPOPurchaseDetail A
		INNER JOIN #tmpReceivedPOItems B ON A.intItemId = B.intItemId AND A.intPurchaseDetailId = B.intLineNo
	AND intPurchaseId = B.intSourceId
	--AND intPurchaseDetailId IN (SELECT intLineNo FROM #tmpReceivedPOItems)

	UPDATE A
		SET intOrderStatusId = CASE WHEN (SELECT SUM(dblQtyReceived) - SUM(dblQtyOrdered) FROM tblPOPurchaseDetail WHERE intPurchaseId = B.intSourceId) 
											= 0
									THEN 3 ELSE 2 END
	FROM tblPOPurchase A
	INNER JOIN #tmpReceivedPOItems B ON A.intPurchaseId = B.intSourceId

END
