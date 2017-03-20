CREATE VIEW [dbo].[vyuCTGridContractHeader]

AS 

	SELECT	CH.*,
			
			intPriceFixationId,
			intPriceContractId,
			ysnSpreadAvailable,
			dblCommodityUOMConversionFactor,
			strPrepaidIds,
			ysnExchangeTraded,
			strEntityName,
			strPosition,
			strGrade,
			strWeight,
			strTerm,
			strINCOLocationType,
			strCommodityUOM,
			ysnPrepaid

	FROM	tblCTContractHeader				CH
	JOIN	vyuCTContractHeaderNotMapped	NM	ON	NM.intContractHeaderId	=	CH.intContractHeaderId
