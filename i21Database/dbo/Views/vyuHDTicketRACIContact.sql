CREATE VIEW [dbo].[vyuHDTicketRACIContact]
	AS
	select distinct intThirdPartyEntityId = b.intEntityId, intEntityContactId = c.intEntityId, strContactName = c.strName from tblEMEntityType a, tblEMEntityToContact b, tblEMEntity c
	where b.intEntityId = a.intEntityId and c.intEntityId = b.intEntityContactId
