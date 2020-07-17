CREATE PROCEDURE uspIPCoverageEntryPopulateStgXML @intCoverageEntryId INT
	,@intToEntityId INT
	,@intCompanyLocationId INT
	,@strToTransactionType NVARCHAR(100)
	,@intToCompanyId INT
	,@strRowState NVARCHAR(100)
	,@ysnReplication BIT = 1
	,@intToBookId INT = NULL
	,@intUserId INT = NULL
	,@strFromCompanyName NVARCHAR(150) = NULL
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strHeaderXML NVARCHAR(MAX)
		,@strHeaderCondition NVARCHAR(MAX)
		,@intCoverageEntryStageId INT
		,@strObjectName NVARCHAR(50)
		,@strLastModifiedUser NVARCHAR(100)
		,@strAdditionalInfo NVARCHAR(MAX)
		,@strDetailXML NVARCHAR(MAX)
		,@strBatchName NVARCHAR(50)
		,@dtmDate DATETIME
		,@intCompanyId INT
		,@intTransactionId INT
		,@intScreenId INT

	SET @intCoverageEntryStageId = NULL
	SET @strHeaderXML = NULL
	SET @strHeaderCondition = NULL
	SET @strLastModifiedUser = NULL
	SET @strBatchName = NULL
	SET @dtmDate = NULL

	SELECT @strBatchName = strBatchName
		,@dtmDate = dtmDate
	FROM tblRKCoverageEntry WITH (NOLOCK)
	WHERE intCoverageEntryId = @intCoverageEntryId

	SELECT @intCompanyId = intCompanyId
	FROM dbo.tblIPMultiCompany
	WHERE ysnCurrentCompany = 1

	SELECT @intScreenId = intScreenId
	FROM tblSMScreen WITH (NOLOCK)
	WHERE strNamespace = 'RiskManagement.view.CoverageReport'

	SELECT @intTransactionId = intTransactionId
	FROM tblSMTransaction WITH (NOLOCK)
	WHERE intRecordId = @intCoverageEntryId
		AND intScreenId = @intScreenId

	-------------------------Header-----------------------------------------------------------
	SELECT @strHeaderCondition = 'intCoverageEntryId = ' + LTRIM(@intCoverageEntryId)

	SELECT @strObjectName = 'vyuIPGetCoverageEntry'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strHeaderXML OUTPUT
		,NULL
		,NULL

	---------------------------------------------Detail------------------------------------------
	SELECT @strDetailXML = NULL
		,@strObjectName = NULL

	SELECT @strObjectName = 'vyuIPGetCoverageEntryDetail'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strDetailXML OUTPUT
		,NULL
		,NULL

	SELECT @strLastModifiedUser = t.strName
	FROM tblEMEntity t
	JOIN tblEMEntityType ET ON ET.intEntityId = t.intEntityId
	WHERE ET.strType = 'User'
		AND t.intEntityId = @intUserId
		AND t.strEntityNo <> ''

	IF @strLastModifiedUser IS NULL
	BEGIN
		IF EXISTS (
				SELECT 1
				FROM tblSMUserSecurity
				WHERE strUserName = 'irelyadmin'
				)
			SELECT TOP 1 @intUserId = intEntityId
				,@strLastModifiedUser = strUserName
			FROM tblSMUserSecurity
			WHERE strUserName = 'irelyadmin'
		ELSE
			SELECT TOP 1 @intUserId = intEntityId
				,@strLastModifiedUser = strUserName
			FROM tblSMUserSecurity
	END

	SET @intCoverageEntryStageId = SCOPE_IDENTITY();

	DECLARE @strSQL NVARCHAR(MAX)
		,@strServerName NVARCHAR(50)
		,@strDatabaseName NVARCHAR(50)

	SELECT @strServerName = strServerName
		,@strDatabaseName = strDatabaseName
	FROM tblIPMultiCompany WITH (NOLOCK)
	WHERE intCompanyId = @intToCompanyId

	SELECT @strSQL = N'INSERT INTO ' + @strServerName + '.' + @strDatabaseName + '.dbo.tblRKCoverageEntryStage (
		intCoverageEntryId
		,strBatchName
		,dtmDate
		,strHeaderXML
		,strDetailXML
		,strRowState
		,strUserName
		,intMultiCompanyId
		,intEntityId
		,intCompanyLocationId
		,strTransactionType
		,intToBookId
		,strFromCompanyName
		,intTransactionId
		,intCompanyId
		)
	SELECT intCoverageEntryId = @intCoverageEntryId
		,strBatchName = @strBatchName
		,dtmDate = @dtmDate
		,strHeaderXML = @strHeaderXML
		,strDetailXML = @strDetailXML
		,strRowState = @strRowState
		,strUserName = @strLastModifiedUser
		,intMultiCompanyId = @intToCompanyId
		,intEntityId = @intToEntityId
		,intCompanyLocationId = @intCompanyLocationId
		,strTransactionType = @strToTransactionType
		,intToBookId = @intToBookId
		,strFromCompanyName = @strFromCompanyName
		,intTransactionId = @intTransactionId
		,intCompanyId = @intCompanyId'

	EXEC sp_executesql @strSQL
		,N'@intCoverageEntryId INT
			,@strBatchName NVARCHAR(50)
			,@dtmDate DATETIME
			,@strHeaderXML NVARCHAR(MAX)
			,@strDetailXML NVARCHAR(MAX)
			,@strRowState NVARCHAR(100)
			,@strLastModifiedUser NVARCHAR(100)
			,@intToCompanyId INT
			,@intToEntityId INT
			,@intCompanyLocationId INT
			,@strToTransactionType NVARCHAR(100)
			,@intToBookId INT
			,@strFromCompanyName NVARCHAR(150)
			,@intTransactionId INT
			,@intCompanyId INT'
		,@intCoverageEntryId
		,@strBatchName
		,@dtmDate
		,@strHeaderXML
		,@strDetailXML
		,@strRowState
		,@strLastModifiedUser
		,@intToCompanyId
		,@intToEntityId
		,@intCompanyLocationId
		,@strToTransactionType
		,@intToBookId
		,@strFromCompanyName
		,@intTransactionId
		,@intCompanyId
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
