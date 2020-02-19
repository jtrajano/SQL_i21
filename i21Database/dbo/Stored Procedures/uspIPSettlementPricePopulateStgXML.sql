CREATE PROCEDURE uspIPSettlementPricePopulateStgXML @intFutureSettlementPriceId INT
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
		,@intFutureSettlementPriceStageId INT
		,@strObjectName NVARCHAR(50)
		,@strLastModifiedUser NVARCHAR(100)
		,@strAdditionalInfo NVARCHAR(MAX)
		,@strFutSettlementPriceXML NVARCHAR(MAX)
		,@strOptSettlementPriceXML NVARCHAR(MAX)
		,@strDisplayName NVARCHAR(100)

	SET @intFutureSettlementPriceStageId = NULL
	SET @strHeaderXML = NULL
	SET @strHeaderCondition = NULL
	SET @strLastModifiedUser = NULL
	SET @strDisplayName = NULL

	SELECT @strDisplayName = CONVERT(NVARCHAR, dtmPriceDate, 120)
	FROM tblRKFuturesSettlementPrice
	WHERE intFutureSettlementPriceId = @intFutureSettlementPriceId

	-------------------------Header-----------------------------------------------------------
	SELECT @strHeaderCondition = 'intFutureSettlementPriceId = ' + LTRIM(@intFutureSettlementPriceId)

	SELECT @strObjectName = 'vyuIPGetFuturesSettlementPrice'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strHeaderXML OUTPUT
		,NULL
		,NULL

	---------------------------------------------Detail------------------------------------------
	SELECT @strFutSettlementPriceXML = NULL
		,@strObjectName = NULL

	SELECT @strObjectName = 'vyuIPGetFutSettlementPriceMarketMap'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strFutSettlementPriceXML OUTPUT
		,NULL
		,NULL

	SELECT @strOptSettlementPriceXML = NULL
		,@strObjectName = NULL

	SELECT @strObjectName = 'vyuIPGetOptSettlementPriceMarketMap'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strOptSettlementPriceXML OUTPUT
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

	SET @intFutureSettlementPriceStageId = SCOPE_IDENTITY();

	INSERT INTO tblRKFuturesSettlementPriceStage (
		intFutureSettlementPriceId
		,strDisplayName
		,strHeaderXML
		,strFutSettlementPriceXML
		,strOptSettlementPriceXML
		,strRowState
		,strUserName
		,intMultiCompanyId
		,intEntityId
		,intCompanyLocationId
		,strTransactionType
		,intToBookId
		)
	SELECT intFutureSettlementPriceId = @intFutureSettlementPriceId
		,strDisplayName = @strDisplayName
		,strHeaderXML = @strHeaderXML
		,strFutSettlementPriceXML = @strFutSettlementPriceXML
		,strOptSettlementPriceXML = @strOptSettlementPriceXML
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
