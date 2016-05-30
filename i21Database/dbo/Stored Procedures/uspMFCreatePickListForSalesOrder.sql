CREATE PROCEDURE [dbo].[uspMFCreatePickListForSalesOrder]
	@intSalesOrderId int
AS

Declare @intLocationId INT
Declare @intMinItem INT
Declare @intItemId INT
Declare @dblRequiredQty NUMERIC(38,20)
Declare @dblItemRequiredQty NUMERIC(38,20)
Declare @strLotTracking nvarchar(50)
Declare @intItemUOMId INT
Declare @intMinLot INT
Declare @intLotId INT
Declare @dblAvailableQty NUMERIC(38,20)
Declare @intPickListId INT

DECLARE @tblInputItem TABLE (
	intRowNo INT IDENTITY(1, 1)
	,intItemId INT
	,dblQty NUMERIC(38,20)
	,intItemUOMId int
	,strLotTracking nvarchar(50)
	)

DECLARE @tblInputItemCopy TABLE (
	intItemId INT
	,dblQty NUMERIC(38,20)
	,intItemUOMId int
	,strLotTracking nvarchar(50)
	)

DECLARE @tblLot TABLE (
	 intRowNo INT IDENTITY
	,intLotId INT
	,intItemId INT
	,dblQty NUMERIC(38,20)
	,intItemUOMId INT
	,intLocationId INT
	,intSubLocationId INT
	,intStorageLocationId INT
	)

DECLARE @tblPickedLot TABLE(
	 intRowNo INT IDENTITY
	,intLotId INT
	,intItemId INT
	,dblQty NUMERIC(38,20)
	,intItemUOMId INT
	,intLocationId INT
	,intSubLocationId INT
	,intStorageLocationId INT
	,dblItemRequiredQty NUMERIC(38,20)
)

Insert Into @tblInputItem(intItemId,dblQty,intItemUOMId,strLotTracking)
Select sd.intItemId,SUM(sd.dblQtyOrdered),sd.intItemUOMId,i.strLotTracking 
From tblSOSalesOrderDetail sd Join tblICItem i on sd.intItemId=i.intItemId 
Where intSalesOrderId=@intSalesOrderId Group By sd.intItemId,sd.intItemUOMId,i.strLotTracking


If Exists (Select 1 From tblMFPickList Where intSalesOrderId=@intSalesOrderId)
Begin
	Insert Into @tblInputItemCopy(intItemId,dblQty,intItemUOMId,strLotTracking)
	Select intItemId,dblQty,intItemUOMId,strLotTracking from @tblInputItem

	Delete From @tblInputItem

	Select TOP 1 @intPickListId=intPickListId From tblMFPickList Where intSalesOrderId=@intSalesOrderId

	--Remaining Qty to pick
	INSERT INTO @tblInputItem(intItemId,dblQty,intItemUOMId,strLotTracking)
	Select ti.intItemId,ISNULL(ti.dblQty,0) - ISNULL(t.dblQty,0),ti.intItemUOMId,ti.strLotTracking
	From @tblInputItemCopy ti 
	Left Join (Select pld.intItemId,SUM(pld.dblPickQuantity) AS dblQty From tblMFPickListDetail pld Where intPickListId=@intPickListId Group By pld.intItemId) t ON ti.intItemId=t.intItemId

	Delete From @tblInputItem Where ISNULL(dblQty,0)=0
End

Select @intLocationId=intCompanyLocationId From tblSOSalesOrder Where intSalesOrderId=@intSalesOrderId

Select @intMinItem = MIN(intRowNo) From @tblInputItem

