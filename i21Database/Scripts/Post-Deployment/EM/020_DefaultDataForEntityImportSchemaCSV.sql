DELETE FROM [tblEMEntityImportSchemaCSV]

SET IDENTITY_INSERT [tblEMEntityImportSchemaCSV] ON

INSERT INTO [tblEMEntityImportSchemaCSV](intEntityImportSchemaCSV,strObject, strProperty, strCSVProp)

SELECT 1001, 'tblEMEntity', 'strName', 'name'
UNION
SELECT 1002, 'tblEMEntity', 'strEmail', 'email'
UNION
SELECT 1003, 'tblEMEntity', 'strMobile', 'mobile'

UNION
SELECT 1101, 'tblEMEntity.tblEMEntityToContact.tblEMEntityContact', 'strName', 'con_name'
UNION
SELECT 1102, 'tblEMEntity.tblEMEntityToContact.tblEMEntityContact', 'strEmail', 'con_email'
UNION
SELECT 1103, 'tblEMEntity.tblEMEntityToContact.tblEMEntityContact', 'strMobile', 'con_mobile'
UNION
SELECT 1104, 'tblEMEntity.tblEMEntityToContact.tblEMEntityContact', 'strPhone', 'con_phone'
UNION
SELECT 1105, 'tblEMEntity.tblEMEntityToContact.tblEMEntityContact', 'strFax', 'con_fax'

UNION
SELECT 1201, 'tblEMEntity.tblEMEntityLocations', 'strLocationName', 'loc_name'
UNION
SELECT 1202, 'tblEMEntity.tblEMEntityLocations', 'strAddress', 'loc_address'
UNION
SELECT 1203, 'tblEMEntity.tblEMEntityLocations', 'strTermCodeId', 'loc_termsId'
UNION
SELECT 1204, 'tblEMEntity.tblEMEntityLocations', 'strCity', 'loc_city'
UNION
SELECT 1205, 'tblEMEntity.tblEMEntityLocations', 'strState', 'loc_state'
UNION
SELECT 1206, 'tblEMEntity.tblEMEntityLocations', 'strZipCode', 'loc_zipcode'
UNION
SELECT 1207, 'tblEMEntity.tblEMEntityLocations', 'strCountry', 'loc_country'
UNION
SELECT 1208, 'tblEMEntity.tblEMEntityLocations', 'strPricingLevel', 'loc_pricelevel'


UNION	
SELECT 1301, 'tblEMEntity.tblVendor', 'strGLAccountExpenseId', 'ven_expenseId'
UNION	
SELECT 1302, 'tblEMEntity.tblVendor', 'strVendorId', 'ven_vendorId'

UNION	
SELECT 1401, 'tblEMEntity.tblCustomer', 'strCustomerNumber', 'cus_number'
UNION	
SELECT 1402, 'tblEMEntity.tblCustomer', 'strType', 'cus_type'
UNION	
SELECT 1403, 'tblEMEntity.tblCustomer', 'dblCreditLimit', 'cus_creditlimit'
UNION	
SELECT 1405, 'tblEMEntity.tblCustomer', 'ysnPORequired', 'cus_porequired'

SET IDENTITY_INSERT [tblEMEntityImportSchemaCSV] OFF