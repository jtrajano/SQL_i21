GO
	PRINT N'Begin Generating Account Range'
	
	EXEC dbo.uspGLGenerateAccountRange
	
	PRINT N'Finished Generating Account Range'
GO