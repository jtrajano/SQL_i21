CREATE VIEW [dbo].[vyuHDTicketRACIResponsible]
	AS
	select intResponsibleId = 1, strResponsible = 'Responsible'
	union all
	select intResponsibleId = 2, strResponsible = 'Accountable'
	union all
	select intResponsibleId = 3, strResponsible = 'Consulted'
	union all
	select intResponsibleId = 4, strResponsible = 'Informed'
