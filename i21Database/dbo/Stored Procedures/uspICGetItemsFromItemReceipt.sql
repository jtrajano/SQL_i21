CREATE PROCEDURE [dbo].[uspICGetItemsFromItemReceipt]
	@intReceiptId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

SELECT	
		-- Header
		[intInventoryReceiptId]			= Receipt.intInventoryReceiptId
		,[strInventoryReceiptId]		= Receipt.strReceiptNumber
		,[strReceiptType]				= Receipt.strReceiptType
		,[intSourceType]				= Receipt.intSourceType
		,[dtmDate]						= Receipt.dtmReceiptDate
		,[intCurrencyId]				= Receipt.intCurrencyId
		,[dblExchangeRate]				= 1 -- Default to 1. TODO: Implement multi currency.

		-- Detail 
		,[intInventoryReceiptDetailId]	= ReceiptItem.intInventoryReceiptItemId
		,[intItemId]					= ReceiptItem.intItemId
		,[intLotId]						= ItemLot.intLotId
		,[strLotNumber]					= ItemLot.strLotNumber
		,[intLocationId]				= ItemLocation.intLocationId
		,[intItemLocationId]			= ItemLocation.intItemLocationId
		,[intSubLocationId]				= ItemLot.intSubLocationId
		,[intStorageLocationId]			= ItemLot.intStorageLocationId
		,[intItemUOMId]					= ISNULL(ItemLot.intItemUnitMeasureId, ReceiptItem.intUnitMeasureId)
		,[intWeightUOMId]				= ReceiptItem.intWeightUOMId		
		,[dblQty]						= ISNULL(ItemLot.dblQuantity, ReceiptItem.dblOpenReceive) 
		,[dblUOMQty]					= ISNULL(LotItemtUOM.dblUnitQty, ItemUOM.dblUnitQty)
		,[dblNetWeight]					= ISNULL(ItemLot.dblGrossWeight, 0) - ISNULL(ItemLot.dblTareWeight, 0)
		,[dblCost]						= ReceiptItem.dblUnitCost
		,[intContainerId]				= ReceiptItem.intContainerId
		,[intOwnershipType]				= ReceiptItem.intOwnershipType
		,[intOrderId]					= ReceiptItem.intOrderId
		,[intSourceId]					= ReceiptItem.intSourceId
		,[intLineNo]					= ISNULL(ReceiptItem.intLineNo, 0)
		,[intLoadReceive]				= ISNULL(ReceiptItem.intLoadReceive, 0) 
FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
			ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
		INNER JOIN dbo.tblICItemLocation ItemLocation
			ON ItemLocation.intItemId = ReceiptItem.intItemId
			AND ItemLocation.intLocationId = Receipt.intLocationId				
		INNER JOIN dbo.tblICItemUOM	ItemUOM
			ON ItemUOM.intItemUOMId = ReceiptItem.intUnitMeasureId
		LEFT JOIN dbo.tblICItemUOM WeightUOM
			ON WeightUOM.intItemUOMId = ReceiptItem.intWeightUOMId
		LEFT JOIN dbo.tblICInventoryReceiptItemLot ItemLot
			ON ItemLot.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
		LEFT JOIN dbo.tblICItemUOM LotItemtUOM
			ON LotItemtUOM.intItemUOMId = ItemLot.intItemUnitMeasureId
WHERE	Receipt.intInventoryReceiptId = @intReceiptId		