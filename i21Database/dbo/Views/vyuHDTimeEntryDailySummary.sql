CREATE VIEW [dbo].[vyuHDTimeEntryDailySummary]
	AS
		select
			intTimeEntryDailySummaryId
			,intTimeEntryId
			,intEntityId
			,dtmDate
			,intJiraId
			,strJiraKey
			,strJiraStatus
			,strJiraStatusIconUrl
			,strTicketId
			,strTicketNumber
			,strTicketNumbersDisplay
			,dtmDateStarted
			,dtmDateEnded
			,dblTimeSpent
			,strDescription
			,strComments
			,dblBillableHours
			,ysnSent
			,intSendByEntityId
			,strJIRAUserName
			,intConcurrencyId
			,intDate = convert(int, convert(nvarchar(8), dtmDate, 112))
		from tblHDTimeEntryDailySummary

