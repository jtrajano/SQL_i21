﻿CREATE PROCEDURE [dbo].[uspICGetItemsForItemReceipt]
	@intSourceTransactionId AS INT
	,@strSourceType AS NVARCHAR(100) 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @CurrentServerDate AS DATETIME = GETDATE()

DECLARE @ReceiptType_PurchaseContract AS NVARCHAR(100) = 'Purchase Contract'
DECLARE @ReceiptType_PurchaseOrder AS NVARCHAR(100) = 'Purchase Order'
DECLARE @ReceiptType_TransferOrder AS NVARCHAR(100) = 'Transfer Order'
DECLARE @ReceiptType_Direct AS NVARCHAR(100) = 'Direct'
DECLARE @SourceType_Scale AS NVARCHAR(100) = 'Scale'
DECLARE @SourceType_InboundShipment AS NVARCHAR(100) = 'Inbound Shipment'

DECLARE @intPurchaseOrderType AS INT = 1
DECLARE @intTransferOrderType AS INT = 2
DECLARE @intDirectType AS INT = 3
DECLARE @intPurchaseContractType AS INT = 4
DECLARE @intScaleType AS INT = 5
DECLARE @intInboundShipmentType AS INT = 6

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
			,intTransactionDetailId = PODetail.intPurchaseDetailId
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
			AND PODetail.dblQtyOrdered != PODetail.dblQtyReceived
			
END
ELSE IF @strSourceType = @ReceiptType_PurchaseContract
BEGIN
	SELECT intItemId = Contract.intItemId
		,intLocationId = dbo.fnICGetItemLocation(Contract.intItemId, Contract.intCompanyLocationId)
		,intItemUOMId = Contract.intItemUOMId
		,dtmDate = dbo.fnRemoveTimeOnDate(GETDATE())
		,dblQty = Contract.dblDetailQuantity
		,dblUOMQty = Contract.dblItemUOMCF
		,dblCost = ISNULL(Contract.dblCashPrice, 0)
		,dblSalesPrice = 0
		,intCurrencyId = null
		,dblExchangeRate = 1
		,intTransactionId = Contract.intContractHeaderId
		,intTransactionDetailId = Contract.intContractDetailId
		,strTransactionId = CAST(Contract.intContractNumber AS nvarchar)
		,intTransactionTypeId = @intPurchaseContractType 
		,intLotId = null
		,intSubLocationId = Contract.intCompanyLocationSubLocationId
		,intStorageLocationId = Contract.intStorageLocationId
	FROM vyuCTContractDetailView Contract
END
ELSE IF @strSourceType = @SourceType_InboundShipment
BEGIN
	SELECT intItemId = Shipments.intItemId
		,intLocationId = dbo.fnICGetItemLocation(Shipments.intItemId, Shipments.intLocationId)
		,intItemUOMId = Shipments.intItemUOMId
		,dtmDate = dbo.fnRemoveTimeOnDate(GETDATE())
		,dblQty = Shipments.dblQuantity
		,dblUOMQty = Shipments.dblItemUOMCF
		,dblCost = ISNULL(Shipments.dblCost, 0)
		,dblSalesPrice = 0
		,intCurrencyId = null
		,dblExchangeRate = 1
		,intTransactionId = Shipments.intContractHeaderId
		,intTransactionDetailId = Shipments.intContractDetailId
		,strTransactionId = CAST(Shipments.intContractNumber AS nvarchar)
		,intTransactionTypeId = @intScaleType 
		,intLotId = null
		,intSubLocationId = Shipments.intSubLocationId
		,intStorageLocationId = null
	FROM vyuLGShipmentContainerReceiptContracts Shipments
END
ELSE IF @strSourceType = @SourceType_Scale
BEGIN
	SELECT intItemId = ContractDetail.intItemId
		,intLocationId = ItemLocation.intItemLocationId
		,intItemUOMId = ItemUOM.intItemUOMId
		,dtmDate = dbo.fnRemoveTimeOnDate(GETDATE())
		,dblQty = ContractDetail.dblQuantity
		,dblUOMQty = ItemUOM.dblUnitQty
		,dblCost = ISNULL(ItemPricing.dblLastCost, 0)
		,dblSalesPrice = 0
		,intCurrencyId = null
		,dblExchangeRate = 1
		,intTransactionId = Contract.intContractHeaderId
		,intTransactionDetailId = ContractDetail.intContractDetailId
		,strTransactionId = CAST(Contract.intContractNumber AS nvarchar)
		,intTransactionTypeId = @intPurchaseContractType 
		,intLotId = null
		,intSubLocationId = null
		,intStorageLocationId = null
	FROM tblCTContractHeader Contract
		INNER JOIN tblCTContractDetail ContractDetail ON ContractDetail.intContractHeaderId = Contract.intContractHeaderId
		INNER JOIN tblICItemLocation ItemLocation ON ItemLocation.intLocationId = ContractDetail.intCompanyLocationId AND ItemLocation.intItemId = ContractDetail.intItemId
		INNER JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = ContractDetail.intItemUOMId
		INNER JOIN vyuICGetItemPricing ItemPricing ON ItemPricing.intItemId = ContractDetail.intItemId AND ItemPricing.intItemLocationId = ItemLocation.intItemLocationId AND ItemPricing.intItemUnitMeasureId = ItemUOM.intItemUOMId
END
ELSE IF @strSourceType = @intTransferOrderType
BEGIN
	SELECT intItemId = TransferDetail.intItemId
		,intLocationId = ItemLocation.intItemLocationId
		,intItemUOMId = ItemUOM.intItemUOMId
		,dtmDate = dbo.fnRemoveTimeOnDate(GETDATE())
		,dblQty = TransferDetail.dblQuantity
		,dblUOMQty = ItemUOM.dblUnitQty
		,dblCost = ISNULL(ItemPricing.dblLastCost, 0)
		,dblSalesPrice = 0
		,intCurrencyId = null
		,dblExchangeRate = 1
		,intTransactionId = Transfer.intInventoryTransferId
		,intTransactionDetailId = TransferDetail.intInventoryTransferDetailId
		,strTransactionId = Transfer.strTransferNo
		,intTransactionTypeId = @intTransferOrderType 
		,intLotId = TransferDetail.intNewLotId
		,intSubLocationId = TransferDetail.intToSubLocationId
		,intStorageLocationId = TransferDetail.intToStorageLocationId 
	FROM tblICInventoryTransfer Transfer
		INNER JOIN tblICInventoryTransferDetail TransferDetail ON TransferDetail.intInventoryTransferId = Transfer.intInventoryTransferId
		INNER JOIN tblICItemLocation ItemLocation ON ItemLocation.intLocationId = Transfer.intToLocationId AND ItemLocation.intItemId = TransferDetail.intItemId
		INNER JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = TransferDetail.intItemUOMId
		INNER JOIN vyuICGetItemPricing ItemPricing ON ItemPricing.intItemId = TransferDetail.intItemId AND ItemPricing.intItemLocationId = ItemLocation.intItemLocationId AND ItemPricing.intItemUnitMeasureId = ItemUOM.intItemUOMId
END
