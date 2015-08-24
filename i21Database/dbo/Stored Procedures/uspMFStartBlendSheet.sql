CREATE PROCEDURE [dbo].[uspMFStartBlendSheet] 
(
	@strXml NVARCHAR(MAX)
)
AS
BEGIN TRY
	DECLARE @idoc INT
		,@strErrMsg NVARCHAR(MAX)
		,@intWorkOrderId INT
		,@intUserId INT
		,@intStatusId int
		,@intItemId int
		,@intLocationId int
		,@strWONo nVarchar(50)
		,@dtmCurrentDate datetime=GetDate()
		,@strItemNo nVarchar(50)
		,@strItemStatus nVarchar(50)

	EXEC sp_xml_preparedocument @idoc OUTPUT,@strXml

	SELECT	 @intWorkOrderId = intWorkOrderId
			,@intItemId = intItemId
			,@intUserId = intUserId
			,@intLocationId = intLocationId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			 intWorkOrderId INT
			,intItemId int
			,intUserId INT
			,intLocationId int
			)

	Select @intStatusId=intStatusId,@strWONo=strWorkOrderNo
		From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId

	Select @strItemNo=strItemNo,@strItemStatus=strStatus From tblICItem Where intItemId=@intItemId

	if(@intStatusId<>9)
		Begin
			Set @strErrMsg='Blend Sheet ' + @strWONo + ' is either not released or already started. Please reload the blend sheet.'
			RaisError(@strErrMsg,16,1)
		End

	if (@strItemStatus) <> 'Active'
	Begin
		Set @strErrMsg='The blend item ' + @strItemNo + ' is not active, cannot start the blend sheet.'
		RaisError(@strErrMsg,16,1)
	End

	Update tblMFWorkOrder Set intStatusId=10,dtmStartedDate=@dtmCurrentDate,intLastModifiedUserId=@intUserId,dtmLastModified=@dtmCurrentDate 
	Where intWorkOrderId=@intWorkOrderId

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
 SET @strErrMsg = ERROR_MESSAGE()  
 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc  
 RAISERROR(@strErrMsg, 16, 1, 'WITH NOWAIT')  

END CATCH
