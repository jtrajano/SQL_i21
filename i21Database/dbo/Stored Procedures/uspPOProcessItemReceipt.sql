CREATE PROCEDURE [dbo].[uspPOProcessItemReceipt]
	@poId INT,
	@userId INT,
	@receiptNumber NVARCHAR(50) OUTPUT
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
 
DECLARE @itemReceiptId INT, @itemReceiptNumber NVARCHAR(50);
-- Implement your code that validates the transaction you need to process.

--Purchase order already closed.
IF EXISTS(SELECT 1 FROM tblPOPurchase WHERE intPurchaseId = @poId AND intOrderStatusId = 3)
BEGIN
	RAISERROR(51036, 16, 1)
	RETURN;
END

IF EXISTS(SELECT 1 FROM tblPOPurchase WHERE intPurchaseId = @poId AND dblTotal = 0)
BEGIN
	RAISERROR(51039, 16, 1)
	RETURN;
END

IF NOT EXISTS(SELECT 1 FROM tblPOPurchaseDetail A
				INNER JOIN tblICItem B ON A.intItemId = B.intItemId 
				WHERE strType NOT IN ('Non-Inventory', 'Other Charge', 'Service') AND intPurchaseId = @poId)
BEGIN
	RAISERROR('There is no receivable item on this purchase order.', 16, 1);
	RETURN;
END

-- Add code to lock-out editing of the purchase order after it has been processed.
  
-- Call inventory stored procedure to process your transaction into "Item Receipt"

DECLARE @icUserId INT = (SELECT TOP 1 intUserSecurityID FROM tblSMUserSecurity WHERE intEntityId = @userId);

EXEC dbo.uspICProcessToItemReceipt
	@intSourceTransactionId = @poId
	,@strSourceType = 'Purchase Order'
	,@intUserId = @icUserId
	,@InventoryReceiptId = @itemReceiptId OUTPUT

IF @@ERROR > 0 
	RETURN;

SELECT @itemReceiptNumber = strReceiptNumber FROM tblICInventoryReceipt WHERE intInventoryReceiptId = @itemReceiptId

UPDATE A
	SET intOrderStatusId = 7--Pending
FROM tblPOPurchase A
WHERE intPurchaseId = @poId

SET @receiptNumber = @itemReceiptNumber;

END
