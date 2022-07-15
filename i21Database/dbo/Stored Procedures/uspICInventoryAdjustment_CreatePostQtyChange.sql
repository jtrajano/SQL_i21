CREATE PROCEDURE [dbo].[uspICInventoryAdjustment_CreatePostQtyChange]
	-- Parameters for filtering:
	@intItemId AS INT
	,@dtmDate AS DATETIME 
	,@intLocationId AS INT	
	,@intSubLocationId AS INT	
	,@intStorageLocationId AS INT	
	,@strLotNumber AS NVARCHAR(50)
	,@intOwnershipType AS INT = 1 -- (1) Own, (2) Storage, (3) Consigned Purchase, (4) Consigned Sale 
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
	,@ysnPost BIT = 1
	,@InventoryAdjustmentIntegrationId as InventoryAdjustmentIntegrationId READONLY
	
	,@intContractHeaderId AS INT = NULL
	,@intContractDetailId AS INT = NULL
	,@intEntityId AS INT = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @ADJUSTMENT_TYPE_QuantityChange AS INT = 1
		,@ADJUSTMENT_TYPE_UOMChange AS INT = 2
		,@ADJUSTMENT_TYPE_ItemChange AS INT = 3
		,@ADJUSTMENT_TYPE_LotStatusChange AS INT = 4
		,@ADJUSTMENT_TYPE_SplitLot AS INT = 5
		,@ADJUSTMENT_TYPE_ExpiryDateChange AS INT = 6

		,@OWNERSHIP_TYPE_Own AS INT = 1
		,@OWNERSHIP_TYPE_Storage AS INT = 2
		,@OWNERSHIP_TYPE_ConsignedPurchase AS INT = 3
		,@OWNERSHIP_TYPE_ConsignedSale AS INT = 4

DECLARE @TRANSACTION_TYPE_INVENTORY_ADJUSTMENT AS INT = 10

DECLARE @InventoryAdjustment_Batch_Id AS INT = 30
		,@strAdjustmentNo AS NVARCHAR(40)
		,@intLotId AS INT 

DECLARE @intInventoryShipmentId AS INT,
	@intInventoryReceiptId AS INT,
	@intTicketId AS INT,
	@intInvoiceId AS INT

SELECT TOP 1 
	@intInventoryShipmentId = intInventoryShipmentId,
	@intInventoryReceiptId = intInventoryReceiptId,
	@intTicketId = intTicketId,
	@intInvoiceId = intInvoiceId
FROM @InventoryAdjustmentIntegrationId

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
	IF @intLotId IS NULL 
	BEGIN 
		-- Invalid Lot
		EXEC uspICRaiseError 80020; 
		GOTO _Exit
	END 	

	-- Check if the item uom id is valid for the lot record. 
	IF NOT EXISTS (
		SELECT	TOP 1 1
		FROM	dbo.tblICLot 
		WHERE	intItemId = @intItemId
				AND intLotId = @intLotId
				AND (intItemUOMId = @intItemUOMId OR intWeightUOMId = @intItemUOMId) 
	)
	BEGIN 
		-- Item UOM is invalid or missing.
		DECLARE @strText_cdkl3 NVARCHAR(200)
		SET @strText_cdkl3 = (SELECT ISNULL(strItemNo, '') FROM tblICItem WHERE intItemId = @intItemId)
		EXEC uspICRaiseError 80048, @strText_cdkl3
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
	DECLARE @strText_ee642 NVARCHAR(200)
		SET @strText_ee642 = (SELECT ISNULL(strItemNo, '') FROM tblICItem WHERE intItemId = @intItemId)
		EXEC uspICRaiseError 80048, @strText_ee642
	GOTO _Exit
END

------------------------------------------------------------------------------------------------------------------------------------
-- Set the transaction date and expiration date
------------------------------------------------------------------------------------------------------------------------------------
SET @dtmDate = ISNULL(@dtmDate, GETDATE());

