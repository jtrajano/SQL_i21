CREATE PROCEDURE [dbo].[uspMFCreateWorkOrderFromSalesOrder]
	@strXml nVarchar(Max)
AS
Begin Try
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

Declare @intSalesOrderDetailId int
Declare @intLocationId int
Declare @intRecipeId int
Declare @strWorkOrderNo nvarchar(50)
Declare @intItemId int
Declare @dblQuantity numeric(18,6)
Declare @intItemUOMId int
Declare @dtmDueDate DateTime
Declare @intCellId int
Declare @intUserId int
Declare @intAttributeTypeId int
Declare @intManufacturingProcessId int
Declare @strDemandNo nvarchar(50)
Declare @intUOMId int
Declare @dtmCurrentDate DateTime=GetDate()
Declare @intBlendRequirementId int
Declare @intMachineId int
Declare @dblBlendBinSize numeric(18,6)
Declare @ysnKittingEnabled bit
Declare @ErrMsg nvarchar(max)
DECLARE @idoc int 
Declare @ysnBlendSheetRequired bit
Declare @intWokrOrderStatusId int
Declare @intKitStatusId int
Declare @intWokrOrderId int
Declare @intExecutionOrder int=1

EXEC sp_xml_preparedocument @idoc OUTPUT, @strXml  

 Select @intSalesOrderDetailId=intSalesOrderDetailId,@intLocationId=intLocationId,@intRecipeId=intRecipeId,@strWorkOrderNo=strWorkOrderNo,
 @intItemId=intItemId,@dblQuantity=dblQuantity,@intItemUOMId=intItemUOMId,@dtmDueDate=dtmDueDate,@intCellId=intCellId,@intUserId=intUserId
 FROM OPENXML(@idoc, 'root', 2)  
 WITH ( 
	intSalesOrderDetailId int, 
	intLocationId int,
	intRecipeId int,
	strWorkOrderNo nVarchar(50),
	intItemId int,
	dblQuantity numeric(18,6),
	intItemUOMId int,
	dtmDueDate DateTime,
	intCellId int,
	intUserId int
	)

Select @intManufacturingProcessId=r.intManufacturingProcessId,@intAttributeTypeId=mp.intAttributeTypeId 
From tblMFRecipe r Join  tblMFManufacturingProcess mp on r.intManufacturingProcessId=mp.intManufacturingProcessId 
Where r.intItemId=@intItemId And r.intLocationId=@intLocationId And r.ysnActive=1

Begin Tran

