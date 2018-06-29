CREATE PROCEDURE [dbo].[uspMFGetBlendProductionParentLots]
@intWorkOrderId int
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

Declare @ysnEnableParentLot bit=0
Declare @dblWOQty Numeric(38,20)
Declare @intItemId int
Declare @strLotTracking nvarchar(50)

Declare @tblItemQty table
(
	intParentLotId int,
	strParentLotNumber nvarchar(50),
	intItemId int,
	dblQuantity numeric(38,20),
	intItemUOMId int,
	strUOM nvarchar(50),
	dblIssuedQuantity numeric(38,20),
	intItemIssuedUOMId int,
	strIssuedUOM nvarchar(50)
)

Declare @tblItemConfirmQty table
(
	intParentLotId int,
	intItemId int,
	dblQuantity numeric(38,20)
)

Select TOP 1 @ysnEnableParentLot=ISNULL(ysnEnableParentLot,0) From tblMFCompanyPreference

Select @dblWOQty = dblQuantity,@intItemId=intItemId From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId

Select @strLotTracking=strLotTracking From tblICItem Where intItemId=@intItemId

If @ysnEnableParentLot=0 OR @strLotTracking = 'No'
Begin
	Insert into @tblItemConfirmQty(intItemId,dblQuantity)
	Select i.intItemId,sum(wcl.dblQuantity) AS dblQuantity
	from tblMFWorkOrderConsumedLot wcl
	Left Join tblICLot l on wcl.intLotId=l.intLotId --Left Join in tblICLot For Non Lot Track Items
	Join tblICItem i on wcl.intItemId=i.intItemId
	Where wcl.intWorkOrderId=@intWorkOrderId And ISNULL(wcl.ysnStaged,0)=1
	group by i.intItemId
	

	Insert into @tblItemQty(intItemId,dblQuantity,intItemUOMId,strUOM,dblIssuedQuantity,intItemIssuedUOMId,strIssuedUOM)
	Select i.intItemId,sum(wcl.dblQuantity) AS dblQuantity,max(wcl.intItemUOMId) AS intItemUOMId,max(um.strUnitMeasure) AS strUOM,
	sum(wcl.dblIssuedQuantity) AS dblIssuedQuantity,max(wcl.intItemIssuedUOMId) AS intItemIssuedUOMId,max(um1.strUnitMeasure) AS strIssuedUOM
	from tblMFWorkOrderConsumedLot wcl
	LEFT Join tblICLot l on wcl.intLotId=l.intLotId --Left Join in tblICLot For Non Lot Track Items
	Join tblICItem i on wcl.intItemId=i.intItemId
	Join tblICItemUOM iu on wcl.intItemUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Join tblICItemUOM iu1 on wcl.intItemIssuedUOMId=iu1.intItemUOMId
	Join tblICUnitMeasure um1 on iu1.intUnitMeasureId=um1.intUnitMeasureId
	Where wcl.intWorkOrderId=@intWorkOrderId
	group by i.intItemId

	--Find Required Qty For By Location And FIFO Lots
	--intSalesOrderLineItemId = 0 implies WOs are created from Blend Managemnet Screen And Lots are already attached
	If (Select TOP 1 ISNULL(intSalesOrderLineItemId,0) From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId)=0
	Begin
		--If Recipe Contains Bulk Items(By Location or FIFO Use dblPlannedQuantity)
		If Exists (Select 1 
		From tblMFWorkOrderRecipeItem ri 
		Join tblMFWorkOrderRecipe r on r.intWorkOrderId=ri.intWorkOrderId AND r.intRecipeId=ri.intRecipeId 
		where r.intWorkOrderId=@intWorkOrderId and ri.intRecipeItemTypeId=1 and ri.intConsumptionMethodId in (2,3))
		Begin	
			Select @dblWOQty = dblPlannedQuantity From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId
		End
	End

	If (Select intStatusId From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId) NOT IN (12,13)
	Begin
		Insert into @tblItemQty(intItemId,dblQuantity,intItemUOMId,strUOM,dblIssuedQuantity,intItemIssuedUOMId,strIssuedUOM)
		Select DISTINCT ri.intItemId,(ri.dblCalculatedQuantity * (@dblWOQty/r.dblQuantity)) dblQuantity,iu.intItemUOMId,u.strUnitMeasure,
		(ri.dblCalculatedQuantity * (@dblWOQty/r.dblQuantity)) dblIssuedQuantity,iu.intItemUOMId AS intItemIssuedUOMId,u.strUnitMeasure
		From tblMFWorkOrderRecipeItem ri 
		Join tblMFWorkOrderRecipe r on r.intWorkOrderId=ri.intWorkOrderId AND r.intRecipeId=ri.intRecipeId 
		Join tblICItemUOM iu on ri.intItemUOMId=iu.intItemUOMId
		Join tblICUnitMeasure u on iu.intUnitMeasureId=u.intUnitMeasureId
		where r.intWorkOrderId=@intWorkOrderId and ri.intRecipeItemTypeId=1 and ri.intConsumptionMethodId in (2,3)
	End

	--When Work Order Created without Input Lots take the required qty from recipe
	if (Select count(1) From @tblItemQty)=0
	Begin
		Insert into @tblItemQty(intItemId,dblQuantity,intItemUOMId,strUOM,dblIssuedQuantity,intItemIssuedUOMId,strIssuedUOM)
		Select ri.intItemId,(ri.dblCalculatedQuantity * (@dblWOQty/r.dblQuantity)) dblQuantity,0,u.strUnitMeasure,0,0,''
		From tblMFWorkOrderRecipeItem ri 
		Join tblMFWorkOrderRecipe r on r.intRecipeId=ri.intRecipeId 
		Join tblICItemUOM iu on ri.intItemUOMId=iu.intItemUOMId
		Join tblICUnitMeasure u on iu.intUnitMeasureId=u.intUnitMeasureId
		where r.intWorkOrderId=@intWorkOrderId and ri.intRecipeItemTypeId=1
		Union
		Select rs.intSubstituteItemId AS intItemId,(rs.dblQuantity * (@dblWOQty/r.dblQuantity)) RequiredQty,0,u.strUnitMeasure,0,0,''
		From tblMFWorkOrderRecipeSubstituteItem rs
		Join tblMFWorkOrderRecipe r on r.intRecipeId=rs.intRecipeId 
		Join tblICItemUOM iu on rs.intItemUOMId=iu.intItemUOMId
		Join tblICUnitMeasure u on iu.intUnitMeasureId=u.intUnitMeasureId
		where r.intWorkOrderId=@intWorkOrderId and rs.intRecipeItemTypeId=1
	End

	Select wri.intWorkOrderId,i.intItemId,i.strItemNo,i.strDescription,
	ISNULL(iq.dblQuantity,0) AS dblQuantity,ISNULL(iq.intItemUOMId,0) AS intItemUOMId,ISNULL(iq.strUOM,'') AS strUOM,
	ISNULL(iq.dblIssuedQuantity,0) AS dblIssuedQuantity,ISNULL(iq.intItemIssuedUOMId,'') AS intItemIssuedUOMId,ISNULL(iq.strIssuedUOM,'') AS strIssuedUOM,
	ISNULL(cq.dblQuantity,0.0) AS dblConfirmedQty,wri.intConsumptionMethodId,i.strLotTracking 
	From tblMFWorkOrderRecipeItem wri Join tblICItem i on wri.intItemId=i.intItemId 
	Left Join @tblItemQty iq on wri.intItemId=iq.intItemId
	Left Join @tblItemConfirmQty cq on wri.intItemId=cq.intItemId
	Where wri.intWorkOrderId=@intWorkOrderId And wri.intRecipeItemTypeId=1 AND wri.intConsumptionMethodId IN (1,2,3)
	UNION
	Select wri.intWorkOrderId,i.intItemId,i.strItemNo,i.strDescription,
	ISNULL(iq.dblQuantity,0) AS dblQuantity,ISNULL(iq.intItemUOMId,0) AS intItemUOMId,ISNULL(iq.strUOM,'') AS strUOM,
	ISNULL(iq.dblIssuedQuantity,0) AS dblIssuedQuantity,ISNULL(iq.intItemIssuedUOMId,'') AS intItemIssuedUOMId,ISNULL(iq.strIssuedUOM,'') AS strIssuedUOM,
	ISNULL(cq.dblQuantity,0.0) AS dblConfirmedQty,0,i.strLotTracking 
	From tblMFWorkOrderRecipeSubstituteItem wri Join tblICItem i on wri.intSubstituteItemId=i.intItemId 
	Left Join @tblItemQty iq on wri.intSubstituteItemId=iq.intItemId
	Left Join @tblItemConfirmQty cq on wri.intSubstituteItemId=cq.intItemId
	Where wri.intWorkOrderId=@intWorkOrderId And wri.intRecipeItemTypeId=1
