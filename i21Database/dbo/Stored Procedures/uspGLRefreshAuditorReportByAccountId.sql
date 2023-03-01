CREATE PROCEDURE uspGLRefreshAuditorReportByAccountId
AS

TRUNCATE TABLE tblGLAuditorReportByAccountId;

With CTE AS(
select * from fnGLGetAccountCurrencyReportExpRev(6)
union all
select * from fnGLGetAccountCurrencyReport(6)
)
INSERT INTO tblGLAuditorReportByAccountId
SELECT * FROM CTE
ORDER BY strAccountId, intCurrencyID, dtmDate, intGLDetailId


