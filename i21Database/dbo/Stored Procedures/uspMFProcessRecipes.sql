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
	WHERE IsNULL(strMessage, '') = '' and intStatusId is null
	UNION
	SELECT DISTINCT strSessionId
	FROM tblMFRecipeItemStage
	WHERE IsNULL(strMessage, '') = '' and intStatusId is null

	Update tblMFRecipeStage 
	Set intStatusId=3 
	Where strSessionId in (Select strSessionId from @tblMFSession)

	Update tblMFRecipeItemStage 
	Set intStatusId=3 
	Where strSessionId in (Select strSessionId from @tblMFSession)

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
			,1

		EXEC dbo.uspMFImportRecipes @strSessionId
			,'Recipe Item'
			,@intEntityId

		SELECT @intRecordId = MIN(intRecordId)
		FROM @tblMFSession
		WHERE intRecordId > @intRecordId
	END

	Update tblMFRecipeStage 
	Set intStatusId=NULL
	Where strSessionId in (Select strSessionId from @tblMFSession) and intStatusId=3 

	Update tblMFRecipeItemStage 
	Set intStatusId=NULL
	Where strSessionId in (Select strSessionId from @tblMFSession)and intStatusId=3 
END

