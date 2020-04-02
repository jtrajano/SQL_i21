CREATE PROCEDURE uspIPFutureMarketPopulateStgXML @intFutureMarketId INT
	,@intToEntityId INT
	,@intCompanyLocationId INT
	,@strToTransactionType NVARCHAR(100)
	,@intToCompanyId INT
	,@strRowState NVARCHAR(100)
	,@ysnReplication BIT = 1
	,@intToBookId INT = NULL
	,@intUserId INT = NULL
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strHeaderXML NVARCHAR(MAX)
		,@strHeaderCondition NVARCHAR(MAX)
		,@strObjectName NVARCHAR(50)
		,@strLastModifiedUser NVARCHAR(100)
		,@strFutMarketName NVARCHAR(30)
		,@dblForecastPrice NUMERIC(18, 6)

	SET @strHeaderXML = NULL
	SET @strHeaderCondition = NULL
	SET @strLastModifiedUser = NULL
	SET @strFutMarketName = NULL
	SET @dblForecastPrice = NULL

	SELECT @strFutMarketName = strFutMarketName
		,@dblForecastPrice = dblForecastPrice
	FROM tblRKFutureMarket WITH (NOLOCK)
	WHERE intFutureMarketId = @intFutureMarketId

	-------------------------Header-----------------------------------------------------------
	SELECT @strHeaderCondition = 'intFutureMarketId = ' + LTRIM(@intFutureMarketId)

	SELECT @strObjectName = 'vyuIPGetFutureMarket'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strHeaderXML OUTPUT
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

	INSERT INTO tblRKFutureMarketStage (
		intFutureMarketId
		,strFutMarketName
		,dblForecastPrice
		,strHeaderXML
		,strRowState
		,strUserName
		,intMultiCompanyId
		,intEntityId
		,intCompanyLocationId
		,strTransactionType
		,intToBookId
		)
	SELECT intFutureMarketId = @intFutureMarketId
		,strFutureMarketName = @strFutMarketName
		,dblForecastPrice = @dblForecastPrice
		,strHeaderXML = @strHeaderXML
		,strRowState = @strRowState
		,strUserName = @strLastModifiedUser
		,intMultiCompanyId = intCompanyId
		,intEntityId = @intToEntityId
		,intCompanyLocationId = @intCompanyLocationId
		,strTransactionType = @strToTransactionType
		,intToBookId = @intToBookId
	FROM tblIPMultiCompany
	WHERE ysnParent = 0
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
