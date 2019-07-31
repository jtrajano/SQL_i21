CREATE PROCEDURE [dbo].[uspICGenerateStockMovementReport]
	@strResetType AS NVARCHAR(500) = 'Commodity',
	@intUserId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @intReturnValue AS INT = 0; 
DECLARE @Ownership_Own AS INT = 1
		,@Ownership_Storage AS INT = 2

DECLARE @ResetType_Commodity AS NVARCHAR(50) = 'Commodity'
		,@ResetType_Category AS NVARCHAR(50) = 'Category'
		,@ResetType_Item AS NVARCHAR(50) = 'Item'
		,@ResetType_Commodity_Location AS NVARCHAR(50) = 'Commodity - Location'
		,@ResetType_Category_Location AS NVARCHAR(50) = 'Category - Location'
		,@ResetType_Item_Location AS NVARCHAR(50) = 'Item - Location'
		,@ResetType_Item_StorageLocation AS NVARCHAR(50) = 'Item - Storage Location'
		,@ResetType_Item_StorageUnit AS NVARCHAR(50) = 'Item - Storage Unit'
		,@ResetType_StorageLocation AS NVARCHAR(50) = 'Storage Location'
		,@ResetType_StorageUnit AS NVARCHAR(50) = 'Storage Unit'

BEGIN 
	TRUNCATE TABLE [tblICInventoryStockMovementReport]
END 

IF @strResetType IN (@ResetType_StorageLocation, @ResetType_StorageUnit)
BEGIN 
	INSERT INTO dbo.tblICInventoryStockMovementReport (		
		intItemId
		,intItemLocationId
		,intItemUOMId
		,intSubLocationId
		,intStorageLocationId
		,intLotId
		,dtmDate
		,dblQty
		,dblUOMQty
		,dblCost
		,dblValue
		,dblSalesPrice
		,intCurrencyId
		,dblExchangeRate
		,intTransactionId
		,intTransactionDetailId
		,strTransactionId
		,strBatchId
		,intTransactionTypeId
		,ysnIsUnposted
		,strTransactionForm
		,intRelatedInventoryTransactionId
		,intRelatedTransactionId
		,strRelatedTransactionId
		,intCostingMethod
		,dtmCreated
		,intCreatedUserId
		,intCreatedEntityId
		,intConcurrencyId
		,intForexRateTypeId
		,dblForexRate
		,intInventoryTransactionId
		,intInventoryTransactionStorageId
		,intOwnershipType
		,intCommodityId
		,intCategoryId
		,intLocationId
		,intSourceEntityId
	)
	SELECT 
		*
	FROM 
		vyuICGenerateStockMovement
	ORDER BY
		intSubLocationId ASC
		,intStorageLocationId ASC 
		,dtmDate ASC
		,dtmCreated ASC 
END 

ELSE IF @strResetType IN (@ResetType_Item_StorageLocation, @ResetType_Item_StorageUnit)
BEGIN 
	INSERT INTO dbo.tblICInventoryStockMovementReport (		
		intItemId
		,intItemLocationId
		,intItemUOMId
		,intSubLocationId
		,intStorageLocationId
		,intLotId
		,dtmDate
		,dblQty
		,dblUOMQty
		,dblCost
		,dblValue
		,dblSalesPrice
		,intCurrencyId
		,dblExchangeRate
		,intTransactionId
		,intTransactionDetailId
		,strTransactionId
		,strBatchId
		,intTransactionTypeId
		,ysnIsUnposted
		,strTransactionForm
		,intRelatedInventoryTransactionId
		,intRelatedTransactionId
		,strRelatedTransactionId
		,intCostingMethod
		,dtmCreated
		,intCreatedUserId
		,intCreatedEntityId
		,intConcurrencyId
		,intForexRateTypeId
		,dblForexRate
		,intInventoryTransactionId
		,intInventoryTransactionStorageId
		,intOwnershipType
		,intCommodityId
		,intCategoryId
		,intLocationId
		,intSourceEntityId
	)
	SELECT 
		*
	FROM 
		vyuICGenerateStockMovement
	ORDER BY
		intItemId ASC 
		,intSubLocationId ASC
		,intStorageLocationId ASC 
		,dtmDate ASC
		,dtmCreated ASC 
END 

ELSE IF @strResetType = @ResetType_Commodity_Location
BEGIN 
	INSERT INTO dbo.tblICInventoryStockMovementReport (		
		intItemId
		,intItemLocationId
		,intItemUOMId
		,intSubLocationId
		,intStorageLocationId
		,intLotId
		,dtmDate
		,dblQty
		,dblUOMQty
		,dblCost
		,dblValue
		,dblSalesPrice
		,intCurrencyId
		,dblExchangeRate
		,intTransactionId
		,intTransactionDetailId
		,strTransactionId
		,strBatchId
		,intTransactionTypeId
		,ysnIsUnposted
		,strTransactionForm
		,intRelatedInventoryTransactionId
		,intRelatedTransactionId
		,strRelatedTransactionId
		,intCostingMethod
		,dtmCreated
		,intCreatedUserId
		,intCreatedEntityId
		,intConcurrencyId
		,intForexRateTypeId
		,dblForexRate
		,intInventoryTransactionId
		,intInventoryTransactionStorageId
		,intOwnershipType
		,intCommodityId
		,intCategoryId
		,intLocationId
		,intSourceEntityId
	)
	SELECT 
		*
	FROM 
		vyuICGenerateStockMovement
	ORDER BY
		intCommodityId ASC 
		,intLocationId ASC 
		,dtmDate ASC
		,dtmCreated ASC 
		,intCategoryId ASC 
		,intItemId ASC 
