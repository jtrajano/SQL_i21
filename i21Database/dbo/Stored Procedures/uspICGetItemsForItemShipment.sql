CREATE PROCEDURE [dbo].[uspICGetItemsForItemShipment]
	@intSourceTransactionId AS INT
	,@strSourceType AS NVARCHAR(100) 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @CurrentServerDate AS DATETIME = GETDATE()

DECLARE @ShipmentType_SalesContract AS NVARCHAR(100) = 'Sales Contract'
DECLARE @ShipmentType_SalesOrder AS NVARCHAR(100) = 'Sales Order'
DECLARE @ShipmentType_TransferOrder AS NVARCHAR(100) = 'Transfer Order'

DECLARE @intSalesContractType AS INT = 1
DECLARE @intSalesOrderType AS INT = 2
DECLARE @intTransferOrderType AS INT = 3

IF @strSourceType = @ShipmentType_SalesOrder
BEGIN 
	SELECT	intItemId				= SODetail.intItemId
			,intLocationId			= ItemLocation.intLocationId
			,intItemUOMId			= ItemUOM.intItemUOMId
			,dtmDate				= dbo.fnRemoveTimeOnDate(GETDATE())
			,dblQty					= SODetail.dblQtyOrdered
			,dblUOMQty				= ItemUOM.dblUnitQty
			,dblCost				= ISNULL(ItemPricing.dblLastCost, 0) -- Default to the last cost. 
			,dblSalesPrice			= SODetail.dblPrice
			,intCurrencyId			= SO.intCurrencyId
			,dblExchangeRate		= 1 -- TODO: Not yet implemented in PO. Default to 1 for now. 
			,intTransactionId		= SO.intSalesOrderId
			,strTransactionId		= SO.strSalesOrderNumber
			,intTransactionTypeId	= @intSalesOrderType
			,intLotId				= NULL 
			,intSubLocationId		= NULL -- Unable to find a sub location from SO and SODetail
			,intStorageLocationId	= SODetail.intStorageLocationId
	FROM	dbo.tblSOSalesOrder SO INNER JOIN dbo.tblSOSalesOrderDetail SODetail
				ON SO.intSalesOrderId = SODetail.intSalesOrderId
			INNER JOIN dbo.tblICItemUOM ItemUOM
				ON SODetail.intItemId = ItemUOM.intItemId
				AND SODetail.intItemUOMId = ItemUOM.intItemUOMId
			INNER JOIN dbo.tblICItemLocation ItemLocation
				ON SODetail.intItemId = ItemLocation.intItemId
				AND SO.intCompanyLocationId = ItemLocation.intLocationId
			LEFT JOIN dbo.tblICItemPricing ItemPricing
				ON ItemPricing.intItemId = SODetail.intItemId
				AND ItemPricing.intItemLocationId = ItemLocation.intItemLocationId
	WHERE	SODetail.intSalesOrderId = @intSourceTransactionId
			AND dbo.fnIsStockTrackingItem(SODetail.intItemId) = 1			
END

-- TODO IF @strSourceType = @ShipmentType_SalesContract
-- TODO IF @strSourceType = @ShipmentType_TransferOrder