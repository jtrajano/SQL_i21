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
DECLARE @dblReqQtySum numeric(38,20)
DECLARE @dblPickQtySum numeric(38,20)
DECLARE @dblPickQty numeric(38,20)
DECLARE @dblAvailableUnit numeric(38,20)
Declare @ysnBlendSheetRequired bit
Declare @intLocationId int
Declare @intBlendItemId int
Declare @intWorkOrderId int
Declare @strBulkItemXml nvarchar(max)

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
	intSubLocationId int,
	dblQuantity numeric(38,20),
	intItemUOMId int,
	dblIssuedQuantity  numeric(38,20),
	intItemIssuedUOMId int,
	dblPickQuantity numeric(38,20),
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
	dblQuantity numeric(38,20),
	intItemUOMId int,
	dblIssuedQuantity  numeric(38,20),
	intItemIssuedUOMId int,
	dblPickQuantity numeric(38,20),
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

Declare @intManufacturingCellId int
		,@intSubLocationId int

Select TOP 1 @intBlendItemId=intItemId,@intManufacturingCellId=intManufacturingCellId,@intSubLocationId =intSubLocationId  From tblMFWorkOrder Where strWorkOrderNo in (Select strWorkOrderNo From @tblWorkOrder)

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
	@dblAvailableUnit=(l.dblWeight - (Select ISNULL(SUM(ISNULL(sr.dblQty,0)),0) From tblICStockReservation sr Where sr.intLotId=@intLotId AND ISNULL(sr.ysnPosted,0)=0)) / 
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
Begin
Delete From @tblPickListDetail Where intLotId=0
Delete From @tblPickListDetail Where dblPickQuantity<=0

Update pld Set pld.intLotId=NULL,pld.intParentLotId=NULL,pld.intStorageLocationId = CASE WHEN pld.intStorageLocationId=0 THEN NULL ELSE pld.intStorageLocationId END
From @tblPickListDetail pld Join tblICItem i on pld.intItemId=i.intItemId AND i.strLotTracking='No'

Update pld Set pld.intSubLocationId=CASE WHEN sl.intSubLocationId=0 THEN NULL ELSE sl.intSubLocationId End
From @tblPickListDetail pld Join tblICItem i on pld.intItemId=i.intItemId AND i.strLotTracking='No'
Join tblICStorageLocation sl on pld.intStorageLocationId=sl.intStorageLocationId
End

If ISNULL(@strPickListNo,'') = ''
	Begin
		--EXEC dbo.uspSMGetStartingNumber 68,@strPickListNo OUTPUT
		Declare @intCategoryId int
		Select @intCategoryId=intCategoryId from dbo.tblICItem Where intItemId=@intBlendItemId
		EXEC dbo.uspMFGeneratePatternId @intCategoryId = @intCategoryId
							,@intItemId = @intBlendItemId
							,@intManufacturingId = @intManufacturingCellId
							,@intSubLocationId = @intSubLocationId
							,@intLocationId = @intLocationId
							,@intOrderTypeId = NULL
							,@intBlendRequirementId = NULL
							,@intPatternCode = 68
							,@ysnProposed = 0
							,@strPatternString = @strPickListNo OUTPUT

		Update @tblPickList Set strPickListNo=@strPickListNo
	End

Select @intWorkOrderId=intWorkOrderId From tblMFWorkOrder Where strWorkOrderNo = (Select TOP 1 strWorkOrderNo From @tblWorkOrder)

--Xml for Bulk Items for Reservation
Set @strBulkItemXml='<root>'

--Input Item
Select @strBulkItemXml=COALESCE(@strBulkItemXml, '') + '<lot>' + 
'<intItemId>' + convert(varchar,tpl.intItemId) + '</intItemId>' +
'<intItemUOMId>' + convert(varchar,tpl.intItemUOMId) + '</intItemUOMId>' + 
'<dblQuantity>' + convert(varchar,tpl.dblQuantity) + '</dblQuantity>' + '</lot>'
From @tblPickListDetail tpl 
Join tblMFWorkOrderRecipeItem ri on tpl.intItemId=ri.intItemId 
Join tblMFWorkOrderRecipe r on ri.intWorkOrderId=r.intWorkOrderId 
Where r.intItemId=@intBlendItemId AND r.intLocationId=@intLocationId AND r.ysnActive=1 AND ri.intConsumptionMethodId IN (2,3) 
AND r.intWorkOrderId = @intWorkOrderId

--Sub Item
Select @strBulkItemXml=COALESCE(@strBulkItemXml, '') + '<lot>' +  
'<intItemId>' + convert(varchar,tpl.intItemId) + '</intItemId>' + 
'<intItemUOMId>' + convert(varchar,tpl.intItemUOMId) + '</intItemUOMId>' + 
'<dblQuantity>' + convert(varchar,tpl.dblQuantity) + '</dblQuantity>' + '</lot>'
From @tblPickListDetail tpl 
Join tblMFWorkOrderRecipeSubstituteItem rs on tpl.intItemId=rs.intSubstituteItemId
Join tblMFWorkOrderRecipeItem ri on rs.intItemId=ri.intItemId 
Join tblMFWorkOrderRecipe r on ri.intWorkOrderId=r.intWorkOrderId 
Where r.intItemId=@intBlendItemId AND r.intLocationId=@intLocationId AND r.ysnActive=1 AND ri.intConsumptionMethodId IN (2,3) 
AND r.intWorkOrderId = @intWorkOrderId

