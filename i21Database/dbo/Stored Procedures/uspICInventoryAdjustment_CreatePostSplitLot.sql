CREATE PROCEDURE [dbo].[uspICInventoryAdjustment_CreatePostSplitLot]
	-- Parameters for filtering:
	@intItemId AS INT
	,@dtmDate AS DATETIME 
	,@intLocationId AS INT	
	,@intSubLocationId AS INT	
	,@intStorageLocationId AS INT	
	,@strLotNumber AS NVARCHAR(50)		
	-- Parameters for the new values: 
	,@intNewLocationId AS INT
	,@intNewSubLocationId AS INT
	,@intNewStorageLocationId AS INT
	,@strNewLotNumber AS NVARCHAR(50)
	,@dblAdjustByQuantity AS NUMERIC(18,6)
	,@dblNewSplitLotQuantity AS NUMERIC(18,6)	
	,@dblNewWeight AS NUMERIC(18,6)
	,@intNewItemUOMId AS INT
	,@intNewWeightUOMId AS INT
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
		,@ADJUSTMENT_TYPE_LotMerge AS INT = 7
		,@ADJUSTMENT_TYPE_LotMove AS INT = 8

DECLARE @INVENTORY_ADJUSTMENT_QuantityChange AS INT = 10
		,@INVENTORY_ADJUSTMENT_UOMChange AS INT = 14
		,@INVENTORY_ADJUSTMENT_ItemChange AS INT = 15
		,@INVENTORY_ADJUSTMENT_LotStatusChange AS INT = 16
		,@INVENTORY_ADJUSTMENT_SplitLot AS INT = 17
		,@INVENTORY_ADJUSTMENT_ExpiryDateChange AS INT = 18
		,@INVENTORY_ADJUSTMENT_LotMerge AS INT = 19
		,@INVENTORY_ADJUSTMENT_LotMove AS INT = 20
		
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

-- Validate the item. It should be a lot-tracked item. 
IF dbo.fnGetItemLotType(@intItemId) = 0 
BEGIN 
	-- Invalid Item.
	RAISERROR(51077, 11, 1); 
	GOTO _Exit;
END 

-- Validate the new lot number
IF ISNULL(@strNewLotNumber, '') = '' 
BEGIN 
	-- 'Invalid Lot'
	RAISERROR(51053, 11, 1)  
	GOTO _Exit;
END 

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
IF @intLotId IS NULL 
BEGIN 
	-- Invalid Lot
	RAISERROR(51053, 11, 1)  
	GOTO _Exit
END 

-- Raise an error if Adjust By Quantity is invalid
IF ISNULL(@dblAdjustByQuantity, 0) > 0 
BEGIN 
	-- 'Internal Error. The Adjust By Quantity is required to be a negative value.'
	RAISERROR(51127, 11, 1)  
	GOTO _Exit
END 

-- Check if the new sub location is valid
IF NOT EXISTS (
	SELECT TOP 1 1 
	FROM	dbo.tblSMCompanyLocationSubLocation
	WHERE	intCompanyLocationId = ISNULL(@intNewLocationId, @intLocationId)
			AND intCompanyLocationSubLocationId = @intNewSubLocationId
) AND @intNewSubLocationId IS NOT NULL 
BEGIN 
	-- 'Internal Error. The new sub-location is invalid.'
	RAISERROR(51128, 11, 1)  
	GOTO _Exit
END 

-- Check if the new storage location is valid
IF NOT EXISTS (
	SELECT TOP 1 1 
	FROM	dbo.tblICStorageLocation
	WHERE	intLocationId = ISNULL(@intNewLocationId, @intLocationId)
			AND intStorageLocationId = @intNewStorageLocationId
) AND @intNewStorageLocationId IS NOT NULL 
BEGIN 
	-- 'Internal Error. The new storage location is invalid.'
	RAISERROR(51129, 11, 1)  
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
			,intAdjustmentType			= @ADJUSTMENT_TYPE_SplitLot
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
			,strNewLotNumber
			,intItemUOMId
			,intNewItemUOMId
			,dblQuantity
			,dblAdjustByQuantity
			,dblNewQuantity
			,intWeightUOMId
			,intNewWeightUOMId
			,dblWeight
			,dblNewWeight
			,dblWeightPerQty
			,dblNewWeightPerQty
			,dblCost
			,dblNewCost
			,intNewLocationId
			,intNewSubLocationId
			,intNewStorageLocationId			
			,intSort
			,intConcurrencyId
	)
	SELECT 
			intInventoryAdjustmentId	= @intInventoryAdjustmentId
			,intSubLocationId			= Lot.intSubLocationId
			,intStorageLocationId		= Lot.intStorageLocationId
			,intItemId					= Lot.intItemId
			,intLotId					= Lot.intLotId
			,strNewLotNumber			= @strNewLotNumber	
			,intItemUOMId				= Lot.intItemUOMId
			,intNewItemUOMId			= @intNewItemUOMId
			,dblQuantity				= Lot.dblQty
			,dblAdjustByQuantity		= @dblAdjustByQuantity
			,dblNewQuantity				= Lot.dblQty + @dblAdjustByQuantity
			,intWeightUOMId				= Lot.intWeightUOMId
			,intNewWeightUOMId			= @intNewWeightUOMId
			,dblWeight					= Lot.dblWeight
			,dblNewWeight				= @dblNewWeight
			,dblWeightPerQty			= Lot.dblWeightPerQty
			,dblNewWeightPerQty			= CASE	WHEN ABS(ISNULL(@dblAdjustByQuantity, 0)) = 0 THEN 0
												ELSE ISNULL(@dblNewWeight, 0) / ABS(ISNULL(@dblAdjustByQuantity, 0))
										  END 											
			,dblCost					= Lot.dblLastCost
			,dblNewCost					= @dblNewUnitCost
			,intNewLocationId			= @intNewLocationId
			,intNewSubLocationId		= @intNewSubLocationId
			,intNewStorageLocationId	= @intNewStorageLocationId
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