While @intMinItem is not null
Begin
	Select @intItemId=intItemId,@dblRequiredQty=dblQty,@dblItemRequiredQty=dblQty,@intItemUOMId=intItemUOMId,@strLotTracking=strLotTracking 
	From @tblInputItem Where intRowNo=@intMinItem

	DELETE FROM @tblLot

	If @strLotTracking='No'
		INSERT INTO @tblLot (
		 intLotId
		,intItemId
		,dblQty
		,intItemUOMId
		,intLocationId
		,intSubLocationId
		,intStorageLocationId
		)
		Select 0,sd.intItemId,dbo.fnMFConvertQuantityToTargetItemUOM(sd.intItemUOMId,@intItemUOMId,sd.dblAvailableQty),@intItemUOMId,
		sd.intLocationId,sd.intSubLocationId,sd.intStorageLocationId
		From vyuMFGetItemStockDetail sd 
		Where sd.intItemId=@intItemId AND sd.dblAvailableQty > .01 AND sd.intLocationId=@intLocationId AND ISNULL(sd.ysnStockUnit,0)=1 ORDER BY sd.intItemStockUOMId
	Else
		INSERT INTO @tblLot (
		 intLotId
		,intItemId
		,dblQty
		,intItemUOMId
		,intLocationId
		,intSubLocationId
		,intStorageLocationId
		)
	SELECT L.intLotId
		,L.intItemId
		,dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId,@intItemUOMId,L.dblQty) - 
		(Select ISNULL(SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(sr.intItemUOMId,@intItemUOMId,sr.dblQty),0)),0) 
		From tblICStockReservation sr Where sr.intLotId=L.intLotId AND ISNULL(sr.ysnPosted,0)=0) AS dblQty
		,@intItemUOMId
		,L.intLocationId
		,L.intSubLocationId
		,L.intStorageLocationId
	FROM tblICLot L
	JOIN tblICLotStatus LS ON L.intLotStatusId = LS.intLotStatusId
	WHERE L.intItemId = @intItemId
		AND L.intLocationId = @intLocationId
		AND LS.strPrimaryStatus IN (
			'Active'
			)
		AND (L.dtmExpiryDate IS NULL OR L.dtmExpiryDate >= GETDATE())
		AND L.dblQty  >= .01
		ORDER BY L.dtmDateCreated

	Delete From @tblLot Where dblQty < .01

	Select @intMinLot=MIN(intRowNo) From @tblLot
	While @intMinLot is not null
	Begin
		Select @intLotId=intLotId,@dblAvailableQty=dblQty From @tblLot Where intRowNo=@intMinLot

		If @dblAvailableQty >= @dblRequiredQty 
		Begin
			INSERT INTO @tblPickedLot(intLotId,intItemId,dblQty,intItemUOMId,intLocationId,intSubLocationId,intStorageLocationId,dblItemRequiredQty)
			Select @intLotId,@intItemId,@dblRequiredQty,intItemUOMId,intLocationId,intSubLocationId,intStorageLocationId,@dblRequiredQty 
			From @tblLot Where intRowNo=@intMinLot

			GOTO NEXT_ITEM
		End
		Else
		Begin
			INSERT INTO @tblPickedLot(intLotId,intItemId,dblQty,intItemUOMId,intLocationId,intSubLocationId,intStorageLocationId,dblItemRequiredQty)
			Select @intLotId,@intItemId,@dblAvailableQty,intItemUOMId,intLocationId,intSubLocationId,intStorageLocationId,@dblAvailableQty 
			From @tblLot Where intRowNo=@intMinLot

			Set @dblRequiredQty = @dblRequiredQty - @dblAvailableQty
		End

		Select @intMinLot = MIN(intRowNo) From @tblLot Where intRowNo>@intMinLot
	End

	If ISNULL(@dblRequiredQty,0)>0
		INSERT INTO @tblPickedLot(intLotId,intItemId,dblQty,intItemUOMId,intLocationId,intSubLocationId,intStorageLocationId,dblItemRequiredQty)
		Select 0,@intItemId,0,@intItemUOMId,@intLocationId,0,0,@dblRequiredQty

	NEXT_ITEM:
	Select @intMinItem = MIN(intRowNo) From @tblInputItem Where intRowNo>@intMinItem

