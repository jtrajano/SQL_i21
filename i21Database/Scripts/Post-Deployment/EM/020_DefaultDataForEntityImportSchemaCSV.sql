DELETE FROM tblEntityImportSchemaCSV

SET IDENTITY_INSERT tblEntityImportSchemaCSV ON

INSERT INTO tblEntityImportSchemaCSV(intEntityImportSchemaCSV,strObject, strProperty, strCSVProp)

SELECT 1001, 'tblEntity', 'strName', 'name'
UNION
SELECT 1002, 'tblEntity', 'strEmail', 'email'
UNION
SELECT 1003, 'tblEntity', 'strMobile', 'mobile'

UNION
SELECT 1101, 'tblEntity.tblEntityToContact.tblEntityContact', 'strName', 'con_name'
UNION
SELECT 1102, 'tblEntity.tblEntityToContact.tblEntityContact', 'strEmail', 'con_email'
UNION
SELECT 1103, 'tblEntity.tblEntityToContact.tblEntityContact', 'strMobile', 'con_mobile'
UNION
SELECT 1104, 'tblEntity.tblEntityToContact.tblEntityContact', 'strPhone', 'con_phone'
UNION
SELECT 1105, 'tblEntity.tblEntityToContact.tblEntityContact', 'strFax', 'con_fax'

UNION
SELECT 1201, 'tblEntity.tblEntityLocations', 'strLocationName', 'loc_name'
UNION
SELECT 1202, 'tblEntity.tblEntityLocations', 'strAddress', 'loc_address'
UNION
SELECT 1203, 'tblEntity.tblEntityLocations', 'strTermCodeId', 'loc_termsId'
UNION
SELECT 1204, 'tblEntity.tblEntityLocations', 'strCity', 'loc_city'
UNION
SELECT 1205, 'tblEntity.tblEntityLocations', 'strState', 'loc_state'
UNION
SELECT 1206, 'tblEntity.tblEntityLocations', 'strZipCode', 'loc_zipcode'
UNION
SELECT 1207, 'tblEntity.tblEntityLocations', 'strCountry', 'loc_country'
UNION
SELECT 1208, 'tblEntity.tblEntityLocations', 'strPricingLevel', 'loc_pricelevel'


UNION	
SELECT 1301, 'tblEntity.tblVendor', 'strGLAccountExpenseId', 'ven_expenseId'
UNION	
SELECT 1302, 'tblEntity.tblVendor', 'strVendorId', 'ven_vendorId'

UNION	
SELECT 1401, 'tblEntity.tblCustomer', 'strCustomerNumber', 'cus_number'
UNION	
SELECT 1402, 'tblEntity.tblCustomer', 'strType', 'cus_type'
UNION	
SELECT 1403, 'tblEntity.tblCustomer', 'dblCreditLimit', 'cus_creditlimit'
UNION	
SELECT 1405, 'tblEntity.tblCustomer', 'ysnPORequired', 'cus_porequired'

SET IDENTITY_INSERT tblEntityImportSchemaCSV OFF