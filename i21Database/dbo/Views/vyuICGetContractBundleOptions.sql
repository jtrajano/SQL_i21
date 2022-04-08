CREATE VIEW [dbo].[vyuICGetContractBundleOptions]
AS

SELECT 
	r.strReceiptNumber
	,ri.intInventoryReceiptItemId
	,bundleItem.intItemId
	,bundleItem.strItemNo
	,bundleItem.strDescription
	,[strBundle] = bundle.strItemNo
	,intItemUOMId = dbo.fnGetMatchingItemUOMId(bundleItem.intItemId, ri.intUnitMeasureId) 
	,intCostUOMId = dbo.fnGetMatchingItemUOMId(bundleItem.intItemId, ri.intCostUOMId) 
	,intWeightUOMId = dbo.fnGetMatchingItemUOMId(bundleItem.intItemId, ri.intWeightUOMId) 
	,il.intItemLocationId
	,bundleItems.dblMarkUpOrDown
FROM 
	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
		ON r.intInventoryReceiptId = ri.intInventoryReceiptId
	INNER JOIN vyuCTCompactContractDetailView contractView
		ON contractView.intContractDetailId = ISNULL(ri.intContractDetailId, ri.intLineNo) 
		AND r.strReceiptType = 'Purchase Contract'
	INNER JOIN tblICItem bundle
		ON bundle.intItemId = contractView.intItemBundleId
		AND bundle.strBundleType = 'Option'
	INNER JOIN tblICItemBundle bundleItems
		ON bundleItems.intItemId = bundle.intItemId
	INNER JOIN tblICItem bundleItem
		ON bundleItem.intItemId = bundleItems.intBundleItemId
		AND bundleItem.intItemId <> ri.intItemId
	INNER JOIN tblICItemLocation il
		ON il.intItemId = bundleItem.intItemId
		AND il.intLocationId = r.intLocationId 