CREATE PROCEDURE [dbo].[uspICInventoryAdjustment_CreatePostQtyChangeFromSAP]
	-- Parameters for filtering:
	@intItemId AS INT
	,@dtmDate AS DATETIME 
	,@intLocationId AS INT	
	,@intSubLocationId AS INT	
	,@intStorageLocationId AS INT	
	,@strLotNumber AS NVARCHAR(50)		
	-- Parameters for the new values: 
	,@dblAdjustByQuantity AS NUMERIC(38,20)
	,@dblNewUnitCost AS NUMERIC(38,20)
	,@intItemUOMId AS INT 
	-- Parameters used for linking or FK (foreign key) relationships
	,@intSourceId AS INT
	,@intSourceTransactionTypeId AS INT
	,@intEntityUserSecurityId AS INT 
	,@intInventoryAdjustmentId AS INT OUTPUT
	,@strDescription AS NVARCHAR(1000) = NULL 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ADJUSTMENT_TYPE_QuantityChange AS INT = 1
		,@ADJUSTMENT_TYPE_UOMChange AS INT = 2
		,@ADJUSTMENT_TYPE_ItemChange AS INT = 3
		,@ADJUSTMENT_TYPE_LotStatusChange AS INT = 4
		,@ADJUSTMENT_TYPE_SplitLot AS INT = 5
		,@ADJUSTMENT_TYPE_ExpiryDateChange AS INT = 6

DECLARE @TRANSACTION_TYPE_INVENTORY_ADJUSTMENT AS INT = 10

DECLARE @InventoryAdjustment_Batch_Id AS INT = 30
		,@strAdjustmentNo AS NVARCHAR(40)
		,@intLotId AS INT 

------------------------------------------------------------------------------------------------------------------------------------
-- VALIDATIONS
------------------------------------------------------------------------------------------------------------------------------------
-- Validate the source transaction type id. 
IF NOT EXISTS (
	SELECT	TOP 1 1 
	FROM	dbo.tblICInventoryTransactionPostingIntegration
	WHERE	intTransactionTypeId = @TRANSACTION_TYPE_INVENTORY_ADJUSTMENT
			AND intLinkAllowedTransactionTypeId = @intSourceTransactionTypeId
)
BEGIN
	-- 'Internal Error. The source transaction type provided is invalid or not supported.' 
	EXEC uspICRaiseError 80032;   
	GOTO _Exit;
END 

-- Validate the source id. 
IF @intSourceId IS NULL 
BEGIN
	-- 'Internal Error. The source transaction id is invalid.'
	EXEC uspICRaiseError 80033;  
	GOTO _Exit;
END 

-- Check the lot number if it is lot-tracked. Validate the lot number. 
IF dbo.fnGetItemLotType(@intItemId) <> 0 
BEGIN 
	-- Find the Lot Id
	BEGIN 
		SELECT	@intLotId = Lot.intLotId
		FROM	dbo.tblICLot Lot 
		WHERE	Lot.strLotNumber = @strLotNumber
				AND Lot.intItemId = @intItemId
				AND ISNULL(Lot.intLocationId, 0) = ISNULL(@intLocationId, ISNULL(Lot.intLocationId, 0)) 
				AND ISNULL(Lot.intSubLocationId, 0) = ISNULL(@intSubLocationId, ISNULL(Lot.intSubLocationId, 0))
				AND ISNULL(Lot.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, ISNULL(Lot.intStorageLocationId, 0)) 
	END 

	-- Raise an error if Lot id is invalid. 
	IF @intLotId IS NULL AND @dblAdjustByQuantity < 0 
	BEGIN 
		-- Invalid Lot
		EXEC uspICRaiseError 80020; 
		GOTO _Exit
	END 	

	-- Check if the item uom id is valid for the lot record. 
	IF @dblAdjustByQuantity < 0  AND NOT EXISTS (
		SELECT	TOP 1 1
		FROM	dbo.tblICLot 
		WHERE	intItemId = @intItemId
				AND intLotId = @intLotId
				AND (intItemUOMId = @intItemUOMId OR intWeightUOMId = @intItemUOMId) 
	)
	BEGIN 
		-- Item UOM is invalid or missing.
		EXEC uspICRaiseError 80048;   
		GOTO _Exit
	END 
