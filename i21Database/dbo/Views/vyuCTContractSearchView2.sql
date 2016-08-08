CREATE VIEW [dbo].[vyuCTContractSearchView2]

AS	
	SELECT	CH.intContractHeaderId,				
			CH.dtmContractDate,				
			CH.strEntityName		AS strCustomerVendor,
			CH.strContractType,					
			CH.dblHeaderQuantity,			
			CH.strContractNumber,  
			CH.ysnPrinted,						
			BL.dblBalance,
			CH.intEntityId,					
			CH.strCustomerContract,	
			CH.ysnSigned,		
			BL.dblAppliedQty,
			CH.dtmCreated,		
			CH.dtmSigned,
			CASE WHEN CH.ysnLoad = 1 THEN CH.strHeaderUnitMeasure + '/Load' ELSE CH.strHeaderUnitMeasure END strHeaderUnitMeasure,
			-- Hidden fields
			CH.dtmDeferPayDate,	
			CH.dblDeferPayRate,
			CH.strInternalComment,
			CH.strPrintableRemarks,
			CH.dblTolerancePct,
			CH.dblProvisionalInvoicePct,
			CH.ysnPrepaid,		
			CH.ysnSubstituteItem,
			CH.ysnUnlimitedQuantity,
			CH.ysnMaxPrice,
			CH.ysnProvisional,
			CH.intNoOfLoad,
			CH.dblQuantityPerLoad,
			CH.ysnCategory,
			CH.ysnMultiplePriceFixation,
			CH.strCommodityDescription,
			CH.strGrade,
			CH.strWeight,
			CH.strTextCode,	
			CH.strAssociationName,
			CH.strTerm,
			CH.strPosition,
			CH.strInsuranceBy,
			CH.strInvoiceType,
			CH.strCountry,
			CH.strCommodityCode,
			CH.strApprovalBasis,
			CH.strContractBasis,
			CH.strPricingType,
			CH.strPricingLevelName,
			CH.strLoadUnitMeasure,
			CH.strINCOLocation,
			CH.strContractPlan,	
			CH.strCreatedBy,
			CH.strLastModifiedBy,	
			CH.ysnExported,
			CH.dtmExported,
			CH.strCropYear,
			CH.ysnLoad,
			CASE	WHEN	CH.strStatuses LIKE '%Open%'
					THEN	'Open'
					WHEN	CH.strStatuses LIKE '%Complete%'
					THEN	'Complete'
					ELSE	CH.strStatuses
			END		strStatuses

	FROM	vyuCTContractHeaderView2 CH	LEFT
	JOIN
	 (
		SELECT 
			HV.intContractHeaderId,
			dblBalance = SUM(F.dblBalance),
			dblAppliedQty = SUM(F.dblAppliedQuantity)
		FROM tblCTContractHeader HV 
			LEFT JOIN tblICCommodityUnitMeasure UM 
				ON UM.intCommodityUnitMeasureId = HV.intCommodityUOMId 
			LEFT JOIN tblCTContractDetail CD 
				ON CD.intContractHeaderId   = HV.intContractHeaderId
		CROSS APPLY (
			SELECT * FROM [dbo].[fnCTConvertQuantityToTargetItemUOM2](CD.intItemId,CD.intUnitMeasureId,UM.intUnitMeasureId, CD.dblBalance,ISNULL(CD.intNoOfLoad,0),ISNULL(CD.dblQuantity,0),HV.ysnLoad)
		) F
 GROUP BY HV.intContractHeaderId
 )BL ON  BL.intContractHeaderId = CH.intContractHeaderId
