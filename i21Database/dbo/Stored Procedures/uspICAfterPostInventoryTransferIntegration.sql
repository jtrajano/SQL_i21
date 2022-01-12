CREATE PROCEDURE uspICAfterPostInventoryTransferIntegration
	@ysnPost BIT = 0  
	,@intTransactionId INT = NULL   
	,@intEntityUserSecurityId INT  = NULL      
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS ON  

DECLARE @INVENTORY_TRANSFER_TYPE AS INT = 12

-- Mark stock reservation as unposted
IF @ysnPost = 0
BEGIN 
	EXEC dbo.uspICPostStockReservation
		@intTransactionId
		,@INVENTORY_TRANSFER_TYPE
		,@ysnPost
END

_Exit: 