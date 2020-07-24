CREATE PROCEDURE [dbo].[uspMFEndBlendSheet] 
(
	@strXml NVARCHAR(MAX)
   ,@ysnRecap BIT = 0
   ,@strBatchId NVARCHAR(50)='' OUT
)
AS
BEGIN TRY

	DECLARE @idoc INT
		,@strErrMsg NVARCHAR(MAX)
		,@intWorkOrderId INT
		,@intItemId int
		,@dblQtyToProduce NUMERIC(38,20)
		,@dblWOQty NUMERIC(38,20)
		,@intItemUOMId INT
		,@intUserId INT
		,@strRetBatchId nVarchar(40)
		,@intStatusId int
		,@strWONo nvarchar(50)
		,@strConsumeXml nvarchar(Max)
		,@intManufacturingProcessId int
		,@intLocationId int
		,@strOutputLotNumber nvarchar(50)
		,@intAttributeId int
		,@ysnIsNegativeQuantityAllowed bit
		,@strIsNegativeQuantityAllowed nvarchar(50)
		,@dtmCurrentDate datetime=GetDate()
		,@ysnEnableParentLot bit=0
		,@strXmlRecipeComputation nvarchar(Max)
		,@dtmProductionDate DateTime

	EXEC sp_xml_preparedocument @idoc OUTPUT,@strXml

	SELECT	 @intWorkOrderId = intWorkOrderId
			,@intItemId=intItemId
			,@dblQtyToProduce = dblQtyToProduce
			,@intItemUOMId = intItemUOMId
			,@intUserId = intUserId
			,@intLocationId = intLocationId
			,@dtmProductionDate = ISNULL(dtmProductionDate,GETDATE())
	FROM OPENXML(@idoc, 'root', 2) WITH (
			 intWorkOrderId INT
			,intItemId int
			,dblQtyToProduce NUMERIC(38,20)
			,intItemUOMId INT
			,intUserId INT
			,intLocationId int
			,dtmProductionDate DateTime
			)

	Select @intStatusId=intStatusId,@strWONo=strWorkOrderNo,@intManufacturingProcessId=ISNULL(intManufacturingProcessId,0),@dblWOQty=dblQuantity 
		From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId
	
	If @intManufacturingProcessId=0
			Select TOP 1 @intManufacturingProcessId=intManufacturingProcessId From tblMFWorkOrderRecipe Where intWorkOrderId=@intWorkOrderId

	if(@intStatusId<>10 AND @intStatusId <> 12)
		Begin
			Set @strErrMsg='Blend Sheet ' + @strWONo + ' is either not started or already ended. Please reload the blend sheet.'
			RaisError(@strErrMsg,16,1)
		End

If Exists(Select 1 From tblMFWorkOrderRecipeItem Where intWorkOrderId=@intWorkOrderId And intRecipeItemTypeId=1 And intConsumptionMethodId=1)
Begin
	If (Select count(1)	
		FROM OPENXML(@idoc, 'root/lot', 2))=0  
		Begin
			Set @strErrMsg='Please add lots to Blend Sheet.'
			RaisError(@strErrMsg,16,1)
		End
