CREATE PROCEDURE dbo.uspMFProcessRecipes
AS
BEGIN
	DECLARE @strSessionId NVARCHAR(50),@intRecordId int,@intEntityId int
	DECLARE @tblMFSession TABLE (
		intRecordId INT identity(1, 1)
		,strSessionId NVARCHAR(50)
		)

		Select @intEntityId=intEntityId 
		from tblSMUserSecurity 
		Where strUserName ='IRELYADMIN'

	INSERT INTO @tblMFSession
	SELECT DISTINCT strSessionId
	FROM tblMFRecipeStage
	WHERE IsNULL(strMessage, '') = ''

	SELECT @intRecordId = MIN(intRecordId)
	FROM @tblMFSession

	WHILE @intRecordId IS NOT NULL
	BEGIN
		SELECT @strSessionId = NULL

		SELECT @strSessionId = strSessionId
		FROM @tblMFSession
		WHERE intRecordId = @intRecordId

		EXEC dbo.uspMFImportRecipes @strSessionId
			,'Recipe Delete'
			,@intEntityId

		EXEC dbo.uspMFImportRecipes @strSessionId
			,'Recipe Item Delete'
			,@intEntityId

		EXEC dbo.uspMFImportRecipes @strSessionId
			,'Recipe'
			,@intEntityId

		EXEC dbo.uspMFImportRecipes @strSessionId
			,'Recipe Item'
			,@intEntityId

		SELECT @intRecordId = MIN(intRecordId)
		FROM @tblMFSession
		WHERE intRecordId > @intRecordId
	END
END

