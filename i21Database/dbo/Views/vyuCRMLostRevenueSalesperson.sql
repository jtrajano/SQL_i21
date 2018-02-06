CREATE VIEW [dbo].[vyuCRMLostRevenueSalesperson]
	AS
	select
		a.intEntityId
		,a.strContactNumber
		,a.strTitle
		,a.strMobile
		,a.strPhone
		,a.ysnActive
		,a.strName
		,a.strEmail
		,a.strEntityNo
		,imgPhoto = null
	from
		tblEMEntity a
		,tblEMEntityType b
	where
		a.ysnActive = convert(bit, 1)
		and b.intEntityId = a.intEntityId
		and b.strType = 'Salesperson'
