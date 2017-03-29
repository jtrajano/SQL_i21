CREATE VIEW [dbo].[vyuCRMCustomerProspectType]
	AS
	select
		distinct
		intId = ROW_NUMBER() over (order by tblARCustomer.[intEntityId])
		,tblARCustomer.[intEntityId]
		,tblARCustomer.strCustomerNumber
		,strEntityName = tblEMEntity.strName
		,tblEMEntityType.strType
		,contact.strEmail
	from tblARCustomer
		left outer join tblEMEntity on tblEMEntity.intEntityId = tblARCustomer.[intEntityId]
		left outer join tblEMEntityType on tblEMEntityType.intEntityId = tblARCustomer.[intEntityId] and tblEMEntityType.strType in ('Customer','Prospect')
		left outer join tblEMEntityToContact on tblEMEntityToContact.intEntityId = tblARCustomer.[intEntityId] and tblEMEntityToContact.ysnDefaultContact = 1
		left outer join tblEMEntity contact on contact.intEntityId = tblEMEntityToContact.intEntityContactId
