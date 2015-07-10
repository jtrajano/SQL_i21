
CREATE PROCEDURE [dbo].[uspMFSaveBlendSheet]
@strXml nVarchar(Max),
@intWorkOrderId int Out
AS
Begin Try

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @idoc int 
Declare @ErrMsg nVarchar(Max)

Set @intWorkOrderId=0;

EXEC sp_xml_preparedocument @idoc OUTPUT, @strXml

Declare @tblBlendSheet table
(
	intWorkOrderId int,
	strWorkOrderNo nVarchar(50),
	intBlendRequirementId int,
	intItemId int,
	intCellId int,
	intMachineId int,
	dtmDueDate DateTime,
	dblQtyToProduce numeric(18,6),
	dblPlannedQuantity numeric(18,6),
	intItemUOMId int,
	dblBinSize numeric(18,6),
	strComment nVarchar(Max),
	ysnUseTemplate bit,
	ysnKittingEnabled bit,
	intLocationId int,
	intUserId int,
	intConcurrencyId int
)

Declare @tblLot table
(
	intRowNo int Identity(1,1),
	intWorkOrderInputLotId int,
	intLotId int,
	intItemId int,
	dblQty numeric(18,6),
	intItemUOMId int,
	dblIssuedQuantity numeric(18,6),
	intItemIssuedUOMId int,
	intUserId int,
	strRowState nVarchar(50),
	intRecipeItemId int
)

INSERT INTO @tblBlendSheet(intWorkOrderId,strWorkOrderNo,intBlendRequirementId,
 intItemId,intCellId,intMachineId,dtmDueDate,dblQtyToProduce,dblPlannedQuantity,intItemUOMId,dblBinSize,strComment,  
 ysnUseTemplate,ysnKittingEnabled,intLocationId,intUserId,intConcurrencyId)
 Select intWorkOrderId,strWorkOrderNo,intBlendRequirementId,
 intItemId,intCellId,intMachineId,dtmDueDate,dblQtyToProduce,dblPlannedQuantity,intItemUOMId,dblBinSize,strComment,  
 ysnUseTemplate,ysnKittingEnabled,intLocationId,intUserId,intConcurrencyId
 FROM OPENXML(@idoc, 'root', 2)  
 WITH (
	intWorkOrderId int,
	strWorkOrderNo nVarchar(50),  
    intBlendRequirementId int,
	intItemId int,
	intCellId int,
	intMachineId int,
	dtmDueDate DateTime,
	dblQtyToProduce numeric(18,6),
	dblPlannedQuantity  numeric(18,6),
	intItemUOMId int,
	dblBinSize numeric(18,6),
	strComment nVarchar(Max),
	ysnUseTemplate bit,
	ysnKittingEnabled bit,
	intLocationId int,
	intUserId int,
	intConcurrencyId int
	)

INSERT INTO @tblLot(
 intWorkOrderInputLotId,intLotId,intItemId,dblQty,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,strRowState,intRecipeItemId)
 Select intWorkOrderInputLotId,intLotId,intItemId,dblQty,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,strRowState,intRecipeItemId
 FROM OPENXML(@idoc, 'root/lot', 2)  
 WITH (  
	intWorkOrderInputLotId int,
	intLotId int,
	intItemId int,
	dblQty numeric(18,6),
	intItemUOMId int,
	dblIssuedQuantity numeric(18,6),
	intItemIssuedUOMId int,
	intUserId int,
	strRowState nVarchar(50),
	intRecipeItemId int
	)

Declare	@intBlendRequirementId int,
		@strDemandNo nVarchar(50)

Select @intWorkOrderId=intWorkOrderId,@intBlendRequirementId=intBlendRequirementId from @tblBlendSheet
Select @strDemandNo=strDemandNo from tblMFBlendRequirement where intBlendRequirementId=@intBlendRequirementId

Begin Tran

If @intWorkOrderId=0
Begin
Declare @strNextWONo nVarchar(50)

If (select count(1) from tblMFWorkOrder where strWorkOrderNo like @strDemandNo + '%') = 0
Set @strNextWONo=convert(varchar,@strDemandNo) + '01'
else
Select @strNextWONo= convert(varchar,@strDemandNo) + right('00' + Convert(varchar,(Max(Cast(right(strWorkOrderNo,2) as int)))+1),2)  from tblMFWorkOrder where strWorkOrderNo like @strDemandNo + '%'

