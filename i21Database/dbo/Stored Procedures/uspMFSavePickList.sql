CREATE PROCEDURE [dbo].[uspMFSavePickList]
	@strXml nVarchar(Max),
	@intPickListIdOut int = 0 OUT
AS
Begin Try

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrMsg nvarchar(max)
DECLARE @idoc int 
DECLARE @intPickListId int=0
DECLARE @dtmCurrentDate DATETIME=GETDATE()
DECLARE @strWorkOrderNos nvarchar(max)
DECLARE @index int
DECLARE @id nvarchar(50)
DECLARE @intAssignedToId int
DECLARE @intConCurrencyId int
DECLARE @strPickListNo nVarchar(50)
DECLARE @intMinPickDetail int
DECLARE @strLotNumber nvarchar(50)
DECLARE @strParentLotNumber nvarchar(50)
DECLARE @intLotId int
DECLARE @intParentLotId int
DECLARE @dblReqQtySum numeric(18,6)
DECLARE @dblPickQtySum numeric(18,6)
DECLARE @dblPickQty numeric(18,6)
DECLARE @dblAvailableUnit numeric(18,6)
Declare @ysnBlendSheetRequired bit
Declare @intLocationId int
Declare @intBlendItemId int

EXEC sp_xml_preparedocument @idoc OUTPUT, @strXml  

Declare @tblWorkOrder AS table
(
	strWorkOrderNo nvarchar(50) COLLATE Latin1_General_CI_AS
)

Declare @tblPickList table
(
	intPickListId int,
	strPickListNo nvarchar(50),
	strWorkOrderNo nvarchar(max),
	intAssignedToId int,
	intLocationId int,
	intUserId int
)

Declare @tblPickListDetail table
(
	intRowNo int IDENTITY(1,1),
	intPickListId int,
	intPickListDetailId int,
	intLotId int,
	intParentLotId int,
	intItemId int,
	intStorageLocationId int,
	dblQuantity numeric(18,6),
	intItemUOMId int,
	dblIssuedQuantity  numeric(18,6),
	intItemIssuedUOMId int,
	dblPickQuantity numeric(18,6),
	intPickUOMId int,
	intUserId int
)

INSERT INTO @tblPickList(
 intPickListId,strPickListNo,strWorkOrderNo,intAssignedToId,intLocationId,intUserId)
 Select intPickListId,strPickListNo,strWorkOrderNo,intAssignedToId,intLocationId,intUserId
 FROM OPENXML(@idoc, 'root', 2)  
 WITH ( 
	intPickListId int, 
	strPickListNo nvarchar(50),
	strWorkOrderNo nvarchar(max),
	intAssignedToId int,
	intLocationId int,
	intUserId int
	)

INSERT INTO @tblPickListDetail(
 intPickListId,intPickListDetailId,intLotId,intParentLotId,intItemId,intStorageLocationId,dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,
 dblPickQuantity,intPickUOMId,intUserId)
 Select intPickListId,intPickListDetailId,intLotId,intParentLotId,intItemId,intStorageLocationId,dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,
 dblPickQuantity,intPickUOMId,intUserId
 FROM OPENXML(@idoc, 'root/lot', 2)  
 WITH ( 
	intPickListId int,
	intPickListDetailId int,
	intLotId int,
	intParentLotId int,
	intItemId int,
	intStorageLocationId int,
	dblQuantity numeric(18,6),
	intItemUOMId int,
	dblIssuedQuantity  numeric(18,6),
	intItemIssuedUOMId int,
	dblPickQuantity numeric(18,6),
	intPickUOMId int,
	intUserId int
	)

Select TOP 1 @intPickListId=intPickListId,@strWorkOrderNos=strWorkOrderNo,@intAssignedToId=intAssignedToId,@strPickListNo=strPickListNo,@intLocationId=intLocationId 
From @tblPickList

Select TOP 1 @intBlendItemId=intItemId From tblMFWorkOrder Where intPickListId=@intPickListId

