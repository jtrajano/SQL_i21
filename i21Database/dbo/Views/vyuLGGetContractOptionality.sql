CREATE VIEW [dbo].[vyuLGGetContractOptionality]
AS
SELECT 
	CO.intContractOptionalityId
	,CO.intContractDetailId
	,CO.intOptionId
	,CO.strValue
	,dblPremiumDiscount
	,dblPremiumDiscountInContractUOM = CONVERT(NUMERIC(18, 6), dbo.fnCalculateCostBetweenUOM(OptUOM.intItemUOMId, CD.intPriceItemUOMId, CO.dblPremiumDiscount))
	,CO.intCurrencyId
	,CO.intUnitMeasureId
	,CO.intConcurrencyId
FROM tblCTContractOptionality CO
INNER JOIN tblCTContractDetail CD ON CD.intContractDetailId = CO.intContractDetailId
OUTER APPLY (SELECT TOP 1 intItemUOMId FROM tblICItemUOM WHERE intItemId = CD.intItemId AND intUnitMeasureId = CO.intUnitMeasureId) OptUOM

GO