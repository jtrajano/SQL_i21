CREATE VIEW [dbo].[vyuCTSearchContract]

AS	
	SELECT	CH.intContractHeaderId,
			CH.intContractTypeId,
			CH.dtmContractDate,				
			CH.strEntityName		AS strCustomerVendor,
			CH.strContractType,					
			CH.dblHeaderQuantity,			
			CH.strContractNumber,  
			CH.ysnPrinted,						
			dblTotalBalance = CAST(BL.dblTotalBalance AS NUMERIC(18,6)),
			CH.intEntityId,					
			CH.strCustomerContract,	
			CH.ysnSigned,		
			dblTotalAppliedQty= CAST(BL.dblTotalAppliedQty AS NUMERIC(18,6)),
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
			CH.strPricingType strHeaderPricingType,
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
			CASE	
					WHEN	CH.strStatuses LIKE '%Incomplete%'
					THEN	'Incomplete'
					WHEN	CH.strStatuses LIKE '%Open%'
					THEN	'Open'					
					WHEN	CH.strStatuses LIKE '%Complete%'
					THEN	'Complete'
					ELSE	CH.strStatuses
			END		COLLATE Latin1_General_CI_AS AS strStatuses,

			CH.intStockCommodityUnitMeasureId,
			CH.strStockCommodityUnitMeasure,
			CH.strProducer,
			CH.strSalesperson,
			CH.strCPContract,
			CH.strCounterParty,
			ISNULL(TR.ysnApproved,0) AS ysnApproved,
			CH.intDefaultCommodityUnitMeasureId,
			CH.ysnBrokerage,
			CH.strBook,
			CH.strSubBook,
			CH.intBookId,
			CH.intSubBookId,
			CH.intFreightTermId,
			CH.strFreightTerm,
			CH.strExternalEntity,
			CH.strExternalContractNumber,
			CH.ysnReceivedSignedFixationLetter

	FROM	[vyuCTSearchContractHeader]  CH	WITH (NOLOCK) LEFT
	JOIN
	 (
		SELECT 
			HV.intContractHeaderId,
			dblTotalBalance = SUM(F.dblBalance),
			dblTotalAppliedQty = SUM(F.dblAppliedQuantity)
		FROM tblCTContractHeader HV WITH (NOLOCK)
			LEFT JOIN tblICCommodityUnitMeasure UM WITH (NOLOCK)
				ON UM.intCommodityUnitMeasureId = HV.intCommodityUOMId 
			LEFT JOIN tblCTContractDetail CD WITH (NOLOCK)
				ON CD.intContractHeaderId   = HV.intContractHeaderId
		CROSS APPLY (
			SELECT * FROM [dbo].[fnCTConvertQuantityToTargetItemUOM2](CD.intItemId,CD.intUnitMeasureId,UM.intUnitMeasureId, CD.dblBalance,ISNULL(CD.intNoOfLoad,0),ISNULL(CD.dblQuantity,0),HV.ysnLoad)
		) F
 GROUP BY HV.intContractHeaderId
 )BL ON  BL.intContractHeaderId = CH.intContractHeaderId
 OUTER APPLY
 (
	SELECT intRecordId = MIN(TR.intRecordId)
		, TR.ysnOnceApproved
		, ysnApproved = CASE WHEN TR.strApprovalStatus IN ( 'Approved', 'Approved with Modifications') THEN CONVERT(BIT,1) ELSE CONVERT(BIT,0) END
	FROM tblSMTransaction TR WITH (NOLOCK)
	JOIN tblSMScreen SC	WITH (NOLOCK) ON SC.intScreenId = TR.intScreenId
	WHERE SC.strNamespace IN('ContractManagement.view.Contract', 'ContractManagement.view.Amendments') AND TR.intRecordId = CH.intContractHeaderId
	GROUP BY TR.ysnOnceApproved
		, CASE WHEN TR.strApprovalStatus IN ( 'Approved', 'Approved with Modifications') THEN CONVERT(BIT,1) ELSE CONVERT(BIT,0) END
	
) TR --ON TR.intRecordId = CH.intContractHeaderId	
