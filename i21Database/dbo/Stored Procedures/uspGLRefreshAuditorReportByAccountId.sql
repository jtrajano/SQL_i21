CREATE PROCEDURE uspGLRefreshAuditorReportByAccountId
AS
DECLARE @intDefaultCurrencyId INT
SELECT TOP 1 @intDefaultCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference 
TRUNCATE TABLE tblGLAuditorReportByAccountId;

With CTE AS(
select * from fnGLGetAccountCurrencyReportExpRev(@intDefaultCurrencyId)
union all
select * from fnGLGetAccountCurrencyReport(@intDefaultCurrencyId)
)
INSERT INTO tblGLAuditorReportByAccountId
SELECT * FROM CTE
ORDER BY strAccountId, intCurrencyID, dtmDate, intGLDetailId


