PRINT N'BEGIN - IC Data Fix for 19.1. Populate the Stock Usage'
GO

IF	EXISTS (SELECT 1 FROM (SELECT TOP 1 dblVersion = CAST(LEFT(strVersionNo, 4) AS NUMERIC(18,1)) FROM tblSMBuildNumber ORDER BY intVersionID DESC) v WHERE v.dblVersion <= 19.1)
	AND NOT EXISTS (SELECT TOP 1 1 FROM tblICItemStockUsagePerPeriod)
BEGIN 
	EXEC uspARFixStockUsage
END 
GO

PRINT N'END - IC Data Fix for 19.1. Populate the Stock Usage'