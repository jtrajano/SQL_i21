CREATE VIEW [dbo].[vyuMFGetBlendTransactions]
	AS 
SELECT DISTINCT intBlendTransactionId = w.intWorkOrderId
	, strBlendTransactionNo = w.strWorkOrderNo
	, dtmBlendDate = ISNULL(wp.dtmProductionDate,w.dtmCompletedDate)
	, intPrimaryItemId = t1.intItemId
	, strPrimaryItemNo = t1.strItemNo
	, dblPrimaryQty = t1.dblQuantity
	, intBlendAgendItemId = t2.intItemId
	, strBlendAgentItemNo = t2.strItemNo
	, dblBlendAgentQty = t2.dblQuantity
	, intFinishedGoodItemId = i.intItemId
	, strFinishedGoodItemNo = i.strItemNo
	, dblFinishedGoodQty = wp.dblQuantity
FROM tblMFWorkOrderProducedLot wp 
JOIN tblMFWorkOrder w ON wp.intWorkOrderId = w.intWorkOrderId
JOIN tblICItem i ON wp.intItemId = i.intItemId
JOIN tblMFManufacturingProcess mp ON w.intManufacturingProcessId = mp.intManufacturingProcessId
LEFT JOIN
(
	SELECT intWorkOrderId
		, i.intItemId
		, i.strItemNo
		, SUM(dblQuantity) dblQuantity
		, ROW_NUMBER() OVER(Partition By intWorkOrderId Order By SUM(dblQuantity) Desc) intRowNo
	FROM tblMFWorkOrderConsumedLot wp
	JOIN tblICItem i ON wp.intItemId = i.intItemId
	GROUP BY intWorkOrderId, i.intItemId, i.strItemNo 
) t1 ON w.intWorkOrderId = t1.intWorkOrderId AND t1.intRowNo = 1
LEFT JOIN
(
	SELECT intWorkOrderId
		, i.intItemId
		, i.strItemNo
		, SUM(dblQuantity) dblQuantity
		, ROW_NUMBER() OVER(Partition By intWorkOrderId Order By SUM(dblQuantity) Desc) intRowNo
	FROM tblMFWorkOrderConsumedLot wp
	JOIN tblICItem i ON wp.intItemId = i.intItemId
	GROUP BY intWorkOrderId, i.intItemId, i.strItemNo 
) t2 ON w.intWorkOrderId = t2.intWorkOrderId AND t2.intRowNo = 2
WHERE mp.intAttributeTypeId = 2 AND ISNULL(wp.ysnProductionReversed,0) = 0
