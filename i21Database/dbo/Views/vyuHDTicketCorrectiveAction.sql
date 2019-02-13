CREATE VIEW [dbo].[vyuHDTicketCorrectiveAction]
	AS
	select a.intCorrectiveActionId, a.intTicketId, a.intCorrectiveActionTicketId, b.strTicketNumber, b.strSubject, a.intConcurrencyId from tblHDTicketCorrectiveAction a, tblHDTicket b where b.intTicketId = a.intCorrectiveActionTicketId
