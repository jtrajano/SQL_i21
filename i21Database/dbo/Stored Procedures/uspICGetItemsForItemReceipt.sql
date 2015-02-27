CREATE PROCEDURE [dbo].[uspICGetItemsForItemReceipt]
	@intSourceTransactionId AS INT
	,@strSourceType AS NVARCHAR(100) 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @CurrentServerDate AS DATETIME = GETDATE()

DECLARE @ReceiptType_PurchaseOrder AS NVARCHAR(100) = 'Purchase Order'
DECLARE @ReceiptType_TransferOrder AS NVARCHAR(100) = 'Transfer Order'
DECLARE @ReceiptType_Direct AS NVARCHAR(100) = 'Direct'

DECLARE @intPurchaseOrderType AS INT = 1
DECLARE @intTransferOrderType AS INT = 2
DECLARE @intDirectType AS INT = 3

IF @strSourceType = @ReceiptType_PurchaseOrder
BEGIN 
	SELECT	intItemId = PODetail.intItemId
			,intLocationId = ItemLocation.intItemLocationId 
			,intItemUOMId = ItemUOM.intItemUOMId
			,dtmDate = dbo.fnRemoveTimeOnDate(GETDATE())
			,dblQty = PODetail.dblQtyOrdered 
			,dblUOMQty = ItemUOM.dblUnitQty
			,dblCost = PODetail.dblCost
			,dblSalesPrice = 0
			,intCurrencyId = PO.intCurrencyId
			,dblExchangeRate = 1 -- TODO: Not yet implemented in PO. Default to 1 for now. 
			,intTransactionId = PO.intPurchaseId
			,strTransactionId = PO.strPurchaseOrderNumber
			,intTransactionTypeId = @intPurchaseOrderType
			,intLotId = NULL 
			,intSubLocationId = PODetail.intSubLocationId
			,intStorageLocationId = PODetail.intStorageLocationId
	FROM	dbo.tblPOPurchase PO INNER JOIN dbo.tblPOPurchaseDetail PODetail
				ON PO.intPurchaseId = PODetail.intPurchaseId
			INNER JOIN dbo.tblICItemUOM ItemUOM
				ON PODetail.intItemId = ItemUOM.intItemId
				AND PODetail.intUnitOfMeasureId = ItemUOM.intItemUOMId
			INNER JOIN dbo.tblICItemLocation ItemLocation
				ON PODetail.intItemId = ItemLocation.intItemId
				-- Use "Ship To" because this is where the items in the PO will be delivered by the Vendor. 
				AND PO.intShipToId = ItemLocation.intLocationId
	WHERE	PODetail.intPurchaseId = @intSourceTransactionId
			AND dbo.fnIsStockTrackingItem(PODetail.intItemId) = 1
			
END

