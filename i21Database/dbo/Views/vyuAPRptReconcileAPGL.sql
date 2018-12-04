CREATE VIEW [dbo].[vyuAPRptReconcileAPGL]
	AS 
	SELECT
	strCustomerNumber = 'CustomerNumber' COLLATE Latin1_General_CI_AS
	,strContactMethod = 'CustomerContact' COLLATE Latin1_General_CI_AS
	,strTicketNumber = 'TicketNumber' COLLATE Latin1_General_CI_AS
	,dtmDate = CONVERT(VARCHAR(10), GETDATE(), 101) COLLATE Latin1_General_CI_AS
	,dtmTime = CONVERT(VARCHAR(5), GETDATE(), 108) + ' ' + RIGHT(CONVERT(VARCHAR(30), GETDATE(), 9), 2) COLLATE Latin1_General_CI_AS
	,strAgent = 'Agent' COLLATE Latin1_General_CI_AS
	,strNote = 'Note' COLLATE Latin1_General_CI_AS
	,intTicketNoteId = 0
