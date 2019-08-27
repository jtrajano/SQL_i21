GO
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountRange)
	BEGIN
		PRINT 'Start generating default account range'
		EXEC uspGLGenerateAccountRange
		PRINT 'Fnished generating default account range'
	END
GO
