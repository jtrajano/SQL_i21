CREATE PROCEDURE [dbo].[uspPOProcessItemReceipt]
	@poIds NVARCHAR(MAX),
	@userId NVARCHAR(50)
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
 
-- Implement your code that validates the transaction you need to process.
 
-- Add code to lock-out editing of the purchase order after it has been processed.
  
-- Call inventory stored procedure to process your transaction into "Item Receipt"
EXEC dbo.uspICProcessToItemReceipt
	@intSourceTransactionId = 1
	,@strSourceType = 'Purchase Order'
	,@intUserId = 1

END
