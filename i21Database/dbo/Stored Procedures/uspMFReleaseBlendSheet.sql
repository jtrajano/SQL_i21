CREATE PROCEDURE [dbo].[uspMFReleaseBlendSheet]
@strXml nVarchar(Max),
@strWorkOrderNoOut nvarchar(50)='' OUT,
@dblBalancedQtyToProduceOut numeric(18,6) = 0 OUTPUT 
AS
Begin Try

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @idoc int 
Declare @intWorkOrderId int
Declare @strNextWONo nVarchar(50)
Declare @strDemandNo nVarchar(50)
Declare @intBlendRequirementId int
Declare @ErrMsg nVarchar(Max)
Declare @intLocationId int
Declare @intCellId int
Declare @intUserId int
Declare @dblQtyToProduce numeric(18,6)
Declare @dtmDueDate datetime
Declare @intExecutionOrder int=1
Declare @intBlendItemId int
Declare @strBlendItemNo nVarchar(50)
Declare @strBlendItemStatus nVarchar(50)
Declare @strInputItemNo nVarchar(50)
Declare @strInputItemStatus nVarchar(50)
Declare @ysnEnableParentLot bit=0

EXEC sp_xml_preparedocument @idoc OUTPUT, @strXml  

Begin Tran

Declare @tblBlendSheet table
(
	intWorkOrderId int,
	intItemId int,
	intCellId int,
	intMachineId int,
	dtmDueDate DateTime,
	dblQtyToProduce numeric(18,6),
	dblPlannedQuantity  numeric(18,6),
	dblBinSize numeric(18,6),
	strComment nVarchar(Max),
	ysnUseTemplate bit,
	ysnKittingEnabled bit,
	intLocationId int,
	intBlendRequirementId int,
	intItemUOMId int,
	intUserId int
)

Declare @tblItem table
(
	intRowNo int Identity(1,1),
	intItemId int,
	dblReqQty numeric(18,6)
)

Declare @tblLot table
(
	intRowNo int Identity(1,1),
	intLotId int,
	intItemId int,
	dblQty numeric(18,6),
	dblIssuedQuantity numeric(18,6),
	dblWeightPerUnit numeric(18,6),
	intItemUOMId int,
	intItemIssuedUOMId int,
	intUserId int,
	intRecipeItemId int,
	intLocationId int,
	intStorageLocationId int,
	ysnParentLot bit
)

Declare @tblBSLot table
(
	intLotId int,
	intItemId int,
	dblQty numeric(18,6),
	intUOMId int,
	dblIssuedQuantity numeric(18,6),
	intIssuedUOMId int,
	dblWeightPerUnit numeric(18,6),
	intRecipeItemId int,
	intLocationId int,
	intStorageLocationId int
)

INSERT INTO @tblBlendSheet(
 intWorkOrderId,intItemId,intCellId,intMachineId,dtmDueDate,dblQtyToProduce,dblPlannedQuantity,dblBinSize,strComment,  
 ysnUseTemplate,ysnKittingEnabled,intLocationId,intBlendRequirementId,intItemUOMId,intUserId)
 Select intWorkOrderId,intItemId,intCellId,intMachineId,dtmDueDate,dblQtyToProduce,dblPlannedQuantity,dblBinSize,strComment,  
 ysnUseTemplate,ysnKittingEnabled,intLocationId,intBlendRequirementId,intItemUOMId,intUserId
 FROM OPENXML(@idoc, 'root', 2)  
 WITH ( 
	intWorkOrderId int, 
	intItemId int,
	intCellId int,
	intMachineId int,
	dtmDueDate DateTime,
	dblQtyToProduce numeric(18,6),
	dblPlannedQuantity  numeric(18,6),
	dblBinSize numeric(18,6),
	strComment nVarchar(Max),
	ysnUseTemplate bit,
	ysnKittingEnabled bit,
	intLocationId int,
	intBlendRequirementId int,
	intItemUOMId int,
	intUserId int
	)
	
--Declare @dblQtyToProduce numeric(18,6),@intUserId int
--Select @intUserId=intUserId,@intLocationId=intLocationId from @tblBlendSheet

