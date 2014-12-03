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
			,intLocationId = PODetail.intLocationId
			,dtmDate = dbo.fnRemoveTimeOnDate(GETDATE())
			,dblUnitQty = PODetail.dblQtyOrdered 
			,dblUOMQty = UOMConversion.dblConversionToStock 
			,dblCost = PODetail.dblCost
			,dblSalesPrice = 0
			,intCurrencyId = PO.intCurrencyId
			,dblExchangeRate = 1 -- TODO: Not yet implemented in PO. Default to 1 for now. 
			,intTransactionId = PO.intPurchaseId
			,strTransactionId = PO.strPurchaseOrderNumber
			,intTransactionTypeId = @intPurchaseOrderType
			,intLotId = null 
	FROM	dbo.tblPOPurchase PO INNER JOIN dbo.tblPOPurchaseDetail PODetail
				ON PO.intPurchaseId = PODetail.intPurchaseId
			LEFT JOIN dbo.tblICUnitMeasure UOM
				ON PODetail.intUnitOfMeasureId = UOM.intUnitMeasureId
			INNER JOIN dbo.tblICUnitMeasureConversion UOMConversion
				ON UOM.intUnitMeasureId = UOMConversion.intUnitMeasureId
	WHERE	PODetail.intPurchaseId = @intSourceTransactionId
END