IF @ysnPost = 1
BEGIN

------------------------------------------------------------------------------------------------------------------------------------
-- Create the starting number for the inventory adjustment. 
------------------------------------------------------------------------------------------------------------------------------------
EXEC dbo.uspSMGetStartingNumber @InventoryAdjustment_Batch_Id, @strAdjustmentNo OUTPUT, @intLocationId
IF @@ERROR <> 0 GOTO _Exit

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

			,intInventoryShipmentId
			,intInventoryReceiptId
			,intTicketId
			,intInvoiceId
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


			,intInventoryShipmentId		= @intInventoryShipmentId
			,intInventoryReceiptId		= @intInventoryReceiptId
			,intTicketId				= @intTicketId
			,intInvoiceId				= @intInvoiceId
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
			,intOwnershipType
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
			,intContractHeaderId
			,intContractDetailId
			,intEntityId
	)
	SELECT 
			intInventoryAdjustmentId	= @intInventoryAdjustmentId
			,intSubLocationId			= ISNULL(Lot.intSubLocationId, @intSubLocationId)
			,intStorageLocationId		= ISNULL(Lot.intStorageLocationId, @intStorageLocationId)
			,intItemId					= @intItemId
			,intLotId					= Lot.intLotId
			,intItemUOMId				= @intItemUOMId
			,intOwnershipType			= 
				CASE 
					WHEN Lot.intOwnershipType IS NOT NULL THEN 
						Lot.intOwnershipType
					WHEN @intOwnershipType IN (@OWNERSHIP_TYPE_Own, @OWNERSHIP_TYPE_Storage, @OWNERSHIP_TYPE_ConsignedPurchase, @OWNERSHIP_TYPE_ConsignedSale) THEN 
						@intOwnershipType
					ELSE 
						@OWNERSHIP_TYPE_Own -- Default to "Own"
				END 
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
			,intWeightUOMId				= Lot.intWeightUOMId
			,dblWeight					=	CASE	WHEN Lot.intItemUOMId = @intItemUOMId THEN ABS(dbo.fnMultiply(@dblAdjustByQuantity, Lot.dblWeightPerQty)) 
													WHEN Lot.intWeightUOMId = @intItemUOMId THEN ABS(@dblAdjustByQuantity) 
													ELSE 0 
											END 
			,dblWeightPerQty			= Lot.dblWeightPerQty
			,dblCost					= dbo.fnCalculateCostBetweenUOM(StockUnit.intItemUOMId, @intItemUOMId, ISNULL(Lot.dblLastCost, ISNULL(ItemPricing.dblLastCost, 0)))
			,dblNewCost					= @dblNewUnitCost
			,intSort					= 1
			,intConcurrencyId			= 1
			,intContractHeaderId		= @intContractHeaderId
			,intContractDetailId		= @intContractDetailId
			,intEntityId				= @intEntityId

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

END

IF @ysnPost = 1
-- Auto post the inventory adjustment
BEGIN 

	EXEC dbo.uspICPostInventoryAdjustment
		@ysnPost = 1
		,@ysnRecap = 0
		,@strTransactionId = @strAdjustmentNo
		,@intEntityUserSecurityId = @intEntityUserSecurityId
END 

IF @ysnPost = 0
BEGIN
	SELECT 
		@strAdjustmentNo = strAdjustmentNo
	FROM 
		tblICInventoryAdjustment
	WHERE 
		intSourceId = @intSourceId
		AND intSourceTransactionTypeId = @intSourceTransactionTypeId
	
	EXEC dbo.uspICPostInventoryAdjustment
		@ysnPost = 0
		,@ysnRecap = 0
		,@strTransactionId = @strAdjustmentNo
		,@intEntityUserSecurityId = @intEntityUserSecurityId

	DELETE FROM tblICInventoryAdjustment WHERE strAdjustmentNo = @strAdjustmentNo
END

_Exit: