CREATE VIEW [dbo].[vyuGLPostRemind]
AS
WITH cte AS(
	SELECT A.PostRemind_Days,A.PostRemind_BeforeAfter, B.Item intEntity FROM tblGLCompanyPreferenceOption A
	CROSS APPLY dbo.fnSplitString(A.PostRemind_Users,',')  B
)
,cte2 as (
SELECT TOP 1
case when Options.PostRemind_BeforeAfter = 'Before' then 
	DATEADD(day, Options.PostRemind_Days *-1, dtmEndDate) 
else
	dtmStartDate end	
as DateLimit1,
case when Options.PostRemind_BeforeAfter = 'Before' then 
	 dtmEndDate
else
	DATEADD(day,Options.PostRemind_Days, dtmStartDate)  end	
as DateLimit2
FROM tblGLFiscalYearPeriod 
CROSS APPLY(SELECT TOP 1  PostRemind_Days,PostRemind_BeforeAfter FROM cte )Options
where getdate() between dateadd(day,-1, dtmStartDate) and DATEADD(day,1, dtmEndDate)
)
SELECT  intJournalId, intEntityId, DateLimit1,DateLimit2 FROM tblGLJournal J JOIN 
	cte ON J.intEntityId = cte.intEntity 
	join cte2 on J.dtmDate BETWEEN DateLimit1 and  DateLimit2
	WHERE ysnPosted = 0
	AND ISNULL(ysnRecurringTemplate,0) =0
	and getdate() between dateadd(day,-1, DateLimit1) and DATEADD(day,1, DateLimit2)
GO
