CREATE PROCEDURE [dbo].[uspMFReleaseBlendSheet]
@strXml nVarchar(Max),
@strWorkOrderNoOut nvarchar(50)='' OUT,
@dblBalancedQtyToProduceOut numeric(38,20) = 0 OUTPUT,
@intWorkOrderIdOut int=0 OUTPUT 
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
Declare @dblQtyToProduce numeric(38,20)
Declare @dtmDueDate datetime
Declare @intExecutionOrder int=1
Declare @intBlendItemId int
Declare @strBlendItemNo nVarchar(50)
Declare @strBlendItemStatus nVarchar(50)
Declare @strInputItemNo nVarchar(50)
Declare @strInputItemStatus nVarchar(50)
Declare @ysnEnableParentLot bit=0
Declare @intRecipeId int
Declare @intManufacturingProcessId int
Declare @dblBinSize numeric(38,20)
Declare @intNoOfSheet int
Declare @intNoOfSheetOriginal int
Declare @dblRemainingQtyToProduce numeric(38,20)
Declare @PerBlendSheetQty  numeric(38,20)
Declare @ysnCalculateNoSheetUsingBinSize bit=0
Declare @ysnKittingEnabled bit
Declare @ysnRequireCustomerApproval bit
Declare @intWorkOrderStatusId INT
Declare @intKitStatusId INT=NULL
Declare @dblBulkReqQuantity numeric(38,20)
Declare @dblPlannedQuantity numeric(38,20)
Declare @ysnAllInputItemsMandatory bit

EXEC sp_xml_preparedocument @idoc OUTPUT, @strXml  

Begin Tran

Declare @tblBlendSheet table
(
	intWorkOrderId int,
	intItemId int,
	intCellId int,
	intMachineId int,
	dtmDueDate DateTime,
	dblQtyToProduce numeric(38,20),
	dblPlannedQuantity  numeric(38,20),
	dblBinSize numeric(38,20),
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
	dblReqQty numeric(38,20),
	ysnIsSubstitute BIT
	,intConsumptionMethodId INT
	,intConsumptionStoragelocationId INT
	,intParentItemId int
)

Declare @tblLot table
(
	intRowNo int Identity(1,1),
	intLotId int,
	intItemId int,
	dblQty numeric(38,20),
	dblIssuedQuantity numeric(38,20),
	dblWeightPerUnit numeric(38,20),
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
	dblQty numeric(38,20),
	intUOMId int,
	dblIssuedQuantity numeric(38,20),
	intIssuedUOMId int,
	dblWeightPerUnit numeric(38,20),
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
	dblQtyToProduce numeric(38,20),
	dblPlannedQuantity  numeric(38,20),
	dblBinSize numeric(38,20),
	strComment nVarchar(Max),
	ysnUseTemplate bit,
	ysnKittingEnabled bit,
	intLocationId int,
	intBlendRequirementId int,
	intItemUOMId int,
	intUserId int
	)
	
INSERT INTO @tblLot(
 intLotId,intItemId,dblQty,dblIssuedQuantity,dblWeightPerUnit,intItemUOMId,intItemIssuedUOMId,intUserId,intRecipeItemId,intLocationId,intStorageLocationId,ysnParentLot)
 Select intLotId,intItemId,dblQty,dblIssuedQuantity,dblWeightPerUnit,intItemUOMId,intItemIssuedUOMId,intUserId,intRecipeItemId,intLocationId,intStorageLocationId,ysnParentLot
 FROM OPENXML(@idoc, 'root/lot', 2)  
 WITH (  
	intLotId int,
	intItemId int,
	dblQty numeric(38,20),
	dblIssuedQuantity numeric(38,20),
	dblPickedQuantity numeric(38,20),
	dblWeightPerUnit numeric(38,20),
	intItemUOMId int,
	intItemIssuedUOMId int,
	intUserId int,
	intRecipeItemId int,
	intLocationId int,
	intStorageLocationId int,
	ysnParentLot bit
	)

--Available Qty Check
Declare @tblLotSummary AS table
(
	intRowNo int IDENTITY,
	intLotId INT,
	intItemId int,
	dblQty NUMERIC(38,20)	
)
Declare @dblInputAvlQty NUMERIC(38,20)
Declare @dblInputReqQty NUMERIC(38,20)
Declare @intInputLotId int
Declare @intInputItemId int
Declare @strInputLotNumber nvarchar(50)

