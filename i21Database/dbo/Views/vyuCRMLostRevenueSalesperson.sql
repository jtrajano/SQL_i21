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
		,a.strEmail
		,a.strEntityNo
		,imgPhoto = null
	from
		tblEMEntity a
		,tblEMEntityType b
		,tblARSalesperson c
	where
		b.intEntityId = a.intEntityId
		and b.strType = 'Salesperson'
		and c.intEntityId = a.intEntityId
		and c.ysnActive = convert(bit, 1)
		and a.ysnActive = convert(bit, 1)
