CREATE VIEW [dbo].[vyuCTContractFeed]

AS 


	SELECT	CD.intContractHeaderId,			CD.intContractDetailId,		CH.strCommodityCode,	CH.strCommodityDescription		AS strCommodityDesc,
			CH.strContractBasis,			CD.strSubLocation,			CH.strCreatedBy,		CH.strContractBasisDescription	AS strContractBasisDesc,	
			CD.strCreatedByNo,				CH.strTerm,					CD.strPurchasingGroup,	CH.strEntityNumber				AS strEntityNo,	
			CH.strContractNumber,			CD.strERPPONumber,			CD.intContractSeq,		CD.strItemNo,
			CD.strStorageLocation,			CD.dblQuantity,										CD.strItemUOM					AS strQuantityUOM,
			CD.dtmPlannedAvailabilityDate,	CD.dblBasis,				CD.strCurrency,			CD.dblCashPrice / 100.0			AS dblUnitCashPrice,	
			CD.strPriceUOM,					CH.dtmContractDate,			CD.dtmStartDate,		CD.dtmEndDate,
			CD.dblNetWeight,				CD.strNetWeightUOM,			VE.strVendorAccountNum,	AE.intEntityId					AS intSubmittedById,
			CH.strTermCode,					CD.strContractItemNo,		CD.strContractItemName,	AE.strName						AS strSubmittedBy,
			CD.strERPItemNumber,			CD.strERPBatchNumber,		CD.intContractStatusId,	ISNULL(AE.strExternalERPId,UE.strExternalERPId)			AS strSubmittedByNo,
			OG.strCountry	AS strOrigin,
			CASE	WHEN	CD.intPricingTypeId = 1 THEN	CD.dblFutures
					WHEN	CD.intPricingTypeId = 6	THEN	CD.dblCashPrice
					ELSE	0
			END	dblCashPrice
			
	FROM	vyuCTContractSequence	CD
	JOIN	vyuCTContractHeaderView	CH	ON	CH.intContractHeaderId		=	CD.intContractHeaderId	LEFT
	JOIN	tblICItem				IM	ON	IM.intItemId				=	CD.intItemId			LEFT
	JOIN	tblICItemUOM			PU	ON	PU.intItemUOMId				=	CD.intPriceItemUOMId	LEFT
	JOIN	tblICUnitMeasure		LB	ON	LB.strUnitMeasure			=	'LB'					LEFT
	JOIN	tblICUnitMeasure		TN	ON	TN.strUnitMeasure			=	'TON'					LEFT
	JOIN	tblICUnitMeasure		KG	ON	KG.strUnitMeasure			=	'KG'					LEFT
	JOIN	tblICCommodityAttribute	CA	ON	CA.intCommodityAttributeId	=	IM.intOriginId			
										AND	CA.strType					=	'Origin'				LEFT
	JOIN	tblICCommodityAttribute	PT	ON	PT.intCommodityAttributeId	=	IM.intProductTypeId			
										AND	PT.strType					=	'ProductType'			LEFT
	JOIN	tblSMCountry			OG	ON	OG.intCountryID				=	CA.intCountryID			LEFT
	JOIN	(
					SELECT * FROM 
					(
						SELECT	ROW_NUMBER() OVER (PARTITION BY TR.intRecordId ORDER BY AP.intApprovalId ASC) intRowNum,
								TR.intRecordId, AP.intSubmittedById 
						FROM	tblSMApproval		AP
						JOIN	tblSMTransaction	TR	ON	TR.intTransactionId =	AP.intTransactionId
						JOIN	tblSMScreen			SC	ON	SC.intScreenId		=	TR.intScreenId
						WHERE	SC.strNamespace IN( 'ContractManagement.view.Contract',
													'ContractManagement.view.Amendments')AND 
								AP.strStatus = 'Submitted'
					) t
					WHERE intRowNum = 1
			) AP ON AP.intRecordId = CD.intContractHeaderId											LEFT
	JOIN	tblEMEntity	AE	ON	AE.intEntityId	=	AP.intSubmittedById
	JOIN	tblEMEntity	UE	ON	UE.intEntityId	=	ISNULL(CH.intLastModifiedById,CH.intCreatedById)LEFT
	JOIN	tblAPVendor	VE	ON	VE.intEntityVendorId	=	CH.intEntityId