--Get the Comma Separated Work Order Nos into a table
SET @index = CharIndex(',',@strWorkOrderNos)
WHILE @index > 0
BEGIN
        SET @id = SUBSTRING(@strWorkOrderNos,1,@index-1)
        SET @strWorkOrderNos = SUBSTRING(@strWorkOrderNos,@index+1,LEN(@strWorkOrderNos)-@index)

        INSERT INTO @tblWorkOrder values (@id)
        SET @index = CharIndex(',',@strWorkOrderNos)
END
SET @id=@strWorkOrderNos
INSERT INTO @tblWorkOrder values (@id)

If @intAssignedToId=0
	Raiserror('Assigned To cannot be empty.',16,1)

If (Select count(1) from @tblWorkOrder)=0
	Raiserror('No Blend Sheet(s) are selected for picking.',16,1)

Select TOP 1 @ysnBlendSheetRequired=ISNULL(ysnBlendSheetRequired,0) From tblMFCompanyPreference

Select TOP 1 @intBlendItemId=intItemId From tblMFWorkOrder Where strWorkOrderNo in (Select strWorkOrderNo From @tblWorkOrder)

If @ysnBlendSheetRequired = 1
Begin

Select @intMinPickDetail=Min(intRowNo) from @tblPickListDetail
While(@intMinPickDetail is not null) --Pick List Detail Loop
Begin
	Select @intParentLotId = pld.intParentLotId, @strParentLotNumber=pl.strParentLotNumber,@dblPickQty=dblPickQuantity 
	From @tblPickListDetail pld Join tblICParentLot pl on pld.intParentLotId=pl.intParentLotId 
	where intRowNo=@intMinPickDetail

	Select @intLotId=pld.intLotId From @tblPickListDetail pld where intRowNo=@intMinPickDetail

	If ISNULL(@intLotId,0) = 0
		Begin
			Set @ErrMsg='Lot Number cannot be empty for parent lot number ' + @strParentLotNumber + '.'
			RaisError(@ErrMsg,16,1)
		End

	Select @strLotNumber=strLotNumber,
	@dblAvailableUnit=(l.dblWeight - (Select ISNULL(SUM(ISNULL(sr.dblQty,0)),0) From tblICStockReservation sr Where sr.intLotId=@intLotId)) / 
	(CASE WHEN ISNULL(l.dblWeightPerQty,0)=0 THEN 1 ELSE l.dblWeightPerQty END)
	From tblICLot l Where intLotId=@intLotId

	If ISNULL(@dblPickQty,0) = 0
		Begin
			Set @ErrMsg='Pick Quantity cannot be 0 for lot number ' + @strLotNumber + '.'
			RaisError(@ErrMsg,16,1)
		End
	
	If @dblPickQty > @dblAvailableUnit
		Begin
			Set @ErrMsg='Pick Quantity cannot be greater than the available quantity for lot number ' + @strLotNumber + '.'
			RaisError(@ErrMsg,16,1)
		End

	Select @dblReqQtySum=SUM(dblIssuedQuantity),@dblPickQtySum=Sum(dblPickQuantity) From @tblPickListDetail Where intParentLotId=@intParentLotId
	If @dblPickQtySum < @dblReqQtySum
		Begin
			Set @ErrMsg='Sum of pick quantity should be greater than or equal to required quantity for the parent lot number ' + @strParentLotNumber + '.'
			RaisError(@ErrMsg,16,1)
		End

	Select @intMinPickDetail=Min(intRowNo) from @tblPickListDetail where intRowNo>@intMinPickDetail
End

End

If @ysnBlendSheetRequired = 0
Delete From @tblPickListDetail Where intLotId=0

If ISNULL(@strPickListNo,'') = ''
	Begin
		EXEC dbo.uspSMGetStartingNumber 68,@strPickListNo OUTPUT
		Update @tblPickList Set strPickListNo=@strPickListNo
	End

--Do not save items if consumption method is not By Lot
Delete tpl From @tblPickListDetail tpl 
Join tblMFRecipeItem ri on tpl.intItemId=ri.intItemId 
Join tblMFRecipe r on ri.intRecipeId=r.intRecipeId 
Where r.intItemId=@intBlendItemId AND r.intLocationId=@intLocationId AND r.ysnActive=1 AND ri.intConsumptionMethodId <> 1 

