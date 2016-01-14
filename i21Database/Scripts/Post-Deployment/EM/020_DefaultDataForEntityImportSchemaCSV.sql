DELETE FROM tblEntityImportSchemaCSV

SET IDENTITY_INSERT tblEntityImportSchemaCSV ON

INSERT INTO tblEntityImportSchemaCSV(intEntityImportSchemaCSV,strObject, strProperty, strCSVProp)

SELECT 1001, 'tblEntity', 'strName', 'name'
UNION
SELECT 1002, 'tblEntity', 'strEmail', 'email'
UNION
SELECT 1003, 'tblEntity', 'strMobile', 'mobile'

UNION
SELECT 1101, 'tblEntity.tblEntityToContact.tblEntity', 'strName', 'con_name'
UNION
SELECT 1102, 'tblEntity.tblEntityToContact.tblEntity', 'strName', 'con_email'
UNION
SELECT 1103, 'tblEntity.tblEntityToContact.tblEntity', 'strName', 'con_mobile'

UNION
SELECT 1201, 'tblEntity.tblEntityLocations', 'strLocationName', 'loc_name'
UNION
SELECT 1202, 'tblEntity.tblEntityLocations', 'strAddress', 'loc_address'

SET IDENTITY_INSERT tblEntityImportSchemaCSV OFF