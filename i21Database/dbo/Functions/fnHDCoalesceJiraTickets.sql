﻿CREATE FUNCTION [dbo].[fnHDCoalesceJiraTickets](@jiraKey nvarchar(50),@ysnDisplay bit, @isId bit)
RETURNS nvarchar(max)
AS
BEGIN

	DECLARE @strJiraTickets nvarchar(max);
	DECLARE @strJiraTicketIds nvarchar(max);
	SELECT
		@strJiraTickets = (case when @ysnDisplay = convert(bit,1) then COALESCE(@strJiraTickets + ',<br>', '') + '<a href="#" onclick="i21.controller.ModuleManager.HelpDesk.timeEntryGotoTicket('''+ tblHDTicket.strTicketNumber +'''); return false;" title="Click to view ' + tblHDTicket.strTicketNumber + '.">' + tblHDTicket.strTicketNumber + '</a>' else COALESCE(@strJiraTickets + ',', '') + tblHDTicket.strTicketNumber end) COLLATE Latin1_General_CI_AS
		,@strJiraTicketIds = COALESCE(@strJiraTicketIds + ',', '') + convert(nvarchar(20),tblHDTicket.intTicketId) COLLATE Latin1_General_CI_AS
	FROM
		tblHDTicketJIRAIssue
	inner join tblHDTicket on tblHDTicket.intTicketId = tblHDTicketJIRAIssue.intTicketId
	WHERE
		tblHDTicketJIRAIssue.strJiraKey = @jiraKey

	if (@isId = convert(bit,1))
	begin
		set @strJiraTickets = @strJiraTicketIds;
	end
	return @strJiraTickets COLLATE Latin1_General_CI_AS

END

GO