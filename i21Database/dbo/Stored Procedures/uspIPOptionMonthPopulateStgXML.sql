CREATE PROCEDURE uspIPOptionMonthPopulateStgXML @intOptionMonthId INT
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
		,@intOptionMonthStageId INT
		,@strObjectName NVARCHAR(50)
		,@strLastModifiedUser NVARCHAR(100)
		,@strAdditionalInfo NVARCHAR(MAX)
		,@strOptionMonth NVARCHAR(20)

	SET @intOptionMonthStageId = NULL
	SET @strHeaderXML = NULL
	SET @strHeaderCondition = NULL
	SET @strLastModifiedUser = NULL
	SET @strOptionMonth = NULL

	SELECT @strOptionMonth = strOptionMonth
	FROM tblRKOptionsMonth WITH (NOLOCK)
	WHERE intOptionMonthId = @intOptionMonthId

	-------------------------Header-----------------------------------------------------------
	SELECT @strHeaderCondition = 'intOptionMonthId = ' + LTRIM(@intOptionMonthId)

	SELECT @strObjectName = 'vyuIPGetOptionMonth'

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

	SET @intOptionMonthStageId = SCOPE_IDENTITY();

	DECLARE @tblIPMultiCompany TABLE (intCompanyId INT)
	DECLARE @intCompanyId INT

	DECLARE @strSQL NVARCHAR(MAX)
		,@strServerName NVARCHAR(50)
		,@strDatabaseName NVARCHAR(50)

	INSERT INTO @tblIPMultiCompany (intCompanyId)
	SELECT intCompanyId
	FROM tblIPMultiCompany WITH (NOLOCK)
	WHERE ysnParent = 0

	WHILE EXISTS (
			SELECT TOP 1 NULL
			FROM @tblIPMultiCompany
			)
	BEGIN
		SELECT TOP 1 @intCompanyId = intCompanyId
		FROM @tblIPMultiCompany

		SELECT @strServerName = strServerName
			,@strDatabaseName = strDatabaseName
		FROM tblIPMultiCompany WITH (NOLOCK)
		WHERE intCompanyId = @intCompanyId

		IF EXISTS (SELECT 1 FROM master.dbo.sysdatabases WHERE name = @strDatabaseName)
		BEGIN
			SELECT @strSQL = N'INSERT INTO ' + @strServerName + '.' + @strDatabaseName + '.dbo.tblRKOptionsMonthStage (
				intOptionMonthId
				,strOptionMonth
				,strHeaderXML
				,strRowState
				,strUserName
				,intMultiCompanyId
				,intEntityId
				,intCompanyLocationId
				,strTransactionType
				,intToBookId
				)
			SELECT intOptionMonthId = @intOptionMonthId
				,strOptionMonth = @strOptionMonth
				,strHeaderXML = @strHeaderXML
				,strRowState = @strRowState
				,strUserName = @strLastModifiedUser
				,intMultiCompanyId = @intCompanyId
				,intEntityId = @intToEntityId
				,intCompanyLocationId = @intCompanyLocationId
				,strTransactionType = @strToTransactionType
				,intToBookId = @intToBookId'

			EXEC sp_executesql @strSQL
				,N'@intOptionMonthId INT
					,@strOptionMonth NVARCHAR(20)
					,@strHeaderXML NVARCHAR(MAX)
					,@strRowState NVARCHAR(100)
					,@strLastModifiedUser NVARCHAR(100)
					,@intCompanyId INT
					,@intToEntityId INT
					,@intCompanyLocationId INT
					,@strToTransactionType NVARCHAR(100)
					,@intToBookId INT'
				,@intOptionMonthId
				,@strOptionMonth
				,@strHeaderXML
				,@strRowState
				,@strLastModifiedUser
				,@intCompanyId
				,@intToEntityId
				,@intCompanyLocationId
				,@strToTransactionType
				,@intToBookId
		END

		DELETE
		FROM @tblIPMultiCompany
		WHERE intCompanyId = @intCompanyId
	END
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
