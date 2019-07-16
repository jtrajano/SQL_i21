GO
	PRINT 'Start generating default account range'
GO
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblGLAccountRange)
	BEGIN
		DECLARE @result nvarchar(20)
		EXEC dbo.uspGLGenerateAccountRange @result out
	END
GO
	PRINT 'Fnished generating default account range'
GO
