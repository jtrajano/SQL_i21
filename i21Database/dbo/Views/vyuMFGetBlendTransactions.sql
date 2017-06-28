CREATE VIEW [dbo].[vyuMFGetBlendTransactions]
	AS 
SELECT DISTINCT w.intWorkOrderId [Blending Transaction Id],w.strWorkOrderNo [Blending Transaction No],ISNULL(wp.dtmProductionDate,w.dtmCompletedDate) [Blend Date],
t1.intItemId [Primary Product Id],t1.strItemNo [Primary Product],t1.dblQuantity [Primary Product Qty],
t2.intItemId [Blending Agent Product Id],t2.strItemNo [Blending Agent Product],t2.dblQuantity [Blending Agent Qty],
i.intItemId [Finished Good Id],i.strItemNo [Finished Good Product],wp.dblQuantity [Finished Good Product Qty]
FROM tblMFWorkOrderProducedLot wp 
join tblMFWorkOrder w on wp.intWorkOrderId=w.intWorkOrderId
join tblICItem i on wp.intItemId=i.intItemId
join tblMFManufacturingProcess mp on w.intManufacturingProcessId=mp.intManufacturingProcessId
left join
(
	select intWorkOrderId,i.intItemId,i.strItemNo,SUM(dblQuantity) dblQuantity,ROW_NUMBER() OVER(Partition By intWorkOrderId Order By SUM(dblQuantity) Desc) intRowNo
	from tblMFWorkOrderConsumedLot wp
	join tblICItem i on wp.intItemId=i.intItemId
	group by intWorkOrderId,i.intItemId, i.strItemNo 
) t1 on w.intWorkOrderId=t1.intWorkOrderId AND t1.intRowNo=1
left join
(
	select intWorkOrderId,i.intItemId,i.strItemNo,SUM(dblQuantity) dblQuantity,ROW_NUMBER() OVER(Partition By intWorkOrderId Order By SUM(dblQuantity) Desc) intRowNo
	from tblMFWorkOrderConsumedLot wp
	join tblICItem i on wp.intItemId=i.intItemId
	group by intWorkOrderId,i.intItemId, i.strItemNo 
) t2 on w.intWorkOrderId=t2.intWorkOrderId AND t2.intRowNo=2
Where mp.intAttributeTypeId=2 and isnull(wp.ysnProductionReversed,0)=0
