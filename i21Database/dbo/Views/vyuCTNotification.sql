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

		SELECT	CH.intContractHeaderId,		NULL AS intContractSeq,	 NULL AS dtmStartDate,		NULL AS dtmEndDate,
				CH.dblQuantity,		NULL AS dblFutures,		 NULL AS dblBasis,			NULL AS dblCashPrice,
				NULL AS dblScheduleQty,		NULL AS  dblNoOfLots,	 '' AS strItemNo,			PT.strPricingType,
				'' AS strFutMarketName,		UOM.strUnitMeasure AS strItemUOM,		'' AS strLocationName,		'' AS strPriceUOM,
				'' AS strCurrency,			'' AS strFutureMonth,	'' AS strStorageLocation,	'' AS strSubLocation,
				'' AS strPurchasingGroup,	'' AS strCreatedByNo,	strContractNumber,			CH.dtmContractDate,
				CT.strContractType,			COM.strCommodityCode,	E.strName strEntityName,
				'Empty' AS strNotificationType

		FROM tblCTContractHeader CH
		LEFT JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId  
		JOIN tblICCommodity COM ON COM.intCommodityId=CH.intCommodityId
		JOIN tblCTPricingType PT ON PT.intPricingTypeId=CH.intPricingTypeId
		JOIN tblEMEntity E ON E.intEntityId=CH.intEntityId
		JOIN tblCTContractType CT ON CT.intContractTypeId=CH.intContractTypeId
		JOIN tblICCommodityUnitMeasure CUOM ON CUOM.intCommodityUnitMeasureId=CH.intCommodityUOMId
		JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId=CUOM.intUnitMeasureId
		WHERE CD.intContractDetailId IS NULL

		UNION ALL

		SELECT	CH.intContractHeaderId,		NULL AS intContractSeq,			 NULL AS dtmStartDate,		  NULL AS dtmEndDate,
				CH.dblQuantity,				NULL AS dblFutures,				 NULL AS dblBasis,			  NULL AS dblCashPrice,
				NULL AS dblScheduleQty,		NULL AS dblNoOfLots,			 '' AS strItemNo,			  PT.strPricingType,
				'' AS strFutMarketName,		UOM.strUnitMeasure AS strItemUOM,		'' AS strLocationName,		'' AS strPriceUOM,
				'' AS strCurrency,			'' AS strFutureMonth,			 '' AS strStorageLocation,	  '' AS strSubLocation,
				'' AS strPurchasingGroup,	'' AS strCreatedByNo,			strContractNumber,			  CH.dtmContractDate,
				 CT.strContractType,		COM.strCommodityCode,			E.strName AS strEntityName,
				'Unsigned' AS strNotificationType

		FROM tblCTContractHeader CH
		JOIN tblICCommodity COM ON COM.intCommodityId=CH.intCommodityId
		JOIN tblCTPricingType PT ON PT.intPricingTypeId=CH.intPricingTypeId
		JOIN tblEMEntity E ON E.intEntityId=CH.intEntityId
		JOIN tblCTContractType CT ON CT.intContractTypeId=CH.intContractTypeId
		JOIN tblICCommodityUnitMeasure CUOM ON CUOM.intCommodityUnitMeasureId=CH.intCommodityUOMId
		JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId=CUOM.intUnitMeasureId
		WHERE ISNULL(ysnSigned,0) = 0 

		UNION ALL

		SELECT	CH.intContractHeaderId,		NULL AS intContractSeq,			 NULL AS dtmStartDate,		  NULL AS dtmEndDate,
				CH.dblQuantity,				NULL AS dblFutures,				 NULL AS dblBasis,			  NULL AS dblCashPrice,
				NULL AS dblScheduleQty,		NULL AS dblNoOfLots,			 '' AS strItemNo,			  PT.strPricingType,
				'' AS strFutMarketName,		UOM.strUnitMeasure AS strItemUOM,		'' AS strLocationName,		'' AS strPriceUOM,
				'' AS strCurrency,			'' AS strFutureMonth,			 '' AS strStorageLocation,	  '' AS strSubLocation,
				'' AS strPurchasingGroup,	'' AS strCreatedByNo,			strContractNumber,			  CH.dtmContractDate,
				 CT.strContractType,		COM.strCommodityCode,			E.strName AS strEntityName,
				'Unsubmitted' AS strNotificationType

		FROM tblCTContractHeader CH
		JOIN tblICCommodity COM ON COM.intCommodityId=CH.intCommodityId
		JOIN tblCTPricingType PT ON PT.intPricingTypeId=CH.intPricingTypeId
		JOIN tblEMEntity E ON E.intEntityId=CH.intEntityId
		JOIN tblCTContractType CT ON CT.intContractTypeId=CH.intContractTypeId
		JOIN tblICCommodityUnitMeasure CUOM ON CUOM.intCommodityUnitMeasureId=CH.intCommodityUOMId
		JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId=CUOM.intUnitMeasureId
		WHERE CH.strContractNumber NOT IN(SELECT strTransactionNumber FROM tblSMApproval WHERE strStatus='Submitted')
		AND   CH.intContractHeaderId   IN(SELECT intContractHeaderId FROM tblCTContractDetail WHERE strERPPONumber IS NULL)

	)t

	
