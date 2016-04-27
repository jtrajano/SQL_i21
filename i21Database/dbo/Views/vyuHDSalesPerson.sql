CREATE VIEW [dbo].[vyuHDSalesPerson]
	AS
	select
			tblEntity.intEntityId
			,tblEntity.strName
			,strSalespersonId = (case when tblEntity.strEntityNo is null then tblARSalesperson.strSalespersonId else tblEntity.strEntityNo end)
			,tblARSalesperson.strTitle
			,tblARSalesperson.strType
			,tblEntity.strEmail
			,tblEntity.strPhone
			,ysnActiveEntity = tblEntity.ysnActive
			,ysnActiveSalesPerson = tblARSalesperson.ysnActive
	from tblARSalesperson, tblEntity
	where
		tblEntity.intEntityId = tblARSalesperson.intEntitySalespersonId