INSERT INTO @tblLot(
 intLotId,intItemId,dblQty,dblIssuedQuantity,dblWeightPerUnit,intItemUOMId,intItemIssuedUOMId,intUserId,intRecipeItemId,intLocationId,intStorageLocationId,ysnParentLot)
 Select intLotId,intItemId,dblQty,dblIssuedQuantity,dblWeightPerUnit,intItemUOMId,intItemIssuedUOMId,intUserId,intRecipeItemId,intLocationId,intStorageLocationId,ysnParentLot
 FROM OPENXML(@idoc, 'root/lot', 2)  
 WITH (  
	intLotId int,
	intItemId int,
	dblQty numeric(18,6),
	dblIssuedQuantity numeric(18,6),
	dblPickedQuantity numeric(18,6),
	dblWeightPerUnit numeric(18,6),
	intItemUOMId int,
	intItemIssuedUOMId int,
	intUserId int,
	intRecipeItemId int,
	intLocationId int,
	intStorageLocationId int,
	ysnParentLot bit
	)

Update @tblBlendSheet Set dblQtyToProduce=(Select sum(dblQty) from @tblLot)

Update @tblLot Set intStorageLocationId=null where intStorageLocationId=0

Select TOP 1 @ysnEnableParentLot=ISNULL(ysnEnableParentLot,0) From tblMFCompanyPreference

Select @dblQtyToProduce=dblQtyToProduce,@intUserId=intUserId,@intLocationId=intLocationId,@dtmDueDate=dtmDueDate,
@intBlendItemId=intItemId,@intCellId=intCellId from @tblBlendSheet

Select @strBlendItemNo=strItemNo,@strBlendItemStatus=strStatus From tblICItem Where intItemId=@intBlendItemId

If (@strBlendItemStatus <> 'Active')
	Begin
		Set @ErrMsg='The blend item ' + @strBlendItemNo + ' is not active, cannot release the blend sheet.'
		RaisError(@ErrMsg,16,1)
	End

Select TOP 1 @strInputItemNo=strItemNo,@strInputItemStatus=strStatus 
From @tblLot l join tblICItem i on l.intItemId=i.intItemId 
Where strStatus <> 'Active'

If @strInputItemNo is not null
	Begin
		Set @ErrMsg='The input item ' + @strInputItemNo + ' is not active, cannot release the blend sheet.'
		RaisError(@ErrMsg,16,1)
	End

If @ysnEnableParentLot=0
	Update a Set a.dblWeightPerUnit=b.dblWeightPerQty 
	from @tblLot a join tblICLot b on a.intLotId=b.intLotId
Else
	Update a Set a.dblWeightPerUnit=b.dblWeightPerQty 
	from @tblLot a join tblICParentLot b on a.intLotId=b.intParentLotId

Declare @intNoOfSheet int
Declare @intNoOfSheetOriginal int
Declare @dblRemainingQtyToProduce numeric(18,6)
Declare @PerBlendSheetQty  numeric(18,6)
Select @intNoOfSheet=Ceiling(@dblQtyToProduce/dblBinSize),
@PerBlendSheetQty=dblBinSize,
@intWorkOrderId=intWorkOrderId,
@intBlendRequirementId=intBlendRequirementId
from @tblBlendSheet

Set @intNoOfSheetOriginal=@intNoOfSheet

Declare @intRecipeId int,@intDemandItemId int,@intManufacturingProcessId int

Select @intRecipeId = intRecipeId ,@intManufacturingProcessId=a.intManufacturingProcessId 
from tblMFRecipe a Join @tblBlendSheet b on a.intItemId=b.intItemId
 and a.intLocationId=b.intLocationId and ysnActive=1

Select @strDemandNo=strDemandNo,@intDemandItemId=intItemId from tblMFBlendRequirement where intBlendRequirementId=@intBlendRequirementId


If Exists (Select 1 From tblMFWorkOrder where intWorkOrderId=@intWorkOrderId) 
		Delete From tblMFWorkOrder where intWorkOrderId=@intWorkOrderId

Declare @intItemCount int,
		@intLotCount int,
		@intItemId int,
		@dblReqQty numeric(18,6),
		@intLotId int,
		@dblQty numeric(18,6)

Select @intExecutionOrder = Count(1) From tblMFWorkOrder Where intManufacturingCellId=@intCellId 
And convert(date,dtmExpectedDate)=convert(date,@dtmDueDate) And intBlendRequirementId is not null
And intStatusId Not in (2,13)

