CREATE VIEW [dbo].[vyuAPContractItemDistinct]
AS

SELECT
	DISTINCT
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
	A.dblBalance,
	dblTotalBalance = Total.dblTotalBalance
FROM vyuCTContractDetailView A
INNER JOIN
(
	SELECT intContractHeaderId, 
		   intItemId, 
	MIN(dblCashPrice) dblCashPriceMin 
	FROM vyuCTContractDetailView 
	GROUP BY 
			intContractHeaderId, 
			intItemId
) MinimumCashPrice 
ON A.intContractHeaderId = MinimumCashPrice.intContractHeaderId 
AND A.intItemId = MinimumCashPrice.intItemId
AND A.dblCashPrice = MinimumCashPrice.dblCashPriceMin
CROSS APPLY
(
	SELECT intContractHeaderId, 
		   SUM(dblBalance) AS dblTotalBalance, 
		   intItemId 
	FROM vyuCTContractDetailView B
	WHERE B.intContractHeaderId = A.intContractHeaderId  
		  AND B.intItemId = A.intItemId
	GROUP BY 
			intContractHeaderId, 
			dblBalance, 
			intItemId	
) Total 

GO