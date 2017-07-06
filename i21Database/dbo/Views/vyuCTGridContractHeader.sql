CREATE VIEW [dbo].[vyuCTGridContractHeader]

AS 

	SELECT	CH.*,
			
			NM.intPriceFixationId,
			NM.intPriceContractId,
			NM.ysnSpreadAvailable,
			NM.dblCommodityUOMConversionFactor,
			NM.strPrepaidIds,
			NM.ysnExchangeTraded,
			NM.strEntityName,
			NM.strPosition,
			NM.strGrade,
			NM.strWeight,
			NM.strTerm,
			NM.strINCOLocationType,
			NM.strCommodityUOM,
			NM.ysnPrepaid,
			NM.strContractBasis,
			NM.intUnitMeasureId,
			NM.strSalesperson,
			NM.strTextCode,
			NM.strArbitration,
			NM.strInsuranceBy,
			NM.strInvoiceType,
			NM.strAssociationName,
			NM.strProducer,
			NM.strCountry,
			NM.strINCOLocation

	FROM	tblCTContractHeader				CH
	JOIN	vyuCTContractHeaderNotMapped	NM	ON	NM.intContractHeaderId	=	CH.intContractHeaderId
