CREATE PROCEDURE [dbo].[uspMFValidateTransferKit]
	@intWorkOrderId int,
	@intKitStagingLocationId int
AS
Declare @intManufacturingProcessId int
--Declare @intKitStagingLocationId int
Declare @strKitStagingLocationName nvarchar(50)
--Declare @intLocationId int
Declare @intItemId int
Declare @ErrMsg nvarchar(max)
Declare @intMinParentLot int
Declare @intPickListId int
Declare @intParentLotId int
Declare @dblReqQty numeric(18,6)
Declare @dblReqUnit numeric(18,6)
Declare @dblAvailableQty numeric(18,6)
Declare @dblAvailableUnit numeric(18,6)
Declare @dblWeightPerUnit numeric(18,6)
Declare @strIssuedUOM nvarchar(50)
Declare @strLotAlias nvarchar(50)
Declare @strItemNo nvarchar(50)
Declare @strWONumber nvarchar(50)

Select @intPickListId=intPickListId From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId
--Select TOP 1 @intManufacturingProcessId=intManufacturingProcessId From tblMFManufacturingProcess Where intAttributeTypeId=2
--Select @intLocationId=intLocationId from tblMFPickList Where intPickListId=@intPickListId

--Select @intKitStagingLocationId=pa.strAttributeValue 
--From tblMFManufacturingProcessAttribute pa Join tblMFAttribute at on pa.intAttributeId=at.intAttributeId
--Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId 
--and at.strAttributeName='Kit Staging Location'

If ISNULL(@intKitStagingLocationId ,0)=0
	RaisError('Kit Staging Location is not defined.',16,1)

Select @strKitStagingLocationName=strName 
From tblICStorageLocation Where intStorageLocationId=@intKitStagingLocationId

Declare @tblParentLot table
(
	intRowNo int Identity(1,1),
	intWorkOrderId int,
	intParentLotId int,
	dblReqQty numeric(18,6),
	intItemUOMId int,
	intItemIssuedUOMId int
)

	Select @strWONumber=strWorkOrderNo From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId

	If (Select intKitStatusId From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId) = 8
	Begin
		Set @ErrMsg='The Blend Sheet ' + @strWONumber + ' is already transferred.'
		RaisError(@ErrMsg,16,1)
	End

	If (Select intKitStatusId From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId) <> 12 
	Begin
		Set @ErrMsg='The Blend Sheet ' + @strWONumber + ' is not staged.'
		RaisError(@ErrMsg,16,1)
	End

	If (Select intStatusId From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId) = 13
	Begin
		Set @ErrMsg='The Blend Sheet ' + @strWONumber + ' is already completed.'
		RaisError(@ErrMsg,16,1)
	End

	-- Start Validate available qty in Kit Staging

	--Get the parent Lots for the workorder
	Delete From @tblParentLot
	Insert Into @tblParentLot(intWorkOrderId,intParentLotId,dblReqQty,intItemUOMId,intItemIssuedUOMId)
	Select DISTINCT wi.intWorkOrderId,wi.intParentLotId,wi.dblQuantity,wi.intItemUOMId,wi.intItemIssuedUOMId 
	From tblMFWorkOrderInputParentLot wi 
	Join tblMFPickListDetail pld on wi.intParentLotId=pld.intParentLotId
	Where wi.intWorkOrderId=@intWorkOrderId And pld.intPickListId=@intPickListId

	Select @intMinParentLot=Min(intRowNo) from @tblParentLot

	While(@intMinParentLot is not null) --Loop Parent Lots
	Begin
		Select @intParentLotId=intParentLotId,@dblReqQty=dblReqQty From @tblParentLot Where intRowNo=@intMinParentLot

		Select @dblAvailableQty=SUM(l.dblWeight)
		From tblICLot l Join tblMFPickListDetail pld on l.intLotId=pld.intStageLotId 
		Where pld.intPickListId=@intPickListId And l.intParentLotId=@intParentLotId And l.dblQty > 0 
		AND l.intStorageLocationId=@intKitStagingLocationId

		If @dblAvailableQty < @dblReqQty
		Begin
			Select @strIssuedUOM=um.strUnitMeasure From tblICItemUOM iu Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId 
			Where iu.intItemUOMId=(Select intItemIssuedUOMId From @tblParentLot Where intRowNo=@intMinParentLot)

			Select TOP 1 @strLotAlias=l.strLotAlias,@dblWeightPerUnit=l.dblWeightPerQty,@strItemNo=i.strItemNo 
			From tblICLot l Join tblICItem i on l.intItemId=i.intItemId Where intParentLotId=@intParentLotId

			Set @dblAvailableUnit = @dblAvailableQty / @dblWeightPerUnit
			Set @dblReqUnit = @dblReqQty / @dblWeightPerUnit

			Set @ErrMsg='Required qty of ' + Convert(varchar,@dblReqUnit) + ' ' + @strIssuedUOM + ' is not available for the blend sheet ' + 
			@strWONumber + ' with Lot Alias ' + @strLotAlias + ' and Item No.' + @strItemNo + ' in kit staging location ' + @strKitStagingLocationName + '.' 
			RaisError(@ErrMsg,16,1)
		End
		
		Select @intMinParentLot=Min(intRowNo) from @tblParentLot where intRowNo>@intMinParentLot	
	End
	--End Validate available qty in Kit Staging