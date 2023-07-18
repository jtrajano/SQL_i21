
GO
	PRINT 'BEGIN FRD 2210'
GO


IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intAccountGroupClusterId' AND OBJECT_ID = OBJECT_ID(N'tblFRReport')) 
BEGIN
    UPDATE tblFRReport SET intAccountGroupClusterId = 1 WHERE strReportType = 'Group'
END
GO

GO
	PRINT 'END FRD 2220'
GO

