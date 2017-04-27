CREATE PROCEDURE [dbo].[uspICInventoryAdjustment_CreatePostOwnerChange]
	@intItemId AS INT
	,@dtmDate AS DATETIME 
	,@intLocationId AS INT
	,@intSubLocationId AS INT
	,@intStorageLocationId AS INT
	,@strLotNumber AS NVARCHAR(50)
	,@intNewOwnerId AS INT
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

DECLARE --@ADJUSTMENT_TYPE_QuantityChange AS INT = 1
		--,@ADJUSTMENT_TYPE_UOMChange AS INT = 2
		--,@ADJUSTMENT_TYPE_ItemChange AS INT = 3
		--,@ADJUSTMENT_TYPE_LotStatusChange AS INT = 4
		--,@ADJUSTMENT_TYPE_SplitLot AS INT = 5
		--,@ADJUSTMENT_TYPE_ExpiryDateChange AS INT = 6
		@ADJUSTMENT_TYPE_LotOwnerChange AS INT = 9

DECLARE @TRANSACTION_TYPE_INVENTORY_ADJUSTMENT AS INT = 10

DECLARE @InventoryAdjustment_Batch_Id AS INT = 30
		,@strAdjustmentNo AS NVARCHAR(40)
		,@intLotId AS INT 
		,@intNewItemOwnerId AS INT 

-- Validate the source transaction type id. 
IF NOT EXISTS (
	SELECT	TOP 1 1 
	FROM	dbo.tblICInventoryTransactionPostingIntegration
	WHERE	intTransactionTypeId = @TRANSACTION_TYPE_INVENTORY_ADJUSTMENT
			AND intLinkAllowedTransactionTypeId = @intSourceTransactionTypeId
)
BEGIN
	-- 'Internal Error. The source transaction type provided is invalid or not supported.' 
	RAISERROR('Internal Error. The source transaction type provided is invalid or not supported.', 11, 1)  
	GOTO _Exit;
END 

-- Validate the source id. 
IF @intSourceId IS NULL 
BEGIN
	-- 'Internal Error. The source transaction id is invalid.'
	RAISERROR('Internal Error. The source transaction id is invalid.', 11, 1)  
	GOTO _Exit;
END 

-- Create the starting number for the inventory adjustment. 
EXEC dbo.uspSMGetStartingNumber @InventoryAdjustment_Batch_Id, @strAdjustmentNo OUTPUT, @intLocationId
IF @@ERROR <> 0 GOTO _Exit

-- Set the transaction date. 
SET @dtmDate = ISNULL(@dtmDate, GETDATE());

-- Create the header record
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
			,intAdjustmentType			= @ADJUSTMENT_TYPE_LotOwnerChange
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
	RAISERROR('Invalid Lot.', 11, 1)  
	GOTO _Exit
END 

-- Raise an error if new owner is invalid 
BEGIN 
	SELECT	TOP 1 
			@intNewItemOwnerId = o.intItemOwnerId  
	FROM	dbo.tblICItemOwner o 
	WHERE	o.intItemId = @intItemId
			AND o.intOwnerId = @intNewOwnerId

	IF @intNewItemOwnerId IS NULL 
	BEGIN 
		DECLARE @strItemNo AS NVARCHAR(50)
				,@strName AS NVARCHAR(200)

		SELECT	@strItemNo = strItemNo 
		FROM	tblICItem i
		WHERE	i.intItemId = @intItemId

		SELECT	@strName = e.strName
		FROM	tblEMEntity e
		WHERE	e.intEntityId = @intNewOwnerId

		-- 'Invalid Owner. {Owner name} is not configured as an Owner for {Item}. Please check the Item setup.'
		RAISERROR('Invalid Owner. %s is not configured as an Owner for %s. Please check the Item setup.', 11, 1, @strName, @strItemNo)  
		GOTO _Exit
	END
END 

-- Continue with the insert if following passed: 
-- 1. It is a valid lot id. 
-- 2. The new owner is valid. 
BEGIN 
	INSERT INTO dbo.tblICInventoryAdjustmentDetail (
			intInventoryAdjustmentId
			,intSubLocationId
			,intStorageLocationId
			,intItemId
			,intLotId
			,intItemOwnerId
			,intNewItemOwnerId
			,intSort
			,intConcurrencyId
	)
	SELECT 
			intInventoryAdjustmentId	= @intInventoryAdjustmentId
			,intSubLocationId			= Lot.intSubLocationId
			,intStorageLocationId		= Lot.intStorageLocationId
			,intItemId					= Lot.intItemId
			,intLotId					= Lot.intLotId
			,intItemOwnerId				= Lot.intItemOwnerId
			,intNewItemOwnerId			= @intNewItemOwnerId
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
		,@intEntityUserSecurityId = @intEntityUserSecurityId
END 

_Exit: 