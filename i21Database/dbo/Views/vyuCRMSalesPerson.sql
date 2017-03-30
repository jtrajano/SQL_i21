CREATE VIEW [dbo].[vyuCRMSalesPerson]
	AS
	select
			tblEMEntity.intEntityId
			,tblEMEntity.strName
			,strSalespersonId = (case when tblEMEntity.strEntityNo is null then tblARSalesperson.strSalespersonId else tblEMEntity.strEntityNo end)
			,tblARSalesperson.strTitle
			,tblARSalesperson.strType
			,tblEMEntity.strEmail
			,tblEMEntity.strPhone
			,ysnActiveEntity = tblEMEntity.ysnActive
			,ysnActiveSalesPerson = tblARSalesperson.ysnActive
			,strSalesPersonType = 'Sales Rep Entity'
	from tblARSalesperson, tblEMEntity
	where
		tblEMEntity.intEntityId = tblARSalesperson.[intEntityId]

	/*
	union all

		select
			intEntityId = tblEMEntityToContact.intEntityContactId
			,e.strName
			,strSalespersonId = (case when e.strEntityNo is null then tblARSalesperson.strSalespersonId else e.strEntityNo end)
			,tblARSalesperson.strTitle
			,tblARSalesperson.strType
			,e.strEmail
			,e.strPhone
			,ysnActiveEntity = e.ysnActive
			,ysnActiveSalesPerson = tblARSalesperson.ysnActive
			,strSalesPersonType = 'Sales Rep Contact'
	from tblARSalesperson, tblEMEntity e, tblEMEntityToContact
	where
		tblEMEntityToContact.intEntityId = tblARSalesperson.intEntitySalespersonId
		and e.intEntityId = tblEMEntityToContact.intEntityContactId
	*/
