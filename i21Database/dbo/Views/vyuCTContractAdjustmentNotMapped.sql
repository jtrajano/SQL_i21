CREATE VIEW [dbo].[vyuCTContractAdjustmentNotMapped]

AS

	SELECT	AD.intAdjustmentId,
			CD.strContractNumber,
			CD.intContractSeq,
			CD.strContractType,
			CD.strEntityName,
			CD.strPricingType,
			CD.strFutureMonth,
			CD.dblFutures,
			CD.dblBasis,
			CD.dblCashPrice,
			CD.strPriceUOM,
			CD.dblBalance,
			CD.strItemUOM
			
	FROM	tblCTContractAdjustment	AD
	JOIN	vyuCTContractDetailView	CD	ON	AD.intContractDetailId	=	CD.intContractDetailId
