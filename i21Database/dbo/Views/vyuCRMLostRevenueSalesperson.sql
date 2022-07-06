CREATE VIEW [dbo].[vyuCRMLostRevenueSalesperson]
	AS
	select
		a.intEntityId
		,a.strContactNumber
		,a.strTitle
		,a.strMobile
		,a.strPhone
		,c.ysnActive
		,a.strName
		,e.strEmail
		,a.strEntityNo
		,imgPhoto = null
	from
		tblEMEntity a
		inner join tblEMEntityType b on b.intEntityId = a.intEntityId
		inner join tblARSalesperson c on c.intEntityId = a.intEntityId
		inner join tblEMEntityToContact d on d.intEntityId = a.intEntityId
		inner join tblEMEntity e on e.intEntityId = d.intEntityContactId
	where
		b.strType = 'Salesperson'
		and c.ysnActive = convert(bit, 1)
