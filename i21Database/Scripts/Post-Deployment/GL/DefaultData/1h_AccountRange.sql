GO
	PRINT 'Start generating default account range'
GO
	DECLARE @result nvarchar(20)
	EXEC dbo.uspGLGenerateAccountRange @result out
GO
	PRINT 'Fnished generating default account range'
GO
