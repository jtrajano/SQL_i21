CREATE PROCEDURE uspICPostInventoryAdjustmentChangeLotWeight
	@intTransactionId INT = NULL,
	@ysnPost BIT = 0   
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  

BEGIN

-----------------------------------------------------------------------------------------------
-- UPDATE LOT WEIGHT
-----------------------------------------------------------------------------------------------
UPDATE LotMaster
SET intWeightUOMId = CASE	
						WHEN @ysnPost = 1 THEN Detail.intNewWeightUOMId
						ELSE Detail.intWeightUOMId
					END,
	dblWeight = CASE	
						WHEN @ysnPost = 1 THEN Detail.dblNewWeight
						ELSE Detail.dblWeight
					END,
	dblWeightPerQty = CASE	
						WHEN @ysnPost = 1 THEN Detail.dblNewWeightPerQty
						ELSE Detail.dblWeightPerQty
					END
FROM tblICLot LotMaster
INNER JOIN tblICInventoryAdjustmentDetail Detail ON Detail.intLotId = LotMaster.intLotId
INNER JOIN tblICInventoryAdjustment Header ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
WHERE Header.intInventoryAdjustmentId = @intTransactionId
END