CREATE PROCEDURE [dbo].[uspQMSamplePopulateStgXML] @intSampleId INT
	,@intToEntityId INT
	,@intCompanyLocationId INT
	,@strToTransactionType NVARCHAR(100)
	,@intToCompanyId INT
	,@strRowState NVARCHAR(100)
	,@ysnReplication BIT = 1
	,@intToBookId INT = NULL
	,@strFromCompanyName NVARCHAR(150) = NULL
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strSampleNumber NVARCHAR(100)
		,@strHeaderXML NVARCHAR(MAX)
		,@strHeaderCondition NVARCHAR(MAX)
		,@strDetailXML NVARCHAR(MAX)
		,@strTestResultXML NVARCHAR(MAX)
		,@intSampleStageId INT
		,@intMultiCompanyId INT
		,@strObjectName NVARCHAR(50)

	SET @intSampleStageId = NULL
	SET @strSampleNumber = NULL
	SET @strHeaderXML = NULL
	SET @strHeaderCondition = NULL

	SELECT @strSampleNumber = strSampleNumber
	FROM tblQMSample
	WHERE intSampleId = @intSampleId

	-------------------------Header-----------------------------------------------------------
	SELECT @strHeaderCondition = 'intSampleId = ' + LTRIM(@intSampleId)

	SELECT @strObjectName = 'vyuQMSampleHeaderView'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strHeaderXML OUTPUT
		,NULL
		,NULL

	SET @intSampleStageId = SCOPE_IDENTITY();

	---------------------------------------------Detail------------------------------------------
	SELECT @strDetailXML = NULL
		,@strObjectName = NULL

	SELECT @strObjectName = 'vyuQMSampleDetailView'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strDetailXML OUTPUT
		,NULL
		,NULL

	---------------------------------------------Test Result------------------------------------------
	SELECT @strTestResultXML = NULL
		,@strObjectName = NULL

	SELECT @strObjectName = 'vyuQMSampleTestResultView'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strTestResultXML OUTPUT
		,NULL
		,NULL

	INSERT INTO tblQMSampleStage (
		intSampleId
		,strSampleNumber
		,strHeaderXML
		,strRowState
		,strDetailXML
		,strTestResultXML
		,intEntityId
		,intCompanyLocationId
		,strTransactionType
		,intMultiCompanyId
		,intToBookId
		,strFromCompanyName
		)
	SELECT intSampleId = @intSampleId
		,strSampleNumber = @strSampleNumber
		,strHeaderXML = @strHeaderXML
		,strRowState = @strRowState
		,strDetailXML = @strDetailXML
		,strTestResultXML = @strTestResultXML
		,intEntityId = @intToEntityId
		,intCompanyLocationId = @intCompanyLocationId
		,strTransactionType = @strToTransactionType
		,intMultiCompanyId = @intToCompanyId
		,intToBookId = @intToBookId
		,strFromCompanyName = @strFromCompanyName
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