Set @strBulkItemXml=@strBulkItemXml+'</root>'

If LTRIM(RTRIM(@strBulkItemXml))='<root></root>' 
	Set @strBulkItemXml=''

--Do not save items if consumption method is not By Lot
Delete tpl From @tblPickListDetail tpl 
Join tblMFWorkOrderRecipeItem ri on tpl.intItemId=ri.intItemId 
Join tblMFWorkOrderRecipe r on ri.intWorkOrderId=r.intWorkOrderId 
Where r.intItemId=@intBlendItemId AND r.intLocationId=@intLocationId AND r.ysnActive=1 AND ri.intConsumptionMethodId <> 1 
AND r.intWorkOrderId = @intWorkOrderId

--Sub Items
Delete tpl From @tblPickListDetail tpl 
Join tblMFWorkOrderRecipeSubstituteItem rs on tpl.intItemId=rs.intSubstituteItemId
Join tblMFWorkOrderRecipeItem ri on rs.intItemId=ri.intItemId 
Join tblMFWorkOrderRecipe r on ri.intWorkOrderId=r.intWorkOrderId 
Where r.intItemId=@intBlendItemId AND r.intLocationId=@intLocationId AND r.ysnActive=1 AND ri.intConsumptionMethodId <> 1 
AND r.intWorkOrderId = @intWorkOrderId

Begin Tran

If @intPickListId=0
Begin
	If Exists (Select 1 From tblMFWorkOrder 
	Where strWorkOrderNo in (Select strWorkOrderNo From @tblWorkOrder) And intKitStatusId <> 6)
		RaisError('Blend Sheet(s) are already picked.',16,1)

	If Exists (Select 1 From tblMFPickList Where strPickListNo=@strPickListNo)
	Begin
		Set @ErrMsg='Pick List No ' + @strPickListNo + ' already exist.'
		RaisError(@ErrMsg,16,1)
	End

	Insert Into tblMFPickList(strPickListNo,strWorkOrderNo,intKitStatusId,intAssignedToId,intLocationId,dtmCreated,intCreatedUserId,dtmLastModified,intLastModifiedUserId,intConcurrencyId)
	Select @strPickListNo,strWorkOrderNo,7,intAssignedToId,intLocationId,@dtmCurrentDate,intUserId,@dtmCurrentDate,intUserId,1 From @tblPickList

	SET @intPickListId=SCOPE_IDENTITY()

	Insert Into tblMFPickListDetail(intPickListId,intLotId,intParentLotId,intItemId,intLocationId,intStorageLocationId,intSubLocationId,
	dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,dblPickQuantity,intPickUOMId,intStageLotId,
	dtmCreated,intCreatedUserId,dtmLastModified,intLastModifiedUserId,intConcurrencyId)
	Select @intPickListId,intLotId,intParentLotId,intItemId,@intLocationId,intStorageLocationId,intSubLocationId,
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

	Update pld Set pld.dblPickQuantity=tpld.dblPickQuantity,pld.dblQuantity=tpld.dblQuantity,pld.dblIssuedQuantity=tpld.dblIssuedQuantity,
	pld.intLotId=tpld.intLotId,pld.intStageLotId=tpld.intLotId,pld.intParentLotId=tpld.intParentLotId,pld.intStorageLocationId=tpld.intStorageLocationId,pld.intSubLocationId=tpld.intSubLocationId,
	pld.intItemUOMId=tpld.intItemUOMId,pld.intItemIssuedUOMId=tpld.intItemIssuedUOMId,pld.intPickUOMId=tpld.intPickUOMId,
	pld.intLastModifiedUserId=tpld.intUserId,pld.dtmLastModified=@dtmCurrentDate,pld.intConcurrencyId=@intConCurrencyId,
	pld.intItemId=tpld.intItemId
	From tblMFPickListDetail pld Join @tblPickListDetail tpld on pld.intPickListDetailId=tpld.intPickListDetailId 
	Where pld.intPickListId=@intPickListId AND pld.intLotId = pld.intStageLotId

	--Delete Records if not there in @tblPickListDetail table
	Delete From tblMFPickListDetail Where intPickListId=@intPickListId AND 
	intPickListDetailId NOT IN (Select intPickListDetailId From @tblPickListDetail) AND intLotId=intStageLotId

	--insert new picked lots
	Insert Into tblMFPickListDetail(intPickListId,intLotId,intParentLotId,intItemId,intLocationId,intStorageLocationId,intSubLocationId,
	dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,dblPickQuantity,intPickUOMId,intStageLotId,
	dtmCreated,intCreatedUserId,dtmLastModified,intLastModifiedUserId,intConcurrencyId)
	Select @intPickListId,intLotId,intParentLotId,intItemId,@intLocationId,intStorageLocationId,intSubLocationId,
	dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,dblPickQuantity,intPickUOMId,intLotId,
	@dtmCurrentDate,intUserId,@dtmCurrentDate,intUserId,1
	from @tblPickListDetail Where intPickListDetailId=0
End

SET @intPickListIdOut=@intPickListId

--Reserve Lots
Exec [uspMFCreateLotReservationByPickList] @intPickListId,@strBulkItemXml

Commit Tran

EXEC sp_xml_removedocument @idoc 

END TRY  
  
BEGIN CATCH  
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
 SET @ErrMsg = ERROR_MESSAGE()  
 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc  
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')  
  
END CATCH  
