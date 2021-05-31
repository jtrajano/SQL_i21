CREATE VIEW [dbo].[vyuHDTimeEntryResources]
	AS
	select
	a.intTimeEntryResourcesId
	,a.intTimeEntryId
	,a.intEntityId
	,a.intResourcesEntityId
	,a.intConcurrencyId
	,strResourcesEntityName = b.strName
	,strResourcesEntityEmail = d.strEmail
from 
	tblHDTimeEntryResources a
	inner join tblEMEntity b on b.intEntityId = a.intResourcesEntityId 
	inner join tblEMEntityToContact c on c.intEntityId = a.intResourcesEntityId 
	inner join tblEMEntity d on d.intEntityId = c.intEntityContactId
where 
	c.ysnDefaultContact = convert(bit,1) 

