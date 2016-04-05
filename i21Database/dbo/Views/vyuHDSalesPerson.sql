CREATE VIEW [dbo].[vyuHDSalesPerson]
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
	from tblARSalesperson, tblEMEntity
	where
		tblEMEntity.intEntityId = tblARSalesperson.intEntitySalespersonId
