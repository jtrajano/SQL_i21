﻿CREATE PROCEDURE [dbo].[uspICInventoryAdjustment_CreatePostLotStatusChange]
	@intItemId AS INT
	,@dtmDate AS DATETIME 
	,@intLocationId AS INT
	,@intSubLocationId AS INT
	,@intStorageLocationId AS INT
	,@strLotNumber AS NVARCHAR(50)
	,@intNewLotStatusId AS INT
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
			,intAdjustmentType			= @ADJUSTMENT_TYPE_LotStatusChange
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
	EXEC uspICRaiseError 80020; 
	GOTO _Exit
END 

-- Raise an error if new lot status is invalid.
BEGIN 
	IF NOT EXISTS (
		SELECT	TOP 1 1 
		FROM	dbo.tblICLotStatus 
		WHERE	intLotStatusId = @intNewLotStatusId
	)
	OR EXISTS (
		SELECT TOP 1 1 
		FROM	dbo.tblICLot
		WHERE	intLotId = @intLotId
				AND intLotStatusId = @intNewLotStatusId
	)
	BEGIN 
		-- The lot status is invalid.
		EXEC uspICRaiseError 80030;
		GOTO _Exit
	END
END 

-- Continue with the insert if 
-- 1. It is a valid lot id. 
-- 2. And the lot status is valid. 
IF @intLotId IS NOT NULL
BEGIN 
	INSERT INTO dbo.tblICInventoryAdjustmentDetail (
			intInventoryAdjustmentId
			,intSubLocationId
			,intStorageLocationId
			,intItemId
			,intLotId
			,intLotStatusId
			,intNewLotStatusId
			,intSort
			,intConcurrencyId
	)
	SELECT 
			intInventoryAdjustmentId	= @intInventoryAdjustmentId
			,intSubLocationId			= Lot.intSubLocationId
			,intStorageLocationId		= Lot.intStorageLocationId
			,intItemId					= Lot.intItemId
			,intLotId					= Lot.intLotId
			,intLotStatusId				= Lot.intLotStatusId
			,intNewLotStatusId			= @intNewLotStatusId
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