INSERT INTO @tblLotSummary(intLotId,intItemId,dblQty)
Select intLotId,intItemId,SUM(dblQty) From @tblLot GROUP BY intLotId,intItemId

Declare @intMinLot INT
Select @intMinLot=Min(intRowNo) From @tblLotSummary
While(@intMinLot is not null)
Begin
	Select @intInputLotId=intLotId,@dblInputReqQty=dblQty,@intInputItemId=intItemId From @tblLotSummary Where intRowNo=@intMinLot
	Select @dblInputAvlQty=dblWeight - (Select ISNULL(SUM(ISNULL(dblQty,0)),0) From tblICStockReservation Where intLotId=@intInputLotId) 
	From tblICLot Where intLotId=@intInputLotId

	if @dblInputReqQty > @dblInputAvlQty
	Begin
		Select @strInputLotNumber=strLotNumber From tblICLot Where intLotId=@intInputLotId
		Select @strInputItemNo=strItemNo From tblICItem Where intItemId=@intInputItemId

		Set @ErrMsg='Quantity of ' + CONVERT(varchar,@dblInputReqQty) + ' from lot ' + @strInputLotNumber + ' of item ' + CONVERT(nvarchar,@strInputItemNo) +
		+ ' cannot be added to blend sheet because the lot has available qty of ' + CONVERT(varchar,@dblInputAvlQty) + '.'
		RaisError(@ErrMsg,16,1)
	End

	Select @intMinLot=Min(intRowNo) From @tblLotSummary Where intRowNo>@intMinLot
End
--End Available Qty Check

Update @tblBlendSheet Set dblQtyToProduce=(Select sum(dblQty) from @tblLot)

Update @tblLot Set intStorageLocationId=null where intStorageLocationId=0

Select TOP 1 @ysnEnableParentLot=ISNULL(ysnEnableParentLot,0) From tblMFCompanyPreference

Select @dblQtyToProduce=dblQtyToProduce,@intUserId=intUserId,@intLocationId=intLocationId,@dtmDueDate=dtmDueDate,
@intBlendItemId=intItemId,@intCellId=intCellId,@intBlendRequirementId=intBlendRequirementId,@dblBinSize=dblBinSize,
@intWorkOrderId=intWorkOrderId,@ysnKittingEnabled=ysnKittingEnabled,@dblPlannedQuantity=dblPlannedQuantity from @tblBlendSheet

Select @strDemandNo=strDemandNo from tblMFBlendRequirement where intBlendRequirementId=@intBlendRequirementId

Select @strBlendItemNo=strItemNo,@strBlendItemStatus=strStatus,@ysnRequireCustomerApproval=ysnRequireCustomerApproval 
From tblICItem Where intItemId=@intBlendItemId

--If @ysnKittingEnabled=1 And (@ysnEnableParentLot=0 OR (Select TOP 1 ysnParentLot From @tblLot) = 0 )
--	Begin
--		Set @ErrMsg='Please enable Parent Lot for Kitting.'
--		RaisError(@ErrMsg,16,1)
--	End

If @ysnKittingEnabled=1
	Set @intKitStatusId=6

If @ysnRequireCustomerApproval = 1
	Set @intWorkOrderStatusId=5 --Hold
Else
	Set @intWorkOrderStatusId=9 --Released

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
	Update a Set a.dblWeightPerUnit=(Select TOP 1 dblWeightPerQty From tblICLot Where intParentLotId=b.intParentLotId)
	from @tblLot a join tblICParentLot b on a.intLotId=b.intParentLotId

Select @intRecipeId = intRecipeId ,@intManufacturingProcessId=a.intManufacturingProcessId 
from tblMFRecipe a Join @tblBlendSheet b on a.intItemId=b.intItemId
 and a.intLocationId=b.intLocationId and ysnActive=1

Select @ysnCalculateNoSheetUsingBinSize=CASE When UPPER(pa.strAttributeValue) = 'TRUE' then 1 Else 0 End 
From tblMFManufacturingProcessAttribute pa Join tblMFAttribute at on pa.intAttributeId=at.intAttributeId
Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId 
and at.strAttributeName='Calculate No Of Blend Sheet Using Blend Bin Size'

