CREATE VIEW [dbo].[vyuEMCustomerHelpDeskSearch]
	AS 
	
	
	select 
		intEntityCustomerId = cust_product.intCustomerId,
		cust_product.strCompany,
		strProductName = cust_product.strName,
		cust_product.strOperatingSystem,
		cust_product.strAcuVersion,
		cust_product.strDatabase,
		hd_product.strProduct,
		hd_module.strModule,
		hd_version.strVersionNo,
		cust_product.strServPak,
		cust_product.strApplyDt,
		cust_product.strInfoPulled,
		ent.strName,
		ent.strEntityNo

		from tblARCustomerProductVersion cust_product
			inner join tblEntity ent
				on cust_product.intCustomerId = ent.intEntityId
			left join tblHDTicketProduct hd_product
				on  cust_product.intProductId = hd_product.intTicketProductId
			left join tblHDModule hd_module
				on cust_product.intModuleId = hd_module.intModuleId
			left join tblHDVersion hd_version
				on cust_product.intVersionId = hd_version.intVersionId
