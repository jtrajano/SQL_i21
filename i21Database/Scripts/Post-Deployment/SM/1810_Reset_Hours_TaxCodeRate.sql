PRINT N'BEGIN - RESET HOURS TAX CODE Fix for 18.1. '
GO

IF EXISTS( SELECT 1 FROM (SELECT TOP 1 dblVersion = CAST(LEFT(strVersionNo, 4) AS NUMERIC(18,1)) FROM tblSMBuildNumber ORDER BY intVersionID DESC) v WHERE v.dblVersion <= 19.1)
BEGIN
	UPDATE t SET dtmEffectiveDate = CAST(t.dtmEffectiveDate AS DATE)
	FROM tblSMTaxCodeRate t
END

GO

PRINT N'END - RESET HOURS TAX CODE Fix for 18.1. '