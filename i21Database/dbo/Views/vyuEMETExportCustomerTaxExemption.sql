CREATE VIEW [dbo].[vyuEMETExportCustomerTaxExemption]
	AS 


	select 
		CustomerNumber = bb.strEntityNo,
		ItemNumber = d.strItemNo,
		state = a.strState,
		Authority1 = '',
		Authority2 = '',
		FETCharge = CASE WHEN e.strTaxCodeReference = 'FET' THEN 'Y' ELSE 'N' END,
		SETCharge = CASE WHEN e.strTaxCodeReference = 'SET' THEN 'Y' ELSE 'N' END,
		SSTCharge = CASE WHEN e.strTaxCodeReference = 'SST' THEN 'Y' ELSE 'N' END,
		Locale1Charge = CASE WHEN e.strTaxCodeReference = 'LC1' THEN 'Y' ELSE 'N' END,
		Locale2Charge = CASE WHEN e.strTaxCodeReference = 'LC2' THEN 'Y' ELSE 'N' END ,
		Locale3Charge = CASE WHEN e.strTaxCodeReference = 'LC3' THEN 'Y' ELSE 'N' END,
		Locale4Charge = CASE WHEN e.strTaxCodeReference = 'LC4' THEN 'Y' ELSE 'N' END,
		Locale5Charge = CASE WHEN e.strTaxCodeReference = 'LC5' THEN 'Y' ELSE 'N' END,
		Locale6Charge = CASE WHEN e.strTaxCodeReference = 'LC6' THEN 'Y' ELSE 'N' END
		 
from tblARCustomerTaxingTaxException a
	join tblARCustomer b
		on a.intEntityCustomerId = b.intEntityCustomerId
	join tblEMEntity bb
		on b.intEntityCustomerId = bb.intEntityId
	join vyuEMEntityType c
		on c.intEntityId = b.intEntityCustomerId and Customer = 1
	left join tblICItem d
		on a.intItemId = d.intItemId
	left join tblETExportTaxCodeMapping e
		on a.intTaxCodeId = e.intTaxCodeId