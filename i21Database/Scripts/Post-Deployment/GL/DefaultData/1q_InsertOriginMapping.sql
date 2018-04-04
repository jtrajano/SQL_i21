GO
IF EXISTS( SELECT TOP 1 1 FROM tblGLAccountSystem WHERE strAccountSystemDescription = 'Origin')
BEGIN
	PRINT('Begin deleting exisiting Origin account mapping')
	DECLARE @intAccountSystemId INT
	SELECT TOP 1 @intAccountSystemId = intAccountSystemId FROM tblGLAccountSystem WHERE strAccountSystemDescription = 'Origin'
	DELETE FROM tblGLCrossReferenceMapping WHERE intAccountSystemId = @intAccountSystemId
	DELETE FROM tblGLAccountSystem WHERE intAccountSystemId = @intAccountSystemId
	PRINT('Finished deleting exisiting Origin account mapping')
END

