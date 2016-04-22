CREATE VIEW [dbo].[vyuHDCustomerLineOfBusiness]
	AS
		select
			tblARCustomerLineOfBusiness.intCustomerLineOfBusinessId
			,tblARCustomerLineOfBusiness.intEntityCustomerId
			,tblHDLineOfBusiness.*
		from
			tblARCustomerLineOfBusiness
			,tblHDLineOfBusiness
		where
			tblHDLineOfBusiness.intLineOfBusinessId = tblARCustomerLineOfBusiness.intLineOfBusinessId
