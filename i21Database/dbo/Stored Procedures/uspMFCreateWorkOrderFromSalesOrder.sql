﻿CREATE PROCEDURE [dbo].[uspMFCreateWorkOrderFromSalesOrder]
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
Declare @intWorkOrderStatusId int
Declare @intKitStatusId int
Declare @intWokrOrderId int
Declare @intExecutionOrder int=1
Declare @intNoOfSheet int
Declare @intSubLocationId int
Declare @intCustomerId int
Declare @strSalesOrderNo nvarchar(50)
Declare @intNoOfSheetCounter int=0
Declare @intNoOfSheetOrig int
Declare @strWorkOrderNoOrig nVarchar(50)
Declare @ysnRequireCustomerApproval bit
Declare @strLotTracking nvarchar(50)
Declare @intMinWO int
Declare @intCategoryId int

Declare @tblWO As table
(
	intRowNo int IDENTITY,
	dblQuantity numeric(18,6),
	dtmDueDate datetime,
	intCellId int
)

EXEC sp_xml_preparedocument @idoc OUTPUT, @strXml  

 Select @intSalesOrderDetailId=intSalesOrderDetailId,@intLocationId=intLocationId,@intRecipeId=intRecipeId,
 @intItemId=intItemId,@intItemUOMId=intItemUOMId,@intUserId=intUserId
 FROM OPENXML(@idoc, 'root', 2)  
 WITH ( 
	intSalesOrderDetailId int, 
	intLocationId int,
	intRecipeId int,
	intItemId int,
	intItemUOMId int,
	intUserId int
	)

Insert Into @tblWO(dblQuantity,dtmDueDate,intCellId)
 Select dblQuantity,dtmDueDate,intCellId
 FROM OPENXML(@idoc, 'root/wo', 2)  
 WITH ( 
	dblQuantity numeric(18,6), 
	dtmDueDate datetime,
	intCellId int
	)

Select @intManufacturingProcessId=r.intManufacturingProcessId,@intAttributeTypeId=mp.intAttributeTypeId 
From tblMFRecipe r Join  tblMFManufacturingProcess mp on r.intManufacturingProcessId=mp.intManufacturingProcessId 
Where r.intItemId=@intItemId And r.intLocationId=@intLocationId And r.ysnActive=1

Begin Tran