End

	Select @intAttributeId=intAttributeId from tblMFAttribute Where strAttributeName='Is Negative Quantity Allowed'

	Select @strIsNegativeQuantityAllowed=strAttributeValue
	From tblMFManufacturingProcessAttribute
	Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId and intAttributeId=@intAttributeId

	Select @ysnIsNegativeQuantityAllowed=0
	If @strIsNegativeQuantityAllowed='True'
	Begin
		Select @ysnIsNegativeQuantityAllowed=1
	End

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

	Begin Transaction

	Exec uspMFUpdateBlendProductionDetail @strXml=@strXml

	Begin
		Set @strConsumeXml='<root>'
		Set @strConsumeXml=@strConsumeXml + '<intWorkOrderId>' + convert(varchar,@intWorkOrderId) + '</intWorkOrderId>'
		Set @strConsumeXml=@strConsumeXml + '<intItemId>' + convert(varchar,@intItemId) + '</intItemId>'
		Set @strConsumeXml=@strConsumeXml + '<intManufacturingProcessId>' + convert(varchar,@intManufacturingProcessId) + '</intManufacturingProcessId>'
		Set @strConsumeXml=@strConsumeXml + '<intStatusId>' + convert(varchar,10) + '</intStatusId>'
		Set @strConsumeXml=@strConsumeXml + '<intUserId>' + convert(varchar,@intUserId) + '</intUserId>'
		Set @strConsumeXml=@strConsumeXml + '<intLocationId>' + convert(varchar,@intLocationId) + '</intLocationId>'
		Set @strConsumeXml=@strConsumeXml + '<ysnNegativeQtyAllowed>' + convert(varchar,@ysnIsNegativeQuantityAllowed) + '</ysnNegativeQtyAllowed>'
		--Set @strConsumeXml=@strConsumeXml + '<ysnSubLotAllowed>' + convert(varchar,@intWorkOrderId) + '</ysnSubLotAllowed>'
		Set @strConsumeXml=@strConsumeXml + '<intProductionTypeId>' + convert(varchar,1) + '</intProductionTypeId>'
		Set @strConsumeXml=@strConsumeXml + '<dblProduceQty>' + convert(varchar,@dblWOQty) + '</dblProduceQty>'
		Set @strConsumeXml=@strConsumeXml + '<intProduceUnitMeasureId>' + convert(varchar,@intItemUOMId) + '</intProduceUnitMeasureId>'
		SET @strConsumeXml=@strConsumeXml + '<dtmPlannedDate>' + convert(VARCHAR, @dtmProductionDate) + '</dtmPlannedDate>'
		Set @strConsumeXml=@strConsumeXml + '</root>'

		Exec uspMFCompleteWorkOrder @strXML=@strConsumeXml,@strOutputLotNumber=@strOutputLotNumber OUT,@ysnRecap=@ysnRecap,@strRetBatchId=@strRetBatchId OUT

		Set @strBatchId=@strRetBatchId

		--Update tblMFWorkOrder 
		--Set dblQuantity=(Select sum(dblQuantity) From tblMFWorkOrderConsumedLot Where intWorkOrderId=@intWorkOrderId)
		--Where intWorkOrderId=@intWorkOrderId

		Update tblMFWorkOrderConsumedLot Set ysnStaged=1 Where intWorkOrderId=@intWorkOrderId

		Exec [uspMFDeleteLotReservation] @intWorkOrderId=@intWorkOrderId

		--Recipe Computation for Actual Qty Consumed
		If (Select COUNT(1) From tblMFWorkOrderRecipeComputation Where intWorkOrderId=@intWorkOrderId AND intTypeId=1)>0
		Begin
			DECLARE @tblBlendProduction AS TABLE
			   (
				 intRowNo INT
				,intTestId INT
				,strTestName NVARCHAR(50)
				,intPropertyId INT
				,strPropertyName NVARCHAR(100)
				,dblComputedValue NUMERIC(18,6)
				,dblMinValue NUMERIC(18,6)
				,dblMaxValue NUMERIC(18,6)
				,strMethodName NVARCHAR(50)
				,intMethodId INT
				,intSequenceNo int
			   )

			Select TOP 1 @ysnEnableParentLot=ISNULL(ysnEnableParentLot,0) From tblMFCompanyPreference

			Set @strXmlRecipeComputation=''
			If @ysnEnableParentLot=0
			Begin
				Select @strXmlRecipeComputation=@strXmlRecipeComputation 
				+ '<lot>'   
				+  '<intLotId>' + CONVERT(VARCHAR(500),intLotId) + '</intLotId>'	
				+  '<dblQty>' + CONVERT(VARCHAR(500),dblQuantity) + '</dblQty>'	
				+ '</lot>' 
				From tblMFWorkOrderConsumedLot Where intWorkOrderId=@intWorkOrderId
			End
			Else
			Begin
				Select @strXmlRecipeComputation=@strXmlRecipeComputation 
				+ '<lot>'   
				+  '<intLotId>' + CONVERT(VARCHAR(500),l.intParentLotId) + '</intLotId>'	
				+  '<dblQty>' + CONVERT(VARCHAR(500),SUM(cl.dblQuantity)) + '</dblQty>'	
				+ '</lot>' 
				From tblMFWorkOrderConsumedLot cl Join tblICLot l on cl.intLotId=l.intLotId
				Where intWorkOrderId=@intWorkOrderId
				Group By l.intParentLotId 
			End

			If ISNULL(@strXmlRecipeComputation,'')<>''
			Begin
				Set @strXmlRecipeComputation='<root>' + @strXmlRecipeComputation  + '</root>'

				--Get the computation values based on actual Qty consumed
				Insert Into @tblBlendProduction
				Exec uspMFGetBlendRecipeComputation @strXml=@strXmlRecipeComputation,@intTypeId=2,@intProductId=@intItemId
	
				--insert the values to tblMFWorkOrderRecipeComputation
				If (Select count(1) From @tblBlendProduction) > 0
				Begin
					Set @strXmlRecipeComputation=''

					Select @strXmlRecipeComputation=@strXmlRecipeComputation
					+ '<computation>'
                    + '<intTestId>' + CONVERT(VARCHAR(500),intTestId) + '</intTestId>'
                    + '<intPropertyId>' + CONVERT(VARCHAR(500),intPropertyId) + '</intPropertyId>'
                    + '<dblComputedValue>' + CONVERT(VARCHAR(500),dblComputedValue) + '</dblComputedValue>'
                    + '<dblMinValue>' + CONVERT(VARCHAR(500),dblMinValue) + '</dblMinValue>'
                    + '<dblMaxValue>' + CONVERT(VARCHAR(500),dblMaxValue) + '</dblMaxValue>'
                    + '<intMethodId>' + CONVERT(VARCHAR(500),intMethodId) + '</intMethodId>'
                    + '</computation>'
					From @tblBlendProduction

					Set @strXmlRecipeComputation='<root>' + @strXmlRecipeComputation  + '</root>'

					Exec [uspMFCreateBlendRecipeComputation] @intWorkOrderId=@intWorkOrderId,@intTypeId=2,@strXml=@strXmlRecipeComputation	

				End
			End
		End
	End

	Update tblMFWorkOrder Set intStatusId=12,dtmCompletedDate=@dtmCurrentDate,intLastModifiedUserId=@intUserId,dtmLastModified=@dtmCurrentDate 
	Where intWorkOrderId=@intWorkOrderId

	Commit Transaction

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
 
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
 SET @strErrMsg = ERROR_MESSAGE()  
 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc  
 RAISERROR(@strErrMsg, 16, 1, 'WITH NOWAIT')  

END CATCH
