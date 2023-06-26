CREATE PROCEDURE [dbo].[uspMFDeleteBlendSheet]
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
		,@dblQuantity numeric(18,6)
		,@strWorkOrderNo nVarchar(50)
		,@intBlendRequirementId int
		,@intManufacturingCellId int
		,@dtmDueDate DateTime
		,@intExecutionOrder int
		,@intRowCount int
		,@intPickListId int
		,@strWorkOrderNos nvarchar(max)
		,@strPickListNo nvarchar(50)
		,@intTransactionFrom int
		,@strERPOrderNo nvarchar(50) 
		,@strUserName nvarchar(50)
		,@strCompanyLocation nvarchar(6)
		,@strSubLocationName nvarchar(50)
		,@strWorkOrderType nvarchar(50)

	EXEC sp_xml_preparedocument @idoc OUTPUT,@strXml

	Declare @tblWO AS table
	(
		intRowNo int IDENTITY,
		intWorkOrderId int,
		intStatusId int,
		dblQuantity numeric(18,6),
		strWorkOrderNo nVarchar(50),
		intBlendRequirementId int,
		intManufacturingCellId int,
		dtmDueDate DateTime,
		intExecutionOrder int,
		intUserId int,
		intTransactionFrom int
		,strERPOrderNo nvarchar(50) 
		,strUserName nvarchar(50)
		,strCompanyLocation nvarchar(6)
		,strSubLocationName nvarchar(50)
		,strWorkOrderType nvarchar(50)
	)

	insert into @tblWO(intWorkOrderId,intStatusId,dblQuantity,strWorkOrderNo,intBlendRequirementId,intManufacturingCellId,dtmDueDate,intExecutionOrder,intUserId,intTransactionFrom,strERPOrderNo,strUserName,strCompanyLocation,strSubLocationName,strWorkOrderType)
	SELECT	 w.intWorkOrderId
			,w.intStatusId
			,w.dblQuantity
			,w.strWorkOrderNo
			,w.intBlendRequirementId
			,w.intManufacturingCellId
			,w.dtmExpectedDate
			,w.intExecutionOrder
			,x.intUserId
			,IsNULL(w.intTransactionFrom,0)
			,w.strERPOrderNo
			,US.strUserName
			,CL.strLotOrigin 
			,CLSL.strSubLocationName
			,(Case When CLSL.ysnExternal =1 Then 'Offsite' Else 'Inhouse' End) AS strWorkOrderType
	FROM OPENXML(@idoc, 'root/workorder', 2) WITH (
			 intWorkOrderId INT
			,intUserId INT
			) x 
	Join dbo.tblMFWorkOrder w on x.intWorkOrderId=w.intWorkOrderId
	JOIN dbo.tblSMUserSecurity US on US.intEntityId =x.intUserId
	JOIN dbo.tblSMCompanyLocation CL on CL.intCompanyLocationId =w.intLocationId 
	JOIN dbo.tblMFManufacturingCell MC on MC.intManufacturingCellId =w.intManufacturingCellId 
	JOIN dbo.tblSMCompanyLocationSubLocation  CLSL on CLSL.intCompanyLocationSubLocationId =MC.intSubLocationId 

	Select @intRowCount=Min(intRowNo) from @tblWO

	Begin Tran

	While(@intRowCount is not null)
	Begin
		Select @intWorkOrderId=intWorkOrderId,@intStatusId=intStatusId,@dblQuantity=dblQuantity,
				@strWorkOrderNo=strWorkOrderNo,@intBlendRequirementId=intBlendRequirementId,@intManufacturingCellId=intManufacturingCellId,
				@dtmDueDate=dtmDueDate,@intExecutionOrder=intExecutionOrder,
				@intUserId=intUserId,@intTransactionFrom=intTransactionFrom,
				@strERPOrderNo=strERPOrderNo,@strUserName=strUserName,@strCompanyLocation=strCompanyLocation,@strSubLocationName=strSubLocationName,@strWorkOrderType=strWorkOrderType from @tblWO where intRowNo=@intRowCount

		Select @intPickListId=ISNULL(intPickListId,0) From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId

		If (Select COUNT(1) From tblMFWorkOrder Where intPickListId=@intPickListId)>1 
			AND Exists (Select intKitStatusId From tblMFPickList Where intPickListId=@intPickListId AND intKitStatusId IN (7,12))
		Begin
			Select @strPickListNo=strPickListNo From tblMFPickList Where intPickListId=@intPickListId
			Set @strErrMsg='The blend sheet (' + @strWorkOrderNo + ') belongs to a pick list (' + @strPickListNo 
			+ ') that has multiple blend sheets associated with it. Please delete the pick list from Kit Manager before deleting the blend sheet.'
			RaisError(@strErrMsg,16,1)
		End

		IF @intStatusId IN (2,19)
		BEGIN
			Exec dbo.uspMFDeleteTrialBlendSheetReservation @intWorkOrderId=@intWorkOrderId
		END

		IF @intStatusId in (2,9,19,20,13) or (@intTransactionFrom=4 and @intStatusId=10)
		Begin			
			Delete from tblMFWorkOrder where intWorkOrderId=@intWorkOrderId
			Update tblMFBlendRequirement Set dblIssuedQty=ISNULL(dblIssuedQty,0) - ISNULL(@dblQuantity,0) where intBlendRequirementId=@intBlendRequirementId

			If (Select ISNULL(dblQuantity,0) - ISNULL(dblIssuedQty,0) From tblMFBlendRequirement where intBlendRequirementId=@intBlendRequirementId) > 0
				Update tblMFBlendRequirement Set intStatusId=1 where intBlendRequirementId=@intBlendRequirementId
			Else
				Update tblMFBlendRequirement Set intStatusId=2 where intBlendRequirementId=@intBlendRequirementId

			If @intStatusId IN (9,18,20) or (@intTransactionFrom=4 and @intStatusId=10)
				Begin
					UPDATE tblMFWorkOrder
					SET intExecutionOrder = intExecutionOrder - 1
					WHERE dtmExpectedDate = convert(date,@dtmDueDate) 
					AND intExecutionOrder > @intExecutionOrder
					AND intManufacturingCellId = @intManufacturingCellId

					Exec [uspMFDeleteLotReservation] @intWorkOrderId=@intWorkOrderId
				End

			If Not Exists (Select 1 From tblMFWorkOrder Where intPickListId=@intPickListId)
				Begin
					If (Select intKitStatusId from tblMFPickList Where intPickListId = @intPickListId) IN (7,12)
					Begin
						Exec uspMFDeletePickList @intPickListId,@intUserId
					End
					Else
					Begin
						Delete From tblMFPickListDetail Where intPickListId=@intPickListId
						Delete From tblMFPickList Where intPickListId=@intPickListId
					End
				End

			If @intPickListId > 0
			Begin
				SELECT @strWorkOrderNos=coalesce(@strWorkOrderNos + ', ', '') + t.strWorkOrderNo
				FROM (SELECT DISTINCT strWorkOrderNo From tblMFWorkOrder Where intPickListId=@intPickListId) t

				Update tblMFPickList Set strWorkOrderNo=@strWorkOrderNos Where intPickListId=@intPickListId
			End
		End

		DELETE
		FROM dbo.tblMFWorkOrderPreStage
		WHERE intWorkOrderId = @intWorkOrderId
			AND strRowState = 'Modified'
			AND intStatusId IS NULL

		INSERT INTO dbo.tblMFWorkOrderPreStage (
			intWorkOrderId
			,intWorkOrderStatusId
			,intUserId
			,strRowState
			,strERPOrderNo 
			,strWorkOrderNo 
			,strUserName 
			,strCompanyLocation 
			,strSubLocationName
			,strWorkOrderType
			)
		SELECT @intWorkOrderId
			,9
			,@intUserId
			,'Deleted'
			,@strERPOrderNo 
			,@strWorkOrderNo 
			,@strUserName 
			,@strCompanyLocation 
			,@strSubLocationName
			,@strWorkOrderType				
		Select @intRowCount=Min(intRowNo) from @tblWO where intRowNo>@intRowCount	
	End

	Commit Tran

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION  
 SET @strErrMsg = ERROR_MESSAGE()  
 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc  
 RAISERROR(@strErrMsg, 16, 1, 'WITH NOWAIT')  

END CATCH