Select @ysnAllInputItemsMandatory=CASE When UPPER(pa.strAttributeValue) = 'TRUE' then 1 Else 0 End 
From tblMFManufacturingProcessAttribute pa Join tblMFAttribute at on pa.intAttributeId=at.intAttributeId
Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId 
and UPPER(at.strAttributeName)=UPPER('All input items mandatory for consumption')

--Missing Item Check / Required Qty Check
if @ysnAllInputItemsMandatory=1
Begin
	Insert into @tblItem(intItemId,dblReqQty,ysnIsSubstitute,intConsumptionMethodId,intConsumptionStoragelocationId,intParentItemId)
	Select ri.intItemId,(ri.dblCalculatedQuantity * (@dblPlannedQuantity/r.dblQuantity)) AS RequiredQty,0 AS ysnIsSubstitute,ri.intConsumptionMethodId,ri.intStorageLocationId,0
	From tblMFRecipeItem ri 
	Join tblMFRecipe r on r.intRecipeId=ri.intRecipeId 
	where ri.intRecipeId=@intRecipeId and ri.intRecipeItemTypeId=1
	UNION
	Select rs.intSubstituteItemId,(rs.dblQuantity * (@dblPlannedQuantity/r.dblQuantity)) AS RequiredQty,1 AS ysnIsSubstitute,0,0,rs.intItemId
	From tblMFRecipeSubstituteItem rs 
	Join tblMFRecipe r on r.intRecipeId=rs.intRecipeId 
	where rs.intRecipeId=@intRecipeId and rs.intRecipeItemTypeId=1

	Declare @intMinMissingItem INT
	Declare @intConsumptionMethodId int
	Declare @dblInputItemBSQty numeric(38,20)
	Declare @dblBulkItemAvlQty numeric(38,20)

	Select @intMinMissingItem=Min(intRowNo) From @tblItem
	While(@intMinMissingItem is not null)
	Begin
		Select @intInputItemId=intItemId,@dblInputReqQty=dblReqQty,@intConsumptionMethodId=intConsumptionMethodId 
		From @tblItem Where intRowNo=@intMinMissingItem AND ysnIsSubstitute=0

		If @intConsumptionMethodId=1
		Begin
			If Not Exists (Select 1 From @tblLot Where intItemId=@intInputItemId) 
			AND 
			Not Exists (Select 1 From @tblLot Where intItemId=(Select intItemId From @tblItem Where intParentItemId=@intInputItemId))
			Begin
				Select @strInputItemNo=strItemNo From tblICItem Where intItemId=@intInputItemId

				Set @ErrMsg='There is no lot selected for item ' + CONVERT(nvarchar,@strInputItemNo) + '.'
				RaisError(@ErrMsg,16,1)
			End

			Select @dblInputItemBSQty=ISNULL(SUM(ISNULL(dblQty,0)),0) From @tblLot Where intItemId=@intInputItemId

			--Include Sub Items
			Set @dblInputItemBSQty=@dblInputItemBSQty + (Select ISNULL(SUM(ISNULL(dblQty,0)),0) From @tblLot 
			Where intItemId in (Select intItemId From @tblItem Where intParentItemId = @intInputItemId))

			if @dblInputItemBSQty < @dblInputReqQty
			Begin
				Select @strInputItemNo=strItemNo From tblICItem Where intItemId=@intInputItemId

				Set @ErrMsg='Selected quantity of ' + CONVERT(varchar,@dblInputItemBSQty) + ' of item ' + CONVERT(nvarchar,@strInputItemNo) +
				+ ' is less than the required quantity of ' + CONVERT(varchar,@dblInputReqQty) + '.'
				RaisError(@ErrMsg,16,1)
			End
		End
		
		--Bulk
		If @intConsumptionMethodId in (2,3)
		Begin
			Select @dblBulkItemAvlQty=ISNULL(SUM(ISNULL(dblWeight,0)),0) From tblICLot l Join tblICLotStatus ls on l.intLotStatusId=ls.intLotStatusId
			Where l.intItemId=@intInputItemId AND l.intLocationId = @intLocationId
				AND ls.strPrimaryStatus IN (
					'Active'
					,'Quarantine'
					)
				AND l.dtmExpiryDate >= GETDATE()
				AND l.dblWeight >0

				--Iclude Sub Items
				Set @dblBulkItemAvlQty = @dblBulkItemAvlQty + (Select ISNULL(SUM(ISNULL(dblWeight,0)),0) From tblICLot l Join tblICLotStatus ls on l.intLotStatusId=ls.intLotStatusId
				Where l.intItemId in (Select intItemId From @tblItem Where intParentItemId = @intInputItemId)
				AND l.intLocationId = @intLocationId
				AND ls.strPrimaryStatus IN (
					'Active'
					,'Quarantine'
					)
				AND l.dtmExpiryDate >= GETDATE()
				AND l.dblWeight >0)

			if @dblBulkItemAvlQty < @dblInputReqQty
			Begin
				Select @strInputItemNo=strItemNo From tblICItem Where intItemId=@intInputItemId

				Set @ErrMsg='Required quantity of ' + CONVERT(varchar,@dblInputReqQty) + ' of bulk item ' + CONVERT(nvarchar,@strInputItemNo) +
				+ ' is not avaliable.'
				RaisError(@ErrMsg,16,1)
			End
		End

		Select @intMinMissingItem=Min(intRowNo) From @tblItem Where intRowNo>@intMinMissingItem AND ysnIsSubstitute=0
	End
