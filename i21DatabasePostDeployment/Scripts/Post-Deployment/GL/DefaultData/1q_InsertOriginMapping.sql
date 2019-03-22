GO
IF EXISTS( SELECT TOP 1 1 FROM tblGLAccountSystem WHERE strAccountSystemDescription = 'Origin')
BEGIN
	PRINT('Begin deleting exisiting Origin account mapping')
	DECLARE @intAccountSystemId INT
	SELECT TOP 1 @intAccountSystemId = intAccountSystemId FROM tblGLAccountSystem WHERE strAccountSystemDescription = 'Origin'
	DELETE FROM tblGLCrossReferenceMapping WHERE intAccountSystemId = @intAccountSystemId
	--DELETE FROM tblGLAccountSystem WHERE intAccountSystemId = @intAccountSystemId
	PRINT('Finished deleting exisiting Origin account mapping')
	--update strOldAccountId column in tblGLAccount
	DECLARE @intDefaultAccountSystemId INT
	SELECT TOP 1 @intDefaultAccountSystemId =intDefaultVisibleOldAccountSystemId FROM tblGLCompanyPreferenceOption 
	IF @intDefaultAccountSystemId IS NOT NULL
	BEGIN
		IF @intDefaultAccountSystemId = @intAccountSystemId
			UPDATE tblGLAccount set strOldAccountId = null
		IF @intAccountSystemId IS NOT NULL AND @intDefaultAccountSystemId <> @intAccountSystemId
			EXEC dbo.uspGLUpdateOldAccountId @intDefaultAccountSystemId
	END
END

