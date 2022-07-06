CREATE VIEW [dbo].[vyuHDCustomerLineOfBusiness]
	AS
		select distinct
			tblARCustomerLineOfBusiness.intCustomerLineOfBusinessId
			,tblARCustomerLineOfBusiness.intEntityCustomerId
			,[tblSMLineOfBusiness].*
			,strSalesPerson = tblEMEntity.strName
		from
			tblARCustomerLineOfBusiness
			inner join tblSMLineOfBusiness on tblSMLineOfBusiness.intLineOfBusinessId = tblARCustomerLineOfBusiness.intLineOfBusinessId
			inner join tblEMEntity on tblEMEntity.intEntityId = tblSMLineOfBusiness.intEntityId