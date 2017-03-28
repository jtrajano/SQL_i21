CREATE VIEW [dbo].[vyuEMEntityCusVenCurrency]
	AS 

	select 
	intEntityId = a.intEntityId,
	strName = a.strName,
	strEntityNo = a.strEntityNo,
	strEntityType = case when b.Vendor = 1 then 'Vendor,' else '' end + case when b.Customer = 1 then 'Customer,'  else '' end,
	
	intVendorCurrencyId = c.intCurrencyId,
	strVendorCurrency = e.strCurrency,
	ysnVendor = b.Vendor,

	intCustomerCurrencyId = d.intCurrencyId,
	strCustomerCurrency = f.strCurrency,
	ysnCustomer = b.Customer


	from tblEMEntity a
		join vyuEMEntityType b
			on a.intEntityId = b.intEntityId
				and (b.Vendor = 1 or b.Customer = 1)

		left join tblAPVendor c
			on a.intEntityId = c.intEntityVendorId
		left join tblARCustomer d
			on a.intEntityId = d.intEntityCustomerId
		left join tblSMCurrency e
			on c.intCurrencyId = e.intCurrencyID
		left join tblSMCurrency f
			on d.intCurrencyId = f.intCurrencyID


