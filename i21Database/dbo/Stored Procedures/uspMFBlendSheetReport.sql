CREATE Procedure [dbo].[uspMFBlendSheetReport] 
@intWorkOrderId int=null
AS
Select b.intWorkOrderId,b.strWorkOrderNo,b.dblQuantity AS WOQuantity,
Convert(varchar,e.strItemNo) + ' - ' + ISNULL(e.strDescription,'') AS WOItem,g.strUnitMeasure AS WOUOM,
c.strLotNumber,a.dblQuantity AS LotQuantity,i.strUnitMeasure AS LotUOM, 
case when a.intItemUOMId=a.intItemIssuedUOMId then null else 
Cast(a.dblIssuedQuantity as int) end AS FullBags,
case when a.intItemUOMId=a.intItemIssuedUOMId then null else 
l.strUnitMeasure end AS FullAddUOM,
case when a.intItemUOMId=a.intItemIssuedUOMId then null else
(a.dblIssuedQuantity  - Cast(a.dblIssuedQuantity as int)) * (Case When ISNULL(c.dblWeightPerQty,0)=0 then 1 else c.dblWeightPerQty end) end AS HandAdds,
d.strItemNo,d.strDescription from tblMFWorkOrderConsumedLot a 
Join tblMFWorkOrder b on a.intWorkOrderId=b.intWorkOrderId 
Join tblICLot c on a.intLotId = c.intLotId 
Join tblICItem d on c.intItemId=d.intItemId 
Join tblICItem e on b.intItemId=e.intItemId
Join tblICItemUOM f on b.intItemUOMId=f.intItemUOMId 
Join tblICUnitMeasure g on f.intUnitMeasureId=g.intUnitMeasureId
Join tblICItemUOM h on a.intItemUOMId=h.intItemUOMId 
Join tblICUnitMeasure i on i.intUnitMeasureId=h.intUnitMeasureId
Join tblICItemUOM k on a.intItemIssuedUOMId=k.intItemUOMId 
Join tblICUnitMeasure l on l.intUnitMeasureId=k.intUnitMeasureId
where b.intWorkOrderId=@intWorkOrderId