If @intAttributeTypeId=2 --Blending
Begin

	Select TOP 1 @ysnBlendSheetRequired=ISNULL(ysnBlendSheetRequired,0) From tblMFCompanyPreference

	If @ysnBlendSheetRequired=1
		Set @intWokrOrderStatusId=2
	Else
		Set @intWokrOrderStatusId=9

	--Get Demand No
	EXEC dbo.uspSMGetStartingNumber 46
		,@strDemandNo OUTPUT

	Select @intUOMId=intUnitMeasureId From tblICItemUOM Where intItemUOMId=@intItemUOMId And intItemId=@intItemId

	Select TOP 1 @intMachineId=m.intMachineId,@dblBlendBinSize=mp.dblMachineCapacity 
	From tblMFMachine m Join tblMFMachinePackType mp on m.intMachineId=mp.intMachineId 
	Join tblMFManufacturingCellPackType mcp on mp.intPackTypeId=mcp.intPackTypeId 
	Join tblMFManufacturingCell mc on mcp.intManufacturingCellId=mc.intManufacturingCellId

	If ISNULL(@intMachineId,0) =0
		RaisError('Machine is not defined for the Manufacturing Cell',16,1)

	Select @ysnKittingEnabled=CASE When UPPER(pa.strAttributeValue) = 'TRUE' then 1 Else 0 End 
	From tblMFManufacturingProcessAttribute pa Join tblMFAttribute at on pa.intAttributeId=at.intAttributeId
	Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId 
	and at.strAttributeName='Enable Kitting'

	If @ysnKittingEnabled=1
		Set @intKitStatusId=6
	Else
		Set @intKitStatusId=null

	If ISNULL(@strWorkOrderNo,'') = ''
		Set  @strWorkOrderNo = @strDemandNo + '01'

	Select @intExecutionOrder = Count(1) From tblMFWorkOrder Where intManufacturingCellId=@intCellId 
	And convert(date,dtmExpectedDate)=convert(date,@dtmDueDate) And intBlendRequirementId is not null
	And intStatusId Not in (2,13)

	Insert Into tblMFBlendRequirement(strDemandNo,intItemId,dblQuantity,intUOMId,dtmDueDate,intLocationId,intStatusId,dblIssuedQty,
	intCreatedUserId,dtmCreated,intLastModifiedUserId,dtmLastModified,intMachineId)
	Values(@strDemandNo,@intItemId,@dblQuantity,@intUOMId,@dtmDueDate,@intLocationId,2,@dblQuantity,
	@intUserId,@dtmCurrentDate,@intUserId,@dtmCurrentDate,@intMachineId)

	Select @intBlendRequirementId=SCOPE_IDENTITY()

	INSERT INTO tblMFBlendRequirementRule(intBlendRequirementId,intBlendSheetRuleId,strValue,intSequenceNo) 
	SELECT @intBlendRequirementId,a.intBlendSheetRuleId,b.strValue,a.intSequenceNo 
	FROM tblMFBlendSheetRule a JOIN tblMFBlendSheetRuleValue b on a.intBlendSheetRuleId=b.intBlendSheetRuleId AND b.ysnDefault=1

	insert into tblMFWorkOrder(strWorkOrderNo,intItemId,dblQuantity,intItemUOMId,intStatusId,intManufacturingCellId,intMachineId,intLocationId,dblBinSize,dtmExpectedDate,intExecutionOrder,
	intProductionTypeId,dblPlannedQuantity,intBlendRequirementId,ysnKittingEnabled,intKitStatusId,ysnUseTemplate,strComment,dtmCreated,intCreatedUserId,dtmLastModified,intLastModifiedUserId,dtmReleasedDate,intManufacturingProcessId,intSalesOrderLineItemId)
	Select @strWorkOrderNo,@intItemId,@dblQuantity,@intItemUOMId,@intWokrOrderStatusId,@intCellId,@intMachineId,@intLocationId,@dblBlendBinSize,@dtmDueDate,@intExecutionOrder,1,
	@dblQuantity,@intBlendRequirementId,@ysnKittingEnabled,@intKitStatusId,0,'',@dtmCurrentDate,@intUserId,@dtmCurrentDate,@intUserId,@dtmCurrentDate,@intManufacturingProcessId,@intSalesOrderDetailId

	Select @intWokrOrderId=SCOPE_IDENTITY()

	--Copy Recipe
	If @ysnKittingEnabled=0
		Exec uspMFCopyRecipe @intItemId,@intLocationId,@intUserId,@intWokrOrderId
End

If @intAttributeTypeId=3 --Packaging
Begin

	--Get Work Order No
	If ISNULL(@strWorkOrderNo,'') = ''
		EXEC dbo.uspSMGetStartingNumber 34
			,@strWorkOrderNo OUTPUT

	insert into tblMFWorkOrder(strWorkOrderNo,intItemId,dblQuantity,intItemUOMId,intStatusId,intManufacturingCellId,intMachineId,intLocationId,dtmExpectedDate,intExecutionOrder,
	intProductionTypeId,dblPlannedQuantity,ysnKittingEnabled,ysnUseTemplate,strComment,dtmCreated,intCreatedUserId,dtmLastModified,intLastModifiedUserId,intManufacturingProcessId,intSalesOrderLineItemId)
	Select @strWorkOrderNo,@intItemId,@dblQuantity,@intItemUOMId,3,@intCellId,null,@intLocationId,@dtmDueDate,1,1,
	@dblQuantity,0,0,'',@dtmCurrentDate,@intUserId,@dtmCurrentDate,@intUserId,@intManufacturingProcessId,@intSalesOrderDetailId

End

Commit Tran

EXEC sp_xml_removedocument @idoc 

END TRY  
  
BEGIN CATCH  
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
 SET @ErrMsg = ERROR_MESSAGE()  
 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc  
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')  
  
END CATCH  