CREATE PROCEDURE [dbo].[uspCTNotification]
	 @strNotificationType	NVARCHAR(50)
	,@intUserId				INT
	,@ysnCount				BIT				=  0
	,@strStart				NVARCHAR(10)	= '0'
	,@strLimit				NVARCHAR(10)	= '100'
	,@strFilterCriteria		NVARCHAR(MAX)	= ' 1 = 1'
	,@strSortField			NVARCHAR(MAX)	= 'intContractHeaderId'
	,@strSortDirection		NVARCHAR(5)		= 'DESC'
AS

SET NOCOUNT ON

BEGIN TRY

	DECLARE  @SQL		NVARCHAR(MAX)
			,@ErrMsg	NVARCHAR(MAX)

	IF @strFilterCriteria = ''
		SET @strFilterCriteria = ' 1 = 1'
    
	WHILE @strFilterCriteria like '%OR OR%'
	BEGIN
		SET @strFilterCriteria = REPLACE(@strFilterCriteria,'OR OR','OR')
	END

	SELECT @SQL = 'SELECT '+CASE WHEN ISNULL(@ysnCount,0) = 1 THEN 'COUNT(*),strNotificationType' ELSE '*' END +' FROM ( SELECT * FROM ( '

	IF @strNotificationType = 'Unconfirmed'
	BEGIN
		SELECT @SQL += '
			SELECT	CD.intContractHeaderId,			CD.intContractSeq,				CD.dtmStartDate,					CD.dtmEndDate,
					CD.dblQuantity,					CD.dblFutures,					CD.dblBasis,						CD.dblCashPrice,
					CD.dblScheduleQty,				CD.dblNoOfLots,					CD.strItemNo,						CD.strPricingType,
					CD.strFutMarketName,			CD.strItemUOM,					CD.strLocationName,					CD.strPriceUOM,
					CD.strCurrency,					CD.strFutureMonth,				CD.strStorageLocation,				CD.strSubLocation,
					CD.strPurchasingGroup,			CD.strCreatedByNo,				CD.strContractNumber,				CD.dtmContractDate,
					CD.strContractType,				CD.strCommodityCode,			CD.strEntityName,					''Unconfirmed'' AS strNotificationType,
					CD.strItemDescription,			CH.dblQtyInStockUOM,			CD.intContractDetailId,				CD.strProductType,
					dbo.fnCTGetBasisComponentString(CD.intContractDetailId) strBasisComponent,			
													CH.strPosition,					CH.strContractBasis,				CH.strCountry,			
					CH.strCustomerContract,			strSalesperson,					CD.intContractStatusId,				CD.strContractItemName,		
					CD.strContractItemNo,
					CAST(ROW_NUMBER() OVER(ORDER BY CD.intContractHeaderId DESC) AS INT) AS intUniqueId,
					DENSE_RANK() OVER (ORDER BY CD.intContractDetailId DESC) intRankNo					
				

			FROM	vyuCTContractSequence		CD
			JOIN	vyuCTNotificationHeader		CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
	LEFT	JOIN	vyuCTEventRecipientFilter	RF	ON	RF.intEntityId			=	'+LTRIM(@intUserId)+' AND RF.strNotificationType = ''Unconfirmed''  
			WHERE	CD.intContractStatusId = 2 AND CH.intCommodityId = ISNULL(RF.intCommodityId,CH.intCommodityId) '
	END
	ELSE IF @strNotificationType = 'Empty'
	BEGIN
		SELECT @SQL += '
			SELECT	CH.intContractHeaderId,			NULL intContractSeq,			NULL dtmStartDate,					NULL dtmEndDate,
					CH.dblQuantity,					CH.dblFutures,					NULL dblBasis,						NULL dblCashPrice,
					NULL dblScheduleQty,			CH.dblNoOfLots,					NULL strItemNo,						NULL strPricingType,
					NULL strFutMarketName,			UM.strUnitMeasure strItemUOM,	NULL strLocationName,				NULL strPriceUOM,
					NULL strCurrency,				NULL strFutureMonth ,			NULL strStorageLocation,			NULL strSubLocation,
					NULL strPurchasingGroup,		CY.strEntityNo strCreatedByNo,	CH.strContractNumber,				CH.dtmContractDate,
					CT.strContractType,				CO.strCommodityCode,			EY.strName strEntityName,			''Empty'' AS strNotificationType,
					NULL strItemDescription,		dbo.fnCTConvertQuantityToTargetCommodityUOM(CH.intCommodityUOMId,SU.intCommodityUnitMeasureId,CH.dblQuantity) dblQtyInStockUOM,		NULL intContractDetailId,			NULL strProductType,
					NULL strBasisComponent,			PO.strPosition,					CB.strContractBasis,				CR.strCountry,			
					CH.strCustomerContract,			SP.strName strSalesperson,		CD.intContractStatusId,				'''' AS strContractItemName,		
					'''' AS strContractItemNo,
					CAST(ROW_NUMBER() OVER(ORDER BY CH.intContractHeaderId DESC) AS INT) AS intUniqueId,
					DENSE_RANK() OVER (ORDER BY CH.intContractHeaderId DESC) intRankNo	

			FROM	tblCTContractHeader			CH
			JOIN	tblICCommodity				CO	ON	CO.intCommodityId				=	CH.intCommodityId
			JOIN	tblCTPricingType			PT	ON	PT.intPricingTypeId				=	CH.intPricingTypeId
			JOIN	tblEMEntity					EY	ON	EY.intEntityId					=	CH.intEntityId
			JOIN	tblCTContractType			CT	ON	CT.intContractTypeId			=	CH.intContractTypeId
			JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityUnitMeasureId	=	CH.intCommodityUOMId
			JOIN	tblICUnitMeasure			UM	ON	UM.intUnitMeasureId				=	CU.intUnitMeasureId
			JOIN	tblICCommodityUnitMeasure	SU	ON	SU.intCommodityId				=	CH.intCommodityId
													AND	SU.ysnStockUnit					=	1						
	LEFT	JOIN	tblCTContractBasis			CB	ON	CB.intContractBasisId			=	CH.intContractBasisId
	LEFT	JOIN	tblCTPosition				PO	ON	PO.intPositionId				=	CH.intPositionId	
	LEFT	JOIN	tblEMEntity					SP	ON	SP.intEntityId					=	CH.intSalespersonId	
	LEFT	JOIN	tblSMCountry				CR	ON	CR.intCountryID					=	CH.intCountryId		
	LEFT	JOIN	tblEMEntity					CY	ON	CY.intEntityId					=	CH.intCreatedById		
	LEFT	JOIN	tblCTContractDetail			CD	ON CD.intContractHeaderId			=	CH.intContractHeaderId
	LEFT	JOIN	vyuCTEventRecipientFilter	RF	ON	RF.intEntityId					=	'+LTRIM(@intUserId)+' AND RF.strNotificationType = ''Empty''  
			WHERE intContractDetailId IS NULL AND CH.intCommodityId = ISNULL(RF.intCommodityId,CH.intCommodityId)'
	END
	ELSE IF @strNotificationType = 'Unsigned'
	BEGIN
		SELECT @SQL += '
			SELECT	CH.intContractHeaderId,			CH.intContractSeq,			CH.dtmStartDate,				CH.dtmEndDate,
					CH.dblQuantity,					CH.dblFutures,				CH.dblBasis,					CH.dblCashPrice,
					CH.dblScheduleQty,				CH.dblNoOfLots,				CH.strItemNo,					CH.strPricingType,
					CH.strFutMarketName,			CH.strItemUOM,				CH.strLocationName,				CH.strPriceUOM,
					CH.strCurrency,					CH.strFutureMonth,			CH.strStorageLocation,			CH.strSubLocation,
					CH.strPurchasingGroup,			CH.strCreatedByNo,			CH.strContractNumber,			CH.dtmContractDate,
					CH.strContractType,				CH.strCommodityCode,		CH.strEntityName,				''Unsigned'' AS strNotificationType,
					CH.strItemDescription,			CH.dblQtyInStockUOM,		CH.intContractDetailId,			CH.strProductType,
					CH.strBasisComponent,			CH.strPosition,				CH.strContractBasis,			CH.strCountry,			
					CH.strCustomerContract,			strSalesperson,				CH.intContractStatusId,			CH.strContractItemName,		
					CH.strContractItemNo,
					CAST(ROW_NUMBER() OVER(ORDER BY CH.intContractHeaderId DESC) AS INT) AS intUniqueId,
					DENSE_RANK() OVER (ORDER BY CH.intContractHeaderId DESC) intRankNo

			FROM	vyuCTNotificationHeader		CH
	LEFT	JOIN	vyuCTEventRecipientFilter	RF	ON	RF.intEntityId			=	'+LTRIM(@intUserId)+' AND RF.strNotificationType = ''Unsigned'' 
			WHERE	ISNULL(ysnSigned,0) = 0 AND CH.intContractDetailId IS NOT NULL AND CH.intCommodityId = ISNULL(RF.intCommodityId,CH.intCommodityId)'
	END
	ELSE IF @strNotificationType = 'Unsubmitted'
	BEGIN
		SELECT @SQL += '	
			SELECT	CH.intContractHeaderId,			CH.intContractSeq,			CH.dtmStartDate,				CH.dtmEndDate,
					CH.dblQuantity,					CH.dblFutures,				CH.dblBasis,					CH.dblCashPrice,
					CH.dblScheduleQty,				CH.dblNoOfLots,				CH.strItemNo,					CH.strPricingType,
					CH.strFutMarketName,			CH.strItemUOM,				CH.strLocationName,				CH.strPriceUOM,
					CH.strCurrency,					CH.strFutureMonth,			CH.strStorageLocation,			CH.strSubLocation,
					CH.strPurchasingGroup,			CH.strCreatedByNo,			CH.strContractNumber,			CH.dtmContractDate,
					CH.strContractType,				CH.strCommodityCode,		CH.strEntityName,				''Unsubmitted'' AS strNotificationType,
					CH.strItemDescription,			CH.dblQtyInStockUOM,		CH.intContractDetailId,			CH.strProductType,
					CH.strBasisComponent,			CH.strPosition,				CH.strContractBasis,			CH.strCountry,			
					CH.strCustomerContract,			strSalesperson,				CH.intContractStatusId,			CH.strContractItemName,		
					CH.strContractItemNo,
					CAST(ROW_NUMBER() OVER(ORDER BY CH.intContractHeaderId DESC) AS INT) AS intUniqueId,
					DENSE_RANK() OVER (ORDER BY CH.intContractHeaderId DESC) intRankNo	

			FROM	vyuCTNotificationHeader CH
	LEFT	JOIN	vyuCTEventRecipientFilter	RF	ON	RF.intEntityId			=	'+LTRIM(@intUserId)+' AND RF.strNotificationType = ''Unsubmitted'' 
			WHERE	CH.strContractNumber NOT IN(SELECT strTransactionNumber FROM tblSMApproval WHERE strStatus=''Submitted'')  AND 4 <> intAllStatusId & 4
			AND		intContractDetailId IS NOT NULL'
	END
	ELSE IF @strNotificationType = 'Approved Not Sent'
	BEGIN
		SELECT @SQL += '		
			SELECT	CH.intContractHeaderId,			CH.intContractSeq,			CH.dtmStartDate,				CH.dtmEndDate,
					CH.dblQuantity,					CH.dblFutures,				CH.dblBasis,					CH.dblCashPrice,
					CH.dblScheduleQty,				CH.dblNoOfLots,				CH.strItemNo,					CH.strPricingType,
					CH.strFutMarketName,			CH.strItemUOM,				CH.strLocationName,				CH.strPriceUOM,
					CH.strCurrency,					CH.strFutureMonth,			CH.strStorageLocation,			CH.strSubLocation,
					CH.strPurchasingGroup,			CH.strCreatedByNo,			CH.strContractNumber,			CH.dtmContractDate,
					CH.strContractType,				CH.strCommodityCode,		CH.strEntityName,				''Approved Not Sent'' AS strNotificationType,
					CH.strItemDescription,			CH.dblQtyInStockUOM,		CH.intContractDetailId,			CH.strProductType,
					CH.strBasisComponent,			CH.strPosition,				CH.strContractBasis,			CH.strCountry,			
					CH.strCustomerContract,			strSalesperson,				CH.intContractStatusId,			CH.strContractItemName,		
					CH.strContractItemNo,
					CAST(ROW_NUMBER() OVER(ORDER BY CH.intContractHeaderId DESC) AS INT) AS intUniqueId,
					DENSE_RANK() OVER (ORDER BY CH.intContractHeaderId DESC) intRankNo		

			FROM	vyuCTNotificationHeader CH
			JOIN	tblSMTransaction		TN	ON	TN.intRecordId		=	CH.intContractHeaderId 
												AND ysnMailSent			=	0 
												AND TN.ysnOnceApproved	=	1 
												AND 2 = intAllStatusId & 2
			JOIN	tblSMScreen				SN	ON	SN.intScreenId		=	TN.intScreenId 
												AND SN.strNamespace IN (''ContractManagement.view.Contract'', ''ContractManagement.view.Amendments'')
	LEFT	JOIN	vyuCTEventRecipientFilter	RF	ON	RF.intEntityId			=	'+LTRIM(@intUserId)+' AND RF.strNotificationType = ''Approved Not Sent'' 
												'
	END

	SELECT @SQL = @SQL + ')t WHERE ISNULL(intContractStatusId,1) <> 3  AND '+@strFilterCriteria+' )d'
	
	IF ISNULL(@ysnCount,0) = 0
	BEGIN
		SELECT @SQL = @SQL +
			' WHERE intRankNo > ' + @strStart +
			' AND intRankNo <= ' + @strStart + '+' + @strLimit + 
			' ORDER BY [' + @strSortField + '] ' + @strSortDirection
	END
	ELSE
	BEGIN
		SELECT @SQL = @SQL + ' GROUP BY strNotificationType'
	END

	--SELECT @SQL
	EXEC sp_executesql @SQL

END TRY

BEGIN CATCH       
	SET @ErrMsg = ERROR_MESSAGE()      
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH