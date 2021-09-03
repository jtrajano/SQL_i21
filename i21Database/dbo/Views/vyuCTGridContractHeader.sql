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
			NM.strBrokerAccount,
			CH.ysnReceivedSignedFixationLetter,
			AP.strApprovalStatus,
			P.strPositionType,
			CH.ysnReadOnlyInterCoContract,
			CH.ysnEnableFutures,
			intCommodityFutureMarketId = NM.intCommodityFutureMarketId,
			CH.ysnStrategic, -- CT-5315
			CH.intEntitySelectedLocationId, -- CT-5315
			NM.strEntitySelectedLocation, -- CT-5315
			ysnContractRequiresApproval = (case when te.countValue > 0 or ue.countValue > 0 then convert(bit,1) else convert(bit,0) end)
	FROM		tblCTContractHeader				CH
	JOIN		vyuCTContractHeaderNotMapped	NM	ON	NM.intContractHeaderId	=	CH.intContractHeaderId
	OUTER APPLY
	(
		SELECT	TOP 1 AP.strStatus AS strApprovalStatus 
		FROM	tblSMApproval		AP
		JOIN	tblSMTransaction	TR	ON	TR.intTransactionId =	AP.intTransactionId
										AND	TR.intRecordId		=   CH.intContractHeaderId
		JOIN	tblSMScreen			SC	ON	SC.intScreenId		=	TR.intScreenId
		WHERE	SC.strNamespace IN ('ContractManagement.view.Contract','ContractManagement.view.Amendments')
		AND		AP.ysnCurrent = 1
	) AP
	cross apply (
		select countValue=count(*)
		from tblEMEntityRequireApprovalFor em
		cross apply (select sc.intScreenId from tblSMScreen sc where sc.strNamespace = 'ContractManagement.View.Contract')scr
		where em.intEntityId = CH.intEntityId and em.intScreenId = scr.intScreenId
	)te
	cross apply (
		select countValue=count(*)
		from tblSMUserSecurityRequireApprovalFor smUser
		cross apply (select sc.intScreenId from tblSMScreen sc where sc.strNamespace = 'ContractManagement.View.Contract')scr
		where smUser.intEntityUserSecurityId = isnull(CH.intLastModifiedById,CH.intCreatedById) and smUser.intScreenId = scr.intScreenId
	)ue
	LEFT JOIN tblCTPosition P ON CH.intPositionId = P.intPositionId