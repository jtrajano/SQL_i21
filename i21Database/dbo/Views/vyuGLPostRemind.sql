CREATE VIEW [dbo].[vyuGLPostRemind]
AS
WITH cte AS(
	SELECT A.PostRemind_Days,A.PostRemind_BeforeAfter, B.Item intEntity FROM tblGLCompanyPreferenceOption A
	CROSS APPLY dbo.fnSplitString(A.PostRemind_Users,',')  B
),
cte2 as (
	SELECT 
	CASE WHEN Options.PostRemind_BeforeAfter = 'Before' THEN DATEADD (DAY, Options.PostRemind_Days* -1 , dtmEndDate)
		ELSE DATEADD(DAY, Options.PostRemind_Days - 1  , dtmStartDate) END DateLimit1,
	Options.PostRemind_BeforeAfter ,
	CASE WHEN Options.PostRemind_BeforeAfter = 'Before' THEN dtmEndDate ELSE dtmStartDate END DateLimit2
	FROM tblGLFiscalYearPeriod 
	CROSS APPLY(SELECT TOP 1  PostRemind_Days,PostRemind_BeforeAfter FROM cte )Options
	WHERE GETDATE() BETWEEN dtmStartDate AND dtmEndDate
)
SELECT intJournalId,intEntityId,dtmDate,Remind.DateLimit1,Remind.DateLimit2 FROM tblGLJournal J JOIN 
	cte ON J.intEntityId = cte.intEntity 
	CROSS APPLY(
			SELECT TOP 1 
			CASE WHEN PostRemind_BeforeAfter = 'After' THEN DateLimit2 ELSE DateLimit1 END DateLimit1,
			CASE WHEN PostRemind_BeforeAfter = 'After' THEN DateLimit1 ELSE DateLimit2 END DateLimit2
			FROM cte2) Remind
	WHERE ysnPosted = 0
	AND 
		(GETDATE() BETWEEN Remind.DateLimit1 AND Remind.DateLimit2
		AND J.dtmDate BETWEEN Remind.DateLimit1 AND DateLimit2) 
GO