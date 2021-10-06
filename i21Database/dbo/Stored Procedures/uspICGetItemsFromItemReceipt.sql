CREATE PROCEDURE [dbo].[uspICGetItemsFromItemReceipt]
	@intReceiptId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON
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
		,[intItemId]					= CASE WHEN ISNULL(ReceiptItem.strItemType,'') = 'Option' THEN ItemBundleDetail.intItemId ELSE ReceiptItem.intItemId END
		,[intLotId]						= ItemLot.intLotId
		,[strLotNumber]					= ItemLot.strLotNumber
		,[intLocationId]				= ItemLocation.intLocationId
		,[intItemLocationId]			= ItemLocation.intItemLocationId
		,[intSubLocationId]				= ItemLot.intSubLocationId
		,[intStorageLocationId]			= ItemLot.intStorageLocationId
		,[intItemUOMId]					= CASE WHEN ISNULL(ReceiptItem.strItemType,'') = 'Option' THEN dbo.[fnGetMatchingItemUOMId](ItemBundleDetail.intItemId, ReceiptItem.intUnitMeasureId) ELSE ISNULL(ItemLot.intItemUnitMeasureId, ReceiptItem.intUnitMeasureId) END
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
		,[ysnLoad]						= ISNULL(ContractView.ysnLoad, 0)
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
		LEFT JOIN tblICItem Item ON Item.intItemId = ReceiptItem.intItemId
		LEFT JOIN vyuCTCompactContractDetailView ContractView
			ON ContractView.intContractDetailId = ReceiptItem.intLineNo
				AND Receipt.strReceiptType = 'Purchase Contract'

		LEFT JOIN tblICItemBundle ItemBundle
			ON ItemBundle.intItemBundleId = ReceiptItem.intParentItemLinkId
			AND ISNULL(ReceiptItem.strItemType,'') = 'Option'
		LEFT JOIN tblICItem ItemBundleDetail
			ON ItemBundleDetail.intItemId = ItemBundle.intItemId
			AND ItemBundleDetail.strType = 'Bundle'
			AND ISNULL(ItemBundleDetail.strBundleType,'') = 'Option'

WHERE	Receipt.intInventoryReceiptId = @intReceiptId	
		AND 1 = CASE WHEN ISNULL(ReceiptItem.strItemType,'') <> '' AND Item.strType = 'Bundle' THEN 1
					WHEN ISNULL(ReceiptItem.strItemType,'') = 'Option' THEN 1
					WHEN ISNULL(ReceiptItem.strItemType,'') <> '' THEN 0
					ELSE 1 END