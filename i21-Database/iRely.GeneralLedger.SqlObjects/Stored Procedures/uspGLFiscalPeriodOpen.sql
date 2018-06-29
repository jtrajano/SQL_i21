CREATE PROCEDURE uspGLFiscalPeriodOpen
(
	@intFiscalPeriodId INT
)
AS

DECLARE @tbl TABLE (strDescription NVARCHAR(100))
INSERT INTO @tbl
SELECT TOP 1 'AP Already Revalued.'  FROM tblGLFiscalYearPeriod WHERE intGLFiscalYearPeriodId = @intFiscalPeriodId AND ysnAPRevalued = 1 
UNION SELECT TOP 1 'AR Already Revalued.'  FROM tblGLFiscalYearPeriod WHERE intGLFiscalYearPeriodId = @intFiscalPeriodId AND ysnARRevalued = 1 
UNION SELECT TOP 1 'CM Already Revalued.'  FROM tblGLFiscalYearPeriod WHERE intGLFiscalYearPeriodId = @intFiscalPeriodId AND ysnCMRevalued = 1 
UNION SELECT TOP 1 'INV Already Revalued.'  FROM tblGLFiscalYearPeriod WHERE intGLFiscalYearPeriodId = @intFiscalPeriodId AND ysnINVRevalued = 1 
UNION SELECT TOP 1 'CT Already Revalued.'  FROM tblGLFiscalYearPeriod WHERE intGLFiscalYearPeriodId = @intFiscalPeriodId AND ysnCTRevalued = 1 
UNION SELECT TOP 1 'GL Already Consolidated.'  FROM tblGLFiscalYearPeriod WHERE intGLFiscalYearPeriodId = @intFiscalPeriodId AND ysnConsolidated = 1 
	
DECLARE @ErrorMessage NVARCHAR(100)
IF EXISTS(SELECT TOP 1 strDescription  FROM @tbl)
BEGIN
	SELECT TOP 1 @ErrorMessage=strDescription  FROM @tbl
	RAISERROR (@ErrorMessage,11,1)
	RETURN
END
UPDATE tblGLFiscalYearPeriod SET 
ysnAPOpen = 1
,ysnAROpen = 1
,ysnCMOpen = 1
,ysnCTOpen = 1
,ysnFAOpen = 1
,ysnINVOpen = 1
,ysnPROpen = 1
,ysnOpen = 1
WHERE intGLFiscalYearPeriodId = @intFiscalPeriodId