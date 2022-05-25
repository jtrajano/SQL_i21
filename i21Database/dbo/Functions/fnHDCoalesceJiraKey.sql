CREATE FUNCTION [dbo].[fnHDCoalesceJiraKey](@intTicketId int,@ysnDisplay bit)
RETURNS nvarchar(max)
AS
BEGIN

	DECLARE @strJiraKeys nvarchar(max);
	SELECT
		@strJiraKeys = (case when @ysnDisplay = convert(bit,1) then COALESCE(@strJiraKeys + ',<br>', '') + '<a target="_blank" title="Click to go to ' + Ticket.strKey + '." href="http://jira.irelyserver.com/browse/' + Ticket.strKey + '">' + Ticket.strKey + '</a>' else COALESCE(@strJiraKeys + ',', '') + Ticket.strKey end)
	FROM
		( 
			SELECT strKey = CASE WHEN ISNULL(strJiraKey, '') <> '' AND strKey != strJiraKey  
									THEN strJiraKey
								ELSE strKey
							END
			FROM tblHDTicketJIRAIssue	
			WHERE LTRIM(RTRIM(tblHDTicketJIRAIssue.strKey)) <> ''
				  AND tblHDTicketJIRAIssue.intTicketId = @intTicketId
		) Ticket

	RETURN @strJiraKeys

END