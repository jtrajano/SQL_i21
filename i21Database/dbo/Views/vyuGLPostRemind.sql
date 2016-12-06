CREATE VIEW [dbo].[vyuGLPostRemind]
AS
WITH cte AS(
	SELECT A.PostRemind_Days,A.PostRemind_BeforeAfter, B.Item intEntity FROM tblGLCompanyPreferenceOption A
	CROSS APPLY dbo.fnSplitString(A.PostRemind_Users,',')  B
)
,cte2 as (
SELECT TOP 1
case when Options.PostRemind_BeforeAfter = 'Before' THEN 
	DATEADD(day, Options.PostRemind_Days *-1, dtmEndDate) 
ELSE
	dtmStartDate END	
AS DateLimit1,
CASE WHEN Options.PostRemind_BeforeAfter = 'Before' THEN 
	 DATEADD(DAY,1,dtmEndDate)
ELSE
	DATEADD(day,Options.PostRemind_Days+1, dtmStartDate)  END	
AS DateLimit2
FROM tblGLFiscalYearPeriod 
CROSS APPLY(
	SELECT TOP 1  PostRemind_Days,PostRemind_BeforeAfter FROM cte )Options
	WHERE CONVERT(DATE, GETDATE(),101) BETWEEN dtmStartDate AND  dtmEndDate
)
SELECT  intJournalId, intEntityId, DateLimit1,DateLimit2 FROM tblGLJournal J JOIN 
	cte ON J.intEntityId = cte.intEntity 
	JOIN cte2 on CONVERT(DATE, J.dtmDate,101) BETWEEN DateLimit1 AND DateLimit2
	WHERE ysnPosted = 0
	AND ISNULL(ysnRecurringTemplate,0) = 0
	AND CONVERT(DATE, GETDATE(),101) BETWEEN DateLimit1 AND  DateLimit2
GO