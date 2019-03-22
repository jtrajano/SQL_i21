CREATE VIEW [dbo].[vyuHDCustomerLineOfBusiness]
	AS
		select distinct
			tblARCustomerLineOfBusiness.intCustomerLineOfBusinessId
			,tblARCustomerLineOfBusiness.intEntityCustomerId
			,[tblSMLineOfBusiness].*
			,strSalesPerson = tblEMEntity.strName
		from
			tblARCustomerLineOfBusiness
			,[tblSMLineOfBusiness]
			,tblEMEntity
		where
			[tblSMLineOfBusiness].intLineOfBusinessId = tblARCustomerLineOfBusiness.intLineOfBusinessId
			and tblEMEntity.intEntityId = [tblSMLineOfBusiness].intEntityId
