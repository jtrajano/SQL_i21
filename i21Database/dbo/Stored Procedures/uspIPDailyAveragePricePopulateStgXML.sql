CREATE PROCEDURE uspIPDailyAveragePricePopulateStgXML @intDailyAveragePriceId INT
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
		,@intDailyAveragePriceStageId INT
		,@strObjectName NVARCHAR(50)
		,@strLastModifiedUser NVARCHAR(100)
		,@strAdditionalInfo NVARCHAR(MAX)
		,@strDetailXML NVARCHAR(MAX)
		,@strAverageNo NVARCHAR(50)
		,@intCompanyId int
		,@intTransactionId int
		,@intScreenId int

	SET @intDailyAveragePriceStageId = NULL
	SET @strHeaderXML = NULL
	SET @strHeaderCondition = NULL
	SET @strLastModifiedUser = NULL
	SET @strAverageNo = NULL

	SELECT @strAverageNo = strAverageNo
		,@intCompanyId = intCompanyId
	FROM tblRKDailyAveragePrice WITH (NOLOCK)
	WHERE intDailyAveragePriceId = @intDailyAveragePriceId

	SELECT @intScreenId = intScreenId
	FROM tblSMScreen WITH (NOLOCK)
	WHERE strNamespace = 'RiskManagement.view.DailyAveragePrice'
 
	SELECT @intTransactionId = intTransactionId 
	FROM tblSMTransaction WITH (NOLOCK)
	WHERE intRecordId = @intDailyAveragePriceId
		AND intScreenId = @intScreenId

	-------------------------Header-----------------------------------------------------------
	SELECT @strHeaderCondition = 'intDailyAveragePriceId = ' + LTRIM(@intDailyAveragePriceId)

	SELECT @strObjectName = 'vyuIPGetDailyAveragePrice'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strHeaderXML OUTPUT
		,NULL
		,NULL

	---------------------------------------------Detail------------------------------------------
	SELECT @strDetailXML = NULL
		,@strObjectName = NULL

	SELECT @strObjectName = 'vyuIPGetDailyAveragePriceDetail'

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

	SET @intDailyAveragePriceStageId = SCOPE_IDENTITY();

	DECLARE @strSQL NVARCHAR(MAX)
		,@strServerName NVARCHAR(50)
		,@strDatabaseName NVARCHAR(50)

	SELECT @strServerName = strServerName
		,@strDatabaseName = strDatabaseName
	FROM tblIPMultiCompany WITH (NOLOCK)
	WHERE intCompanyId = @intToCompanyId

	SELECT @strSQL = N'INSERT INTO ' + @strServerName + '.' + @strDatabaseName + '.dbo.tblRKDailyAveragePriceStage (
		intDailyAveragePriceId
		,strAverageNo
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
	SELECT intDailyAveragePriceId = @intDailyAveragePriceId
		,strAverageNo = @strAverageNo
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
		,N'@intDailyAveragePriceId INT
			,@strAverageNo NVARCHAR(50)
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
		,intDailyAveragePriceId
		,strAverageNo
		,@strHeaderXML
		,strDetailXML
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