End

If Exists (Select 1 From tblMFPickList Where intSalesOrderId=@intSalesOrderId)
Begin --Existing Pick List
	Select pld.intPickListDetailId,pld.intPickListId,p.intSalesOrderId,pld.intItemId,i.strItemNo,i.strDescription,l.intLotId,l.strLotNumber,
	pld.intStorageLocationId,sl.strName AS strStorageLocationName,
	pld.dblQuantity AS dblPickQuantity,pld.intItemUOMId AS intPickUOMId,um.strUnitMeasure AS strPickUOM,
	pl.intParentLotId,pld.intSubLocationId,sbl.strSubLocationName,pld.intLocationId,i.strLotTracking,pld.dblPickQuantity AS dblItemRequiredQty
	from tblMFPickListDetail pld Join tblMFPickList p on pld.intPickListId=p.intPickListId
	Join tblICItem i on pld.intItemId=i.intItemId 
	Left Join tblICLot l on pld.intLotId=l.intLotId
	Left Join tblICParentLot pl on l.intParentLotId=pl.intParentLotId
	Left Join tblICStorageLocation sl on pld.intStorageLocationId=sl.intStorageLocationId
	Left Join tblSMCompanyLocationSubLocation sbl on pld.intSubLocationId=sbl.intCompanyLocationSubLocationId
	Left Join tblSMCompanyLocation cl on pld.intLocationId=cl.intCompanyLocationId
	Join tblICItemUOM iu on pld.intItemUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Where p.intSalesOrderId=@intSalesOrderId
	Union --Remaining Picking
	Select 0,0,@intSalesOrderId,p.intItemId,i.strItemNo,i.strDescription,l.intLotId,l.strLotNumber,p.intStorageLocationId,sl.strName AS strStorageLocationName,
	p.dblQty AS dblPickQuantity,p.intItemUOMId AS intPickUOMId,um.strUnitMeasure AS strPickUOM,
	pl.intParentLotId,p.intSubLocationId,sbl.strSubLocationName,p.intLocationId,i.strLotTracking,p.dblItemRequiredQty
	from @tblPickedLot p Join tblICItem i on p.intItemId=i.intItemId 
	Left Join tblICLot l on p.intLotId=l.intLotId
	Left Join tblICParentLot pl on l.intParentLotId=pl.intParentLotId
	Left Join tblICStorageLocation sl on p.intStorageLocationId=sl.intStorageLocationId
	Left Join tblSMCompanyLocationSubLocation sbl on p.intSubLocationId=sbl.intCompanyLocationSubLocationId
	Left Join tblSMCompanyLocation cl on p.intLocationId=cl.intCompanyLocationId
	Join tblICItemUOM iu on p.intItemUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
End
Else 
Begin --New PickList
	Select p.intItemId,i.strItemNo,i.strDescription,l.intLotId,l.strLotNumber,p.intStorageLocationId,sl.strName AS strStorageLocationName,
	p.dblQty AS dblPickQuantity,p.intItemUOMId AS intPickUOMId,um.strUnitMeasure AS strPickUOM,
	pl.intParentLotId,p.intSubLocationId,sbl.strSubLocationName,p.intLocationId,i.strLotTracking,p.dblItemRequiredQty
	from @tblPickedLot p Join tblICItem i on p.intItemId=i.intItemId 
	Left Join tblICLot l on p.intLotId=l.intLotId
	Left Join tblICParentLot pl on l.intParentLotId=pl.intParentLotId
	Left Join tblICStorageLocation sl on p.intStorageLocationId=sl.intStorageLocationId
	Left Join tblSMCompanyLocationSubLocation sbl on p.intSubLocationId=sbl.intCompanyLocationSubLocationId
	Left Join tblSMCompanyLocation cl on p.intLocationId=cl.intCompanyLocationId
	Join tblICItemUOM iu on p.intItemUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
End
