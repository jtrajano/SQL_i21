﻿CREATE VIEW [dbo].[vyuEMExportInformation]
	AS 

	select 
--Entity
	id				= a.intEntityId
	,name			= a.strName
	,website		= a.strWebsite
	,type			= case when e.intEntityVendorId is not null then 'vendor,' else '' end + 
						case when f.intEntityCustomerId is not null then 'customer,' else '' end + 
						case when g.intEntitySalespersonId is not null then 'salesperson,' else '' end
	--Contact
	,con_name		= c.strName
	,con_phone		= c.strPhone
	--,con_extension	= ''
	,con_fax		= c.strFax
	,con_email		= c.strEmail
	
	--Location
	,loc_name			= d.strLocationName
	,loc_addressline1	= REPLACE(REPLACE(d.strAddress, CHAR(13), ' '), CHAR(10), ' ')
	--,loc_addressline2	
	--,loc_addressline3	
	,loc_city			= d.strCity
	,loc_state			= d.strState
	,loc_zipcode		= d.strZipCode
	,loc_country		= d.strCountry
	,loc_termsId		= d.intTermsId
	,loc_pricelevel		= d.strPricingLevel
	
	--Customer
	,cus_number			= f.strCustomerNumber
	,cus_type			= f.strType
	,cus_salesperson	= i.strSalespersonId
	--,cus_servicecharge	= f.
	,cus_creditlimit	= f.dblCreditLimit
	--,cus_defaultwarehouse = f.ware	
	,cus_porequired		= f.ysnPORequired
	,cus_revenue		= f.dblRevenue
	,cus_employee_count	= f.intEmployeeCount
	--Salesperson
	,sal_salespersonid	= g.strSalespersonId
	
	--Vendor
	,ven_vendorId		= e.strVendorId
	,ven_expenseId		= j.strAccountId


	from tblEntity a
	join tblEntityToContact b
		on a.intEntityId = b.intEntityId and ysnDefaultContact = 1
	join tblEntity c
		on b.intEntityContactId = c.intEntityId
	join tblEntityLocation d
		on d.intEntityId = a.intEntityId and ysnDefaultLocation = 1
	left join tblAPVendor e
		on e.intEntityVendorId = a.intEntityId
	left join tblARCustomer f
		on f.intEntityCustomerId = a.intEntityId
	left join tblARSalesperson g
		on g.intEntitySalespersonId = a.intEntityId
	left join tblSMTerm h
		on d.intTermsId = h.intTermID
	left join tblARSalesperson i
		on f.intSalespersonId = i.intEntitySalespersonId
	left join tblGLAccount j
		on e.intGLAccountExpenseId = j.intAccountId
