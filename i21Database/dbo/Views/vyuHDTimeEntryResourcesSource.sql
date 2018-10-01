CREATE VIEW [dbo].[vyuHDTimeEntryResourcesSource]
	AS
	select b.intEntityId, b.ysnActive, b.strName, d.strEmail
	from tblEMEntityType a, tblEMEntity b, tblEMEntityToContact c, tblEMEntity d
	where a.strType = 'User'
	and b.intEntityId = a.intEntityId
	and c.intEntityId = b.intEntityId
	and d.intEntityId = c.intEntityContactId
