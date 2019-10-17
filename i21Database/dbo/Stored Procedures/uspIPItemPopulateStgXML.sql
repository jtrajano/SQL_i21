Create PROCEDURE uspIPItemPopulateStgXML @intItemId INT
	,@strRowState NVARCHAR(50)
	,@intUserId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strItemXML NVARCHAR(MAX)
		,@strHeaderCondition NVARCHAR(MAX)
		,@strObjectName NVARCHAR(50)
		,@strLastModifiedUser NVARCHAR(100)

	SET @strItemXML = NULL
	SET @strHeaderCondition = NULL
	SET @strLastModifiedUser = NULL

	-------------------------Header-----------------------------------------------------------
	SELECT @strHeaderCondition = 'intItemId = ' + LTRIM(@intItemId)

	SELECT @strObjectName = 'vyuIPGetItem'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strHeaderCondition
		,@strItemXML OUTPUT
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

	INSERT INTO tblICItemStage (
		intItemId
		,strItemXML
		,strRowState
		,strUserName
		,intMultiCompanyId
		)
	SELECT intItemId = @intItemId
		,strItemXML = @strItemXML
		,strRowState = @strRowState
		,strUserName = @strLastModifiedUser
		,intMultiCompanyId = intCompanyId
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

