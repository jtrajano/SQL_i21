CREATE VIEW [dbo].[vyuCTContractDetailItemStockView]

AS
	SELECT 
			CD.intContractHeaderId,			CD.strContractNumber,			CD.intContractDetailId,		CD.intContractSeq,
			IK.intKey,						IK.intItemId,					IK.strItemNo,
			IK.strType,						IK.strDescription,				IK.strLotTracking,			IK.strInventoryTracking,
			IK.strStatus,					IK.intLocationId,				IK.intItemLocationId,		IK.intSubLocationId,
			IK.intCategoryId,				IK.strCategoryCode,				IK.intCommodityId,			IK.strCommodityCode,
			IK.strStorageLocationName,		IK.strSubLocationName,			IK.intStorageLocationId,	IK.strLocationName,
			IK.strLocationType,				IK.intVendorId,					IK.strVendorId,				IK.intStockUOMId,
			IK.strStockUOM,					IK.strStockUOMType,				IK.intReceiveUOMId,			IK.dblReceiveUOMConvFactor,
			IK.intIssueUOMId,				IK.dblIssueUOMConvFactor,		IK.strReceiveUOMType,		IK.strIssueUOMType,
			IK.strReceiveUOM,				IK.dblReceiveSalePrice,			IK.dblReceiveMSRPPrice,		IK.dblReceiveLastCost,
			IK.dblReceiveStandardCost,		IK.dblReceiveAverageCost,		IK.dblReceiveEndMonthCost,	IK.strIssueUOM,
			IK.dblIssueSalePrice,			IK.dblIssueMSRPPrice,			IK.dblIssueLastCost,		IK.dblIssueStandardCost,
			IK.dblIssueAverageCost,			IK.dblIssueEndMonthCost,		IK.dblMinOrder,				IK.dblReorderPoint,
			IK.intAllowNegativeInventory,	IK.strAllowNegativeInventory,	IK.intCostingMethod,		IK.strCostingMethod,
			IK.dblAmountPercent,			IK.dblSalePrice,				IK.dblMSRPPrice,			IK.strPricingMethod,
			IK.dblLastCost,					IK.dblStandardCost,				IK.dblAverageCost,			IK.dblEndMonthCost,
			IK.dblUnitOnHand,				IK.dblOnOrder,					IK.dblOrderCommitted,		IK.dblBackOrder
	
	FROM	vyuCTContractDetailView CD
	JOIN	vyuICGetItemStock		IK	ON	CD.intItemId = IK.intItemId