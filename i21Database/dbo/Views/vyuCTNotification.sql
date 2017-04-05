﻿CREATE VIEW [dbo].[vyuCTNotification]

AS
	WITH Header AS
	(
		SELECT	CH.intContractHeaderId,	CH.dtmContractDate,		CT.strContractType,		CO.strCommodityCode,	CH.strContractNumber,
				CB.strContractBasis,	PO.strPosition,			CR.strCountry,			CH.strCustomerContract,	CH.dblQuantity			AS	dblHdrQuantity,		
				PT.strPricingType		AS	strHdrPricingType,	
				UM.strUnitMeasure		AS	strHdrUOM,	
				EY.strName				AS	strEntityName,		
				ISNULL(ysnSigned,0)		AS	ysnSigned,
				ISNULL(ysnMailSent,0)	AS	ysnMailSent,		
				CY.strEntityNo			AS	strCreatedByNo,	
				SP.strName				AS	strSalesperson,
				dbo.fnCTConvertQuantityToTargetCommodityUOM(CH.intCommodityUOMId,SU.intCommodityUnitMeasureId,CH.dblQuantity) dblQtyInStockUOM,

				CD.intCurrencyId,		CD.intBookId,			CD.intSubBookId,		CD.intCompanyLocationId, 
				CD.intContractSeq,		CD.dtmStartDate,		CD.dtmEndDate,			CD.strPurchasingGroup,
				CD.dblQuantity,			CD.dblFutures,			CD.dblBasis,			CD.dblCashPrice,
				CD.dblScheduleQty,		CD.dblNoOfLots,			CD.strItemNo,			CD.strPricingType,
				CD.strFutMarketName,	CD.strItemUOM,			CD.strLocationName,		CD.strPriceUOM,
				CD.strCurrency,			CD.strFutureMonth,		CD.strStorageLocation,	CD.strSubLocation,
				CD.strItemDescription,	CD.intContractDetailId,	CD.strProductType,		
				dbo.fnCTGetBasisComponentString(CD.intContractDetailId) strBasisComponent,
				CD.intContractStatusId
				
		FROM	tblCTContractHeader			CH
		JOIN	tblICCommodity				CO	ON	CO.intCommodityId				=	CH.intCommodityId
		JOIN	tblCTPricingType			PT	ON	PT.intPricingTypeId				=	CH.intPricingTypeId
		JOIN	tblEMEntity					EY	ON	EY.intEntityId					=	CH.intEntityId
		JOIN	tblCTContractType			CT	ON	CT.intContractTypeId			=	CH.intContractTypeId
		JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityUnitMeasureId	=	CH.intCommodityUOMId
		JOIN	tblICUnitMeasure			UM	ON	UM.intUnitMeasureId				=	CU.intUnitMeasureId
		JOIN	tblICCommodityUnitMeasure	SU	ON	SU.intCommodityId				=	CH.intCommodityId
												AND	SU.ysnStockUnit					=	1						LEFT
		JOIN	tblCTContractBasis			CB	ON	CB.intContractBasisId			=	CH.intContractBasisId	LEFT
		JOIN	tblCTPosition				PO	ON	PO.intPositionId				=	CH.intPositionId		LEFT
		JOIN	tblEMEntity					SP	ON	SP.intEntityId					=	CH.intSalespersonId		LEFT
		JOIN	tblSMCountry				CR	ON	CR.intCountryID					=	CH.intCountryId			LEFT
		JOIN	tblEMEntity					CY	ON	CY.intEntityId					=	CH.intCreatedById		OUTER
		APPLY	dbo.fnCTGetTopOneSequence(CH.intContractHeaderId,0) CD
	)

	SELECT	CAST(ROW_NUMBER() OVER(ORDER BY intContractHeaderId DESC) AS INT) AS intUniqueId,
			*
	FROM 
	(
		SELECT	CD.intContractHeaderId,			CD.intContractSeq,				CD.dtmStartDate,					CD.dtmEndDate,
				CD.dblQuantity,					CD.dblFutures,					CD.dblBasis,						CD.dblCashPrice,
				CD.dblScheduleQty,				CD.dblNoOfLots,					CD.strItemNo,						CD.strPricingType,
				CD.strFutMarketName,			CD.strItemUOM,					CD.strLocationName,					CD.strPriceUOM,
				CD.strCurrency,					CD.strFutureMonth,				CD.strStorageLocation,				CD.strSubLocation,
				CD.strPurchasingGroup,			CD.strCreatedByNo,				CD.strContractNumber,				CD.dtmContractDate,
				CD.strContractType,				CD.strCommodityCode,			CD.strEntityName,					'Unconfirmed' AS strNotificationType,
				CD.strItemDescription,			CH.dblQtyInStockUOM,			CD.intContractDetailId,				CD.strProductType,
				dbo.fnCTGetBasisComponentString(CD.intContractDetailId) strBasisComponent,			
												CH.strPosition,					CH.strContractBasis,				CH.strCountry,			
				CH.strCustomerContract,			strSalesperson,					CD.intContractStatusId					
				

		FROM	vyuCTContractSequence	CD
		JOIN	Header					CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
		WHERE	CD.intContractStatusId = 2
	
		UNION ALL

		SELECT	CH.intContractHeaderId,			CH.intContractSeq,			CH.dtmStartDate,				CH.dtmEndDate,
				CH.dblHdrQuantity,				CH.dblFutures,				CH.dblBasis,					CH.dblCashPrice,
				CH.dblScheduleQty,				CH.dblNoOfLots,				CH.strItemNo,					CH.strPricingType,
				CH.strFutMarketName,			CH.strHdrUOM,				CH.strLocationName,				CH.strPriceUOM,
				CH.strCurrency,					CH.strFutureMonth,			CH.strStorageLocation,			CH.strSubLocation,
				CH.strPurchasingGroup,			CH.strCreatedByNo,			CH.strContractNumber,			CH.dtmContractDate,
				CH.strContractType,				CH.strCommodityCode,		CH.strEntityName,				'Empty' AS strNotificationType,
				CH.strItemDescription,			CH.dblQtyInStockUOM,		CH.intContractDetailId,			CH.strProductType,
				CH.strBasisComponent,			CH.strPosition,				CH.strContractBasis,			CH.strCountry,			
				CH.strCustomerContract,			strSalesperson,				CD.intContractStatusId

		FROM Header CH
		LEFT JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId 
		WHERE CD.intContractDetailId IS NULL

		UNION ALL

		SELECT	CH.intContractHeaderId,			CH.intContractSeq,			CH.dtmStartDate,				CH.dtmEndDate,
				CH.dblQuantity,					CH.dblFutures,				CH.dblBasis,					CH.dblCashPrice,
				CH.dblScheduleQty,				CH.dblNoOfLots,				CH.strItemNo,					CH.strPricingType,
				CH.strFutMarketName,			CH.strItemUOM,				CH.strLocationName,				CH.strPriceUOM,
				CH.strCurrency,					CH.strFutureMonth,			CH.strStorageLocation,			CH.strSubLocation,
				CH.strPurchasingGroup,			CH.strCreatedByNo,			CH.strContractNumber,			CH.dtmContractDate,
				CH.strContractType,				CH.strCommodityCode,		CH.strEntityName,				'Unsigned' AS strNotificationType,
				CH.strItemDescription,			CH.dblQtyInStockUOM,		CH.intContractDetailId,			CH.strProductType,
				CH.strBasisComponent,			CH.strPosition,				CH.strContractBasis,			CH.strCountry,			
				CH.strCustomerContract,			strSalesperson,				CH.intContractStatusId

		FROM Header CH
		WHERE ISNULL(ysnSigned,0) = 0 

		UNION ALL

		SELECT	CH.intContractHeaderId,			CH.intContractSeq,			CH.dtmStartDate,				CH.dtmEndDate,
				CH.dblQuantity,					CH.dblFutures,				CH.dblBasis,					CH.dblCashPrice,
				CH.dblScheduleQty,				CH.dblNoOfLots,				CH.strItemNo,					CH.strPricingType,
				CH.strFutMarketName,			CH.strItemUOM,				CH.strLocationName,				CH.strPriceUOM,
				CH.strCurrency,					CH.strFutureMonth,			CH.strStorageLocation,			CH.strSubLocation,
				CH.strPurchasingGroup,			CH.strCreatedByNo,			CH.strContractNumber,			CH.dtmContractDate,
				CH.strContractType,				CH.strCommodityCode,		CH.strEntityName,				'Unsubmitted' AS strNotificationType,
				CH.strItemDescription,			CH.dblQtyInStockUOM,		CH.intContractDetailId,			CH.strProductType,
				CH.strBasisComponent,			CH.strPosition,				CH.strContractBasis,			CH.strCountry,			
				CH.strCustomerContract,			strSalesperson,				CH.intContractStatusId	

		FROM	Header CH
		WHERE	CH.strContractNumber NOT IN(SELECT strTransactionNumber FROM tblSMApproval WHERE strStatus='Submitted')
		AND		CH.intContractHeaderId	NOT IN (SELECT intContractDetailId FROM tblCTContractDetail WHERE intContractStatusId = 2)
		UNION ALL

		SELECT	CH.intContractHeaderId,			CH.intContractSeq,			CH.dtmStartDate,				CH.dtmEndDate,
				CH.dblQuantity,					CH.dblFutures,				CH.dblBasis,					CH.dblCashPrice,
				CH.dblScheduleQty,				CH.dblNoOfLots,				CH.strItemNo,					CH.strPricingType,
				CH.strFutMarketName,			CH.strItemUOM,				CH.strLocationName,				CH.strPriceUOM,
				CH.strCurrency,					CH.strFutureMonth,			CH.strStorageLocation,			CH.strSubLocation,
				CH.strPurchasingGroup,			CH.strCreatedByNo,			CH.strContractNumber,			CH.dtmContractDate,
				CH.strContractType,				CH.strCommodityCode,		CH.strEntityName,				'Approved Not Sent' AS strNotificationType,
				CH.strItemDescription,			CH.dblQtyInStockUOM,		CH.intContractDetailId,			CH.strProductType,
				CH.strBasisComponent,			CH.strPosition,				CH.strContractBasis,			CH.strCountry,			
				CH.strCustomerContract,			strSalesperson,				CH.intContractStatusId	

		FROM	Header CH
		JOIN	tblSMTransaction	TN	ON	TN.intRecordId	=	CH.intContractHeaderId
		JOIN	tblSMScreen			SN	ON	SN.intScreenId	=	TN.intScreenId AND SN.strNamespace IN ('ContractManagement.view.Contract', 'ContractManagement.view.Amendments')
		WHERE	ysnMailSent = 0 AND TN.ysnOnceApproved = 1

	)t

	WHERE intContractStatusId <> 3
