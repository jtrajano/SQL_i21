﻿CREATE VIEW [dbo].[vyuCTGridContractHeader]

AS 

	SELECT	CH.intContractHeaderId,
			CH.intConcurrencyId,
			CH.intContractTypeId,
			CH.intEntityId,
			CH.intBookId,
			CH.intSubBookId,
			CH.intCounterPartyId,
			CH.intEntityContactId,
			CH.intContractPlanId,
			CH.intCommodityId,
			CH.dblQuantity,
			CH.intCommodityUOMId,
			CH.strContractNumber,
			CH.dtmContractDate,
			CH.strCustomerContract,
			CH.strCPContract,
			CH.dtmDeferPayDate,
			CH.dblDeferPayRate,
			CH.intContractTextId,
			CH.ysnSigned,
			CH.dtmSigned,
			CH.ysnPrinted,
			CH.intSalespersonId,
			CH.intGradeId,
			CH.intWeightId,
			CH.intCropYearId,
			CH.strInternalComment,
			CH.strPrintableRemarks,
			CH.intAssociationId,
			CH.intTermId,
			CH.intPricingTypeId,
			CH.intApprovalBasisId,
			CH.intContractBasisId,
			CH.intFreightTermId,
			CH.intPositionId,
			CH.intInsuranceById,
			CH.intInvoiceTypeId,
			CH.dblTolerancePct,
			CH.dblProvisionalInvoicePct,
			CH.ysnSubstituteItem,
			CH.ysnUnlimitedQuantity,
			CH.ysnMaxPrice,
			CH.intINCOLocationTypeId,
			CH.intWarehouseId,
			CH.intCountryId,
			CH.intCompanyLocationPricingLevelId,
			CH.ysnProvisional,
			CH.ysnLoad,
			CH.intNoOfLoad,
			CH.dblQuantityPerLoad,
			CH.intLoadUOMId,
			CH.ysnCategory,
			CH.ysnMultiplePriceFixation,
			CH.intFutureMarketId,
			CH.intFutureMonthId,
			CH.dblFutures,
			CH.dblNoOfLots,
			CH.intCategoryUnitMeasureId,
			CH.intLoadCategoryUnitMeasureId,
			CH.intArbitrationId,
			CH.intProducerId,
			CH.ysnClaimsToProducer,
			CH.ysnRiskToProducer,
			CH.ysnExported,
			CH.dtmExported,
			CH.intCreatedById,
			CH.dtmCreated,
			CH.intLastModifiedById,
			CH.dtmLastModified,
			CH.ysnMailSent,
			CH.strAmendmentLog,
			CH.ysnBrokerage,
			CH.ysnBestPriceOnly,
			CH.intCompanyId,
			CH.intContractHeaderRefId,
			CH.strReportTo,
			CH.intBrokerId,
			CH.intBrokerageAccountId,
			CH.strExternalEntity,
			CH.strExternalContractNumber,

			NM.intPriceFixationId,
			NM.intPriceContractId,
			NM.ysnSpreadAvailable,
			NM.dblCommodityUOMConversionFactor,
			NM.strPrepaidIds  COLLATE Latin1_General_CI_AS AS strPrepaidIds,
			NM.ysnExchangeTraded,						
			NM.strINCOLocationType,			
			NM.ysnPrepaid,			
			NM.intUnitMeasureId,

			NM.strContractBasis,
			NM.strFreightTerm,
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
			NM.ysnMarketSubCurrency,
			NM.intMarketCent,
			NM.strCommodityAttributeId,
			NM.intEntityDefaultLocationId,
			NM.strEntityDefaultLocation,
			NM.intPositionNoOfDays,
			CH.intNoOfLoad - (SELECT SUM(dblBalanceLoad) FROM tblCTContractDetail WHERE intContractHeaderId = CH.intContractHeaderId) AS dblLoadsDelivered,
			NM.strBook,
			NM.strSubBook,
			NM.strMarketMainCurrency,
			NM.strBroker,
			NM.strBrokerAccount

	FROM	tblCTContractHeader				CH
	JOIN	vyuCTContractHeaderNotMapped	NM	ON	NM.intContractHeaderId	=	CH.intContractHeaderId