While(@intNoOfSheet > 0)
Begin
	Set @intWorkOrderId=null

	--Calculate Required Quantity by Item
		if (@dblQtyToProduce>@PerBlendSheetQty)
			select @PerBlendSheetQty=@PerBlendSheetQty
			else
			select @PerBlendSheetQty=@dblQtyToProduce

		Delete from @tblItem
		Insert into @tblItem(intItemId,dblReqQty)
		Select ri.intItemId,(ri.dblCalculatedQuantity * (@PerBlendSheetQty/r.dblQuantity)) AS RequiredQty
		From tblMFRecipeItem ri 
		Join tblMFRecipe r on r.intRecipeId=ri.intRecipeId 
		where ri.intRecipeId=@intRecipeId and ri.intRecipeItemTypeId=1
		UNION
		Select rs.intSubstituteItemId,(rs.dblQuantity * (@PerBlendSheetQty/r.dblQuantity)) AS RequiredQty
		From tblMFRecipeSubstituteItem rs 
		Join tblMFRecipe r on r.intRecipeId=rs.intRecipeId 
		where rs.intRecipeId=@intRecipeId and rs.intRecipeItemTypeId=1

	Select @intItemCount=Min(intRowNo) from @tblItem

	While(@intItemCount is not null)
	Begin
			Set @intLotCount=null
			Set @strNextWONo=null

			Select @intItemId=intItemId,@dblReqQty=dblReqQty from @tblItem where intRowNo=@intItemCount
			Select @intLotCount=Min(intRowNo) from @tblLot where intItemId=@intItemId and dblQty>0
			While(@intLotCount is not null)
			Begin
				Select @intLotId=intLotId,@dblQty=dblQty from @tblLot where intRowNo=@intLotCount
			
				if (@dblQty >= @dblReqQty And @intNoOfSheet>1)
					Begin
						insert into @tblBSLot(intLotId,intItemId,dblQty,intUOMId,dblIssuedQuantity,intIssuedUOMId,dblWeightPerUnit,intRecipeItemId,intLocationId,intStorageLocationId)
						Select intLotId,intItemId,@dblReqQty,intItemUOMId,@dblReqQty/dblWeightPerUnit,intItemIssuedUOMId,dblWeightPerUnit,intRecipeItemId,intLocationId,intStorageLocationId 
						from @tblLot where intRowNo=@intLotCount

						Update @tblLot set dblQty=dblQty-@dblReqQty where intRowNo=@intLotCount
						GOTO NextItem
					End
					Else
					Begin
						insert into @tblBSLot(intLotId,intItemId,dblQty,intUOMId,dblIssuedQuantity,intIssuedUOMId,dblWeightPerUnit,intRecipeItemId,intLocationId,intStorageLocationId)
						Select intLotId,intItemId,@dblQty,intItemUOMId,@dblQty/dblWeightPerUnit,intItemIssuedUOMId,dblWeightPerUnit,intRecipeItemId,intLocationId,intStorageLocationId 
						from @tblLot where intRowNo=@intLotCount

						Update @tblLot set dblQty=0 where intRowNo=@intLotCount
						Set @dblReqQty=@dblReqQty-@dblQty
					End

				Select @intLotCount=Min(intRowNo) from @tblLot where intItemId=@intItemId and dblQty>0 And intRowNo>@intLotCount	
			End
			
			NextItem:
			Select @intItemCount=Min(intRowNo) from @tblItem where intRowNo>@intItemCount
	End

	--Create WorkOrder
	If (select count(1) from tblMFWorkOrder where strWorkOrderNo like @strDemandNo + '%') = 0
	Set @strNextWONo=convert(varchar,@strDemandNo) + '01'
	else
	Select @strNextWONo= convert(varchar,@strDemandNo) + right('00' + Convert(varchar,(Max(Cast(right(strWorkOrderNo,2) as int)))+1),2)  from tblMFWorkOrder where strWorkOrderNo like @strDemandNo + '%'

	Set @intExecutionOrder=@intExecutionOrder +1 

	insert into tblMFWorkOrder(strWorkOrderNo,intItemId,dblQuantity,intItemUOMId,intStatusId,intManufacturingCellId,intMachineId,intLocationId,dblBinSize,dtmExpectedDate,intExecutionOrder,
	intProductionTypeId,dblPlannedQuantity,intBlendRequirementId,ysnKittingEnabled,ysnUseTemplate,strComment,dtmCreated,intCreatedUserId,dtmLastModified,intLastModifiedUserId,dtmReleasedDate,intManufacturingProcessId)
	Select @strNextWONo ,intItemId,@PerBlendSheetQty,intItemUOMId,9,intCellId,intMachineId,intLocationId,dblBinSize,dtmDueDate,@intExecutionOrder,1,
	Case When @intNoOfSheetOriginal=1 then dblPlannedQuantity else @PerBlendSheetQty End,intBlendRequirementId,
	ysnKittingEnabled,ysnUseTemplate,strComment,GetDate(),intUserId,GetDate(),intUserId,GetDate(),@intManufacturingProcessId
	from @tblBlendSheet

	Set @intWorkOrderId=SCOPE_IDENTITY()
	
	--Insert Into Input/Consumed Lot
	if @ysnEnableParentLot=0
	Begin
		Insert Into tblMFWorkOrderInputLot(intWorkOrderId,intLotId,intItemId,dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,intSequenceNo,
		dtmCreated,intCreatedUserId,dtmLastModified,intLastModifiedUserId,intRecipeItemId)
		Select @intWorkOrderId,intLotId,intItemId,dblQty,intUOMId,dblIssuedQuantity,intIssuedUOMId,null,
		GetDate(),@intUserId,GetDate(),@intUserId,intRecipeItemId
		From @tblBSLot

		Insert Into tblMFWorkOrderConsumedLot(intWorkOrderId,intLotId,intItemId,dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,intSequenceNo,
		dtmCreated,intCreatedUserId,dtmLastModified,intLastModifiedUserId,intRecipeItemId)
		Select @intWorkOrderId,intLotId,intItemId,dblQty,intUOMId,dblIssuedQuantity,intIssuedUOMId,null,
		GetDate(),@intUserId,GetDate(),@intUserId,intRecipeItemId
		From @tblBSLot
	End
	Else
	Begin
		Insert Into tblMFWorkOrderInputParentLot(intWorkOrderId,intParentLotId,intItemId,dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,intSequenceNo,
		dtmCreated,intCreatedUserId,dtmLastModified,intLastModifiedUserId,intRecipeItemId,dblWeightPerUnit,intLocationId,intStorageLocationId)
		Select @intWorkOrderId,intLotId,intItemId,dblQty,intUOMId,dblIssuedQuantity,intIssuedUOMId,null,
		GetDate(),@intUserId,GetDate(),@intUserId,intRecipeItemId,dblWeightPerUnit,intLocationId,intStorageLocationId
		From @tblBSLot
	End

	if @ysnEnableParentLot=0
		Update tblMFWorkOrder Set dblQuantity=(Select sum(dblQuantity) from tblMFWorkOrderConsumedLot where intWorkOrderId=@intWorkOrderId) where intWorkOrderId=@intWorkOrderId
	Else
		Update tblMFWorkOrder Set dblQuantity=(Select sum(dblQuantity) from tblMFWorkOrderInputParentLot where intWorkOrderId=@intWorkOrderId) where intWorkOrderId=@intWorkOrderId

	EXEC dbo.uspMFCopyRecipe @intItemId = @intDemandItemId
			,@intLocationId = @intLocationId
			,@intUserId = @intUserId
			,@intWorkOrderId = @intWorkOrderId

	--Create Quality Computations
	Exec uspMFCreateBlendRecipeComputation @intWorkOrderId=@intWorkOrderId,@intTypeId=1,@strXml=@strXml

	Delete from @tblBSLot

	Select @dblQtyToProduce=@dblQtyToProduce-@PerBlendSheetQty
	Set @intNoOfSheet=@intNoOfSheet - 1
End


Update tblMFBlendRequirement Set dblIssuedQty=(Select SUM(dblQuantity) from tblMFWorkOrder where intBlendRequirementId=@intBlendRequirementId) where intBlendRequirementId=@intBlendRequirementId

Update tblMFBlendRequirement Set intStatusId=2 where intBlendRequirementId=@intBlendRequirementId and ISNULL(dblIssuedQty,0) >= dblQuantity

Select @dblBalancedQtyToProduceOut = (dblQuantity - ISNULL(dblIssuedQty,0)) From tblMFBlendRequirement Where intBlendRequirementId=@intBlendRequirementId

if @dblBalancedQtyToProduceOut <=0 
	Set @dblBalancedQtyToProduceOut=0

Set @strWorkOrderNoOut=@strNextWONo;

Commit Tran

EXEC sp_xml_removedocument @idoc 

END TRY  
  
BEGIN CATCH  
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
 SET @ErrMsg = ERROR_MESSAGE()  
 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc  
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')  
  
END CATCH  
