
PRINT N'BEGIN Update of data in tblSMSite'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMSite]') AND type in (N'U')) 
BEGIN
	IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblWinterDailyUse' AND OBJECT_ID = OBJECT_ID(N'tblTMSite')) 
    BEGIN
        UPDATE tblTMSite
		SET dblWinterDailyUse = 0.0
		WHERE dblWinterDailyUse IS NULL
    END

	IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblSummerDailyUse' AND OBJECT_ID = OBJECT_ID(N'tblTMSite')) 
    BEGIN
        UPDATE tblTMSite
		SET dblSummerDailyUse = 0.0
		WHERE dblSummerDailyUse IS NULL
    END
END
GO
PRINT N'END Update of data in tblSMSite'
GO

