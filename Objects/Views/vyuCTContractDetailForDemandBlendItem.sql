CREATE VIEW vyuCTContractDetailForDemandBlendItem
AS
SELECT CD.intContractDetailId
	,CD.strSequenceNumber
	,CD.strEntityName
	,RI.intItemId
	,RI.dblQuantity * CD.dblBalanceInItemStockUOM AS dblQtyInStockUOM
	--,CD.dblQtyInStockUOM
	,CD.strStockItemUOM
	,CD.intUpdatedAvailabilityMonth
	,CD.intUpdatedAvailabilityYear
	,CD.dtmUpdatedAvailabilityDate
	,CD.intCompanyLocationId
FROM [dbo].[tblMFRecipeItem] RI
JOIN [dbo].[tblMFRecipe] R ON R.intRecipeId = RI.intRecipeId
	AND R.ysnActive = 1
	AND RI.intRecipeItemTypeId = 1
JOIN vyuCTContractDetailView CD ON CD.intItemId = R.intItemId
	AND CD.intContractStatusId = 1
	AND CD.dblBalanceInItemStockUOM > 0