End

If @ysnCalculateNoSheetUsingBinSize=0
	Begin
		Set @intNoOfSheet=1
		Set @PerBlendSheetQty=@dblQtyToProduce
		Set @intNoOfSheetOriginal=@intNoOfSheet
	End
Else
	Begin
		Set @intNoOfSheet=Ceiling(@dblQtyToProduce/@dblBinSize)
		Set @PerBlendSheetQty=@dblBinSize
		Set @intNoOfSheetOriginal=@intNoOfSheet
	End

If Exists (Select 1 From tblMFWorkOrder where intWorkOrderId=@intWorkOrderId) 
		Delete From tblMFWorkOrder where intWorkOrderId=@intWorkOrderId

Declare @intItemCount int,
		@intLotCount int,
		@intItemId int,
		@dblReqQty numeric(38,20),
		@intLotId int,
		@dblQty numeric(38,20)

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
						Select intLotId,intItemId,@dblReqQty,intItemUOMId,CASE WHEN intItemUOMId=intItemIssuedUOMId THEN @dblReqQty ELSE @dblReqQty/dblWeightPerUnit END,intItemIssuedUOMId,dblWeightPerUnit,intRecipeItemId,intLocationId,intStorageLocationId 
						from @tblLot where intRowNo=@intLotCount

						Update @tblLot set dblQty=dblQty-@dblReqQty where intRowNo=@intLotCount
						GOTO NextItem
					End
					Else
					Begin
						insert into @tblBSLot(intLotId,intItemId,dblQty,intUOMId,dblIssuedQuantity,intIssuedUOMId,dblWeightPerUnit,intRecipeItemId,intLocationId,intStorageLocationId)
						Select intLotId,intItemId,@dblQty,intItemUOMId,CASE WHEN intItemUOMId=intItemIssuedUOMId THEN @dblQty ELSE @dblQty/dblWeightPerUnit END,intItemIssuedUOMId,dblWeightPerUnit,intRecipeItemId,intLocationId,intStorageLocationId 
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
	intProductionTypeId,dblPlannedQuantity,intBlendRequirementId,ysnKittingEnabled,intKitStatusId,ysnUseTemplate,strComment,dtmCreated,intCreatedUserId,dtmLastModified,intLastModifiedUserId,dtmReleasedDate,intManufacturingProcessId)
	Select @strNextWONo ,intItemId,@PerBlendSheetQty,intItemUOMId,@intWorkOrderStatusId,intCellId,intMachineId,intLocationId,dblBinSize,dtmDueDate,@intExecutionOrder,1,
	Case When @intNoOfSheetOriginal=1 then dblPlannedQuantity else @PerBlendSheetQty End,intBlendRequirementId,
	ysnKittingEnabled,@intKitStatusId,ysnUseTemplate,strComment,GetDate(),intUserId,GetDate(),intUserId,GetDate(),@intManufacturingProcessId
	from @tblBlendSheet

	Set @intWorkOrderId=SCOPE_IDENTITY()
	
	--Insert Into Input/Consumed Lot
	if @ysnEnableParentLot=0
	Begin
		If @ysnKittingEnabled=0
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
			Insert Into tblMFWorkOrderInputLot(intWorkOrderId,intLotId,intItemId,dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,intSequenceNo,
			dtmCreated,intCreatedUserId,dtmLastModified,intLastModifiedUserId,intRecipeItemId)
			Select @intWorkOrderId,intLotId,intItemId,dblQty,intUOMId,dblIssuedQuantity,intIssuedUOMId,null,
			GetDate(),@intUserId,GetDate(),@intUserId,intRecipeItemId
			From @tblBSLot
		End
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
		If @ysnKittingEnabled=0
			Update tblMFWorkOrder Set dblQuantity=(Select sum(dblQuantity) from tblMFWorkOrderConsumedLot where intWorkOrderId=@intWorkOrderId) where intWorkOrderId=@intWorkOrderId
		Else
			Update tblMFWorkOrder Set dblQuantity=(Select sum(dblQuantity) from tblMFWorkOrderInputLot where intWorkOrderId=@intWorkOrderId) where intWorkOrderId=@intWorkOrderId
	Else
		Update tblMFWorkOrder Set dblQuantity=(Select sum(dblQuantity) from tblMFWorkOrderInputParentLot where intWorkOrderId=@intWorkOrderId) where intWorkOrderId=@intWorkOrderId

	EXEC dbo.uspMFCopyRecipe @intItemId = @intBlendItemId
			,@intLocationId = @intLocationId
			,@intUserId = @intUserId
			,@intWorkOrderId = @intWorkOrderId

	--Create Quality Computations
	Exec uspMFCreateBlendRecipeComputation @intWorkOrderId=@intWorkOrderId,@intTypeId=1,@strXml=@strXml

	--Create Reservation
	Exec [uspMFCreateLotReservation] @intWorkOrderId=@intWorkOrderId,@ysnReservationByParentLot=@ysnEnableParentLot

	Delete from @tblBSLot

	Select @dblQtyToProduce=@dblQtyToProduce-@PerBlendSheetQty
	Set @intNoOfSheet=@intNoOfSheet - 1