insert into tblMFWorkOrder(strWorkOrderNo,intItemId,dblQuantity,intItemUOMId,intStatusId,intManufacturingCellId,intMachineId,intLocationId,dblBinSize,dtmExpectedDate,intExecutionOrder,
intProductionTypeId,dblPlannedQuantity,intBlendRequirementId,ysnKittingEnabled,ysnUseTemplate,strComment,dtmCreated,intCreatedUserId,dtmLastModified,intLastModifiedUserId,intConcurrencyId)
Select @strNextWONo ,intItemId,dblQtyToProduce,intItemUOMId,2,intCellId,intMachineId,intLocationId,dblBinSize,dtmDueDate,0,1,dblPlannedQuantity,intBlendRequirementId,
	ysnKittingEnabled,ysnUseTemplate,strComment,GetDate(),intUserId,GetDate(),intUserId,intConcurrencyId +1 
	from @tblBlendSheet

Set @intWorkOrderId=SCOPE_IDENTITY()
End
Else
Update a Set a.dblQuantity=b.dblQtyToProduce,
a.intManufacturingCellId=b.intCellId,
a.intMachineId=b.intMachineId,
a.dblBinSize=b.dblBinSize,
a.dtmExpectedDate=b.dtmDueDate,
a.dblPlannedQuantity=b.dblPlannedQuantity,
a.ysnKittingEnabled=b.ysnKittingEnabled,
a.ysnUseTemplate=b.ysnUseTemplate,
a.strComment=b.strComment,
a.intLastModifiedUserId=b.intUserId,
a.dtmLastModified=GetDate(),
a.intConcurrencyId=a.intConcurrencyId+1
from tblMFWorkOrder a Join @tblBlendSheet b on a.intWorkOrderId=b.intWorkOrderId

--Delete From tblMFWorkOrderInputLot where intWorkOrderId=@intWorkOrderId

Declare @intMinRowNo int
Select @intMinRowNo=Min(intRowNo) from @tblLot

Declare @strRowState nVarchar(50),
		@intWorkOrderInputLotId int

While (@intMinRowNo is not null)
Begin
Select @strRowState=strRowState,@intWorkOrderInputLotId=intWorkOrderInputLotId from @tblLot where intRowNo=@intMinRowNo

If @strRowState='ADDED'
	Insert Into tblMFWorkOrderInputLot(intWorkOrderId,intLotId,dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,intSequenceNo,
	dtmCreated,intCreatedUserId,dtmLastModified,intLastModifiedUserId,intRecipeItemId)
	Select @intWorkOrderId,intLotId,dblQty,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,null,
	GetDate(),intUserId,GetDate(),intUserId,intRecipeItemId
	From @tblLot where intRowNo=@intMinRowNo

If @strRowState='MODIFIED'
		Update  tblMFWorkOrderInputLot 
			Set dblQuantity=(Select dblQty from @tblLot where intRowNo=@intMinRowNo),
				dblIssuedQuantity=(Select dblIssuedQuantity from @tblLot where intRowNo=@intMinRowNo)
				where intWorkOrderInputLotId=@intWorkOrderInputLotId

If @strRowState='DELETE'
	Delete From tblMFWorkOrderInputLot where intWorkOrderInputLotId=@intWorkOrderInputLotId

Select @intMinRowNo=Min(intRowNo) from @tblLot where intRowNo>@intMinRowNo
End

--Insert Into tblMFWorkOrderInputLot(intWorkOrderId,intLotId,dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,intSequenceNo,
--dtmCreated,intCreatedUserId,dtmLastModified,intLastModifiedUserId)
--Select @intWorkOrderId,intLotId,dblQty,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,null,
--GetDate(),intUserId,GetDate(),intUserId
--From @tblLot

Update tblMFBlendRequirement Set dblIssuedQty=(Select SUM(dblQuantity) from tblMFWorkOrder where intBlendRequirementId=@intBlendRequirementId) where intBlendRequirementId=@intBlendRequirementId

Update tblMFBlendRequirement Set intStatusId=2 where intBlendRequirementId=@intBlendRequirementId and ISNULL(dblIssuedQty,0) >= dblQuantity

EXEC sp_xml_removedocument @idoc 

Commit Tran

Select @intWorkOrderId AS intWorkOrderId

END TRY  
  
BEGIN CATCH  
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
 SET @ErrMsg = ERROR_MESSAGE()  
 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc  
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')  
  
END CATCH  

