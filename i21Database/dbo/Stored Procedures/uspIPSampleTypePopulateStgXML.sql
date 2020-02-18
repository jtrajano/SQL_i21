CREATE PROCEDURE uspIPSampleTypePopulateStgXML @intSampleTypeId INT
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
		,@intSampleTypeStageId INT
		,@strObjectName NVARCHAR(50)
		,@strLastModifiedUser NVARCHAR(100)
		,@strAdditionalInfo NVARCHAR(MAX)
		,@strSampleTypeDetailXML NVARCHAR(MAX)
		,@strSampleTypeUserRoleXML NVARCHAR(MAX)
		,@strSampleTypeName NVARCHAR(50)

	SET @intSampleTypeStageId = NULL
	SET @strHeaderXML = NULL
	SET @strHeaderCondition = NULL
	SET @strLastModifiedUser = NULL
	SET @strSampleTypeName = NULL

	SELECT @strSampleTypeName = strSampleTypeName
	FROM tblQMSampleType
	WHERE intSampleTypeId = @intSampleTypeId

	-------------------------Header-----------------------------------------------------------
	SELECT @strHeaderCondition = 'intSampleTypeId = ' + LTRIM(@intSampleTypeId)

	SELECT @strObjectName = 'vyuIPGetSampleType'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strHeaderXML OUTPUT
		,NULL
		,NULL

	---------------------------------------------Detail------------------------------------------
	SELECT @strSampleTypeDetailXML = NULL
		,@strObjectName = NULL

	SELECT @strObjectName = 'vyuIPGetSampleTypeDetail'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strSampleTypeDetailXML OUTPUT
		,NULL
		,NULL

	SELECT @strSampleTypeUserRoleXML = NULL
		,@strObjectName = NULL

	SELECT @strObjectName = 'vyuIPGetSampleTypeUserRole'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strSampleTypeUserRoleXML OUTPUT
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

	SET @intSampleTypeStageId = SCOPE_IDENTITY();

	INSERT INTO tblQMSampleTypeStage (
		intSampleTypeId
		,strSampleTypeName
		,strHeaderXML
		,strSampleTypeDetailXML
		,strSampleTypeUserRoleXML
		,strRowState
		,strUserName
		,intMultiCompanyId
		,intEntityId
		,intCompanyLocationId
		,strTransactionType
		,intToBookId
		)
	SELECT intSampleTypeId = @intSampleTypeId
		,strSampleTypeName = @strSampleTypeName
		,strHeaderXML = @strHeaderXML
		,strSampleTypeDetailXML = @strSampleTypeDetailXML
		,strSampleTypeUserRoleXML = @strSampleTypeUserRoleXML
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
