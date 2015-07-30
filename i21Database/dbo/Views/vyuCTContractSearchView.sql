CREATE VIEW [dbo].[vyuCTContractSearchView]

AS

	SELECT		CH.intContractHeaderId,				CH.dtmContractDate,				CH.strEntityName		AS strCustomerVendor,
				CH.strContractType,					CH.dblHeaderQuantity,			CH.intContractNumber,
				CH.strCustomerContract,				CH.ysnSigned,					CH.ysnPrinted,
				BL.dblBalance,						CH.strHeaderUnitMeasure,		CH.dtmDeferPayDate,
				CH.dblDeferPayRate,					CH.strInternalComments,			CH.strContractComments,									
				CH.dblTolerancePct,
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
				CH.strLoadCategoryUnitMeasure,		CH.strINCOLocation,				CH.strStatuses

	FROM		vyuCTContractHeaderView		CH	LEFT
	JOIN
	(
		SELECT	HV.intContractHeaderId,SUM([dbo].[fnCTConvertQuantityToTargetItemUOM](CD.intItemId,CD.intUnitMeasureId,UM.intUnitMeasureId,CD.dblBalance)) AS dblBalance
		FROM	vyuCTContractHeaderView		HV	LEFT
		JOIN	tblICCommodityUnitMeasure	UM	ON	UM.intCommodityUnitMeasureId	=	HV.intCommodityUnitMeasureId LEFT
		JOIN	vyuCTContractDetailView		CD	ON CD.intContractHeaderId			=	HV.intContractHeaderId
		GROUP 
		BY		HV.intContractHeaderId
	)BL ON		BL.intContractHeaderId = CH.intContractHeaderId