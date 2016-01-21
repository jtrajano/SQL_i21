CREATE VIEW [dbo].[vyuHDSalesPerson]
	AS
	select
			tblEntity.intEntityId
			,tblEntity.strName
			,tblARSalesperson.strSalespersonId
			,tblARSalesperson.strTitle
			,tblARSalesperson.strType
			,tblEntity.strEmail
			,tblEntity.strPhone
			,ysnActiveEntity = tblEntity.ysnActive
			,ysnActiveSalesPerson = tblARSalesperson.ysnActive
	from tblARSalesperson, tblEntity
	where
		tblEntity.intEntityId = tblARSalesperson.intEntitySalespersonId