END 

-- Raise an error if Adjust By Quantity is invalid
IF ISNULL(@dblAdjustByQuantity, 0) = 0 
BEGIN 
	-- 'Internal Error. The Adjust By Quantity is required.'
	EXEC uspICRaiseError 80035; 
	GOTO _Exit
END 

-- Check if the item uom id is valid. 
IF NOT EXISTS (
	SELECT	TOP 1 1
	FROM	dbo.tblICItemUOM
	WHERE	intItemId = @intItemId
			AND intItemUOMId = @intItemUOMId	
)
BEGIN 
	-- Item UOM is invalid or missing.
	EXEC uspICRaiseError 80048;   
	GOTO _Exit
END 

------------------------------------------------------------------------------------------------------------------------------------
-- Create the starting number for the inventory adjustment. 
------------------------------------------------------------------------------------------------------------------------------------
EXEC dbo.uspSMGetStartingNumber @InventoryAdjustment_Batch_Id, @strAdjustmentNo OUTPUT, @intLocationId
IF @@ERROR <> 0 GOTO _Exit


--Re-check if the adjustment id is already used. If yes, then regenerate the adjustment no. 
BEGIN 
	IF EXISTS (SELECT TOP 1 1 FROM tblICInventoryAdjustment WHERE strAdjustmentNo = @strAdjustmentNo)
	BEGIN 
		EXEC dbo.uspSMGetStartingNumber @InventoryAdjustment_Batch_Id, @strAdjustmentNo OUTPUT 
		IF @@ERROR <> 0 GOTO _Exit
	END
END 

------------------------------------------------------------------------------------------------------------------------------------
-- Set the transaction date and expiration date
------------------------------------------------------------------------------------------------------------------------------------
SET @dtmDate = ISNULL(@dtmDate, GETDATE());

------------------------------------------------------------------------------------------------------------------------------------
-- Create the header record
------------------------------------------------------------------------------------------------------------------------------------
BEGIN 
	INSERT INTO dbo.tblICInventoryAdjustment (
			intLocationId
			,dtmAdjustmentDate
			,intAdjustmentType
			,strAdjustmentNo
			,strDescription
			,intSort
			,ysnPosted
			,intEntityId
			,intConcurrencyId
			,dtmPostedDate
			,dtmUnpostedDate
			,intSourceId
			,intSourceTransactionTypeId
	)
	SELECT	intLocationId				= @intLocationId
			,dtmAdjustmentDate			= dbo.fnRemoveTimeOnDate(@dtmDate) 
			,intAdjustmentType			= @ADJUSTMENT_TYPE_QuantityChange
			,strAdjustmentNo			= @strAdjustmentNo
			,strDescription				= @strDescription
			,intSort					= 1
			,ysnPosted					= 0
			,intEntityId				= @intEntityUserSecurityId
			,intConcurrencyId			= 1
			,dtmPostedDate				= NULL 
			,dtmUnpostedDate			= NULL	
			,intSourceTransactionId		= @intSourceId
			,intSourceTransactionTypeId = @intSourceTransactionTypeId

	SELECT @intInventoryAdjustmentId = SCOPE_IDENTITY();
END

