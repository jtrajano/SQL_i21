CREATE VIEW [dbo].[vyuGRGrainFlowReport]
AS
SELECT 
	strCommodityCode
	,dtmReceiptDate
	,dblDelivered = SUM(dblDelivered)
	,dblDirect = SUM(dblDirect)
	,dblFromStorage = SUM(dblFromStorage)
	,dblUnpricedReceipts = SUM(dblUnpricedReceipts)
	,dblAllSales = SUM(dblAllSales)
	,dblBasis = AVG(dblBasis)
	,dblFutures = AVG(dblFutures)
	,strFuturesMonth
FROM (
--delivered
SELECT 
	ICRI.strCommodityCode
	,ICRI.dtmReceiptDate
	--,ICRI.strLocationName
	--,dblDelivered = SUM(SC.dblNetUnits)
	,dblDelivered = SC.dblNetUnits
	,dblDirect = 0
	,dblFromStorage = 0
	,dblUnpricedReceipts = 0
	,dblAllSales = 0
	,ICRI.dblBasis
	,ICRI.dblFutures
	,ICRI.strFuturesMonth
FROM tblSCTicket SC 
INNER JOIN tblICInventoryReceipt ICR ON SC.intInventoryReceiptId = ICR.intInventoryReceiptId
INNER JOIN vyuICGetInventoryReceiptItem ICRI ON SC.strTicketNumber = ICRI.strSourceNumber 
	AND SC.intInventoryReceiptId = ICRI.intInventoryReceiptId
WHERE ICRI.strReceiptType = 'Purchase Contract'
--GROUP BY ICRI.strCommodityCode
--	,ICRI.dtmReceiptDate
--	--,ICRI.strLocationName
--	,ICRI.dblBasis
--	,ICRI.dblFutures
--	,ICRI.strFuturesMonth
UNION ALL
--direct
SELECT 
	CO.strCommodityCode
	,dbo.fnRemoveTimeOnDate(SC.dtmDateCreatedUtc)
	--,CL.strLocationName
	,0
	,SC.dblNetUnits
	,0
	,0
	,0
	,ISNULL(CD.dblBasis,0)
	,ISNULL(CD.dblFutures,0)
	,ISNULL(REPLACE(FM.strFutureMonth, ' ',''),'')
FROM tblSCTicket SC
INNER JOIN tblICCommodity CO
	ON CO.intCommodityId = SC.intCommodityId
INNER JOIN tblSMCompanyLocation CL
	ON CL.intCompanyLocationId = SC.intCompanyId
INNER JOIN tblCTContractDetail CD
	ON CD.intContractDetailId = SC.intContractId
INNER JOIN tblRKFuturesMonth FM
	ON FM.intFutureMonthId = CD.intFutureMonthId
WHERE SC.intTicketType = 6
--GROUP BY CO.strCommodityCode
--	,dbo.fnRemoveTimeOnDate(SC.dtmDateCreatedUtc)
--	--,CL.strLocationName
--	,CD.dblBasis
--	,CD.dblFutures
--	,REPLACE(FM.strFutureMonth, ' ','')
UNION ALL
--from storage
SELECT 
	CO.strCommodityCode
	,dbo.fnRemoveTimeOnDate(SS.dtmCreated)
	--,CL.strLocationName
	,0
	,0
	,SC.dblUnits
	,0
	,0
	,ISNULL(CD.dblBasis,0)
	,ISNULL(CD.dblFutures,0)
	,ISNULL(REPLACE(FM.strFutureMonth, ' ',''),'')
FROM tblGRSettleStorage SS
INNER JOIN tblICCommodity CO
	ON CO.intCommodityId = SS.intCommodityId
INNER JOIN tblSMCompanyLocation CL
	ON CL.intCompanyLocationId = SS.intCompanyLocationId
INNER JOIN tblGRSettleContract SC
	ON SC.intSettleStorageId = SS.intSettleStorageId
INNER JOIN tblCTContractDetail CD
	ON CD.intContractDetailId = SC.intContractDetailId
INNER JOIN tblRKFuturesMonth FM
	ON FM.intFutureMonthId = CD.intFutureMonthId
WHERE SS.intParentSettleStorageId IS NOT NULL
--GROUP BY CO.strCommodityCode
--	,dbo.fnRemoveTimeOnDate(SS.dtmCreated)
--	--,CL.strLocationName
--	,CD.dblBasis
--	,CD.dblFutures
--	,REPLACE(FM.strFutureMonth, ' ','')
UNION ALL
--1.1 unpriced receipts, customer storage
SELECT 
	CO.strCommodityCode
	,dbo.fnRemoveTimeOnDate(CS.dtmDeliveryDate)
	--,CL.strLocationName
	,0
	,0
	,0
	,CS.dblOpenBalance
	,0
	,0
	,0
	,''
FROM tblGRCustomerStorage CS
INNER JOIN tblICCommodity CO
	ON CO.intCommodityId = CS.intCommodityId
INNER JOIN tblSMCompanyLocation CL
	ON CL.intCompanyLocationId = CS.intCompanyLocationId
WHERE dblOpenBalance > 0
--GROUP BY CO.strCommodityCode
--	,CS.dtmDeliveryDate
--	--,CL.strLocationName
UNION ALL
--1.2 unpriced receipts, hold
SELECT 
	CO.strCommodityCode
	,dbo.fnRemoveTimeOnDate(SC.dtmDateCreatedUtc)
	--,CL.strLocationName
	,0
	,0
	,0
	,SC.dblNetUnits
	,0
	,0
	,0
	,''
FROM tblSCTicket SC
INNER JOIN tblICCommodity CO
	ON CO.intCommodityId = SC.intCommodityId
INNER JOIN tblSMCompanyLocation CL
	ON CL.intCompanyLocationId = SC.intCompanyId
INNER JOIN tblCTContractDetail CD
	ON CD.intContractDetailId = SC.intContractId
INNER JOIN tblRKFuturesMonth FM
	ON FM.intFutureMonthId = CD.intFutureMonthId
WHERE SC.strDistributionOption = 'HLD'
--GROUP BY CO.strCommodityCode
--	,SC.dtmDateCreatedUtc
--	--,CL.strLocationName
UNION ALL
--all sales
SELECT
	ICSI.strCommodityCode
	,dbo.fnRemoveTimeOnDate(ICSI.dtmShipDate)
	--,ICSI.strShipFromLocation
	,0
	,0
	,0
	,0
	,SC.dblNetUnits
	,ISNULL(ICSI.dblBasis,0)
	,ISNULL(ICSI.dblFutures,0)
	,ISNULL(ICSI.strFuturesMonth,'')
FROM tblSCTicket SC  
INNER JOIN vyuICGetInventoryShipmentItem ICSI
	ON SC.intTicketId = ICSI.intSourceId
	AND SC.intItemId = ICSI.intItemId
	AND ICSI.strSourceType = 'Scale'
WHERE SC.strDistributionOption = 'Contract'
--GROUP BY ICSI.strCommodityCode
--	,dbo.fnRemoveTimeOnDate(ICSI.dtmShipDate)
--	--,ICSI.strShipFromLocation
--	,ICSI.dblBasis
--	,ICSI.dblFutures
--	,ICSI.strFuturesMonth
) A
GROUP BY strCommodityCode
	,dtmReceiptDate
	,strFuturesMonth