If @intAttributeTypeId=2 --Blending
Begin

	--Validation
	Select @intMinWO=Min(intRowNo) From @tblWO

	While(@intMinWO is not null)
	Begin
		Select @dblQuantity=dblQuantity,@intCellId=intCellId From @tblWO Where intRowNo=@intMinWO

		Select TOP 1 @intMachineId=m.intMachineId,@dblBlendBinSize=mp.dblMachineCapacity 
		From tblMFMachine m Join tblMFMachinePackType mp on m.intMachineId=mp.intMachineId 
		Join tblMFManufacturingCellPackType mcp on mp.intPackTypeId=mcp.intPackTypeId 
		Join tblMFManufacturingCell mc on mcp.intManufacturingCellId=mc.intManufacturingCellId
		Join tblMFPackType pk on mp.intPackTypeId=pk.intPackTypeId 
		Where pk.intPackTypeId=(Select intPackTypeId From tblICItem Where intItemId=@intItemId)
		And mc.intManufacturingCellId=@intCellId

		If ISNULL(@intMachineId,0) =0
			RaisError('Machine is not defined for the Manufacturing Cell',16,1)

		If ISNULL(@dblBlendBinSize,0) =0
			RaisError('Blend Bin Size is zero for the machine',16,1)

		If @dblQuantity > @dblBlendBinSize 
			RaisError('Quantity cannot be greater than blend bin size',16,1)

		Select @intMinWO=Min(intRowNo) From @tblWO Where intRowNo > @intMinWO
	End

	Select TOP 1 @ysnBlendSheetRequired=ISNULL(ysnBlendSheetRequired,0) From tblMFCompanyPreference
	Select @strLotTracking=strLotTracking,@intCategoryId=intCategoryId From tblICItem Where intItemId=@intItemId

	Select @ysnRequireCustomerApproval=ysnRequireCustomerApproval 
	From tblICItem Where intItemId=@intItemId

	if @strLotTracking='No'
		Set @intWorkOrderStatusId=9 --Released
	Else
	Begin
		If @ysnBlendSheetRequired=1
			Set @intWorkOrderStatusId=2 --Not Released
		Else
			Begin
				If @ysnRequireCustomerApproval = 1
					Set @intWorkOrderStatusId=5 --Hold
				Else
					Set @intWorkOrderStatusId=9 --Released
			End
	End

	Select @intUOMId=intUnitMeasureId From tblICItemUOM Where intItemUOMId=@intItemUOMId And intItemId=@intItemId

	Select @ysnKittingEnabled=CASE When UPPER(pa.strAttributeValue) = 'TRUE' then 1 Else 0 End 
	From tblMFManufacturingProcessAttribute pa Join tblMFAttribute at on pa.intAttributeId=at.intAttributeId
	Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId 
	and at.strAttributeName='Enable Kitting'

	if @strLotTracking='No'
	Begin
		Set @intKitStatusId=null
		Set @ysnKittingEnabled=0
	End
	Else
	Begin
		If @ysnKittingEnabled=1
			Set @intKitStatusId=6
		Else
			Set @intKitStatusId=null
	End

	--Get Demand No
	--EXEC dbo.uspSMGetStartingNumber 46
	--	,@strDemandNo OUTPUT

	EXEC dbo.uspMFGeneratePatternId @intCategoryId = @intCategoryId
				,@intItemId = @intItemId
				,@intManufacturingId = NULL
				,@intSubLocationId = @intSubLocationId
				,@intLocationId = @intLocationId
				,@intOrderTypeId = NULL
				,@intBlendRequirementId = NULL
				,@intPatternCode = 46
				,@ysnProposed = 0
				,@strPatternString = @strDemandNo OUTPUT

	Select @dtmDueDate=Min(dtmDueDate) From @tblWO

	Insert Into tblMFBlendRequirement(strDemandNo,intItemId,dblQuantity,intUOMId,dtmDueDate,intLocationId,intStatusId,dblIssuedQty,
	intCreatedUserId,dtmCreated,intLastModifiedUserId,dtmLastModified,intMachineId)
	Values(@strDemandNo,@intItemId,@dblQuantity,@intUOMId,@dtmDueDate,@intLocationId,2,@dblQuantity,
	@intUserId,@dtmCurrentDate,@intUserId,@dtmCurrentDate,@intMachineId)

	Select @intBlendRequirementId=SCOPE_IDENTITY()

	INSERT INTO tblMFBlendRequirementRule(intBlendRequirementId,intBlendSheetRuleId,strValue,intSequenceNo) 
	SELECT @intBlendRequirementId,a.intBlendSheetRuleId,b.strValue,a.intSequenceNo 
	FROM tblMFBlendSheetRule a JOIN tblMFBlendSheetRuleValue b on a.intBlendSheetRuleId=b.intBlendSheetRuleId AND b.ysnDefault=1

	Select @intMinWO=Min(intRowNo) From @tblWO

	While(@intMinWO is not null)
	Begin
		Select @dblQuantity=dblQuantity,@intCellId=intCellId,@dtmDueDate=dtmDueDate From @tblWO Where intRowNo=@intMinWO

		Select TOP 1 @intMachineId=m.intMachineId,@dblBlendBinSize=mp.dblMachineCapacity 
		From tblMFMachine m Join tblMFMachinePackType mp on m.intMachineId=mp.intMachineId 
		Join tblMFManufacturingCellPackType mcp on mp.intPackTypeId=mcp.intPackTypeId 
		Join tblMFManufacturingCell mc on mcp.intManufacturingCellId=mc.intManufacturingCellId
		Join tblMFPackType pk on mp.intPackTypeId=pk.intPackTypeId 
		Where pk.intPackTypeId=(Select intPackTypeId From tblICItem Where intItemId=@intItemId)
		And mc.intManufacturingCellId=@intCellId

		Select @strWorkOrderNo= convert(varchar,@strDemandNo) + right('00' + Convert(varchar,(Max(Cast(right(strWorkOrderNo,2) as int)))+1),2)  
		from tblMFWorkOrder where strWorkOrderNo like @strDemandNo + '%'

		if ISNULL(@strWorkOrderNo,'')=''
			Set @strWorkOrderNo=convert(varchar,@strDemandNo) + '01'

		Select @intExecutionOrder = Count(1) From tblMFWorkOrder Where intManufacturingCellId=@intCellId 
		And convert(date,dtmExpectedDate)=convert(date,@dtmDueDate) And intBlendRequirementId is not null
		And intStatusId Not in (2,13)

		Set @intExecutionOrder=@intExecutionOrder+1

		insert into tblMFWorkOrder(strWorkOrderNo,intItemId,dblQuantity,intItemUOMId,intStatusId,intManufacturingCellId,intMachineId,intLocationId,dblBinSize,dtmExpectedDate,intExecutionOrder,
		intProductionTypeId,dblPlannedQuantity,intBlendRequirementId,ysnKittingEnabled,intKitStatusId,ysnUseTemplate,strComment,dtmCreated,intCreatedUserId,dtmLastModified,intLastModifiedUserId,dtmReleasedDate,intManufacturingProcessId,intSalesOrderLineItemId,intConcurrencyId)
		Select @strWorkOrderNo,@intItemId,@dblQuantity,@intItemUOMId,@intWorkOrderStatusId,@intCellId,@intMachineId,@intLocationId,@dblBlendBinSize,@dtmDueDate,@intExecutionOrder,1,
		@dblQuantity,@intBlendRequirementId,@ysnKittingEnabled,@intKitStatusId,0,'',@dtmCurrentDate,@intUserId,@dtmCurrentDate,@intUserId,@dtmCurrentDate,@intManufacturingProcessId,@intSalesOrderDetailId,1

		Select @intWokrOrderId=SCOPE_IDENTITY()

		--Copy Recipe
		If @ysnKittingEnabled=0
			Exec uspMFCopyRecipe @intItemId,@intLocationId,@intUserId,@intWokrOrderId

		Select @intMinWO=Min(intRowNo) From @tblWO Where intRowNo > @intMinWO
	End