End
Else
Begin
	Insert into @tblItemConfirmQty(intParentLotId,dblQuantity)
	Select l.intParentLotId,sum(wcl.dblQuantity) AS dblQuantity
	from tblMFWorkOrderConsumedLot wcl
	Join tblICLot l on wcl.intLotId=l.intLotId
	Where wcl.intWorkOrderId=@intWorkOrderId And ISNULL(wcl.ysnStaged,0)=1
	group by l.intParentLotId

	Select wi.intWorkOrderId,pl.intParentLotId,pl.strParentLotNumber,i.intItemId,i.strItemNo,i.strDescription,wi.dblQuantity,wi.intItemUOMId,um.strUnitMeasure AS strUOM,
	wi.dblIssuedQuantity,wi.intItemIssuedUOMId,um1.strUnitMeasure AS strIssuedUOM,ISNULL(cq.dblQuantity,0.0) AS dblConfirmedQty 
	from tblMFWorkOrderInputParentLot wi
	Join tblICParentLot pl on wi.intParentLotId=pl.intParentLotId
	Join tblICItem i on pl.intItemId=i.intItemId
	Join tblICItemUOM iu on wi.intItemUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Join tblICItemUOM iu1 on wi.intItemIssuedUOMId=iu1.intItemUOMId
	Join tblICUnitMeasure um1 on iu1.intUnitMeasureId=um1.intUnitMeasureId
	Left Join @tblItemConfirmQty cq on wi.intParentLotId=cq.intParentLotId
	Where wi.intWorkOrderId=@intWorkOrderId

End