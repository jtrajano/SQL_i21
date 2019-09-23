GO
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountRange)
	BEGIN
		PRINT 'Start generating default account range'
		DECLARE @result nvarchar(20)
		EXEC dbo.uspGLGenerateAccountRange @result out
		PRINT 'Fnished generating default account range'
	END
GO