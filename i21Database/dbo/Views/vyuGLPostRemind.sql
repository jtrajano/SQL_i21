CREATE VIEW [dbo].[vyuGLPostRemind]
AS
WITH cte as(
	SELECT A.PostRemind_Days,A.PostRemind_BeforeAfter, B.Item intEntity from tblGLCompanyPreferenceOption A
	 CROSS APPLY dbo.fnSplitString(A.PostRemind_Users,',')  B
),
cte2 as (
	SELECT DATEADD(DAY, Options.PostRemind_Days* -1 , dtmEndDate) BeforeEndDate,  DATEADD(DAY, Options.PostRemind_Days -1  , dtmStartDate)AfterEndDate , Options.PostRemind_BeforeAfter 
	FROM tblGLFiscalYearPeriod
	CROSS APPLY(SELECT TOP 1  PostRemind_Days,PostRemind_BeforeAfter FROM tblGLCompanyPreferenceOption )Options
	WHERE GETDATE() BETWEEN dtmStartDate and dtmEndDate
)
SELECT intJournalId,intEntityId FROM tblGLJournal J JOIN 
	cte ON J.intEntityId = cte.intEntity 
	CROSS APPLY (SELECT BeforeEndDate,AfterEndDate, PostRemind_BeforeAfter FROM 
	cte2) Remind
	where ysnPosted = 0	AND 
	((GETDATE()>=Remind.BeforeEndDate AND Remind.PostRemind_BeforeAfter = 'Before') or
	(GETDATE()>=Remind.AfterEndDate AND Remind.PostRemind_BeforeAfter = 'After'))
GO
