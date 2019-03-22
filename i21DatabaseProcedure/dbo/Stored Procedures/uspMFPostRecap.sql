CREATE PROCEDURE [dbo].[uspMFPostRecap]
	  @strXml NVARCHAR(MAX)
	 ,@strBatchId NVARCHAR(50)='' OUT
AS

Declare  @strErrMsg NVARCHAR(MAX)
		,@GLEntries RecapTableType 
		,@intUserId INT
		,@strType NVARCHAR(50)
  		,@idoc INT
		,@intWorkOrderId INT
		,@intStatusId INT

Begin Try

	EXEC sp_xml_preparedocument @idoc OUTPUT,@strXml

	SELECT	 @intWorkOrderId = intWorkOrderId
			,@intUserId = intUserId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			 intWorkOrderId INT
			,intUserId INT
			)
	
	If ISNULL(@intWorkOrderId,0)=0
		Set @strType='Post Simple Blend Production'
	Else
	Begin
		Select @intStatusId=intStatusId From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId

		If @intStatusId=10
			Set @strType='Post Consume Blend'

		If @intStatusId=12
			Set @strType='Post Produce Blend'

		If @intStatusId=13
		Begin
			Set @strType='Unpost Produce Blend'
		End
	End

	Begin Tran

	IF OBJECT_ID('tempdb..#tblRecap') IS NOT NULL
		DROP TABLE #tblRecap

	--Create Temp table to hold Recap Data
	Select * into #tblRecap from @GLEntries

	If @strType='Post Consume Blend'
	Begin	
		Exec uspMFEndBlendSheet @strXml,1,@strBatchId OUT
	End

	If @strType='Post Produce Blend'
	Begin	
		Exec uspMFCompleteBlendSheet @strXml=@strXml,@ysnRecap=1,@strBatchId=@strBatchId OUT
	End

	If @strType='Post Simple Blend Production'
	Begin	
		Exec uspMFCompleteBlendSheet @strXml=@strXml,@ysnRecap=1,@strBatchId=@strBatchId OUT
	End

	If @strType='Unpost Produce Blend'
	Begin	
		Exec uspMFUnpostProducedLot @strXML=@strXml,@ysnRecap=1,@strBatchId=@strBatchId OUT
	End

	INSERT INTO @GLEntries
	Select * From #tblRecap

	IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION

	If @strType='Post Consume Blend'
	Begin	
		-- Get the next batch number
		EXEC dbo.uspSMGetStartingNumber 3
			,@strBatchId OUTPUT

		Update @GLEntries Set strBatchId=@strBatchId
	End

	--Post Recap
	EXEC dbo.uspGLPostRecap 
			@GLEntries
			,@intUserId
End try
Begin Catch
	IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SET @strErrMsg = ERROR_MESSAGE()  
	IF @idoc <> 0 EXEC sp_xml_removedocument @idoc 
	RAISERROR(@strErrMsg, 16, 1, 'WITH NOWAIT')  
End Catch