END 

ELSE IF @strResetType = @ResetType_Category_Location
BEGIN 
	INSERT INTO dbo.tblICInventoryStockMovementReport (		
		intItemId
		,intItemLocationId
		,intItemUOMId
		,intSubLocationId
		,intStorageLocationId
		,intLotId
		,dtmDate
		,dblQty
		,dblUOMQty
		,dblCost
		,dblValue
		,dblSalesPrice
		,intCurrencyId
		,dblExchangeRate
		,intTransactionId
		,intTransactionDetailId
		,strTransactionId
		,strBatchId
		,intTransactionTypeId
		,ysnIsUnposted
		,strTransactionForm
		,intRelatedInventoryTransactionId
		,intRelatedTransactionId
		,strRelatedTransactionId
		,intCostingMethod
		,dtmCreated
		,intCreatedUserId
		,intCreatedEntityId
		,intConcurrencyId
		,intForexRateTypeId
		,dblForexRate
		,intInventoryTransactionId
		,intInventoryTransactionStorageId
		,intOwnershipType
		,intCommodityId
		,intCategoryId
		,intLocationId
		,intSourceEntityId
	)
	SELECT 
		*
	FROM 
		vyuICGenerateStockMovement
	ORDER BY
		intCategoryId ASC 
		,intLocationId ASC 
		,dtmDate ASC
		,dtmCreated ASC 
		,intCommodityId ASC 
		,intItemId ASC 

END 

ELSE IF @strResetType = @ResetType_Item_Location
BEGIN 
	INSERT INTO dbo.tblICInventoryStockMovementReport (		
		intItemId
		,intItemLocationId
		,intItemUOMId
		,intSubLocationId
		,intStorageLocationId
		,intLotId
		,dtmDate
		,dblQty
		,dblUOMQty
		,dblCost
		,dblValue
		,dblSalesPrice
		,intCurrencyId
		,dblExchangeRate
		,intTransactionId
		,intTransactionDetailId
		,strTransactionId
		,strBatchId
		,intTransactionTypeId
		,ysnIsUnposted
		,strTransactionForm
		,intRelatedInventoryTransactionId
		,intRelatedTransactionId
		,strRelatedTransactionId
		,intCostingMethod
		,dtmCreated
		,intCreatedUserId
		,intCreatedEntityId
		,intConcurrencyId
		,intForexRateTypeId
		,dblForexRate
		,intInventoryTransactionId
		,intInventoryTransactionStorageId
		,intOwnershipType
		,intCommodityId
		,intCategoryId
		,intLocationId
		,intSourceEntityId
	)
	SELECT 
		m.*
	FROM 
		vyuICGenerateStockMovement m
			INNER JOIN vyuICUserCompanyLocations permission ON permission.intCompanyLocationId = m.intLocationId
	WHERE permission.intEntityId = @intUserId
	ORDER BY
		 m.intItemId ASC 
		,m.intLocationId ASC 
		,m.dtmDate ASC
		,m.dtmCreated ASC 
		,m.intCommodityId ASC 
		,m.intCategoryId ASC

END 

ELSE
BEGIN 
	INSERT INTO dbo.tblICInventoryStockMovementReport (		
		intItemId
		,intItemLocationId
		,intItemUOMId
		,intSubLocationId
		,intStorageLocationId
		,intLotId
		,dtmDate
		,dblQty
		,dblUOMQty
		,dblCost
		,dblValue
		,dblSalesPrice
		,intCurrencyId
		,dblExchangeRate
		,intTransactionId
		,intTransactionDetailId
		,strTransactionId
		,strBatchId
		,intTransactionTypeId
		,ysnIsUnposted
		,strTransactionForm
		,intRelatedInventoryTransactionId
		,intRelatedTransactionId
		,strRelatedTransactionId
		,intCostingMethod
		,dtmCreated
		,intCreatedUserId
		,intCreatedEntityId
		,intConcurrencyId
		,intForexRateTypeId
		,dblForexRate
		,intInventoryTransactionId
		,intInventoryTransactionStorageId
		,intOwnershipType
		,intCommodityId
		,intCategoryId
		,intLocationId
		,intSourceEntityId
	)
	SELECT 
		m.*
	FROM 
		vyuICGenerateStockMovement m
			INNER JOIN vyuICUserCompanyLocations permission ON permission.intCompanyLocationId = m.intLocationId
	WHERE permission.intEntityId = @intUserId
	ORDER BY
		 m.intCommodityId ASC 
		,m.intCategoryId ASC 
		,m.intItemId ASC 
		,m.intLocationId ASC
		,m.dtmDate ASC
		,m.dtmCreated ASC 
END 