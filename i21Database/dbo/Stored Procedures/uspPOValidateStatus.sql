CREATE PROCEDURE [dbo].[uspPOValidateStatus]
	@poId INT,
	@statusId INT
AS
BEGIN

	DECLARE @currentStatus INT;
	DECLARE @success BIT = 1;
	DECLARE @errorMsg NVARCHAR(200);
	DECLARE @fullyBilled BIT;
	DECLARE @fullyReceived BIT;
	DECLARE @hasItemReceipt BIT;
	DECLARE @hasBill BIT;

	SELECT @currentStatus = intOrderStatusId FROM tblPOPurchase WHERE intPurchaseId = @poId
	SET @hasItemReceipt  = CASE WHEN 
								EXISTS(SELECT 1 
									FROM   tblICInventoryReceipt A INNER JOIN tblICInventoryReceiptItem B
														ON A.intInventoryReceiptId = B.intInventoryReceiptId
									WHERE  B.intSourceId = @poId)
								THEN 1
								ELSE 0
							END

	SET @hasBill  = CASE WHEN 
								EXISTS(SELECT 1 
									FROM   tblAPBill A INNER JOIN tblAPBillDetail B
														ON A.intBillId = B.intBillId
														INNER JOIN tblPOPurchaseDetail C
														ON B.intItemReceiptId = C.intPurchaseDetailId
									WHERE  C.intPurchaseId = @poId)
								THEN 1
								ELSE 0
							END
	SET @fullyReceived = CASE WHEN
								(SELECT SUM(dblItemQtyReceived) FROM vyuPOStatus WHERE intPurchaseId = @poId) = (SELECT SUM(dblQtyOrdered) FROM vyuPOStatus WHERE intPurchaseId = @poId)
								THEN 1
								ELSE 0
							END 
	SET @fullyBilled = CASE WHEN
								(SELECT SUM(dblItemQtyBilled) FROM vyuPOStatus WHERE intPurchaseId = @poId) = (SELECT SUM(dblQtyOrdered) FROM vyuPOStatus WHERE intPurchaseId = @poId)
								THEN 1
								ELSE 0
							END 


	IF @statusId = 1
	BEGIN
		--Allow to open if no item receipt or bill or from cancelled or short closed status
		IF (@hasItemReceipt = 1 OR @hasBill = 1 OR EXISTS(SELECT 1 FROM (SELECT intOrderStatusId FROM tblPOOrderStatus WHERE intOrderStatusId IN (4,6)) POStatus 
																	WHERE intOrderStatusId = @currentStatus))
					AND @currentStatus != 1
		BEGIN
			SET @success = 0;
			SET @errorMsg = 'You cannot open a purchase order with created item receipt or bill.';
		END
	END
	ELSE IF @statusId = 2
	BEGIN
		IF EXISTS(SELECT 1 FROM vyuPOStatus WHERE intPurchaseId = @poId AND dblQtyReceived > 0) AND @currentStatus != 2
		BEGIN
			SET @success = 0;
			SET @errorMsg = 'Purchase order will automatically set to "Partial" when at least 1 item have been received/billed.';
		END
	END
	ELSE IF @statusId = 3
	BEGIN
		IF (@fullyReceived = 0 OR @fullyBilled = 0) AND @currentStatus != 3
		BEGIN
			SET @success = 0;
			SET @errorMsg = 'Purchase order will automatically set to "Closed" when all items have been received/billed.';
		END
	END
	ELSE IF @statusId = 4
	BEGIN
		IF @currentStatus != 4 AND EXISTS(SELECT 1 FROM vyuPOStatus WHERE intPurchaseId = @poId AND ysnItemReceived = 1)
		BEGIN
			SET @success = 0;
			SET @errorMsg = 'You cannot change the status of this PO to "Cancelled" because it has received item(s).';
		END
	END
	ELSE IF @statusId = 7
	BEGIN
		IF @hasItemReceipt = 0 AND @hasBill = 0 AND @currentStatus != 7
		BEGIN
			SET @success = 0;
			SET @errorMsg = 'This purchase order will automatically set to ''Pending'' after processing to item receipt or bill.';
		END
	END
	ELSE
	BEGIN
		SET @success = 0;
		SET @errorMsg = 'Invalid status provided.';
	END

	IF @success = 0
	BEGIN
		RAISERROR(@errorMsg, 16, 1);
	END

END