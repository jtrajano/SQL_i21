CREATE PROCEDURE [dbo].[uspICCleanupStrayItemLocationTransactions] (@intItemLocationId INT)
AS
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM vyuICItemLocationTransactions WHERE intItemLocationId = @intItemLocationId)
	BEGIN
		DELETE FROM tblICItemSpecialPricing WHERE intItemLocationId = @intItemLocationId
		DELETE FROM tblICItemPricingLevel WHERE intItemLocationId = @intItemLocationId
		DELETE FROM tblICItemPricing WHERE intItemLocationId = @intItemLocationId
		DELETE FROM tblICItemCustomerXref WHERE intItemLocationId = @intItemLocationId
		DELETE FROM tblICInventoryStockMovement WHERE intItemLocationId = @intItemLocationId
		DELETE FROM tblICInventoryTransaction WHERE intItemLocationId = @intItemLocationId
		DELETE FROM tblICItemStockDetail WHERE intItemLocationId = @intItemLocationId
		DELETE FROM tblICStockReservation WHERE intItemLocationId = @intItemLocationId
		DELETE FROM tblICItemStockPath WHERE intItemLocationId = @intItemLocationId
		DELETE FROM tblICItemStock WHERE intItemLocationId = @intItemLocationId
		DELETE FROM tblICBatchInventoryTransaction WHERE intItemLocationId = @intItemLocationId
		DELETE FROM tblICInventoryLotTransaction WHERE intItemLocationId = @intItemLocationId
		DELETE FROM tblICInventoryLotTransactionStorage WHERE intItemLocationId = @intItemLocationId
		DELETE FROM tblICInventoryTransactionStorage WHERE intItemLocationId = @intItemLocationId
		DELETE FROM tblICInventoryTransaction WHERE intItemLocationId = @intItemLocationId
		DELETE FROM tblICItemCommodityCost WHERE intItemLocationId = @intItemLocationId
		DELETE FROM tblICItemContract WHERE intItemLocationId = @intItemLocationId
		DELETE FROM tblICItemNote WHERE intItemLocationId = @intItemLocationId
		DELETE FROM tblICItemVendorXref WHERE intItemLocationId = @intItemLocationId
		DELETE FROM tblSTCheckoutShiftPhysical WHERE intItemLocationId = @intItemLocationId
		DELETE FROM tblICItemSubLocation WHERE intItemLocationId = @intItemLocationId
		DELETE FROM tblICItemLocation WHERE intItemLocationId = @intItemLocationId
	END
	ELSE
	BEGIN
		EXEC uspICRaiseError 80228;
	END
END