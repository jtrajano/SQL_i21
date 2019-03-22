CREATE VIEW [dbo].[vyuAPRptReconcileAPGL]
	AS 
	SELECT
	strCustomerNumber = 'CustomerNumber'
	,strContactMethod = 'CustomerContact'
	,strTicketNumber = 'TicketNumber'
	,dtmDate = CONVERT(VARCHAR(10), GETDATE(), 101)
	,dtmTime = CONVERT(VARCHAR(5), GETDATE(), 108) + ' ' + RIGHT(CONVERT(VARCHAR(30), GETDATE(), 9), 2)
	,strAgent = 'Agent'
	,strNote = 'Note'
	,intTicketNoteId = 0
