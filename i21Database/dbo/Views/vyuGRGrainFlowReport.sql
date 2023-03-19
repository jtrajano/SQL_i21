CREATE VIEW [dbo].[vyuGRGrainFlowReport]
AS
--DELIVERED
--CONTRACTS and SPOT
SELECT 
	strCommodityCode		= ICRI.strCommodityCode
	,dtmReceiptDate			= FORMAT(ICRI.dtmReceiptDate,'MM/yyyy')
	,dblDelivered 			= dbo.fnCTConvertQuantityToTargetCommodityUOM(CO_UOM_FROM.intCommodityUnitMeasureId,CO_UOM_TO.intCommodityUnitMeasureId,SC.dblNetUnits)
	,dblDirect 				= NULL
	,dblFromStorage 		= NULL
	,dblUnpricedReceipts 	= NULL
	,dblAllSales 			= NULL
	,dblBuyBasis			= ISNULL(ICRI.dblBasis,SC.dblUnitBasis)
	,dblSellBasis			= NULL
	,strFuturesMonth		= ISNULL(REPLACE(ICRI.strFuturesMonth, ' ',''),REPLACE(FM.strFutureMonth, ' ',''))
FROM tblSCTicket SC 
INNER JOIN tblICInventoryReceipt ICR ON SC.intInventoryReceiptId = ICR.intInventoryReceiptId
INNER JOIN vyuICGetInventoryReceiptItem ICRI ON SC.strTicketNumber = ICRI.strSourceNumber 
	AND SC.intInventoryReceiptId = ICRI.intInventoryReceiptId
LEFT JOIN (
	tblCTContractDetail CD
	INNER JOIN tblRKFuturesMonth FM
		ON FM.intFutureMonthId = CD.intFutureMonthId
	)	
	ON CD.intContractDetailId = ICRI.intOrderId
		AND CD.intContractSeq = ICRI.intContractSeq
INNER JOIN tblICItemUOM UOM 
	ON UOM.intItemUOMId = SC.intItemUOMIdTo
INNER JOIN tblICCommodityUnitMeasure CO_UOM_FROM
	ON CO_UOM_FROM.intCommodityId = ICRI.intCommodityId
		AND CO_UOM_FROM.intUnitMeasureId = UOM.intUnitMeasureId
INNER JOIN tblICCommodityUnitMeasure CO_UOM_TO
	ON CO_UOM_TO.intCommodityId = ICRI.intCommodityId
		AND CO_UOM_TO.ysnStockUnit = 1
INNER JOIN tblGRStorageType ST
	ON ST.intStorageScheduleTypeId = SC.intStorageScheduleTypeId
		AND ST.intStorageScheduleTypeId < 0
UNION ALL
--DIRECT
--DIRECT IN
SELECT 
	strCommodityCode		= IC.strCommodityCode
	,dtmReceiptDate			= FORMAT(SL.dtmTransactionDate,'MM/yyyy')
	,dblDelivered 			= NULL
	,dblDirect 				= dbo.fnCTConvertQuantityToTargetCommodityUOM(CO_UOM_FROM.intCommodityUnitMeasureId,CO_UOM_TO.intCommodityUnitMeasureId,SL.dblOrigQty)
	,dblFromStorage 		= NULL
	,dblUnpricedReceipts 	= NULL
	,dblAllSales 			= NULL
	,dblBuyBasis			= ISNULL(CD.dblBasis,SC.dblUnitBasis)
	,dblSellBasis			= NULL
	,strFuturesMonth		= REPLACE(FM.strFutureMonth, ' ','')
FROM tblRKSummaryLog SL
INNER JOIN tblSCTicket SC
	ON SC.intTicketId = SL.intTransactionRecordHeaderId
INNER JOIN tblICCommodity IC
	ON IC.intCommodityId = SL.intCommodityId
LEFT JOIN (
	tblCTContractDetail CD
	INNER JOIN tblRKFuturesMonth FM
		ON FM.intFutureMonthId = CD.intFutureMonthId
	)	
	ON CD.intContractDetailId = SL.intContractDetailId
INNER JOIN tblICCommodityUnitMeasure CO_UOM_FROM
	ON CO_UOM_FROM.intCommodityUnitMeasureId = SL.intOrigUOMId
LEFT JOIN tblICCommodityUnitMeasure CO_UOM_TO
	ON CO_UOM_TO.intCommodityId = SL.intCommodityId
		AND CO_UOM_TO.ysnStockUnit = 1
