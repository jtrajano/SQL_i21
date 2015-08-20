CREATE PROCEDURE [dbo].[uspMFGetBlendProductionParentLots]
@intWorkOrderId int
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

Declare @tblItemQty table
(
	intItemId int,
	dblQuantity numeric(18,6),
	intItemUOMId int,
	strUOM nvarchar(50),
	dblIssuedQuantity numeric(18,6),
	intItemIssuedUOMId int,
	strIssuedUOM nvarchar(50)
)

Declare @tblItemConfirmQty table
(
	intItemId int,
	dblQuantity numeric(18,6)
)

Insert into @tblItemConfirmQty(intItemId,dblQuantity)
Select i.intItemId,sum(wcl.dblQuantity) AS dblQuantity
from tblMFWorkOrderConsumedLot wcl
Join tblICLot l on wcl.intLotId=l.intLotId
Join tblICItem i on l.intItemId=i.intItemId
Where wcl.intWorkOrderId=@intWorkOrderId And ISNULL(wcl.ysnStaged,0)=1
group by i.intItemId

Insert into @tblItemQty(intItemId,dblQuantity,intItemUOMId,strUOM,dblIssuedQuantity,intItemIssuedUOMId,strIssuedUOM)
Select i.intItemId,sum(wcl.dblQuantity) AS dblQuantity,max(wcl.intItemUOMId) AS intItemUOMId,max(um.strUnitMeasure) AS strUOM,
sum(wcl.dblIssuedQuantity) AS dblIssuedQuantity,max(wcl.intItemIssuedUOMId) AS intItemIssuedUOMId,max(um1.strUnitMeasure) AS strIssuedUOM
from tblMFWorkOrderConsumedLot wcl
Join tblICLot l on wcl.intLotId=l.intLotId
Join tblICItem i on l.intItemId=i.intItemId
Join tblICItemUOM iu on wcl.intItemUOMId=iu.intItemUOMId
Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
Join tblICItemUOM iu1 on wcl.intItemIssuedUOMId=iu1.intItemUOMId
Join tblICUnitMeasure um1 on iu1.intUnitMeasureId=um1.intUnitMeasureId
Where wcl.intWorkOrderId=@intWorkOrderId
group by i.intItemId

Select wri.intWorkOrderId,i.intItemId,i.strItemNo,i.strDescription,
ISNULL(iq.dblQuantity,0) AS dblQuantity,ISNULL(iq.intItemUOMId,0) AS intItemUOMId,ISNULL(iq.strUOM,'') AS strUOM,
ISNULL(iq.dblIssuedQuantity,0) AS dblIssuedQuantity,ISNULL(iq.intItemIssuedUOMId,'') AS intItemIssuedUOMId,ISNULL(iq.strIssuedUOM,'') AS strIssuedUOM,
ISNULL(cq.dblQuantity,0.0) AS dblConfirmedQty 
From tblMFWorkOrderRecipeItem wri Join tblICItem i on wri.intItemId=i.intItemId 
Left Join @tblItemQty iq on wri.intItemId=iq.intItemId
Left Join @tblItemConfirmQty cq on wri.intItemId=cq.intItemId
Where wri.intWorkOrderId=@intWorkOrderId And wri.intRecipeItemTypeId=1
UNION
Select wri.intWorkOrderId,i.intItemId,i.strItemNo,i.strDescription,
iq.dblQuantity,iq.intItemUOMId,iq.strUOM,iq.dblIssuedQuantity,iq.intItemIssuedUOMId,iq.strIssuedUOM,
ISNULL(cq.dblQuantity,0.0) AS dblConfirmedQty 
From tblMFWorkOrderRecipeSubstituteItem wri Join tblICItem i on wri.intItemId=i.intItemId 
Left Join @tblItemQty iq on wri.intItemId=iq.intItemId
Left Join @tblItemConfirmQty cq on wri.intItemId=cq.intItemId
Where wri.intWorkOrderId=@intWorkOrderId And wri.intRecipeItemTypeId=1

