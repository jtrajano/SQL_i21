CREATE PROCEDURE uspICPostInventoryAdjustmentLotOwnerChange  
	@intTransactionId INT = NULL,
	@ysnPost BIT 
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  

-----------------------------------------------------------------------------------------------
-- UPDATE TO THE NEW LOT OWNER 
-----------------------------------------------------------------------------------------------
UPDATE	LotMaster
SET		intItemOwnerId = CASE WHEN @ysnPost = 1 THEN Detail.intNewItemOwnerId ELSE Detail.intItemOwnerId END
FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
			ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
		INNER JOIN dbo.tblICLot LotMaster 
			ON LotMaster.intLotId = Detail.intLotId
WHERE	Header.intInventoryAdjustmentId = @intTransactionId


Post_Exit: 