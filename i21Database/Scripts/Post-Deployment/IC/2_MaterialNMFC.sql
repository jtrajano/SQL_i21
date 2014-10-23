
IF NOT EXISTS (SELECT * FROM tblICMaterialNMFC WHERE ISNULL(intExternalSystemId, '') = '' AND strInternalCode = 'UNKNOWN' AND strDisplayMember = 'Unknown')
INSERT INTO tblICMaterialNMFC(intExternalSystemId, strInternalCode, strDisplayMember, ysnDefault, ysnLocked, strLastUpdateBy, dtmLastUpdateOn, intSort)
VALUES (NULL, 'UNKNOWN', 'Unknown', 0, 1, 'dbo', GETDATE(), 1)

IF NOT EXISTS (SELECT * FROM tblICMaterialNMFC WHERE ISNULL(intExternalSystemId, '') = '10001' AND strInternalCode = '100' AND strDisplayMember = 'MISC SUPPLIES')
INSERT INTO tblICMaterialNMFC(intExternalSystemId, strInternalCode, strDisplayMember, ysnDefault, ysnLocked, strLastUpdateBy, dtmLastUpdateOn, intSort)
VALUES (10001, '100', 'MISC SUPPLIES', 0, 0, 'dbo', GETDATE(), 1)

IF NOT EXISTS (SELECT * FROM tblICMaterialNMFC WHERE ISNULL(intExternalSystemId, '') = '10002' AND strInternalCode = '60' AND strDisplayMember = 'TEA MIX OR LIQUID CONCENTRATE/PREPARATIONS UNSWEETENED OR SWEETENED WITH SUGAR')
INSERT INTO tblICMaterialNMFC(intExternalSystemId, strInternalCode, strDisplayMember, ysnDefault, ysnLocked, strLastUpdateBy, dtmLastUpdateOn, intSort)
VALUES (10002, '60', 'TEA MIX OR LIQUID CONCENTRATE/PREPARATIONS UNSWEETENED OR SWEETENED WITH SUGAR', 0, 0, 'dbo', GETDATE(), 1)

IF NOT EXISTS (SELECT * FROM tblICMaterialNMFC WHERE ISNULL(intExternalSystemId, '') = '10003' AND strInternalCode = '65' AND strDisplayMember = 'COFFEE OR TEA EXTRACT')
INSERT INTO tblICMaterialNMFC(intExternalSystemId, strInternalCode, strDisplayMember, ysnDefault, ysnLocked, strLastUpdateBy, dtmLastUpdateOn, intSort)
VALUES (10003, '65', 'COFFEE OR TEA EXTRACT', 0, 0, 'dbo', GETDATE(), 1)

IF NOT EXISTS (SELECT * FROM tblICMaterialNMFC WHERE ISNULL(intExternalSystemId, '') = '10005' AND strInternalCode = '55' AND strDisplayMember = 'PACKAGING MATL')
INSERT INTO tblICMaterialNMFC(intExternalSystemId, strInternalCode, strDisplayMember, ysnDefault, ysnLocked, strLastUpdateBy, dtmLastUpdateOn, intSort)
VALUES (10005, '55', 'PACKAGING MATL', 0, 0, 'dbo', GETDATE(), 1)

IF NOT EXISTS (SELECT * FROM tblICMaterialNMFC WHERE ISNULL(intExternalSystemId, '') = '10007' AND strInternalCode = '85' AND strDisplayMember = 'TEA IN TEA BAGS')
INSERT INTO tblICMaterialNMFC(intExternalSystemId, strInternalCode, strDisplayMember, ysnDefault, ysnLocked, strLastUpdateBy, dtmLastUpdateOn, intSort)
VALUES (10007, '85', 'TEA IN TEA BAGS', 0, 0, 'dbo', GETDATE(), 1)

IF NOT EXISTS (SELECT * FROM tblICMaterialNMFC WHERE ISNULL(intExternalSystemId, '') = '10008' AND strInternalCode = '77.5' AND strDisplayMember = 'TEA OTHER THAN IN TEA BAGS')
INSERT INTO tblICMaterialNMFC(intExternalSystemId, strInternalCode, strDisplayMember, ysnDefault, ysnLocked, strLastUpdateBy, dtmLastUpdateOn, intSort)
VALUES (10008, '77.5', 'TEA OTHER THAN IN TEA BAGS', 0, 0, 'dbo', GETDATE(), 1)

IF NOT EXISTS (SELECT * FROM tblICMaterialNMFC WHERE ISNULL(intExternalSystemId, '') = '10009' AND strInternalCode = '70' AND strDisplayMember = 'PREPARATIONS SWEETENED OTHER THAN WITH SUGAR')
INSERT INTO tblICMaterialNMFC(intExternalSystemId, strInternalCode, strDisplayMember, ysnDefault, ysnLocked, strLastUpdateBy, dtmLastUpdateOn, intSort)
VALUES (10009, '70', 'PREPARATIONS SWEETENED OTHER THAN WITH SUGAR', 0, 0, 'dbo', GETDATE(), 1)

