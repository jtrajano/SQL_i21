CREATE PROCEDURE uspIPOptionsPnSPopulateStgXML @intOptionsMatchPnSHeaderId INT
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
		,@intOptionsMatchPnSHeaderStageId INT
		,@strObjectName NVARCHAR(50)
		,@strLastModifiedUser NVARCHAR(100)
		,@strAdditionalInfo NVARCHAR(MAX)
		,@strOptionsMatchPnSXML NVARCHAR(MAX)
		,@strOptionsPnSExpiredXML NVARCHAR(MAX)
		,@strDetailCondition NVARCHAR(MAX)
		,@intCompanyId int
		,@intTransactionId int
		,@intScreenId int

	SET @intOptionsMatchPnSHeaderStageId = NULL
	SET @strHeaderXML = NULL
	SET @strHeaderCondition = NULL
	SET @strLastModifiedUser = NULL
	SET @strDetailCondition = NULL

	SELECT @intCompanyId = intCompanyId
	FROM tblRKOptionsMatchPnSHeader WITH (NOLOCK)
	WHERE intOptionsMatchPnSHeaderId = @intOptionsMatchPnSHeaderId

	SELECT @intScreenId = intScreenId
	FROM tblSMScreen WITH (NOLOCK)
	WHERE strNamespace = 'RiskManagement.view.OptionsLifecycle'
 
	SELECT @intTransactionId = intTransactionId 
	FROM tblSMTransaction WITH (NOLOCK)
	WHERE intRecordId = @intOptionsMatchPnSHeaderId
		AND intScreenId = @intScreenId

	-------------------------Header-----------------------------------------------------------
	SELECT @strHeaderCondition = 'intOptionsMatchPnSHeaderId = ' + LTRIM(@intOptionsMatchPnSHeaderId)

	SELECT @strObjectName = 'tblRKOptionsMatchPnSHeader'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strHeaderXML OUTPUT
		,NULL
		,NULL

	---------------------------------------------Match------------------------------------------
	SELECT @strOptionsMatchPnSXML = NULL
		,@strObjectName = NULL

	SELECT @strDetailCondition = 'intOptionsMatchPnSHeaderId = ' + LTRIM(@intOptionsMatchPnSHeaderId) + ' AND intBookId = ' + LTRIM(@intToBookId)
	SELECT @strObjectName = 'vyuIPGetOptionsMatchPnS'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strDetailCondition
		,@strOptionsMatchPnSXML OUTPUT
		,NULL
		,NULL

	---------------------------------------------Options Expired------------------------------------------
	SELECT @strOptionsPnSExpiredXML = NULL
		,@strObjectName = NULL

	SELECT @strObjectName = 'vyuIPGetOptionsPnSExpired'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strDetailCondition
		,@strOptionsPnSExpiredXML OUTPUT
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

	SET @intOptionsMatchPnSHeaderStageId = SCOPE_IDENTITY();

	DECLARE @strSQL NVARCHAR(MAX)
		,@strServerName NVARCHAR(50)
		,@strDatabaseName NVARCHAR(50)

	SELECT @strServerName = strServerName
		,@strDatabaseName = strDatabaseName
	FROM tblIPMultiCompany WITH (NOLOCK)
	WHERE intCompanyId = @intToCompanyId
	
	SELECT @strSQL = N'INSERT INTO ' + @strServerName + '.' + @strDatabaseName + '.dbo.tblRKOptionsMatchPnSHeaderStage (
		intOptionsMatchPnSHeaderId
		,strHeaderXML
		,strOptionsMatchPnSXML
		,strOptionsPnSExpiredXML
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
	SELECT intOptionsMatchPnSHeaderId = @intOptionsMatchPnSHeaderId
		,strHeaderXML = @strHeaderXML
		,strOptionsMatchPnSXML = @strOptionsMatchPnSXML
		,strOptionsPnSExpiredXML = @strOptionsPnSExpiredXML
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
		,N'@intOptionsMatchPnSHeaderId INT
			,@strHeaderXML NVARCHAR(MAX)
			,@strOptionsMatchPnSXML NVARCHAR(MAX)
			,@strOptionsPnSExpiredXML NVARCHAR(MAX)
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
		,intOptionsMatchPnSHeaderId
		,strHeaderXML
		,strOptionsMatchPnSXML
		,strOptionsPnSExpiredXML
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
