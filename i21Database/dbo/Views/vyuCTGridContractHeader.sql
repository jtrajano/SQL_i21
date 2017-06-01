CREATE VIEW [dbo].[vyuCTGridContractHeader]

AS 

	SELECT	CH.*,
			
			NM.intPriceFixationId,
			NM.intPriceContractId,
			NM.ysnSpreadAvailable,
			NM.dblCommodityUOMConversionFactor,
			NM.strPrepaidIds,
			NM.ysnExchangeTraded,						
			NM.strINCOLocationType,			
			NM.ysnPrepaid,			
			NM.intUnitMeasureId,

			NM.strContractBasis,
			NM.strCommodityUOM,
			NM.strPosition,
			NM.strGrade,
			NM.strWeight,
			NM.strTerm,
			NM.strEntityName,
			NM.strSalesperson,
			NM.strContact,
			NM.strProducer,
			NM.strCounterParty,
			NM.strCountry,
			NM.strContractPlan,
			NM.strCommodityCode,
			NM.strInsuranceBy,
			NM.strInvoiceType,
			NM.strPricingLevelName,
			NM.strPricingType,
			
			NM.strTermCode,
			NM.strContractType,
			NM.strTextCode,
			NM.strLoadUnitMeasure,
			NM.strCategoryUnitMeasure,
			NM.strLoadCategoryUnitMeasure,
			NM.strCropYear,
			NM.strSubLocationName,
			NM.strINCOLocation,
			NM.strArbitration,
			NM.strAssociationName,
			NM.strFutureMarket,
			NM.strFutureMonthYear,
			NM.strMarketUnitMeasure,
			NM.dblMarketContractSize,
			NM.intMarketCurrencyId,
			NM.strMarketCurrency,
			NM.strCommodityAttributeId,
			NM.intEntityDefaultLocationId,
			NM.intPositionNoOfDays

	FROM	tblCTContractHeader				CH
	JOIN	vyuCTContractHeaderNotMapped	NM	ON	NM.intContractHeaderId	=	CH.intContractHeaderId
