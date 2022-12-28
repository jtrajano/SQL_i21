CREATE FUNCTION [dbo].[fnGLGetJournalExportTimberline] (@intJournalId INT)
RETURNS  @tbl TABLE(
	strAccountId NVARCHAR(40),
	strDescription NVARCHAR(255),
	strSourceId NVARCHAR(10),
	dtmDate VARCHAR(20),
	dblDebit NUMERIC(18,6),
	dblCredit NUMERIC(18,6),
	strComments NVARCHAR(255),
	strReference NVARCHAR(100)
)
AS
BEGIN
	INSERT INTO @tbl
	SELECT 
		GLA.strAccountId 
		,RTRIM(D.strDescription) strDescription
		,A.strSourceId
		,CONVERT(VARCHAR(20), A.dtmDate,101) dtmDate
		,D.dblDebit
		,D.dblCredit
		,D.strComments
		,D.strReference 
	FROM tblGLJournal A
	JOIN tblGLJournalDetail D ON A.intJournalId = D.intJournalId
	LEFT JOIN tblGLAccount GLA ON  GLA.intAccountId = D.intAccountId 
	WHERE A.intJournalId = @intJournalId
	RETURN
END