WHERE SL.strTransactionType = 'Direct In'
UNION ALL
--FROM STORAGE
--SETTLEMENTS
SELECT 
	strCommodityCode		= CO.strCommodityCode
	,dtmReceiptDate			= FORMAT(SS.dtmCreated,'MM/yyyy')
	,dblDelivered 			= NULL
	,dblDirect 				= NULL
	,dblFromStorage 		= dbo.fnCTConvertQuantityToTargetCommodityUOM(CO_UOM_FROM.intCommodityUnitMeasureId,CO_UOM_TO.intCommodityUnitMeasureId,ISNULL(SC.dblUnits,SS.dblSpotUnits))
	,dblUnpricedReceipts 	= NULL
	,dblAllSales 			= NULL
	,dblBuyBasis			= ISNULL(CD.dblBasis,SS.dblFuturesBasis)
	,dblSellBasis			= NULL
	,strFuturesMonth		= REPLACE(FM.strFutureMonth, ' ','')
FROM tblGRSettleStorage SS
INNER JOIN tblICCommodity CO
	ON CO.intCommodityId = SS.intCommodityId
INNER JOIN tblSMCompanyLocation CL
	ON CL.intCompanyLocationId = SS.intCompanyLocationId
LEFT JOIN (
	tblGRSettleContract SC
	INNER JOIN tblCTContractDetail CD
		ON CD.intContractDetailId = SC.intContractDetailId
	INNER JOIN tblRKFuturesMonth FM
		ON FM.intFutureMonthId = CD.intFutureMonthId
	)
	ON SC.intSettleStorageId = SS.intSettleStorageId
INNER JOIN tblICItemUOM UOM 
	ON UOM.intItemUOMId = SS.intItemUOMId
INNER JOIN tblICCommodityUnitMeasure CO_UOM_FROM
	ON CO_UOM_FROM.intCommodityId = SS.intCommodityId
		AND CO_UOM_FROM.intUnitMeasureId = UOM.intUnitMeasureId
INNER JOIN tblICCommodityUnitMeasure CO_UOM_TO
	ON CO_UOM_TO.intCommodityId = SS.intCommodityId
		AND CO_UOM_TO.ysnStockUnit = 1
WHERE SS.intParentSettleStorageId IS NOT NULL
UNION ALL
--1.1 unpriced receipts, customer storage
SELECT 
	strCommodityCode		= CO.strCommodityCode
	,dtmReceiptDate			= FORMAT(CS.dtmDeliveryDate,'MM/yyyy')
	,dblDelivered 			= NULL
	,dblDirect 				= NULL
	,dblFromStorage 		= NULL
	,dblUnpricedReceipts 	= dbo.fnCTConvertQuantityToTargetCommodityUOM(CO_UOM_FROM.intCommodityUnitMeasureId,CO_UOM_TO.intCommodityUnitMeasureId,CS.dblOpenBalance)
	,dblAllSales 			= NULL
	,dblBuyBasis			= NULL
	,dblSellBasis			= NULL
	,strFuturesMonth		= NULL
FROM tblGRCustomerStorage CS
INNER JOIN tblICCommodity CO
	ON CO.intCommodityId = CS.intCommodityId
INNER JOIN tblSMCompanyLocation CL
	ON CL.intCompanyLocationId = CS.intCompanyLocationId
INNER JOIN tblICItemUOM UOM 
	ON UOM.intItemUOMId = CS.intItemUOMId
INNER JOIN tblICCommodityUnitMeasure CO_UOM_FROM
	ON CO_UOM_FROM.intCommodityId = CS.intCommodityId
		AND CO_UOM_FROM.intUnitMeasureId = UOM.intUnitMeasureId
INNER JOIN tblICCommodityUnitMeasure CO_UOM_TO
	ON CO_UOM_TO.intCommodityId = CS.intCommodityId
		AND CO_UOM_TO.ysnStockUnit = 1
WHERE CS.dblOpenBalance > 0
UNION ALL
--1.2 unpriced receipts, hold
SELECT 
	strCommodityCode		= IC.strCommodityCode
	,dtmReceiptDate			= FORMAT(SL.dtmTransactionDate,'MM/yyyy')
	,dblDelivered 			= NULL
	,dblDirect 				= NULL
	,dblFromStorage 		= NULL
	,dblUnpricedReceipts 	= dbo.fnCTConvertQuantityToTargetCommodityUOM(CO_UOM_FROM.intCommodityUnitMeasureId,CO_UOM_TO.intCommodityUnitMeasureId,SL.dblOrigQty)
	,dblAllSales 			= NULL
	,dblBuyBasis			= ISNULL(CD.dblBasis,SC.dblUnitBasis)
	,dblSellBasis			= NULL
	,strFuturesMonth		= NULL
FROM tblRKSummaryLog SL
INNER JOIN tblSCTicket SC
	ON SC.intTicketId = SL.intTransactionRecordHeaderId
INNER JOIN tblICCommodity IC
	ON IC.intCommodityId = SL.intCommodityId
LEFT JOIN (
	tblCTContractDetail CD
	INNER JOIN tblRKFuturesMonth FM
		ON FM.intFutureMonthId = CD.intFutureMonthId
	)	
	ON CD.intContractDetailId = SL.intContractDetailId
