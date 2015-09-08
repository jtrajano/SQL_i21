CREATE PROCEDURE [dbo].[uspMFEndBlendSheet] 
(
	@strXml NVARCHAR(MAX)
)
AS
BEGIN TRY
	DECLARE @idoc INT
		,@strErrMsg NVARCHAR(MAX)
		,@intWorkOrderId INT
		,@intItemId int
		,@dblQtyToProduce NUMERIC(18, 6)
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

	EXEC sp_xml_preparedocument @idoc OUTPUT,@strXml

	SELECT	 @intWorkOrderId = intWorkOrderId
			,@intItemId=intItemId
			,@dblQtyToProduce = dblQtyToProduce
			,@intItemUOMId = intItemUOMId
			,@intUserId = intUserId
			,@intLocationId = intLocationId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			 intWorkOrderId INT
			,intItemId int
			,dblQtyToProduce NUMERIC(18, 6)
			,intItemUOMId INT
			,intUserId INT
			,intLocationId int
			)

	Select @intStatusId=intStatusId,@strWONo=strWorkOrderNo,@intManufacturingProcessId=ISNULL(intManufacturingProcessId,0) 
		From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId
	
	If @intManufacturingProcessId=0
			Select TOP 1 @intManufacturingProcessId=intManufacturingProcessId From tblMFWorkOrderRecipe Where intWorkOrderId=@intWorkOrderId

	if(@intStatusId<>10)
		Begin
			Set @strErrMsg='Blend Sheet ' + @strWONo + ' is either not started or already ended. Please reload the blend sheet.'
			RaisError(@strErrMsg,16,1)
		End

	If (Select count(1)	
		FROM OPENXML(@idoc, 'root/lot', 2))=0  
		Begin
			Set @strErrMsg='Please add lots to Blend Sheet.'
			RaisError(@strErrMsg,16,1)
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

	Begin Transaction

	Exec uspMFUpdateBlendProductionDetail @strXml=@strXml

	Set @strConsumeXml='<root>'
	Set @strConsumeXml=@strConsumeXml + '<intWorkOrderId>' + convert(varchar,@intWorkOrderId) + '</intWorkOrderId>'
	Set @strConsumeXml=@strConsumeXml + '<intManufacturingProcessId>' + convert(varchar,@intManufacturingProcessId) + '</intManufacturingProcessId>'
	Set @strConsumeXml=@strConsumeXml + '<intStatusId>' + convert(varchar,10) + '</intStatusId>'
	Set @strConsumeXml=@strConsumeXml + '<intUserId>' + convert(varchar,@intUserId) + '</intUserId>'
	Set @strConsumeXml=@strConsumeXml + '<intLocationId>' + convert(varchar,@intLocationId) + '</intLocationId>'
	Set @strConsumeXml=@strConsumeXml + '<ysnNegativeQtyAllowed>' + convert(varchar,@ysnIsNegativeQuantityAllowed) + '</ysnNegativeQtyAllowed>'
	--Set @strConsumeXml=@strConsumeXml + '<ysnSubLotAllowed>' + convert(varchar,@intWorkOrderId) + '</ysnSubLotAllowed>'
	Set @strConsumeXml=@strConsumeXml + '<intProductionTypeId>' + convert(varchar,1) + '</intProductionTypeId>'
	Set @strConsumeXml=@strConsumeXml + '</root>'

	Exec uspMFCompleteWorkOrder @strXML=@strConsumeXml,@strOutputLotNumber=@strOutputLotNumber OUT

	Exec [uspMFDeleteLotReservation] @intWorkOrderId=@intWorkOrderId

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
