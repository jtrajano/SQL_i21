﻿CREATE VIEW [dbo].[vyuRKSearchDPRSummaryLog]

AS

SELECT intRowNumber  = row_number() OVER(ORDER BY dtmCreatedDate DESC), * FROM (
	select 
		dtmTransactionDate
		,dtmCreatedDate
		,strCommodityCode
		,strBucketType
		,strTransactionType
		,strTransactionNumber
		,strContractNumber
		,intContractSeq
		,strContractType
		,dblTransactionQty = dblOrigQty
		,strTransactionUOM = origUM.strUnitMeasure
		,dblStockQty = CAST(dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,stckUOM.intCommodityUnitMeasureId, dblOrigQty) AS NUMERIC(38, 15))
		,strStockUOM = stckUM.strUnitMeasure
		,strLocationName
		,strEntityName
		,SL.intCommodityId
		,intTransactionRecordId
		,intTransactionRecordHeaderId
		,intContractHeaderId
		,intContractDetailId
		,intEntityId
		,intLocationId
		,intUserId
		,strUserName 
		,strAction
		,strNotes
	from vyuRKGetSummaryLog SL
	left join tblICCommodityUnitMeasure stckUOM on stckUOM.intCommodityId = SL.intCommodityId AND stckUOM.ysnDefault = 1 AND stckUOM.ysnStockUnit = 1
	left join tblICCommodityUnitMeasure origUOM on origUOM.intCommodityUnitMeasureId = SL.intOrigUOMId
	left join tblICUnitMeasure stckUM on stckUM.intUnitMeasureId = stckUOM.intUnitMeasureId
	left join tblICUnitMeasure origUM on origUM.intUnitMeasureId = origUOM.intUnitMeasureId
	where strBucketType not in ('Derivatives', 'Collateral', 'Accounts Payables')


	union all
	SELECT dtmTransactionDate
		,dtmCreatedDate
		,strCommodityCode
		,strBucketType = 'Net Futures'
		,strTransactionType
		,strTransactionNumber
		,strContractNumber
		,intContractSeq
		,strContractType
		,dblTransactionQty 
		,strTransactionUOM 
		,dblStockQty 
		,strStockUOM 
		,strLocationName
		,strEntityName
		,intCommodityId
		,intTransactionRecordId
		,intTransactionRecordHeaderId
		,intContractHeaderId
		,intContractDetailId
		,intEntityId
		,intLocationId
		,intUserId
		,strUserName 
		,strAction
		,strNotes
	FROM (
		SELECT --intRowNum = ROW_NUMBER() OVER (PARTITION BY SL.intTransactionRecordId ORDER BY SL.intSummaryLogId DESC),
				dtmTransactionDate
				,dtmCreatedDate
				,strCommodityCode
				,strBucketType
				,strTransactionType
				,strTransactionNumber
				,strContractNumber
				,intContractSeq
				,strContractType
				,dblTransactionQty = dblOrigQty
				,strTransactionUOM = origUM.strUnitMeasure
				,dblStockQty = CAST(dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,stckUOM.intCommodityUnitMeasureId, dblOrigQty) AS NUMERIC(38, 15))
				,strStockUOM = stckUM.strUnitMeasure
				,strLocationName
				,strEntityName
				,SL.intCommodityId
				,intTransactionRecordId
				,intTransactionRecordHeaderId
				,intContractHeaderId
				,intContractDetailId
				,intEntityId
				,intLocationId
				,intUserId
				,strUserName 
				,strAction
				,strNotes
		FROM vyuRKGetSummaryLog SL
		left join tblICCommodityUnitMeasure stckUOM on stckUOM.intCommodityId = SL.intCommodityId AND stckUOM.ysnDefault = 1 AND stckUOM.ysnStockUnit = 1
		left join tblICCommodityUnitMeasure origUOM on origUOM.intCommodityUnitMeasureId = SL.intOrigUOMId
		left join tblICUnitMeasure stckUM on stckUM.intUnitMeasureId = stckUOM.intUnitMeasureId
		left join tblICUnitMeasure origUM on origUM.intUnitMeasureId = origUOM.intUnitMeasureId
		WHERE strTransactionType IN ('Derivative Entry')
		AND ISNULL(ysnPreCrush, 0) = 0

		UNION ALL

		SELECT --intRowNum = ROW_NUMBER() OVER (PARTITION BY SL.intTransactionRecordId ORDER BY SL.intSummaryLogId DESC), 
					dtmTransactionDate
				,dtmCreatedDate
				,strCommodityCode
				,strBucketType
				,strTransactionType
				,strTransactionNumber
				,strContractNumber
				,intContractSeq
				,strContractType
				,dblTransactionQty = (dblOrigNoOfLots * dblContractSize)
				,strTransactionUOM = origUM.strUnitMeasure
				,dblStockQty = CAST(dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,stckUOM.intCommodityUnitMeasureId, (dblOrigNoOfLots  * dblContractSize)) AS NUMERIC(38, 15))
				,strStockUOM = stckUM.strUnitMeasure
				,strLocationName
				,strEntityName
				,SL.intCommodityId
				,intTransactionRecordId
				,intTransactionRecordHeaderId
				,intContractHeaderId
				,intContractDetailId
				,intEntityId
				,intLocationId
				,intUserId
				,strUserName 
				,strAction
				,strNotes
			FROM vyuRKGetSummaryLog SL
			left join tblICCommodityUnitMeasure stckUOM on stckUOM.intCommodityId = SL.intCommodityId AND stckUOM.ysnDefault = 1 AND stckUOM.ysnStockUnit = 1
			left join tblICCommodityUnitMeasure origUOM on origUOM.intCommodityUnitMeasureId = SL.intOrigUOMId
			left join tblICUnitMeasure stckUM on stckUM.intUnitMeasureId = stckUOM.intUnitMeasureId
			left join tblICUnitMeasure origUM on origUM.intUnitMeasureId = origUOM.intUnitMeasureId
			WHERE strTransactionType IN ('Match Derivatives')
			AND ISNULL(ysnPreCrush, 0) = 0

	) t

	union all
	SELECT  dtmTransactionDate
		,dtmCreatedDate
		,strCommodityCode
		,strBucketType = 'Crush'
		,strTransactionType
		,strTransactionNumber
		,strContractNumber
		,intContractSeq
		,strContractType
		,dblTransactionQty 
		,strTransactionUOM 
		,dblStockQty 
		,strStockUOM 
		,strLocationName
		,strEntityName
		,intCommodityId
		,intTransactionRecordId
		,intTransactionRecordHeaderId
		,intContractHeaderId
		,intContractDetailId
		,intEntityId
		,intLocationId
		,intUserId
		,strUserName 
		,strAction 
		,strNotes
	FROM  (
		SELECT  --intRowNum = ROW_NUMBER() OVER (PARTITION BY SL.intTransactionRecordId ORDER BY SL.intSummaryLogId DESC),
					dtmTransactionDate
				,dtmCreatedDate
				,strCommodityCode
				,strBucketType
				,strTransactionType
				,strTransactionNumber
				,strContractNumber
				,intContractSeq
				,strContractType
				,dblTransactionQty = (dblOrigNoOfLots * dblContractSize)
				,strTransactionUOM = origUM.strUnitMeasure
				,dblStockQty = CAST(dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,stckUOM.intCommodityUnitMeasureId, (dblOrigNoOfLots * dblContractSize)) AS NUMERIC(38, 15))
				,strStockUOM = stckUM.strUnitMeasure
				,strLocationName
				,strEntityName
				,SL.intCommodityId
				,intTransactionRecordId
				,intTransactionRecordHeaderId
				,intContractHeaderId
				,intContractDetailId
				,intEntityId
				,intLocationId
				,intUserId
				,strUserName 
				,strAction
				,strNotes
			FROM vyuRKGetSummaryLog SL
			left join tblICCommodityUnitMeasure stckUOM on stckUOM.intCommodityId = SL.intCommodityId AND stckUOM.ysnDefault = 1 AND stckUOM.ysnStockUnit = 1
			left join tblICCommodityUnitMeasure origUOM on origUOM.intCommodityUnitMeasureId = SL.intOrigUOMId
			left join tblICUnitMeasure stckUM on stckUM.intUnitMeasureId = stckUOM.intUnitMeasureId
			left join tblICUnitMeasure origUM on origUM.intUnitMeasureId = origUOM.intUnitMeasureId
			WHERE strTransactionType IN ('Derivative Entry')
			AND ISNULL(ysnPreCrush, 0) = 1
			
		UNION ALL
		SELECT --intRowNum = ROW_NUMBER() OVER (PARTITION BY SL.intTransactionRecordId ORDER BY SL.intSummaryLogId DESC), 
					dtmTransactionDate
				,dtmCreatedDate
				,strCommodityCode
				,strBucketType
				,strTransactionType
				,strTransactionNumber
				,strContractNumber
				,intContractSeq
				,strContractType
				,dblTransactionQty = (dblOrigNoOfLots * dblContractSize)
				,strTransactionUOM = origUM.strUnitMeasure
				,dblStockQty = CAST(dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,stckUOM.intCommodityUnitMeasureId, (dblOrigNoOfLots  * dblContractSize)) AS NUMERIC(38, 15))
				,strStockUOM = stckUM.strUnitMeasure
				,strLocationName
				,strEntityName
				,SL.intCommodityId
				,intTransactionRecordId
				,intTransactionRecordHeaderId
				,intContractHeaderId
				,intContractDetailId
				,intEntityId
				,intLocationId
				,intUserId
				,strUserName 
				,strAction
				,strNotes
			FROM vyuRKGetSummaryLog SL
			left join tblICCommodityUnitMeasure stckUOM on stckUOM.intCommodityId = SL.intCommodityId AND stckUOM.ysnDefault = 1 AND stckUOM.ysnStockUnit = 1
			left join tblICCommodityUnitMeasure origUOM on origUOM.intCommodityUnitMeasureId = SL.intOrigUOMId
			left join tblICUnitMeasure stckUM on stckUM.intUnitMeasureId = stckUOM.intUnitMeasureId
			left join tblICUnitMeasure origUM on origUM.intUnitMeasureId = origUOM.intUnitMeasureId
			WHERE strTransactionType IN ('Match Derivatives')
			AND ISNULL(ysnPreCrush, 0) = 1
		) t 


	union all
	select 
		dtmTransactionDate = dtmOpenDate
		,dtmCreatedDate
		,strCommodityCode
		,strBucketType = 'Collateral'
		,strTransactionType  
		,strTransactionNumber = strReceiptNo
		,strContractNumber
		,intContractSeq
		,strContractType = NULL
		,dblTransactionQty = dblTotal
		,strTransactionUOM = origUM.strUnitMeasure
		,dblStockQty = CAST(dbo.fnCTConvertQuantityToTargetCommodityUOM(C.intCommodityUnitMeasureId,stckUOM.intCommodityUnitMeasureId, dblTotal) AS NUMERIC(38, 15))
		,strStockUOM = stckUM.strUnitMeasure
		,strLocationName
		,strEntityName = ''
		,C.intCommodityId
		,intTransactionRecordId = intCollateralId
		,intTransactionRecordHeaderId = intCollateralId
		,intContractHeaderId 
		,intContractDetailId 
		,intEntityId
		,intLocationId
		,intUserId
		,strUserName 
		,strAction
		,strNotes
	from dbo.fnRKGetBucketCollateral(getdate(),NULL,NULL) C
	left join tblICCommodityUnitMeasure stckUOM on stckUOM.intCommodityId = C.intCommodityId AND stckUOM.ysnDefault = 1 AND stckUOM.ysnStockUnit = 1
	left join tblICCommodityUnitMeasure origUOM on origUOM.intCommodityUnitMeasureId = C.intCommodityUnitMeasureId
	left join tblICUnitMeasure stckUM on stckUM.intUnitMeasureId = stckUOM.intUnitMeasureId
	left join tblICUnitMeasure origUM on origUM.intUnitMeasureId = origUOM.intUnitMeasureId

	union all
	select 
		dtmTransactionDate
		,dtmCreateDate
		,strCommodityCode
		,strBucketType = (strContractType + ' ' + strPricingType) COLLATE Latin1_General_CI_AS
		,strTransactionType = strTransactionReference
		,strTransactionNumber = strTransactionReferenceNo
		,strContractNumber
		,intContractSeq
		,strContractType
		,dblTransactionQty = dblQty 
		,strTransactionUOM = origUM.strUnitMeasure
		,dblStockQty = CAST(dbo.fnCTConvertQuantityToTargetCommodityUOM(CB.intQtyUOMId,stckUOM.intCommodityUnitMeasureId, dblQty) AS NUMERIC(38, 15))
		,strStockUOM = stckUM.strUnitMeasure
		,strLocationName
		,strEntityName 
		,CB.intCommodityId
		,intTransactionRecordId = intTransactionReferenceDetailId
		,intTransactionRecordHeaderId = intTransactionReferenceId
		,intContractHeaderId
		,intContractDetailId
		,intEntityId
		,intLocationId
		,intUserId
		,strUserName
		,strAction
		,strNotes
	from dbo.fnRKGetBucketContractBalance(getdate(),null,null) CB
	left join tblICCommodityUnitMeasure stckUOM on stckUOM.intCommodityId = CB.intCommodityId AND stckUOM.ysnDefault = 1 AND stckUOM.ysnStockUnit = 1
	left join tblICCommodityUnitMeasure origUOM on origUOM.intCommodityUnitMeasureId = CB.intQtyUOMId
	left join tblICUnitMeasure stckUM on stckUM.intUnitMeasureId = stckUOM.intUnitMeasureId
	left join tblICUnitMeasure origUM on origUM.intUnitMeasureId = origUOM.intUnitMeasureId

	union all
	select
		dtmTransactionDate
		,dtmCreateDate
		,strCommodityCode
		,strBucketType = strTransactionType
		,strTransactionType = strTransactionReference
		,strTransactionNumber = strTransactionReferenceNo
		,strContractNumber
		,intContractSeq
		,strContractType
		,dblTransactionQty = dblQty 
		,strTransactionUOM = origUM.strUnitMeasure
		,dblStockQty = CAST(dbo.fnCTConvertQuantityToTargetCommodityUOM(SD.intQtyUOMId,stckUOM.intCommodityUnitMeasureId, dblQty) AS NUMERIC(38, 15))
		,strStockUOM = stckUM.strUnitMeasure
		,strLocationName
		,strEntityName 
		,SD.intCommodityId
		,intTransactionRecordId = intTransactionReferenceDetailId
		,intTransactionRecordHeaderId = intTransactionReferenceId
		,intContractHeaderId
		,intContractDetailId 
		,intEntityId
		,intLocationId
		,intUserId
		,strUserName 
		,strAction
		,strNotes
	from dbo.fnRKGetBucketBasisDeliveries(getdate(),null,null) SD
	left join tblICCommodityUnitMeasure stckUOM on stckUOM.intCommodityId = SD.intCommodityId AND stckUOM.ysnDefault = 1 AND stckUOM.ysnStockUnit = 1
	left join tblICCommodityUnitMeasure origUOM on origUOM.intCommodityUnitMeasureId = SD.intQtyUOMId
	left join tblICUnitMeasure stckUM on stckUM.intUnitMeasureId = stckUOM.intUnitMeasureId
	left join tblICUnitMeasure origUM on origUM.intUnitMeasureId = origUOM.intUnitMeasureId
)t