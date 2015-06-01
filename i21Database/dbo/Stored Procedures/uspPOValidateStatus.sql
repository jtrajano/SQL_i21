CREATE PROCEDURE [dbo].[uspPOValidateStatus]
	@poId INT,
	@statusId INT
AS
BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @currentStatus INT;
	DECLARE @success BIT = 1;
	DECLARE @errorMsg NVARCHAR(200);
	DECLARE @fullyBilled BIT;
	DECLARE @fullyReceived BIT;
	DECLARE @hasItemReceipt BIT;
	DECLARE @hasBill BIT;

	SELECT @currentStatus = intOrderStatusId FROM tblPOPurchase WHERE intPurchaseId = @poId
	SET @hasItemReceipt  = CASE WHEN (SELECT dbo.fnPOHasItemReceipt(@poId, 0)) = 1 
									THEN 1
								WHEN (SELECT dbo.fnPOHasItemReceipt(@poId, 1)) = 1
									THEN 1
								ELSE 0 END
	SET @hasBill  = CASE WHEN (SELECT dbo.fnPOHasBill(@poId, 0)) = 1 
									THEN 1
								WHEN (SELECT dbo.fnPOHasBill(@poId, 1)) = 1
									THEN 1
								ELSE 0 END
	SET @fullyReceived = CASE WHEN
								(SELECT SUM(dblPOItemQtyReceive) FROM vyuPOStatus WHERE intPurchaseId = @poId) = (SELECT SUM(dblQtyOrdered) FROM vyuPOStatus WHERE intPurchaseId = @poId)
								THEN 1
								ELSE 0
							END 
	SET @fullyBilled = CASE WHEN
								(SELECT SUM(dblItemQtyBilled) FROM vyuPOStatus WHERE intPurchaseId = @poId) = (SELECT SUM(dblQtyOrdered) FROM vyuPOStatus WHERE intPurchaseId = @poId)
								THEN 1
								ELSE 0
							END 


	IF @statusId = 1 --OPEN
	BEGIN
		--Allow to open if no item receipt or bill or from cancelled or short closed status
		IF (@hasItemReceipt = 1 OR
			 @hasBill = 1 OR
			 EXISTS(SELECT 1 FROM (SELECT intOrderStatusId FROM tblPOOrderStatus WHERE intOrderStatusId IN (4,6)) POStatus 
																	WHERE intOrderStatusId = @currentStatus))
					AND @currentStatus != 1
		BEGIN
			SET @success = 0;
			SET @errorMsg = 'You cannot open a purchase order with created item receipt or bill.';
		END
	END
	ELSE IF @statusId = 2 --PARTIAL
	BEGIN
		IF EXISTS(SELECT 1 FROM vyuPOStatus WHERE intPurchaseId = @poId AND dblQtyReceived > 0) AND @currentStatus != 2
		BEGIN
			SET @success = 0;
			SET @errorMsg = 'Purchase order will automatically set to "Partial" when at least 1 item have been received/billed.';
		END
	END
	ELSE IF @statusId = 3 --CLOSED
	BEGIN
		IF (@fullyReceived = 0 OR @fullyBilled = 0) AND @currentStatus != 3
		BEGIN
			SET @success = 0;
			SET @errorMsg = 'Purchase order will automatically set to "Closed" when all items have been received/billed.';
		END
	END
	ELSE IF @statusId = 4 --CANCELLED
	BEGIN
		IF @currentStatus != 4 AND EXISTS(SELECT 1 FROM vyuPOStatus WHERE intPurchaseId = @poId AND ysnItemReceived = 1)
		BEGIN
			SET @success = 0;
			SET @errorMsg = 'You cannot change the status of this PO to "Cancelled" because it has received item(s).';
		END
		IF @currentStatus != 4 AND @success = 1
		BEGIN
			IF (dbo.fnPOHasItemReceipt(@poId, 0) = 1 OR dbo.fnPOHasBill(@poId, 0) = 1)
			BEGIN
				SET @success = 0;
				SET @errorMsg = 'You cannot cancel this PO. Please delete the open receipt/bill before cancelling.';
			END
		END
	END
	ELSE IF @statusId = 6 --SHORT CLOSED
	BEGIN
		IF @currentStatus != 6 AND @currentStatus != 2
		BEGIN
			SET @success = 0;
			SET @errorMsg = 'You can short closed only a partially received Purchase Order.';
		END
	END
	ELSE IF @statusId = 7 --PENDING
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