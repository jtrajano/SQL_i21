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
			CD.strItemUOM,
			GA.strAccountId
			
	FROM	tblCTContractAdjustment	AD
	JOIN	vyuCTContractSequence	CD	ON	AD.intContractDetailId	=	CD.intContractDetailId
	JOIN	tblGLAccount			GA	ON	GA.intAccountId			=	AD.intAccountId
