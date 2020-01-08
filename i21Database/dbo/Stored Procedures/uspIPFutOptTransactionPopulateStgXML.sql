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

	SET @intFutOptTransactionHeaderStageId = NULL
	SET @strHeaderXML = NULL
	SET @strHeaderCondition = NULL
	SET @strLastModifiedUser = NULL

	SELECT @intCompanyId = intCompanyId
	FROM tblRKFutOptTransactionHeader
	WHERE intFutOptTransactionHeaderId = @intFutOptTransactionHeaderId

	SELECT @intScreenId = intScreenId
	FROM tblSMScreen
	WHERE strNamespace = 'RiskManagement.view.DerivativeEntry'
 
	SELECT @intTransactionId = intTransactionId 
	FROM tblSMTransaction
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

	INSERT INTO tblRKFutOptTransactionHeaderStage (
		intFutOptTransactionHeaderId
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
		,intCompanyId = @intCompanyId
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
