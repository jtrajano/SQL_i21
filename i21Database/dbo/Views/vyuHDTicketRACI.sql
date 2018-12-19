CREATE VIEW [dbo].[vyuHDTicketRACI]
	AS
	select
		a.intTicketRACIId
		,a.intTicketId
		,a.intResponsibleId
		,a.intCompanyEntityId
		,a.intThirdPartyEntityId
		,a.intEntityContactId
		,a.intConcurrencyId
		,b.strResponsible COLLATE Latin1_General_CI_AS
		,strCompany = c.strName
		,strThirdParty = d.strName
		,strContactName = e.strName
	from tblHDTicketRACI a
	left join vyuHDTicketRACIResponsible b on b.intResponsibleId = a.intResponsibleId
	left join tblEMEntity c on c.intEntityId = a.intCompanyEntityId
	left join tblEMEntity d on d.intEntityId = a.intThirdPartyEntityId
	left join tblEMEntity e on e.intEntityId = a.intEntityContactId
