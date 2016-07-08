CREATE VIEW [dbo].[vyuCTContractSearchView2]

AS	
	SELECT		CH.intContractHeaderId,				CH.dtmContractDate,				CH.strEntityName		AS strCustomerVendor,
				CH.strContractType,					CH.dblHeaderQuantity,			CH.strContractNumber,  
				CH.ysnPrinted,						BL.dblBalance,					CH.dblTolerancePct,				
				CH.dtmDeferPayDate,					CH.intEntityId,					CH.strCustomerContract,
				CH.dblDeferPayRate,					CH.strInternalComment,			CH.strPrintableRemarks,									
				CH.dblProvisionalInvoicePct,		CH.ysnPrepaid,					CH.ysnSubstituteItem,
				CH.ysnUnlimitedQuantity,			CH.ysnMaxPrice,					CH.ysnProvisional,
				CH.ysnLoad,							CH.intNoOfLoad,					CH.dblQuantityPerLoad,
				CH.ysnCategory,						CH.ysnMultiplePriceFixation,	CH.strEntityName,
				CH.strCommodityDescription,			CH.strGrade,					CH.strWeight,
				CH.strTextCode,						CH.strAssociationName,			CH.strTerm,							
				CH.strPosition,						CH.strInsuranceBy,				CH.strInvoiceType,				
				CH.strCountry,						CH.strCommodityCode,			CH.ysnSigned,
				CH.strApprovalBasis,				CH.strContractBasis,			CH.strPricingType,
				CH.strPricingLevelName,				CH.strLoadUnitMeasure,			BL.dblAppliedQty,
				CH.dtmCreated,						CH.strContractPlan,				CH.dtmSigned,
				CH.strCreatedBy,					CH.strLastModifiedBy,			CH.ysnExported,
				CH.dtmExported,						CH.strCropYear,					CH.strINCOLocation,
				CASE	WHEN	CH.strStatuses LIKE '%Open%'
							THEN	'Open'
						WHEN	CH.strStatuses LIKE '%Complete%'
							THEN	'Complete'
					ELSE	CH.strStatuses
				END		strStatuses,
				CASE WHEN CH.ysnLoad = 1 THEN CH.strHeaderUnitMeasure + '/Load' ELSE CH.strHeaderUnitMeasure END strHeaderUnitMeasure
	FROM		vyuCTContractHeaderView2		CH	LEFT
	JOIN
	(
		SELECT	HV.intContractHeaderId,
				SUM([dbo].[fnCTConvertQuantityToTargetItemUOM](CD.intItemId,CD.intUnitMeasureId,UM.intUnitMeasureId, CD.dblBalance))		AS dblBalance,
				SUM([dbo].[fnCTConvertQuantityToTargetItemUOM](CD.intItemId,CD.intUnitMeasureId,UM.intUnitMeasureId,
					CASE	WHEN	HV.ysnLoad = 1
						THEN	ISNULL(CD.intNoOfLoad,0)	-	ISNULL(CD.dblBalance,0)
						ELSE	ISNULL(CD.dblQuantity,0)	-	ISNULL(CD.dblBalance,0)												
				END))	AS dblAppliedQty
		FROM	tblCTContractHeader	HV	
			LEFT JOIN tblICCommodityUnitMeasure	UM	
				ON	UM.intCommodityUnitMeasureId = HV.intCommodityUOMId 
			LEFT JOIN	tblCTContractDetail	CD	
				ON CD.intContractHeaderId			=	HV.intContractHeaderId
		GROUP 
		BY		HV.intContractHeaderId
	)BL ON		BL.intContractHeaderId = CH.intContractHeaderId