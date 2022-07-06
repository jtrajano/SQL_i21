CREATE VIEW [dbo].[vyuHDTicketRACIContact]
	AS
	select distinct 
		intThirdPartyEntityId = b.intEntityId
		, intEntityContactId = c.intEntityId
		, strContactName = c.strName 
	from 
		tblEMEntityType a
		inner join tblEMEntityToContact b on b.intEntityId = a.intEntityId 
		inner join tblEMEntity c on c.intEntityId = b.intEntityContactId
	
