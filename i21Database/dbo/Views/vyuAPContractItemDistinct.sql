CREATE VIEW [dbo].[vyuAPContractItemDistinct]
AS

SELECT
	A.intContractHeaderId,
	A.intContractDetailId,
	A.intEntityId,
	A.intItemId,
	A.intRackPriceSupplyPointId,
	A.intSupplyPointId,
	A.strIndexType,
	A.strItemNo,
	A.strItemDescription,
	A.strPricingType,
	A.dblAdjustment,
	A.dblCashPrice,
	A.dblBalance
FROM vyuCTContractDetailView A
INNER JOIN
(
	SELECT intContractHeaderId, intItemId, MIN(dblCashPrice) dblCashPriceMin FROM vyuCTContractDetailView GROUP BY intContractHeaderId, intItemId
) MinimumCashPrice 
ON A.intContractHeaderId = MinimumCashPrice.intContractHeaderId 
AND A.intItemId = MinimumCashPrice.intItemId
AND A.dblCashPrice = MinimumCashPrice.dblCashPriceMin