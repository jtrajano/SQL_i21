﻿CREATE VIEW [dbo].[vyuHDCustomerProspectType]
	AS
	select
		distinct
		tblARCustomer.intEntityCustomerId
		,tblARCustomer.strCustomerNumber
		,strEntityName = tblEMEntity.strName
		,tblEMEntityType.strType
		,contact.strEmail
	from tblARCustomer
		left outer join tblEMEntity on tblEMEntity.intEntityId = tblARCustomer.intEntityCustomerId
		left outer join tblEMEntityType on tblEMEntityType.intEntityId = tblARCustomer.intEntityCustomerId and tblEMEntityType.strType in ('Customer','Prospect')
		left outer join tblEMEntityToContact on tblEMEntityToContact.intEntityId = tblARCustomer.intEntityCustomerId and tblEMEntityToContact.ysnDefaultContact = 1
		left outer join tblEMEntity contact on contact.intEntityId = tblEMEntityToContact.intEntityContactId
