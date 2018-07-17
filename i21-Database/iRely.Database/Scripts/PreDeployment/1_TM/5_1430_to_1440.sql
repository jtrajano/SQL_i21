
PRINT N'BEGIN Update of data in tblTMLease'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMLease]') AND type in (N'U')) 
BEGIN
	IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'ysnLeaseToOwn' AND OBJECT_ID = OBJECT_ID(N'tblTMLease')) 
    BEGIN
		EXEC('
			UPDATE tblTMLease
			SET ysnLeaseToOwn = 0
			WHERE ysnLeaseToOwn IS NULL
			')
    END
END
GO
PRINT N'END Update of data in tblTMLease'
GO
