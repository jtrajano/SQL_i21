CREATE PROCEDURE uspICPostInventoryAdjustmentLotStatusChange  
	@intTransactionId INT = NULL,
	@ysnPost BIT 
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF

-----------------------------------------------------------------------------------------------
-- VALIDATION 
-----------------------------------------------------------------------------------------------
-- Validate for duplicate lot ids. 
DECLARE @strItemNo AS NVARCHAR(50)
		,@strLotNumber AS NVARCHAR(50)

SELECT	@strItemNo = Item.strItemNo
		,@strLotNumber = Lot.strLotNumber
FROM	(
			SELECT	Detail.intItemId
					,Detail.intLotId
					,[Count] = COUNT(1) 
			FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
					ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
			WHERE	Header.intInventoryAdjustmentId = @intTransactionId
					AND Detail.intLotId IS NOT NULL 
			GROUP BY Detail.intItemId, Detail.intLotId
			HAVING COUNT(1) > 1
		) DuplicateLotId
		INNER JOIN dbo.tblICItem Item 
			ON DuplicateLotId.intItemId = Item.intItemId
		INNER JOIN dbo.tblICLot Lot
			ON DuplicateLotId.intLotId = Lot.intLotId

IF @ysnPost = 1 AND (@strItemNo IS NOT NULL AND @strLotNumber IS NOT NULL)
BEGIN   
	-- 'Lot status for {Lot Number} for item {Item No} is going to be updated more than once. Please remove the duplicate.'
	EXEC uspICRaiseError 80024, @strLotNumber, @strItemNo;
	RETURN -1
END   

-----------------------------------------------------------------------------------------------
-- UPDATE THE LOT STATUS
-----------------------------------------------------------------------------------------------
UPDATE	LotMaster
SET		intLotStatusId = CASE WHEN @ysnPost = 1 THEN Detail.intNewLotStatusId ELSE Detail.intLotStatusId END
FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
			ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
		INNER JOIN dbo.tblICLot LotMaster 
			ON LotMaster.intLotId = Detail.intLotId
WHERE	Header.intInventoryAdjustmentId = @intTransactionId