Begin Tran

If @intPickListId=0
Begin
	If Exists (Select 1 From tblMFWorkOrder 
	Where strWorkOrderNo in (Select strWorkOrderNo From @tblWorkOrder) And intKitStatusId <> 6)
		RaisError('Blend Sheet(s) are already picked.',16,1)

	Insert Into tblMFPickList(strPickListNo,strWorkOrderNo,intKitStatusId,intAssignedToId,intLocationId,dtmCreated,intCreatedUserId,dtmLastModified,intLastModifiedUserId,intConcurrencyId)
	Select @strPickListNo,strWorkOrderNo,7,intAssignedToId,intLocationId,@dtmCurrentDate,intUserId,@dtmCurrentDate,intUserId,1 From @tblPickList

	SET @intPickListId=SCOPE_IDENTITY()

	Insert Into tblMFPickListDetail(intPickListId,intLotId,intParentLotId,intItemId,intStorageLocationId,
	dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,dblPickQuantity,intPickUOMId,intStageLotId,
	dtmCreated,intCreatedUserId,dtmLastModified,intLastModifiedUserId,intConcurrencyId)
	Select @intPickListId,intLotId,intParentLotId,intItemId,intStorageLocationId,
	dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,dblPickQuantity,intPickUOMId,intLotId,
	@dtmCurrentDate,intUserId,@dtmCurrentDate,intUserId,1
	from @tblPickListDetail

	Update tblMFWorkOrder Set intKitStatusId=7,intPickListId=@intPickListId Where strWorkOrderNo in (Select strWorkOrderNo From @tblWorkOrder)
End
Else
Begin
	If  Exists (Select 1 From tblMFWorkOrder 
	Where strWorkOrderNo in (Select strWorkOrderNo From @tblWorkOrder) And intKitStatusId <> 7)
		RaisError('Blend Sheet(s) are already staged or transferred.',16,1)

	Select @intConCurrencyId=intConcurrencyId + 1 From tblMFPickList Where intPickListId=@intPickListId

	Update pl Set pl.intAssignedToId=tpl.intAssignedToId,pl.intLastModifiedUserId=tpl.intUserId,pl.dtmLastModified=@dtmCurrentDate,pl.intConcurrencyId=@intConCurrencyId 
	From tblMFPickList pl Join @tblPickList tpl on pl.intPickListId=tpl.intPickListId

	Update pld Set pld.dblPickQuantity=tpld.dblPickQuantity,pld.intLotId=tpld.intLotId,pld.intStageLotId=tpld.intLotId,
	pld.intLastModifiedUserId=tpld.intUserId,pld.dtmLastModified=@dtmCurrentDate,pld.intConcurrencyId=@intConCurrencyId
	From tblMFPickListDetail pld Join @tblPickListDetail tpld on pld.intPickListDetailId=tpld.intPickListDetailId 
	Where pld.intPickListId=@intPickListId

	--insert new picked lots
	Insert Into tblMFPickListDetail(intPickListId,intLotId,intParentLotId,intItemId,intStorageLocationId,
	dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,dblPickQuantity,intPickUOMId,intStageLotId,
	dtmCreated,intCreatedUserId,dtmLastModified,intLastModifiedUserId,intConcurrencyId)
	Select @intPickListId,intLotId,intParentLotId,intItemId,intStorageLocationId,
	dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,dblPickQuantity,intPickUOMId,intLotId,
	@dtmCurrentDate,intUserId,@dtmCurrentDate,intUserId,1
	from @tblPickListDetail Where intPickListDetailId=0
End

SET @intPickListIdOut=@intPickListId

--Reserve Lots
Exec [uspMFCreateLotReservationByPickList] @intPickListId

Commit Tran

EXEC sp_xml_removedocument @idoc 

END TRY  
  
BEGIN CATCH  
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
 SET @ErrMsg = ERROR_MESSAGE()  
 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc  
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')  
  
END CATCH  
