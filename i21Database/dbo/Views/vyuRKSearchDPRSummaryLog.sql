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
		,strContractSeq
		,dblTransactionQty = dblOrigQty
		,strTransactionUOM = origUM.strUnitMeasure
		,dblStockQty = dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,stckUOM.intCommodityUnitMeasureId, dblOrigQty)
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
		,strAction = 'Created ' + strTransactionType
	from vyuRKGetSummaryLog SL
	left join tblICCommodityUnitMeasure stckUOM on stckUOM.intCommodityId = SL.intCommodityId AND stckUOM.ysnDefault = 1 AND stckUOM.ysnStockUnit = 1
	left join tblICCommodityUnitMeasure origUOM on origUOM.intCommodityUnitMeasureId = SL.intOrigUOMId
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
		,strContractNumber = strContractNumber + '-' + CONVERT(NVARCHAR(10),intContractSeq)
		,dblTransactionQty = dblQty 
		,strTransactionUOM = origUM.strUnitMeasure
		,dblStockQty = dbo.fnCTConvertQuantityToTargetCommodityUOM(CB.intQtyUOMId,stckUOM.intCommodityUnitMeasureId, dblQty)
		,strStockUOM = stckUM.strUnitMeasure
		,strLocationName
		,strEntityName 
		,CB.intCommodityId
		,intTransactionRecordId = intTransactionReferenceId
		,intTransactionRecordHeaderId = intTransactionReferenceId
		,intContractHeaderId
		,intContractDetailId
		,intEntityId
		,intLocationId
		,intUserId
		,strUserName
		,strAction = 'Created ' + strTransactionReference
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
		,strContractNumber = strContractNumber + '-' + CONVERT(NVARCHAR(10),intContractSeq)
		,dblTransactionQty = dblQty 
		,strTransactionUOM = origUM.strUnitMeasure
		,dblStockQty = dbo.fnCTConvertQtyToTargetItemUOM(SD.intQtyUOMId ,stckUOM.intItemUOMId, dblQty)
		,strStockUOM = stckUM.strUnitMeasure
		,strLocationName
		,strEntityName 
		,SD.intCommodityId
		,intTransactionRecordId = intTransactionReferenceId
		,intTransactionRecordHeaderId = intTransactionReferenceId
		,intContractHeaderId
		,intContractDetailId 
		,intEntityId
		,intLocationId
		,intUserId
		,strUserName 
		,strAction = CASE WHEN strTransactionReference = 'Inventory Shipment' THEN 
							'Shipped a Basis Delivery'
						WHEN strTransactionReference = 'Invoice' THEN
							'Created an Invoice'
						WHEN strTransactionReference = 'Inventory Receipt' THEN
							'Received a Basis Delivery'
						WHEN strTransactionReference = 'Voucher' THEN
							'Created a Voucher'
					END
	from dbo.fnRKGetBucketBasisDeliveries(getdate(),null,null) SD
	left join tblICItemUOM stckUOM on stckUOM.intItemId = SD.intItemId AND stckUOM.ysnStockUnit = 1
	left join tblICItemUOM origUOM ON origUOM.intItemUOMId = SD.intQtyUOMId
	left join tblICUnitMeasure stckUM on stckUM.intUnitMeasureId = stckUOM.intUnitMeasureId
	left join tblICUnitMeasure origUM on origUM.intUnitMeasureId = origUOM.intUnitMeasureId
)t