CREATE PROCEDURE [dbo].[uspICInventoryAdjustment_CreatePostQtyChange]
	-- Parameters for filtering:
	@intItemId AS INT
	,@dtmDate AS DATETIME 
	,@intLocationId AS INT	
	,@intSubLocationId AS INT	
	,@intStorageLocationId AS INT	
	,@strLotNumber AS NVARCHAR(50)		
	-- Parameters for the new values: 
	,@dblAdjustByQuantity AS NUMERIC(18,6)
	,@dblNewUnitCost AS NUMERIC(38, 20)
	-- Parameters used for linking or FK (foreign key) relationships
	,@intSourceId AS INT
	,@intSourceTransactionTypeId AS INT
	,@intUserId AS INT 
	,@intInventoryAdjustmentId AS INT OUTPUT
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
		,@intEntityId AS INT 
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
	RAISERROR(51124, 11, 1)  
	GOTO _Exit;
END 

-- Validate the source id. 
IF @intSourceId IS NULL 
BEGIN
	-- 'Internal Error. The source transaction id is invalid.'
	RAISERROR(51125, 11, 1)  
	GOTO _Exit;
END 

-- Check the lot number if it is lot-tracked. Validate the lot number. 
IF dbo.fnGetItemLotType(@intItemId) = 1
BEGIN 
	-- Find the Lot Id
	BEGIN 
		SELECT	@intLotId = Lot.intLotId
		FROM	dbo.tblICLot Lot 
		WHERE	Lot.strLotNumber = @strLotNumber
				AND Lot.intItemId = @intItemId
				AND Lot.intLocationId = @intLocationId
				AND Lot.intSubLocationId = @intSubLocationId
				AND Lot.intStorageLocationId = @intStorageLocationId
	END 

	-- Raise an error if Lot id is invalid. 
	IF @intLotId IS NULL 
	BEGIN 
		-- Invalid Lot
		RAISERROR(51053, 11, 1)  
		GOTO _Exit
	END 	
END 

-- Raise an error if Adjust By Quantity is invalid
IF ISNULL(@dblAdjustByQuantity, 0) > 0 
BEGIN 
	-- 'Internal Error. The Adjust By Quantity is required to be a negative value.'
	RAISERROR(51127, 11, 1)  
	GOTO _Exit
END 

------------------------------------------------------------------------------------------------------------------------------------
-- Create the starting number for the inventory adjustment. 
------------------------------------------------------------------------------------------------------------------------------------
EXEC dbo.uspSMGetStartingNumber @InventoryAdjustment_Batch_Id, @strAdjustmentNo OUTPUT 
IF @@ERROR <> 0 GOTO _Exit

------------------------------------------------------------------------------------------------------------------------------------
-- Set the transaction date and expiration date
------------------------------------------------------------------------------------------------------------------------------------
SET @dtmDate = ISNULL(@dtmDate, GETDATE());

------------------------------------------------------------------------------------------------------------------------------------
-- Retrieve the entity id of the user id
------------------------------------------------------------------------------------------------------------------------------------
SELECT	@intEntityId = intEntityId
FROM	dbo.tblSMUserSecurity
WHERE	intUserSecurityID = @intUserId

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
			,strDescription				= ''
			,intSort					= 1
			,ysnPosted					= 0
			,intEntityId				= @intEntityId
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
IF @intLotId IS NOT NULL
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
			,intSubLocationId			= Lot.intSubLocationId
			,intStorageLocationId		= Lot.intStorageLocationId
			,intItemId					= Lot.intItemId
			,intLotId					= Lot.intLotId
			,intItemUOMId				= Lot.intItemUOMId
			,dblQuantity				= Lot.dblQty
			,dblAdjustByQuantity		= @dblAdjustByQuantity
			,dblNewQuantity				= Lot.dblQty + @dblAdjustByQuantity
			,intWeightUOMId				= Lot.intWeightUOMId
			,dblWeight					= ABS(@dblAdjustByQuantity * Lot.dblWeightPerQty)
			,dblWeightPerQty			= Lot.dblWeightPerQty
			,dblCost					= Lot.dblLastCost
			,dblNewCost					= @dblNewUnitCost
			,intSort					= 1
			,intConcurrencyId			= 1
	FROM	dbo.tblICItem Item INNER JOIN dbo.tblICLot Lot
				ON Item.intItemId = Lot.intItemId
	WHERE	Item.intItemId = @intItemId
			AND Lot.intLotId = @intLotId
END 

-- Auto post the inventory adjustment
BEGIN 

	EXEC dbo.uspICPostInventoryAdjustment
		@ysnPost = 1
		,@ysnRecap = 0
		,@strTransactionId = @strAdjustmentNo
		,@intUserId = @intUserId
		,@intEntityId = @intEntityId
END 

_Exit: 

