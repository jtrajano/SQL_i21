CREATE VIEW vyuGLPostRemind 
AS
WITH cte AS(
	SELECT top 1 A.PostRemind_Users, A.PostRemind_Days,A.PostRemind_BeforeAfter FROM tblGLCompanyPreferenceOption A
	
),
USERS as (
	SELECT B.Item intEntityId FROM cte A
	OUTER APPLY dbo.fnSplitString(A.PostRemind_Users,',')B
),
After as
(
	SELECT PreviousFiscal.dtmStartDate, PreviousFiscal.dtmEndDate
	FROM cte A
	CROSS APPLY(
		SELECT TOP 1 dtmStartDate, dtmEndDate
		,dateadd( day, PostRemind_Days -1, dtmEndDate) dtmMin
		 FROM tblGLFiscalYearPeriod
		WHERE CONVERT(DATE, GETDATE(),101) > dtmEndDate order by dtmStartDate desc
	) PreviousFiscal
	CROSS APPLY(
	 SELECT top 1 dtmEndDate FROM tblGLFiscalYearPeriod WHERE
		dtmEndDate > PreviousFiscal.dtmEndDate
		order by dtmStartDate 
	)NextFiscal
	WHERE PostRemind_BeforeAfter = 'After'
	AND  GETDATE() >= PreviousFiscal.dtmMin and 
	getdate() <=NextFiscal.dtmEndDate
),
Before as
(
	SELECT CurrentFiscal.dtmStartDate, CurrentFiscal.dtmEndDate
	FROM cte A
	CROSS APPLY(
		SELECT TOP 1 dtmStartDate, dtmEndDate , DATEADD(day,  (A.PostRemind_Days+1) * -1, dtmEndDate) dtmMin FROM tblGLFiscalYearPeriod
		WHERE CONVERT(DATE, GETDATE(),101) BETWEEN dtmStartDate AND dtmEndDate

	) CurrentFiscal
	WHERE PostRemind_BeforeAfter = 'Before'
	AND GETDATE() between CurrentFiscal.dtmMin and CurrentFiscal.dtmEndDate
),
rsult as (
SELECT dtmStartDate DateLimit1, dtmEndDate DateLimit2 FROM After 
UNION
SELECT dtmStartDate DateLimit1, dtmEndDate DateLimit2 FROM Before
)
SELECT  intJournalId, j.intEntityId, DateLimit1,DateLimit2 FROM tblGLJournal j JOIN 
	USERS u ON j.intEntityId = u.intEntityId 
	JOIN rsult on CONVERT(DATE, j.dtmDate,101) BETWEEN DateLimit1 AND DateLimit2
	WHERE j.ysnPosted = 0
	AND ISNULL(j.ysnRecurringTemplate,0) = 0
GO


