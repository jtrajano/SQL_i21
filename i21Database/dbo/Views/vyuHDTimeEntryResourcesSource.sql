CREATE VIEW [dbo].[vyuHDTimeEntryResourcesSource]
	AS
	select b.intEntityId, b.ysnActive, b.strName, d.strEmail
	from 
		tblEMEntityType a
		inner join tblEMEntity b on b.intEntityId = a.intEntityId
		inner join tblEMEntityToContact c on c.intEntityId = b.intEntityId
		inner join tblEMEntity d on d.intEntityId = c.intEntityContactId
	where a.strType = 'User'
