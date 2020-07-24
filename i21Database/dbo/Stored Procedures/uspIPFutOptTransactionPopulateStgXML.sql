CREATE PROCEDURE uspIPFutOptTransactionPopulateStgXML @intFutOptTransactionHeaderId INT
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
		,@dtmTransactionDate DATETIME
		,@strHeaderXML NVARCHAR(MAX)
		,@strHeaderCondition NVARCHAR(MAX)
		,@intFutOptTransactionHeaderStageId INT
		,@strObjectName NVARCHAR(50)
		,@strLastModifiedUser NVARCHAR(100)
		,@strAdditionalInfo NVARCHAR(MAX)
		,@strFutOptTransactionXML NVARCHAR(MAX)
		,@intCompanyId int
		,@intTransactionId int
		,@intScreenId int
		,@intCurrentCompanyId INT

	SELECT @intCurrentCompanyId = intCompanyId
	FROM tblIPMultiCompany
	WHERE ysnCurrentCompany = 1

	UPDATE tblRKFutOptTransactionHeader
	SET intCompanyId = @intCurrentCompanyId
	WHERE intCompanyId IS NULL

	SET @intFutOptTransactionHeaderStageId = NULL
	SET @strHeaderXML = NULL
	SET @strHeaderCondition = NULL
	SET @strLastModifiedUser = NULL

	SELECT @intCompanyId = intCompanyId
		,@dtmTransactionDate = dtmTransactionDate
	FROM tblRKFutOptTransactionHeader WITH (NOLOCK)
	WHERE intFutOptTransactionHeaderId = @intFutOptTransactionHeaderId

	SELECT @intScreenId = intScreenId
	FROM tblSMScreen WITH (NOLOCK)
	WHERE strNamespace = 'RiskManagement.view.DerivativeEntry'
 
	SELECT @intTransactionId = intTransactionId 
	FROM tblSMTransaction WITH (NOLOCK)
	WHERE intRecordId = @intFutOptTransactionHeaderId
		AND intScreenId = @intScreenId

	-------------------------Header-----------------------------------------------------------
	SELECT @strHeaderCondition = 'intFutOptTransactionHeaderId = ' + LTRIM(@intFutOptTransactionHeaderId)

	SELECT @strObjectName = 'vyuIPGetFutOptTransactionHeader'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strHeaderXML OUTPUT
		,NULL
		,NULL

	---------------------------------------------Detail------------------------------------------
	SELECT @strFutOptTransactionXML = NULL
		,@strObjectName = NULL

	SELECT @strHeaderCondition = 'intFutOptTransactionHeaderId = ' + LTRIM(@intFutOptTransactionHeaderId) + ' AND intBookId = ' + LTRIM(ISNULL(@intToBookId, 0))

	SELECT @strObjectName = 'vyuIPGetFutOptTransaction'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strFutOptTransactionXML OUTPUT
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

	SET @intFutOptTransactionHeaderStageId = SCOPE_IDENTITY();

	DECLARE @strSQL NVARCHAR(MAX)
		,@strServerName NVARCHAR(50)
		,@strDatabaseName NVARCHAR(50)

	SELECT @strServerName = strServerName
		,@strDatabaseName = strDatabaseName
	FROM tblIPMultiCompany WITH (NOLOCK)
	WHERE intCompanyId = @intToCompanyId

	SELECT @strSQL = N'INSERT INTO ' + @strServerName + '.' + @strDatabaseName + '.dbo.tblRKFutOptTransactionHeaderStage (
		intFutOptTransactionHeaderId
		,dtmTransactionDate
		,strHeaderXML
		,strFutOptTransactionXML
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
	SELECT intFutOptTransactionHeaderId = @intFutOptTransactionHeaderId
		,dtmTransactionDate = @dtmTransactionDate
		,strHeaderXML = @strHeaderXML
		,strFutOptTransactionXML = @strFutOptTransactionXML
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
		,N'@intFutOptTransactionHeaderId INT
			,@dtmTransactionDate DATETIME
			,@strHeaderXML NVARCHAR(MAX)
			,@strFutOptTransactionXML NVARCHAR(MAX)
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
		,@intFutOptTransactionHeaderId
		,@dtmTransactionDate
		,@strHeaderXML
		,@strFutOptTransactionXML
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
