CREATE PROCEDURE uspIPProductPopulateStgXML @intProductId INT
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
		,@intProductStageId INT
		,@strObjectName NVARCHAR(50)
		,@strLastModifiedUser NVARCHAR(100)
		,@strAdditionalInfo NVARCHAR(MAX)
		,@strProductControlPointXML NVARCHAR(MAX)
		,@strProductTestXML NVARCHAR(MAX)
		,@strProductPropertyXML NVARCHAR(MAX)
		,@strProductPropertyValidityPeriodXML NVARCHAR(MAX)
		,@strConditionalProductPropertyXML NVARCHAR(MAX)
		,@strProductPropertyFormulaPropertyXML NVARCHAR(MAX)
		,@strProductName NVARCHAR(50)

	SET @intProductStageId = NULL
	SET @strHeaderXML = NULL
	SET @strHeaderCondition = NULL
	SET @strLastModifiedUser = NULL
	SET @strProductName = NULL

	SELECT @strProductName = COALESCE(C.strCategoryCode, I.strItemNo)
	FROM tblQMProduct P WITH (NOLOCK)
	LEFT JOIN tblICCategory C WITH (NOLOCK) ON C.intCategoryId = P.intProductValueId
		AND P.intProductTypeId = 1
	LEFT JOIN tblICItem I WITH (NOLOCK) ON I.intItemId = P.intProductValueId
		AND P.intProductTypeId = 2
	WHERE intProductId = @intProductId

	-------------------------Header-----------------------------------------------------------
	SELECT @strHeaderCondition = 'intProductId = ' + LTRIM(@intProductId)

	SELECT @strObjectName = 'vyuIPGetProduct'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strHeaderXML OUTPUT
		,NULL
		,NULL

	---------------------------------------------Detail------------------------------------------
	SELECT @strProductControlPointXML = NULL
		,@strObjectName = NULL

	SELECT @strObjectName = 'vyuIPGetProductControlPoint'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strProductControlPointXML OUTPUT
		,NULL
		,NULL

	SELECT @strProductTestXML = NULL
		,@strObjectName = NULL

	SELECT @strObjectName = 'vyuIPGetProductTest'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strProductTestXML OUTPUT
		,NULL
		,NULL

	SELECT @strProductPropertyXML = NULL
		,@strObjectName = NULL

	SELECT @strObjectName = 'vyuIPGetProductProperty'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strProductPropertyXML OUTPUT
		,NULL
		,NULL

	SELECT @strProductPropertyValidityPeriodXML = NULL
		,@strObjectName = NULL

	SELECT @strObjectName = 'vyuIPGetProductPropertyValidityPeriod'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strProductPropertyValidityPeriodXML OUTPUT
		,NULL
		,NULL

	SELECT @strConditionalProductPropertyXML = NULL
		,@strObjectName = NULL

	SELECT @strObjectName = 'vyuIPGetConditionalProductProperty'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strConditionalProductPropertyXML OUTPUT
		,NULL
		,NULL

	SELECT @strProductPropertyFormulaPropertyXML = NULL
		,@strObjectName = NULL

	SELECT @strObjectName = 'vyuIPGetProductPropertyFormulaProperty'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strProductPropertyFormulaPropertyXML OUTPUT
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

	SET @intProductStageId = SCOPE_IDENTITY();

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
			SELECT @strSQL = N'INSERT INTO ' + @strServerName + '.' + @strDatabaseName + '.dbo.tblQMProductStage (
				intProductId
				,strProductName
				,strHeaderXML
				,strProductControlPointXML
				,strProductTestXML
				,strProductPropertyXML
				,strProductPropertyValidityPeriodXML
				,strConditionalProductPropertyXML
				,strProductPropertyFormulaPropertyXML
				,strRowState
				,strUserName
				,intMultiCompanyId
				,intEntityId
				,intCompanyLocationId
				,strTransactionType
				,intToBookId
				)
			SELECT intProductId = @intProductId
				,strProductName = @strProductName
				,strHeaderXML = @strHeaderXML
				,strProductControlPointXML = @strProductControlPointXML
				,strProductTestXML = @strProductTestXML
				,strProductPropertyXML = @strProductPropertyXML
				,strProductPropertyValidityPeriodXML = @strProductPropertyValidityPeriodXML
				,strConditionalProductPropertyXML = @strConditionalProductPropertyXML
				,strProductPropertyFormulaPropertyXML = @strProductPropertyFormulaPropertyXML
				,strRowState = @strRowState
				,strUserName = @strLastModifiedUser
				,intMultiCompanyId = @intCompanyId
				,intEntityId = @intToEntityId
				,intCompanyLocationId = @intCompanyLocationId
				,strTransactionType = @strToTransactionType
				,intToBookId = @intToBookId'

			EXEC sp_executesql @strSQL
				,N'@intProductId INT
					,@strProductName NVARCHAR(50)
					,@strHeaderXML NVARCHAR(MAX)
					,@strProductControlPointXML NVARCHAR(MAX)
					,@strProductTestXML NVARCHAR(MAX)
					,@strProductPropertyXML NVARCHAR(MAX)
					,@strProductPropertyValidityPeriodXML NVARCHAR(MAX)
					,@strConditionalProductPropertyXML NVARCHAR(MAX)
					,@strProductPropertyFormulaPropertyXML NVARCHAR(MAX)
					,@strRowState NVARCHAR(100)
					,@strLastModifiedUser NVARCHAR(100)
					,@intCompanyId INT
					,@intToEntityId INT
					,@intCompanyLocationId INT
					,@strToTransactionType NVARCHAR(100)
					,@intToBookId INT'
				,@intProductId
				,@strProductName
				,@strHeaderXML
				,@strProductControlPointXML
				,@strProductTestXML
				,@strProductPropertyXML
				,@strProductPropertyValidityPeriodXML
				,@strConditionalProductPropertyXML
				,@strProductPropertyFormulaPropertyXML
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
