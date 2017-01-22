CREATE VIEW [dbo].[vyuCTNotification]

AS
	SELECT	CAST(ROW_NUMBER() OVER(ORDER BY intContractHeaderId DESC) AS INT) AS intUniqueId,
			*
	FROM 
	(
		SELECT	intContractHeaderId,		intContractSeq,			dtmStartDate,				dtmEndDate,
				dblQuantity,				dblFutures,				dblBasis,					dblCashPrice,
				dblScheduleQty,				dblNoOfLots,			strItemNo,					strPricingType,
				strFutMarketName,			strItemUOM,				strLocationName,			strPriceUOM,
				strCurrency,				strFutureMonth,			strStorageLocation,			strSubLocation,
				strPurchasingGroup,			strCreatedByNo,			strContractNumber,			dtmContractDate,
				strContractType,			strCommodityCode,		strEntityName,
				'Unconfirmed' AS strNotificationType

		FROM	vyuCTContractSequence CD
		WHERE	CD.intContractStatusId = 2
	
		UNION ALL

		SELECT	CH.intContractHeaderId,		intContractSeq,			dtmStartDate,				dtmEndDate,
				dblQuantity,				dblFutures,				dblBasis,					dblCashPrice,
				dblScheduleQty,				dblNoOfLots,			'' AS strItemNo,			strPricingType,
				'' AS strFutMarketName,		'' AS strItemUOM,		'' AS strLocationName,		'' AS strPriceUOM,
				'' AS strCurrency,			'' AS strFutureMonth,	'' AS strStorageLocation,	'' AS strSubLocation,
				'' AS strPurchasingGroup,	'' AS strCreatedByNo,	strContractNumber,			dtmContractDate,
				strContractType,			strCommodityCode,		strEntityName,
				'Empty' AS strNotificationType

		FROM	vyuCTContractHeaderView CH	LEFT
		JOIN	tblCTContractDetail		CD	ON	CD.intContractHeaderId	=	CH.intContractHeaderId
		WHERE	CD.intContractHeaderId IS NULL 
	)t

	
