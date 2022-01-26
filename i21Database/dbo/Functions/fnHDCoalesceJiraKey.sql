CREATE FUNCTION [dbo].[fnHDCoalesceJiraKey](@intTicketId int,@ysnDisplay bit)
RETURNS nvarchar(max)
AS
BEGIN

	DECLARE @strJiraKeys nvarchar(max);
	SELECT
		@strJiraKeys = (case when @ysnDisplay = convert(bit,1) then COALESCE(@strJiraKeys + ',<br>', '') + '<a target="_blank" title="Click to go to ' + tblHDTicketJIRAIssue.strKey + '." href="http://jira.irelyserver.com/browse/' + tblHDTicketJIRAIssue.strKey + '">' + tblHDTicketJIRAIssue.strKey + '</a>' else COALESCE(@strJiraKeys + ',', '') + tblHDTicketJIRAIssue.strKey end)
	FROM
		tblHDTicketJIRAIssue
	WHERE
		ltrim(rtrim(tblHDTicketJIRAIssue.strKey)) <> ''
		and tblHDTicketJIRAIssue.intTicketId = @intTicketId
		and strKey = strJiraKey

	return @strJiraKeys

END