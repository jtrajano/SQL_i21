CREATE PROCEDURE [dbo].[uspMFInventoryAdjustment_CreatePostLotItemChange] 
	-- Parameters for filtering:
	 @intLotId AS INT
	,@dtmDate AS DATETIME 
	,@intLocationId AS INT	
	,@intSubLocationId AS INT	
	,@intStorageLocationId AS INT	
	,@strLotNumber AS NVARCHAR(50)		
	-- Parameters for the new values: 
	,@intNewItemId AS INT
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
		,@intItemId AS INT
		,@intOldItemId AS INT
		,@strOldItemType NVARCHAR(MAX)
		,@strNewItemType NVARCHAR(MAX)

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
	RAISERROR(80032, 11, 1)  
	GOTO _Exit;
END 

-- Validate the source id. 
IF @intSourceId IS NULL 
BEGIN
	-- 'Internal Error. The source transaction id is invalid.'
	RAISERROR(80033, 11, 1)  
	GOTO _Exit;
END 

-- Validate the item. It should be a lot-tracked item. 
IF dbo.fnGetItemLotType(@intItemId) = 0 
BEGIN 
	-- Invalid Item.
	RAISERROR(80021, 11, 1); 
	GOTO _Exit;
END 

SELECT @intOldItemId = i.intItemId FROM tblICLot l
JOIN tblICItem i ON i.intItemId = l.intItemId
WHERE l.intLotId = @intLotId

SELECT @strOldItemType = strType FROM tblICItem WHERE intItemId = @intOldItemId
SELECT @strNewItemType = strType FROM tblICItem WHERE intItemId = @intNewItemId

IF @strOldItemType <> @strNewItemType
BEGIN
	RAISERROR('Item type should be same for both new and old item.', 11, 1);
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
	RAISERROR(80020, 11, 1)  
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
SELECT	@intEntityId = intUserRoleID
FROM	dbo.tblSMUserSecurity
WHERE	intEntityUserSecurityId = @intUserId

------------------------------------------------------------------------------------------------------------------------------------
-- Update Lot Item
------------------------------------------------------------------------------------------------------------------------------------


UPDATE tblICLot
SET intItemId = @intNewItemId
WHERE intLotId = @intLotId
	AND intLocationId = @intLocationId
	AND intSubLocationId = @intSubLocationId

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
			,intAdjustmentType			= @ADJUSTMENT_TYPE_ItemChange
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
			,intNewItemUOMId
			,dblQuantity
			,intWeightUOMId
			,dblWeight
			,dblNewWeightPerQty
			,dblCost
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
			,strNewLotNumber			= @strLotNumber	
			,intItemUOMId				= Lot.intItemUOMId
			,dblQuantity				= Lot.dblQty
			,intWeightUOMId				= Lot.intWeightUOMId
			,dblWeight					= Lot.dblWeight
			,dblWeightPerQty			= Lot.dblWeightPerQty
			,dblCost					= Lot.dblLastCost
			,intNewLocationId			= @intLocationId
			,intNewSubLocationId		= @intSubLocationId
			,intNewStorageLocationId	= @intStorageLocationId
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
		,@intEntityUserSecurityId = @intUserId
END 

_Exit: 