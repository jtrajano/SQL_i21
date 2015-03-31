﻿CREATE PROCEDURE [dbo].[uspPOValidateStatus]
	@poId INT,
	@statusId INT
AS
BEGIN

	DECLARE @currentStatus INT;
	DECLARE @success BIT;
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
									FROM   tblICInventoryReceipt A INNER JOIN tblICInventoryReceiptItem B
														ON A.intInventoryReceiptId = B.intInventoryReceiptId
									WHERE  B.intSourceId = @poId)
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
		IF @hasItemReceipt = 1 AND EXISTS(SELECT 1 FROM (
																	SELECT intOrderStatusId FROM tblPOOrderStatus WHERE intOrderStatusId IN (4,6)) POStatus 
																	WHERE intOrderStatusId = @currentStatus)
		BEGIN
			--Do not allow to set to open when current status is not equal to 'Cancelled' or 'Short Closed'
			SET @success = 0;
			SET @errorMsg = 'You cannot open a purchase order with created item receipt.';
		END
	END
	ELSE IF @statusId = 2
	BEGIN
		IF EXISTS(SELECT 1 FROM vyuPOStatus WHERE intPurchaseId = @poId AND dblQtyReceived > 0)
		BEGIN
			SET @success = 0;
			SET @errorMsg = 'Purchase order will automatically set to "Partial" when at least 1 item have been received/billed.';
		END
	END
	ELSE IF @statusId = 3
	BEGIN
		IF @fullyReceived = 0 OR @fullyBilled = 0
		BEGIN
			SET @success = 0;
			SET @errorMsg = 'Purchase order will automatically set to "Closed" when all items have been received/billed.';
		END
	END
	ELSE IF @statusId = 4
	BEGIN
		IF @currentStatus != 3 AND EXISTS(SELECT 1 FROM vyuPOStatus WHERE intPurchaseId = @poId AND ysnItemReceived = 1)
		BEGIN
			SET @success = 0;
			SET @errorMsg = 'You cannot change the status of this PO to "Cancelled" because it has received item(s).';
		END
	END
	ELSE IF @statusId = 7
	BEGIN
		IF @hasItemReceipt = 0
		BEGIN
			SET @success = 0;
			SET @errorMsg = 'This purchase order will automatically set to ''Pending'' after processing to item receipt.';
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