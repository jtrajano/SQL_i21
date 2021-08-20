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
			strApprovalStatus = (case when CD.intDetailCount = 0 and RA.ysnRequireApproval = 1 then 'Waiting for Submit' else AP.strApprovalStatus end),
			P.strPositionType,
			CH.ysnReadOnlyInterCoContract,
			CH.ysnEnableFutures,
			intCommodityFutureMarketId = NM.intCommodityFutureMarketId,
			CH.ysnStrategic, -- CT-5315
			CH.intEntitySelectedLocationId, -- CT-5315
			NM.strEntitySelectedLocation -- CT-5315
	FROM		tblCTContractHeader				CH
	JOIN		vyuCTContractHeaderNotMapped	NM	ON	NM.intContractHeaderId	=	CH.intContractHeaderId
	OUTER APPLY --dbo.[fnCTGetLastApprovalStatus](CH.intContractHeaderId) strApprovalStatus
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
		select intDetailCount = count(*) from tblCTContractDetail where intContractHeaderId = CH.intContractHeaderId
	) CD
	cross apply (
		select ysnRequireApproval = convert(bit,count(*))
		from tblSMUserSecurityRequireApprovalFor af
		cross apply (
			select top 1 intScreenId from tblSMScreen where strModule = 'Contract Management' and strNamespace = 'ContractManagement.view.Contract'
		) sc
		where
		af.intEntityUserSecurityId = isnull(CH.intLastModifiedById,CH.intCreatedById) and af.intScreenId = sc.intScreenId
	)RA
	LEFT JOIN tblCTPosition P ON CH.intPositionId = P.intPositionId