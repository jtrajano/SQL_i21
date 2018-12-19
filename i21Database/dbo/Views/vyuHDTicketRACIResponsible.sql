CREATE VIEW [dbo].[vyuHDTicketRACIResponsible]
	AS
	select intResponsibleId = 1, strResponsible = 'Responsible' COLLATE Latin1_General_CI_AS
	union all
	select intResponsibleId = 2, strResponsible = 'Accountable' COLLATE Latin1_General_CI_AS
	union all
	select intResponsibleId = 3, strResponsible = 'Consulted' COLLATE Latin1_General_CI_AS
	union all
	select intResponsibleId = 4, strResponsible = 'Informed' COLLATE Latin1_General_CI_AS
