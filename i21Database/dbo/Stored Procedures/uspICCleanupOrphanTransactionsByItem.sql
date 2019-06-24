CREATE PROCEDURE [dbo].[uspICCleanupOrphanTransactionsByItem] (@intItemId INT)
AS
BEGIN
	
    DELETE FROM tblICItemSpecialPricing WHERE intItemId = @intItemId
    DELETE FROM tblICItemPricingLevel WHERE intItemId = @intItemId
    DELETE FROM tblICItemPricing WHERE intItemId = @intItemId
    DELETE FROM tblICItemCustomerXref WHERE intItemId = @intItemId
    DELETE FROM tblICInventoryStockMovement WHERE intItemId = @intItemId
    DELETE FROM tblICStockReservation WHERE intItemId = @intItemId
    DELETE FROM tblICItemStockPath WHERE intItemId = @intItemId
    DELETE FROM tblICItemStock WHERE intItemId = @intItemId
    DELETE FROM tblICBatchInventoryTransaction WHERE intItemId = @intItemId
    DELETE FROM tblICInventoryLotTransaction WHERE intItemId = @intItemId
    DELETE FROM tblICInventoryLotTransactionStorage WHERE intItemId = @intItemId
    DELETE FROM tblICInventoryTransactionStorage WHERE intItemId = @intItemId
    DELETE FROM tblICItemCommodityCost WHERE intItemId = @intItemId
    DELETE FROM tblICItemContract WHERE intItemId = @intItemId
    DELETE FROM tblICItemNote WHERE intItemId = @intItemId
    DELETE FROM tblICItemVendorXref WHERE intItemId = @intItemId
    DELETE FROM tblSTCheckoutShiftPhysical WHERE intItemId = @intItemId
    DELETE s FROM tblICItemSubLocation s
	INNER JOIN tblICItemLocation l ON l.intItemLocationId = s.intItemLocationId
	WHERE intItemId = @intItemId
	DELETE FROM tblICItemStockUOM WHERE intItemId = @intItemId
	DELETE FROM tblICItemStockDetail WHERE intItemId = @intItemId
	DELETE FROM tblICInventoryTransaction WHERE intItemId = @intItemId
	DELETE FROM tblICItemStock WHERE intItemId = @intItemId
    DELETE FROM tblICItemLocation WHERE intItemId = @intItemId
	DELETE FROM tblICItemUOM WHERE intItemId = @intItemId
END