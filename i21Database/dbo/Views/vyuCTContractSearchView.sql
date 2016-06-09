CREATE VIEW [dbo].[vyuCTContractSearchView]

AS

	SELECT		CH.intContractHeaderId,				CH.dtmContractDate,				CH.strEntityName		AS strCustomerVendor,
				CH.strContractType,					CH.dblHeaderQuantity,			CH.strContractNumber,
				CH.strCustomerContract,				CH.ysnSigned,					CH.ysnPrinted,
				BL.dblBalance,						CH.dblTolerancePct,				CH.dtmDeferPayDate,
				CH.dblDeferPayRate,					CH.strInternalComment,			CH.strPrintableRemarks,									
				CH.dblProvisionalInvoicePct,		CH.ysnPrepaid,					CH.ysnSubstituteItem,
				CH.ysnUnlimitedQuantity,			CH.ysnMaxPrice,					CH.ysnProvisional,
				CH.ysnLoad,							CH.intNoOfLoad,					CH.dblQuantityPerLoad,
				CH.ysnCategory,						CH.ysnMultiplePriceFixation,	CH.strEntityName,
				CH.strCommodityDescription,			CH.strEntityNumber,				CH.strEntityAddress,
				CH.strEntityState,					CH.strEntityZipCode,			CH.strGrade,
				CH.strEntityPhone,					CH.strWeight,					CH.strEntityType,
				CH.strTextCode,						CH.strAssociationName,			CH.strEntityCity,
				CH.strTerm,							CH.strContractBasisDescription,	CH.strEntityCountry,
				CH.strPosition,						CH.strInsuranceByDescription,	CH.strInsuranceBy,
				CH.strInvoiceTypeDescription,		CH.strInvoiceType,				CH.strCountry,
				CH.strApprovalBasisDescription,		CH.strCommodityCode,			CH.strINCOLocationType,
				CH.strApprovalBasis,				CH.strContractBasis,			CH.strPricingType,
				CH.strPricingLevelName,				CH.strLoadUnitMeasure,			CH.strCategoryUnitMeasure,
				CH.strLoadCategoryUnitMeasure,		CH.strINCOLocation,				BL.dblAppliedQty,
				CH.dtmCreated,						CH.strContractPlan,				CH.dtmSigned,
				CH.strCreatedBy,					CH.strLastModifiedBy,			CH.ysnExported,
				CH.dtmExported,						CH.strCropYear,

				CH.intContractPlanId,				CH.intEntityId,					CH.intCommodityId,
				CH.intGradeId,						CH.intWeightId,					CH.intContractTextId,
				CH.intAssociationId,				CH.intTermId,					CH.intPositionId,
				CH.intCountryId,					CH.intContractBasisId,			CH.intContractTypeId,
				CH.intCommodityUnitMeasureId,		

				CASE	WHEN	CH.strStatuses LIKE '%Open%'
						THEN	'Open'
						WHEN	CH.strStatuses LIKE '%Complete%'
						THEN	'Complete'
						ELSE	CH.strStatuses
				END		strStatuses,
				CASE WHEN CH.ysnLoad = 1 THEN CH.strHeaderUnitMeasure + '/Load' ELSE CH.strHeaderUnitMeasure END strHeaderUnitMeasure

				

	FROM		vyuCTContractHeaderView		CH	LEFT
	JOIN
	(
		SELECT	HV.intContractHeaderId,
				SUM([dbo].[fnCTConvertQuantityToTargetItemUOM](CD.intItemId,CD.intUnitMeasureId,UM.intUnitMeasureId,CD.dblBalance))		AS dblBalance,
				SUM([dbo].[fnCTConvertQuantityToTargetItemUOM](CD.intItemId,CD.intUnitMeasureId,UM.intUnitMeasureId,CD.dblAppliedQty))	AS dblAppliedQty
		FROM	vyuCTContractHeaderView		HV	LEFT
		JOIN	tblICCommodityUnitMeasure	UM	ON	UM.intCommodityUnitMeasureId	=	HV.intCommodityUnitMeasureId LEFT
		JOIN	vyuCTContractDetailView		CD	ON CD.intContractHeaderId			=	HV.intContractHeaderId
		GROUP 
		BY		HV.intContractHeaderId
	)BL ON		BL.intContractHeaderId = CH.intContractHeaderId