End

If @intAttributeTypeId>=3 --Packaging
Begin

	Select TOP 1 @intCustomerId=sh.intEntityCustomerId,@strSalesOrderNo=sh.strSalesOrderNumber 
	From tblSOSalesOrder sh Join tblSOSalesOrderDetail sd on sh.intSalesOrderId=sd.intSalesOrderId Where sd.intSalesOrderDetailId=@intSalesOrderDetailId

	Select @intMinWO=Min(intRowNo) From @tblWO

	While(@intMinWO is not null)
	Begin
		Select @dblQuantity=dblQuantity,@intCellId=intCellId,@dtmDueDate=dtmDueDate From @tblWO Where intRowNo=@intMinWO

		--Get Work Order No
		If ISNULL(@strWorkOrderNo,'') = ''
			--EXEC dbo.uspSMGetStartingNumber 34
			--	,@strWorkOrderNo OUTPUT
		Begin
			EXEC dbo.uspMFGeneratePatternId @intCategoryId = @intCategoryId
			,@intItemId = @intItemId
			,@intManufacturingId = @intCellId
			,@intSubLocationId = @intSubLocationId
			,@intLocationId = @intLocationId
			,@intOrderTypeId = NULL
			,@intBlendRequirementId = NULL
			,@intPatternCode = 34
			,@ysnProposed = 0
			,@strPatternString = @strWorkOrderNo OUTPUT
		End

		Select @intExecutionOrder = Count(1) From tblMFWorkOrder Where intManufacturingCellId=@intCellId 
		And convert(date,dtmExpectedDate)=convert(date,@dtmDueDate)
		And intStatusId Not in (2,13)

		Set @intExecutionOrder=@intExecutionOrder+1

		Select @intSubLocationId=intSubLocationId From tblMFManufacturingCell where intManufacturingCellId=@intCellId

		insert into tblMFWorkOrder(strWorkOrderNo,intItemId,dblQuantity,intItemUOMId,intStatusId,intManufacturingCellId,intMachineId,intLocationId,dtmExpectedDate,intExecutionOrder,
		intProductionTypeId,dblPlannedQuantity,ysnKittingEnabled,ysnUseTemplate,strComment,dtmCreated,intCreatedUserId,dtmLastModified,intLastModifiedUserId,intManufacturingProcessId,intSalesOrderLineItemId,
		dtmOrderDate,dtmPlannedDate,intSupervisorId,intSubLocationId,intCustomerId,strSalesOrderNo,intConcurrencyId)
		Select @strWorkOrderNo,@intItemId,@dblQuantity,@intItemUOMId,1,@intCellId,null,@intLocationId,@dtmDueDate,1,1,
		null,0,0,'',@dtmCurrentDate,@intUserId,@dtmCurrentDate,@intUserId,@intManufacturingProcessId,@intSalesOrderDetailId,
		@dtmCurrentDate,@dtmDueDate,@intUserId,@intSubLocationId,@intCustomerId,@strSalesOrderNo,1

		Select @intMinWO=Min(intRowNo) From @tblWO Where intRowNo > @intMinWO
	End

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