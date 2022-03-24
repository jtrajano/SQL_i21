CREATE PROCEDURE uspICZeroLotStockForSAPIntegration
	@intEntityUserSecurityId AS INT = NULL 
AS 

DECLARE @locations AS TABLE (
	intLocationId INT 
)

INSERT INTO @locations (
	intLocationId
)
SELECT DISTINCT 
	intLocationId
FROM 
	tblICLot l 
WHERE 
	l.dblQty <> 0 

DECLARE 
	@InventoryAdjustment_Batch_Id AS INT = 30
	,@strAdjustmentNo AS NVARCHAR(40)
	,@intLocationId AS INT 
	,@intInventoryAdjustmentId AS INT 

DECLARE @ADJUSTMENT_TYPE_QuantityChange AS INT = 1
SELECT TOP 1
	@intEntityUserSecurityId = intEntityId 
FROM 
	tblSMUserSecurity u 
WHERE 
	u.strUserName IN ('IRELYADMIN', 'AUSSUP')
	AND @intEntityUserSecurityId IS NULL 

WHILE EXISTS (SELECT TOP 1 1 FROM @locations)
BEGIN 
	SELECT TOP 1 @intLocationId = intLocationId FROM @locations
	   
	-- Get the starting number. 
	IF @strAdjustmentNo IS NULL 
	BEGIN
		EXEC dbo.uspSMGetStartingNumber @InventoryAdjustment_Batch_Id, @strAdjustmentNo OUTPUT, @intLocationId	
	
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
				,dtmAdjustmentDate			= dbo.fnRemoveTimeOnDate(GETDATE()) 
				,intAdjustmentType			= @ADJUSTMENT_TYPE_QuantityChange
				,strAdjustmentNo			= @strAdjustmentNo
				,strDescription				= 'Zero the stocks on all active lots in the system.'
				,intSort					= 1
				,ysnPosted					= 0
				,intEntityId				= @intEntityUserSecurityId
				,intConcurrencyId			= 1
				,dtmPostedDate				= NULL 
				,dtmUnpostedDate			= NULL	
				,intSourceTransactionId		= NULL -- @intSourceId
				,intSourceTransactionTypeId = 41 -- @intSourceTransactionTypeId


				,intInventoryShipmentId		= NULL 
				,intInventoryReceiptId		= NULL 
				,intTicketId				= NULL 
				,intInvoiceId				= NULL 

		SELECT @intInventoryAdjustmentId = SCOPE_IDENTITY();
	END	
	ELSE 
	BEGIN 
		UPDATE tblICInventoryAdjustment 
		SET 
			intLocationId = @intLocationId 
		WHERE 
			strAdjustmentNo = @strAdjustmentNo 
			AND ysnPosted = 0 
	END 

	IF @intInventoryAdjustmentId IS NOT NULL 
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
		)
		SELECT 
				intInventoryAdjustmentId	= @intInventoryAdjustmentId
				,intSubLocationId			= Lot.intSubLocationId
				,intStorageLocationId		= Lot.intStorageLocationId
				,intItemId					= Lot.intItemId
				,intLotId					= Lot.intLotId
				,intItemUOMId				= ISNULL(Lot.intWeightUOMId, Lot.intItemUOMId)
				,intOwnershipType			= Lot.intOwnershipType
				,dblQuantity				= CASE WHEN Lot.intWeightUOMId IS NOT NULL THEN Lot.dblWeight ELSE Lot.dblQty END 
				,dblAdjustByQuantity		= -CASE WHEN Lot.intWeightUOMId IS NOT NULL THEN Lot.dblWeight ELSE Lot.dblQty END 
				,dblNewQuantity				= 0
				,intWeightUOMId				= Lot.intWeightUOMId
				,dblWeight					= Lot.dblQty
				,dblWeightPerQty			= Lot.dblWeightPerQty
				,dblCost					= dbo.fnCalculateCostBetweenUOM(
												StockUnit.intItemUOMId
												, ISNULL(Lot.intWeightUOMId, Lot.intItemUOMId)
												, ISNULL(Lot.dblLastCost, ISNULL(ItemPricing.dblLastCost, 0))
											)
				,dblNewCost					= NULL 
				,intSort					= 1
				,intConcurrencyId			= 1
		FROM	dbo.tblICItem Item 
				INNER JOIN dbo.tblICLot Lot
					ON Item.intItemId = Lot.intItemId		
				INNER JOIN dbo.tblICItemLocation ItemLocation
					ON ItemLocation.intItemId = Item.intItemId
					AND ItemLocation.intLocationId = Lot.intLocationId
					AND ItemLocation.intItemLocationId = Lot.intItemLocationId
				LEFT JOIN dbo.tblICItemUOM StockUnit
					ON StockUnit.intItemId = Item.intItemId
					AND ISNULL(StockUnit.ysnStockUnit, 0) = 1
				LEFT JOIN dbo.tblICItemPricing ItemPricing
					ON ItemPricing.intItemId = Item.intItemId
					AND ItemPricing.intItemLocationId = ItemLocation.intItemLocationId
		WHERE	
			Lot.dblQty <> 0 
			AND Lot.intLocationId = @intLocationId

		EXEC uspICPostInventoryAdjustment	
				@ysnPost = 1
				,@ysnRecap = 0 
				,@strTransactionId = @strAdjustmentNo
				,@intEntityUserSecurityId = @intEntityUserSecurityId

		--SELECT 
		--	a.strAdjustmentNo
		--	,ad.* 
		--FROM tblICInventoryAdjustment a inner join tblICInventoryAdjustmentDetail ad on a.intInventoryAdjustmentId = ad.intInventoryAdjustmentId where a.strAdjustmentNo = @strAdjustmentNo

		SET @strAdjustmentNo = NULL 
		SET @intInventoryAdjustmentId = NULL 
	END 
	
	DELETE FROM @locations WHERE intLocationId = @intLocationId
END 
GO