End

--Update Bulk Item(By Location or FIFO) Standard Required Qty Calculated Using Planned Qty
--If @ysnCalculateNoSheetUsingBinSize=0
Begin
	SELECT 
		@dblBulkReqQuantity = ISNULL(SUM((ri.dblCalculatedQuantity * (@dblPlannedQuantity / r.dblQuantity))),0)
	FROM tblMFRecipeItem ri
	JOIN tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
	WHERE r.intItemId = @intBlendItemId
		AND intLocationId = @intLocationId
		AND ysnActive = 1
		AND ri.intRecipeItemTypeId = 1
		AND ri.intConsumptionMethodId IN (2,3)

Update tblMFWorkOrder Set dblQuantity=dblQuantity + @dblBulkReqQuantity Where intWorkOrderId=@intWorkOrderId
End

Update tblMFBlendRequirement Set dblIssuedQty=(Select SUM(dblQuantity) from tblMFWorkOrder where intBlendRequirementId=@intBlendRequirementId) where intBlendRequirementId=@intBlendRequirementId

Update tblMFBlendRequirement Set intStatusId=2 where intBlendRequirementId=@intBlendRequirementId and ISNULL(dblIssuedQty,0) >= dblQuantity

Select @dblBalancedQtyToProduceOut = (dblQuantity - ISNULL(dblIssuedQty,0)) From tblMFBlendRequirement Where intBlendRequirementId=@intBlendRequirementId

if @dblBalancedQtyToProduceOut <=0 
	Set @dblBalancedQtyToProduceOut=0

Set @strWorkOrderNoOut=@strNextWONo;
Set @intWorkOrderIdOut=@intWorkOrderId

Commit Tran

EXEC sp_xml_removedocument @idoc 

END TRY  
  
BEGIN CATCH  
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
 SET @ErrMsg = ERROR_MESSAGE()  
 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc  
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')  
  
END CATCH  