------------------------------------------------------------------------------------------------------------------------------------
-- Create the detail record 
------------------------------------------------------------------------------------------------------------------------------------
BEGIN 
	INSERT INTO dbo.tblICInventoryAdjustmentDetail (
			intInventoryAdjustmentId
			,intSubLocationId
			,intStorageLocationId
			,intItemId
			,intLotId
			,intItemUOMId
			,dblQuantity
			,dblAdjustByQuantity
			,dblNewQuantity
			,intWeightUOMId
			,dblWeight
			,dblWeightPerQty
			,dblCost
			,dblNewCost
			,intSort
			,intConcurrencyId
	)
	SELECT 
			intInventoryAdjustmentId	= @intInventoryAdjustmentId
			,intSubLocationId			= ISNULL(Lot.intSubLocationId, @intSubLocationId)
			,intStorageLocationId		= ISNULL(Lot.intStorageLocationId, @intStorageLocationId)
			,intItemId					= @intItemId
			,intLotId					= Lot.intLotId
			,intItemUOMId				= @intItemUOMId
			,dblQuantity				=	CASE	WHEN Lot.intItemUOMId = @intItemUOMId THEN Lot.dblQty
													WHEN Lot.intWeightUOMId = @intItemUOMId THEN Lot.dblWeight
													ELSE ISNULL(StocksPerUOM.dblOnHand, 0)
											END 
			,dblAdjustByQuantity		= @dblAdjustByQuantity
			,dblNewQuantity				=	CASE	WHEN Lot.intItemUOMId = @intItemUOMId THEN Lot.dblQty
													WHEN Lot.intWeightUOMId = @intItemUOMId THEN Lot.dblWeight
													ELSE ISNULL(StocksPerUOM.dblOnHand, 0)
											END 
											+ @dblAdjustByQuantity
			,intWeightUOMId				= ISNULL(Lot.intWeightUOMId, @intItemUOMId)
			,dblWeight					=	CASE	WHEN Lot.intItemUOMId = @intItemUOMId THEN ABS(dbo.fnMultiply(@dblAdjustByQuantity, Lot.dblWeightPerQty)) 
													WHEN Lot.intWeightUOMId = @intItemUOMId OR Lot.intWeightUOMId IS NULL THEN ABS(@dblAdjustByQuantity)
													ELSE 0 
											END 
			,dblWeightPerQty			= ISNULL(Lot.dblWeightPerQty, 1)
			,dblCost					= dbo.fnCalculateCostBetweenUOM(StockUnit.intItemUOMId, @intItemUOMId, ISNULL(Lot.dblLastCost, ISNULL(ItemPricing.dblLastCost, 0)))
			,dblNewCost					= @dblNewUnitCost
			,intSort					= 1
			,intConcurrencyId			= 1
	FROM	dbo.tblICItem Item INNER JOIN dbo.tblICItemLocation ItemLocation
				ON ItemLocation.intItemId = Item.intItemId
				AND ItemLocation.intLocationId = @intLocationId	
			LEFT JOIN dbo.tblICLot Lot
				ON Item.intItemId = Lot.intItemId
				AND Lot.intLotId = @intLotId
			LEFT JOIN dbo.tblICItemStockUOM StocksPerUOM
				ON StocksPerUOM.intItemId = Item.intItemId
				AND StocksPerUOM.intItemLocationId = ItemLocation.intItemLocationId	
				AND StocksPerUOM.intItemUOMId = @intItemUOMId
				AND StocksPerUOM.intSubLocationId = ItemLocation.intSubLocationId
				AND StocksPerUOM.intStorageLocationId = ItemLocation.intStorageLocationId
			LEFT JOIN dbo.tblICItemUOM StockUnit
				ON StockUnit.intItemId = Item.intItemId
				AND ISNULL(StockUnit.ysnStockUnit, 0) = 1
			LEFT JOIN dbo.tblICItemPricing ItemPricing
				ON ItemPricing.intItemId = Item.intItemId
				AND ItemPricing.intItemLocationId = ItemLocation.intItemLocationId
	WHERE	Item.intItemId = @intItemId			
END 

-- Auto-create the lot numbers 
BEGIN 
	EXEC uspICCreateLotNumberOnAdjustStockFromSAP
		@strTransactionId = @strAdjustmentNo
		,@intLocationId = @intLocationId
		,@intEntityUserSecurityId = @intEntityUserSecurityId
		,@ysnPost = 1
END 

-- Auto post the inventory adjustment
BEGIN 

	EXEC dbo.uspICPostInventoryAdjustment
		@ysnPost = 1
		,@ysnRecap = 0
		,@strTransactionId = @strAdjustmentNo
		,@intEntityUserSecurityId = @intEntityUserSecurityId
END 

_Exit:

