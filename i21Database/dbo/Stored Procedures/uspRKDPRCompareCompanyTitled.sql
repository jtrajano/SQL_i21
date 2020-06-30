CREATE PROCEDURE uspRKDPRCompareCompanyTitled
	@intDPRRun1 INT 
	,@intDPRRun2 INT
AS

BEGIN
	
DECLARE @strBucketType NVARCHAR(100) = 'Company Titled'
		,@strCommodityCode NVARCHAR(100)
		,@dtmRunDateTime1 DATETIME
		,@dtmRunDateTime2 DATETIME
		,@dtmDPRDate1 DATETIME
		,@dtmDPRDate2 DATETIME
		,@strEntityName NVARCHAR(150)
		,@strLocationName NVARCHAR(150)

SELECT TOP 1 
	@strCommodityCode = strCommodityCode
	,@dtmRunDateTime1 = dtmRunDateTime
	,@dtmDPRDate1 = dtmDPRDate
FROM tblRKDPRRunLogDetail LD
INNER JOIN tblRKDPRRunLog L ON L.intDPRRunLogId = LD.intDPRRunLogId
WHERE intRunNumber = @intDPRRun1

SELECT TOP 1 
	@dtmRunDateTime2 = dtmRunDateTime
	,@dtmDPRDate2 = dtmDPRDate
FROM tblRKDPRRunLogDetail LD
INNER JOIN tblRKDPRRunLog L ON L.intDPRRunLogId = LD.intDPRRunLogId
WHERE intRunNumber = @intDPRRun2

SELECT LD.*
INTO #FirstRun
FROM tblRKDPRRunLogDetail LD
INNER JOIN tblRKDPRRunLog L ON L.intDPRRunLogId = LD.intDPRRunLogId
WHERE intRunNumber = @intDPRRun1 and strType = @strBucketType


SELECT LD.*
INTO #SecondRun
FROM tblRKDPRRunLogDetail LD
INNER JOIN tblRKDPRRunLog L ON L.intDPRRunLogId = LD.intDPRRunLogId
WHERE intRunNumber = @intDPRRun2 and strType = @strBucketType


SELECT * INTO #tempFirstToSecond FROM (
	select strTransactionReferenceId, intTransactionReferenceId, intTransactionReferenceDetailId, strTranType, dblTotal, strEntityName, strLocationName from #FirstRun
	except
	select strTransactionReferenceId,  intTransactionReferenceId, intTransactionReferenceDetailId, strTranType, dblTotal, strEntityName, strLocationName from #SecondRun
)t

SELECT * INTO #tempSecondToFirst FROM (
	select strTransactionReferenceId,  intTransactionReferenceId, intTransactionReferenceDetailId, strTranType, dblTotal, strEntityName, strLocationName from #SecondRun
	except
	select strTransactionReferenceId,  intTransactionReferenceId, intTransactionReferenceDetailId, strTranType, dblTotal, strEntityName, strLocationName from #FirstRun
) t



SELECT F.* 
,dblShipReceiveQty = COALESCE(receiptItem.dblReceived,shipmentItem.dblQuantity)
,dtmShipReceiptDate = COALESCE(receipt.dtmReceiptDate,shipment.dtmShipDate)
,dtmContractDate = CH.dtmContractDate
,strContractNumber = CH.strContractNumber+'-'+CAST(CD.intContractSeq as varchar)
,CH.intContractHeaderId
,strHeaderPricing = ptCH.strPricingType
,strSeqPricing = ptCD.strPricingType
,strTicketNumber = COALESCE(receiptItemSource.strSourceNumber,shipmentItemSource.strSourceNumber)
,intTicketId = COALESCE(receiptItem.intSourceId,shipmentItem.intSourceId)
INTO #tempFinalFirstRun
FROM #tempFirstToSecond F
LEFT JOIN tblICInventoryReceiptItem receiptItem 
	ON receiptItem.intInventoryReceiptId = F.intTransactionReferenceId
	AND receiptItem.intInventoryReceiptItemId = F.intTransactionReferenceDetailId
	AND F.strTranType = 'Inventory Receipt' 
LEFT JOIN vyuICGetReceiptItemSource receiptItemSource
	ON receiptItemSource.intInventoryReceiptItemId = receiptItem.intInventoryReceiptItemId
	--AND F.strTranType = 'Inventory Receipt' 
LEFT JOIN tblICInventoryReceipt receipt 
	ON receipt.intInventoryReceiptId = receiptItem.intInventoryReceiptId   
LEFT JOIN tblICInventoryShipmentItem shipmentItem 
	ON shipmentItem.intInventoryShipmentId = F.intTransactionReferenceId
	AND shipmentItem.intInventoryShipmentItemId = F.intTransactionReferenceDetailId
	AND F.strTranType = 'Inventory Shipment'
LEFT JOIN vyuICGetShipmentItemSource shipmentItemSource
	ON shipmentItemSource.intInventoryShipmentItemId = shipmentItem.intInventoryShipmentItemId
	--AND F.strTranType = 'Inventory Shipment'
LEFT JOIN tblICInventoryShipment shipment 
	ON shipment.intInventoryShipmentId = shipmentItem.intInventoryShipmentId   
LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId  = COALESCE(receiptItem.intLineNo,shipmentItem.intLineNo)
LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
LEFT JOIN tblCTPricingType ptCH on ptCH.intPricingTypeId = CH.intPricingTypeId
LEFT JOIN tblCTPricingType ptCD on ptCD.intPricingTypeId = CD.intPricingTypeId


SELECT S.* 
,dblShipReceiveQty = COALESCE(receiptItem.dblReceived,shipmentItem.dblQuantity)
,dtmShipReceiptDate = COALESCE(receipt.dtmReceiptDate,shipment.dtmShipDate)
,dtmContractDate = CH.dtmContractDate
,strContractNumber = CH.strContractNumber+'-'+CAST(CD.intContractSeq as varchar)
,CH.intContractHeaderId
,strHeaderPricing = ptCH.strPricingType
,strSeqPricing = ptCD.strPricingType
,strTicketNumber = COALESCE(receiptItemSource.strSourceNumber,shipmentItemSource.strSourceNumber)
,intTicketId = COALESCE(receiptItem.intSourceId,shipmentItem.intSourceId)
INTO #tempFinalSecondRun
FROM #tempSecondToFirst S
LEFT JOIN tblICInventoryReceiptItem receiptItem 
	ON receiptItem.intInventoryReceiptId = S.intTransactionReferenceId
	AND receiptItem.intInventoryReceiptItemId = S.intTransactionReferenceDetailId
	AND S.strTranType = 'Inventory Receipt' 
LEFT JOIN vyuICGetReceiptItemSource receiptItemSource
	ON receiptItemSource.intInventoryReceiptItemId = receiptItem.intInventoryReceiptItemId
	--AND S.strTranType = 'Inventory Receipt' 
LEFT JOIN tblICInventoryReceipt receipt 
	ON receipt.intInventoryReceiptId = receiptItem.intInventoryReceiptId   
LEFT JOIN tblICInventoryShipmentItem shipmentItem 
	ON shipmentItem.intInventoryShipmentId =S.intTransactionReferenceId
	AND shipmentItem.intInventoryShipmentItemId = S.intTransactionReferenceDetailId
	AND S.strTranType = 'Inventory Shipment'
LEFT JOIN vyuICGetShipmentItemSource shipmentItemSource
	ON shipmentItemSource.intInventoryShipmentItemId = shipmentItem.intInventoryShipmentItemId
	--AND S.strTranType = 'Inventory Shipment'
LEFT JOIN tblICInventoryShipment shipment 
	ON shipment.intInventoryShipmentId = shipmentItem.intInventoryShipmentId   
LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId  = COALESCE(receiptItem.intLineNo,shipmentItem.intLineNo)
LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
LEFT JOIN tblCTPricingType ptCH on ptCH.intPricingTypeId = CH.intPricingTypeId
LEFT JOIN tblCTPricingType ptCD on ptCD.intPricingTypeId = CD.intPricingTypeId




SELECT 
	strTransactionReferenceId
	,ysnPurchaseBasis = CAST([Purchase Basis] AS BIT)
	,ysnPurchasePriced = CAST([Purchase Priced] AS BIT)
	,ysnPurchaseBasisDeliveries = CAST([Purchase Basis Deliveries] AS BIT)
	,ysnSaleBasis = CAST([Sale Basis] AS BIT)
	,ysnSalePriced = CAST([Sale Priced] AS BIT)
	,ysnSalesBasisDeliveries = CAST([Sales Basis Deliveries] AS BIT)
INTO #tempPivotTable
FROM (
	select
		intValue = (case when count(strTransactionReferenceId) > 1 then 1 else 0 end)
		,strTransactionReferenceId
		,strType 
	from tblRKDPRRunLogDetail LD
	inner join tblRKDPRRunLog L on L.intDPRRunLogId = LD.intDPRRunLogId
	where strType in( 'Purchase Basis','Purchase Priced','Purchase Basis Deliveries','Sale Basis','Sale Priced','Sales Basis Deliveries') 
		and L.intDPRRunLogId = @intDPRRun2
	group by strTransactionReferenceId,strType
) t
PIVOT (
	COUNT(intValue)
	FOR strType IN (
		[Purchase Basis]
		,[Purchase Priced]
		,[Purchase Basis Deliveries]
		,[Sale Basis]
		,[Sale Priced]
		,[Sales Basis Deliveries]
	)

) AS pivot_table


SELECT
	 intRowNumber = CONVERT(INT, ROW_NUMBER() OVER (ORDER BY t.strTransactionReferenceId ASC))
	,strBucketType = @strBucketType
	,strTransactionId = t.strTransactionReferenceId
	,t.intTransactionReferenceId
	,t.intTransactionReferenceDetailId
	,t.strTranType
	,dblTotalRun1
	,dblTotalRun2
	,dblDifference = ISNULL(dblTotalRun2,0) - ISNULL(dblTotalRun1,0)
	,strComment
	,strCommodityCode = @strCommodityCode
	,strVendorCustomer = t.strEntityName 
	,t.strLocationName 
	,dblShipReceiveQty
	,dblVariance = ABS(dblShipReceiveQty) - ABS(ISNULL(dblTotalRun2,0) - ISNULL(dblTotalRun1,0))
	,dtmShipReceiptDate
	,dtmContractDate
	,t.strContractNumber
	,t.intContractHeaderId
	,strHeaderPricing
	,strSeqPricing = (CASE WHEN ysnPurchaseBasis = 1 OR ysnSaleBasis = 1 
							THEN 'Basis' 
						WHEN ysnPurchasePriced = 1 OR ysnSalePriced = 1
							THEN 'Priced'
						ELSE strSeqPricing
					END)
	,strTicketNumber
	,intTicketId
	,ysnPurchaseBasis
	,ysnPurchasePriced
	,ysnPurchaseBasisDeliveries
	,ysnSaleBasis
	,ysnSalePriced
	,ysnSalesBasisDeliveries
	,dtmRunDateTime1 = @dtmRunDateTime1
	,dtmRunDateTime2 = @dtmRunDateTime2
	,dtmDPRDate1 = @dtmDPRDate1
	,dtmDPRDate2 = @dtmDPRDate2
FROM (

	SELECT 
		a.strTransactionReferenceId
		, a.intTransactionReferenceId
		, a.intTransactionReferenceDetailId
		, a.strTranType
		, dblTotalRun1 =  a.dblTotal 
		, dblTotalRun2 = b.dblTotal
		, strComment = 'Balance Difference'
		, a.strEntityName
		, a.strLocationName
		, a.dblShipReceiveQty
		, a.dtmShipReceiptDate
		, a.dtmContractDate
		, a.strContractNumber
		, a.intContractHeaderId
		, a.strHeaderPricing
		, a.strSeqPricing
		, a.strTicketNumber
		, a.intTicketId
	FROM #tempFinalFirstRun a
	INNER JOIN #tempFinalSecondRun b ON b.strTransactionReferenceId = a.strTransactionReferenceId


	UNION ALL
	SELECT 
		 a.strTransactionReferenceId
		, a.intTransactionReferenceId
		, a.intTransactionReferenceDetailId
		, a.strTranType
		, dblTotalRun1 = a.dblTotal
		, dblTotalRun2 = NULL
		, strComment = 'Missing in Run 2'
		, a.strEntityName
		, a.strLocationName
		, a.dblShipReceiveQty
		, a.dtmShipReceiptDate
		, a.dtmContractDate
		, a.strContractNumber
		, a.intContractHeaderId
		, a.strHeaderPricing
		, a.strSeqPricing
		, a.strTicketNumber
		, a.intTicketId
	FROM #tempFinalFirstRun  a
	WHERE a.strTransactionReferenceId NOT IN (SELECT strTransactionReferenceId FROM #tempFinalSecondRun)

	UNION ALL
	SELECT 
		 b.strTransactionReferenceId
		, b.intTransactionReferenceId
		, b.intTransactionReferenceDetailId
		, b.strTranType
		, dblTotalRun1 = NULL
		, dblTotalRun2 = b.dblTotal
		, strComment = 'Missing in Run 1'
		, b.strEntityName
		, b.strLocationName
		, b.dblShipReceiveQty
		, b.dtmShipReceiptDate
		, b.dtmContractDate
		, b.strContractNumber
		, b.intContractHeaderId
		, b.strHeaderPricing
		, b.strSeqPricing
		, b.strTicketNumber
		, b.intTicketId
	FROM #tempFinalSecondRun b
	WHERE b.strTransactionReferenceId NOT IN (SELECT strTransactionReferenceId FROM #tempFinalFirstRun)
) t
INNER JOIN #tempPivotTable PT ON PT.strTransactionReferenceId = t.strTransactionReferenceId


DROP TABLE #FirstRun
DROP TABLE #SecondRun
DROP TABLE #tempFirstToSecond
DROP TABLE #tempSecondToFirst
DROP TABLE #tempFinalFirstRun
DROP TABLE #tempFinalSecondRun
DROP TABLE #tempPivotTable

END