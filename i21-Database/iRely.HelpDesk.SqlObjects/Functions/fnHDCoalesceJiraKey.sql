CREATE FUNCTION [dbo].[fnHDCoalesceJiraKey](@intTicketId int)
RETURNS nvarchar(max)
AS
BEGIN

	DECLARE @strJiraKeys nvarchar(max);
	SELECT
		@strJiraKeys = COALESCE(@strJiraKeys + ',<br>', '') + '<a target="_blank" title="Click to go to ' + tblHDTicketJIRAIssue.strKey + '." href="http://jira.irelyserver.com/browse/' + tblHDTicketJIRAIssue.strKey + '">' + tblHDTicketJIRAIssue.strKey + '</a>'
	FROM
		tblHDTicketJIRAIssue
	WHERE
		ltrim(rtrim(tblHDTicketJIRAIssue.strKey)) <> ''
		and tblHDTicketJIRAIssue.intTicketId = @intTicketId

	return @strJiraKeys

END