CREATE VIEW [dbo].[vyuHDCustomerLineOfBusiness]
	AS
		select distinct
			tblARCustomerLineOfBusiness.intCustomerLineOfBusinessId
			,tblARCustomerLineOfBusiness.intEntityCustomerId
			,tblHDLineOfBusiness.*
			,strSalesPerson = tblEMEntity.strName
		from
			tblARCustomerLineOfBusiness
			,tblHDLineOfBusiness
			,tblEMEntity
		where
			tblHDLineOfBusiness.intLineOfBusinessId = tblARCustomerLineOfBusiness.intLineOfBusinessId
			and tblEMEntity.intEntityId = tblHDLineOfBusiness.intEntityId
