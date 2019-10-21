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
from tblHDTimeEntryResources a, tblEMEntity b, tblEMEntityToContact c, tblEMEntity d
where b.intEntityId = a.intResourcesEntityId and c.intEntityId = a.intResourcesEntityId and c.ysnDefaultContact = convert(bit,1) and d.intEntityId = c.intEntityContactId

