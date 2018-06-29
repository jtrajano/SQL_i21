CREATE VIEW [dbo].[vyuCTNotification]

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
				CD.strItemDescription,	CD.intContractDetailId,	CD.strProductType,		PW.intAllStatusId,
				BC.strBasisComponent,
				CD.intContractStatusId,	CD.strContractItemName,	CD.strContractItemNo
				
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
		JOIN	tblEMEntity					CY	ON	CY.intEntityId					=	CH.intCreatedById		LEFT
		JOIN	
		(
				SElECT * FROM
				(
					SELECT	intCurrencyId,					intBookId,					intSubBookId,					intCompanyLocationId, 
							intContractSeq,					dtmStartDate,				dtmEndDate,						strPurchasingGroup,
							dblQuantity,					dblFutures,					dblBasis,						dblCashPrice,
							dblScheduleQty,					dblNoOfLots,				strItemNo,						strPricingType,
							strFutMarketName,				strItemUOM,					strLocationName,				strPriceUOM,
							strCurrency,					strFutureMonth,				strStorageLocation,				strSubLocation,
							strItemDescription,				intContractDetailId,		strProductType,					ysnSubCurrency,
							intContractStatusId,			strContractItemName,		strContractItemNo,				intContractHeaderId,
							ROW_NUMBER() OVER (PARTITION BY intContractHeaderId ORDER BY intContractDetailId ASC) intRowNum
					FROM	vyuCTContractSequence 
					WHERE	ISNULL(intContractStatusId,1) NOT IN (3,5)
				)t	WHERE intRowNum = 1			

		)									CD	ON	CD.intContractHeaderId			=	CH.intContractHeaderId	LEFT
		JOIN
		(
				SELECT intContractDetailId, strBasisComponent = STUFF((
				SELECT ', ' + strItemNo + ' = ' + dbo.fnRemoveTrailingZeroes(dblRate) FROM vyuCTContractCostView
				WHERE intContractDetailId = x.intContractDetailId
				FOR XML PATH(''), TYPE).value('.[1]', 'nvarchar(max)'), 1, 2, '')
				FROM vyuCTContractCostView AS x
				GROUP BY intContractDetailId
		)									BC	ON	BC.intContractDetailId			=	CD.intContractDetailId	LEFT
		JOIN 
		(
				SELECT intContractHeaderId
				,SUM(POWER(2, intContractStatusId )) intAllStatusId
				FROM 
				(
					SELECT DISTINCT intContractHeaderId
					,intContractStatusId
					FROM tblCTContractDetail
				 ) t
				GROUP BY intContractHeaderId
		)									PW	ON	PW.intContractHeaderId			=	CD.intContractHeaderId
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
				CH.strCustomerContract,			strSalesperson,					CD.intContractStatusId,				CD.strContractItemName,		
				CD.strContractItemNo					
				

		FROM	vyuCTContractSequence	CD
		JOIN	Header					CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
		WHERE	CD.intContractStatusId = 2
	
		UNION ALL

		SELECT	CH.intContractHeaderId,			NULL,							NULL,								NULL,
				CH.dblQuantity,					CH.dblFutures,					NULL,								NULL,
				NULL,							CH.dblNoOfLots,					NULL,								NULL,
				NULL,							UM.strUnitMeasure,				NULL,								NULL,
				NULL,							NULL,							NULL,								NULL,
				NULL,							CY.strEntityNo,					CH.strContractNumber,				CH.dtmContractDate,
				CT.strContractType,				CO.strCommodityCode,			EY.strName,							'Empty' AS strNotificationType,
				NULL,							dbo.fnCTConvertQuantityToTargetCommodityUOM(CH.intCommodityUOMId,SU.intCommodityUnitMeasureId,CH.dblQuantity) dblQtyInStockUOM,		NULL,			NULL,
				NULL,							PO.strPosition,					CB.strContractBasis,				CR.strCountry,			
				CH.strCustomerContract,			SP.strName,						CD.intContractStatusId,				'' AS strContractItemName,		
				'' AS strContractItemNo

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
		JOIN	tblEMEntity					CY	ON	CY.intEntityId					=	CH.intCreatedById		LEFT
		JOIN	tblCTContractDetail			CD	ON CD.intContractHeaderId = CH.intContractHeaderId
		WHERE intContractDetailId IS NULL

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
				CH.strCustomerContract,			strSalesperson,				CH.intContractStatusId,			CH.strContractItemName,		
				CH.strContractItemNo

		FROM Header CH
		WHERE ISNULL(ysnSigned,0) = 0 AND CH.intContractDetailId IS NOT NULL

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
				CH.strCustomerContract,			strSalesperson,				CH.intContractStatusId,			CH.strContractItemName,		
				CH.strContractItemNo	

		FROM	Header CH
		WHERE	CH.strContractNumber NOT IN(SELECT strTransactionNumber FROM tblSMApproval WHERE strStatus='Submitted')  AND 4 <> intAllStatusId & 4
		--AND		CH.intContractHeaderId	NOT IN (SELECT intContractHeaderId FROM tblCTContractDetail WHERE intContractStatusId = 2)
		AND		intContractDetailId IS NOT NULL

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
				CH.strCustomerContract,			strSalesperson,				CH.intContractStatusId,			CH.strContractItemName,		
				CH.strContractItemNo	

		FROM	Header CH
		JOIN	tblSMTransaction	TN	ON	TN.intRecordId	=	CH.intContractHeaderId AND ysnMailSent = 0 AND TN.ysnOnceApproved = 1 AND 2 = intAllStatusId & 2
		JOIN	tblSMScreen			SN	ON	SN.intScreenId	=	TN.intScreenId AND SN.strNamespace IN ('ContractManagement.view.Contract', 'ContractManagement.view.Amendments')
		--WHERE	CH.intContractHeaderId IN (SELECT intContractHeaderId FROM tblCTContractDetail WHERE intContractStatusId = 1)

	)t

	WHERE ISNULL(intContractStatusId,1) <> 3