INNER JOIN tblICCommodityUnitMeasure CO_UOM_FROM
	ON CO_UOM_FROM.intCommodityUnitMeasureId = SL.intOrigUOMId
LEFT JOIN tblICCommodityUnitMeasure CO_UOM_TO
	ON CO_UOM_TO.intCommodityId = SL.intCommodityId
		AND CO_UOM_TO.ysnStockUnit = 1
WHERE SL.strDistributionType = 'Hold'
UNION ALL
--all sales
SELECT
	strCommodityCode		= ICSI.strCommodityCode
	,dtmReceiptDate			= FORMAT(ICSI.dtmShipDate,'MM/yyyy')
	--,ICRI.strLocationName
	--,dblDelivered = SUM(SC.dblNetUnits)
	,dblDelivered 			= NULL
	,dblDirect 				= NULL
	,dblFromStorage 		= NULL
	,dblUnpricedReceipts 	= NULL
	,dblAllSales 			= dbo.fnCTConvertQuantityToTargetCommodityUOM(CO_UOM_FROM.intCommodityUnitMeasureId,CO_UOM_TO.intCommodityUnitMeasureId,SC.dblNetUnits)
	,dblBuyBasis			= NULL
	,dblSellBasis			= CASE WHEN ISNULL(ICSI.dblBasis,0) = 0 THEN CD.dblBasis ELSE ICSI.dblBasis END
	,strFuturesMonth		= ISNULL(REPLACE(ICSI.strFuturesMonth, ' ',''),REPLACE(FM.strFutureMonth, ' ',''))
FROM tblSCTicket SC  
INNER JOIN vyuICGetInventoryShipmentItem ICSI
	ON SC.intTicketId = ICSI.intSourceId
	AND SC.intItemId = ICSI.intItemId
	AND ICSI.strSourceType = 'Scale'
LEFT JOIN (
	tblCTContractDetail CD
	INNER JOIN tblRKFuturesMonth FM
		ON FM.intFutureMonthId = CD.intFutureMonthId
	)	
	ON CD.intContractDetailId = ICSI.intOrderId
		AND CD.intContractSeq = ICSI.intContractSeq
INNER JOIN tblICItemUOM UOM 
	ON UOM.intItemUOMId = SC.intItemUOMIdTo
INNER JOIN tblICCommodityUnitMeasure CO_UOM_FROM
	ON CO_UOM_FROM.intCommodityId = ICSI.intCommodityId
		AND CO_UOM_FROM.intUnitMeasureId = UOM.intUnitMeasureId
INNER JOIN tblICCommodityUnitMeasure CO_UOM_TO
	ON CO_UOM_TO.intCommodityId = ICSI.intCommodityId
		AND CO_UOM_TO.ysnStockUnit = 1
UNION ALL
--all sales
--DIRECT OUT
SELECT
	strCommodityCode		= CO.strCommodityCode
	,dtmReceiptDate			= FORMAT(SC.dtmTicketDateTime,'MM/yyyy')
	,dblDelivered 			= NULL
	,dblDirect 				= NULL
	,dblFromStorage 		= NULL
	,dblUnpricedReceipts 	= NULL
	,dblAllSales 			= dbo.fnCTConvertQuantityToTargetCommodityUOM(CO_UOM_FROM.intCommodityUnitMeasureId,CO_UOM_TO.intCommodityUnitMeasureId,SC.dblNetUnits)
	,dblBuyBasis			= NULL
	,dblSellBasis			= CASE WHEN ISNULL(CD.dblBasis,0) = 0 THEN SC.dblUnitBasis ELSE CD.dblBasis END
	,strFuturesMonth		= REPLACE(FM.strFutureMonth, ' ','')
FROM tblSCTicket SC
LEFT JOIN (
	tblCTContractDetail CD
	INNER JOIN tblRKFuturesMonth FM
		ON FM.intFutureMonthId = CD.intFutureMonthId
	)	
	ON CD.intContractDetailId = SC.intContractId
INNER JOIN tblICCommodity CO
	ON CO.intCommodityId = SC.intCommodityId
INNER JOIN tblICItemUOM UOM 
	ON UOM.intItemUOMId = SC.intItemUOMIdTo
INNER JOIN tblICCommodityUnitMeasure CO_UOM_FROM
	ON CO_UOM_FROM.intCommodityId = SC.intCommodityId
		AND CO_UOM_FROM.intUnitMeasureId = UOM.intUnitMeasureId
INNER JOIN tblICCommodityUnitMeasure CO_UOM_TO
	ON CO_UOM_TO.intCommodityId = SC.intCommodityId
		AND CO_UOM_TO.ysnStockUnit = 1
WHERE SC.intTicketType = 6
	AND SC.strInOutFlag = 'O'
	AND SC.strTicketStatus NOT IN ('O','V')