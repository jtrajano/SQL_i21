CREATE VIEW vyuQMGetSupplier
AS
/****************************************************************
	Title: Supplier Entity
	Description: Supplier/Vendor list 
	JIRA: QC-919
	Created By: Jonathan Valenzuela
	Date: 01/05/2023
*****************************************************************/
SELECT Entity.*
	 , CompanyLocation.strLocationName 
FROM vyuCTEntity AS Entity
LEFT JOIN tblAPVendorCompanyLocation AS VendorLocation ON Entity.intEntityId = VendorLocation.intEntityVendorId
LEFT JOIN tblSMCompanyLocation AS CompanyLocation ON VendorLocation.intCompanyLocationId = CompanyLocation.intCompanyLocationId
WHERE strEntityType = 'Vendor' OR strEntityType = 'Customer';