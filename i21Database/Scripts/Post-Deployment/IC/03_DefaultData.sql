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

IF NOT EXISTS(SELECT TOP 1 1 FROM tblICMeasurement WHERE strMeasurementName = 'Pulse Reading')
BEGIN
	INSERT INTO tblICMeasurement (strMeasurementName, strDescription, strMeasurementType) VALUES ('Pulse Reading','Pulse Reading','F')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblICMeasurement WHERE strMeasurementName = 'Tape Reading')
BEGIN
	INSERT INTO tblICMeasurement (strMeasurementName, strDescription, strMeasurementType) VALUES ('Tape Reading','Tape Reading','T')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblICMeasurement WHERE strMeasurementName = 'Totalizer Reading')
BEGIN
	INSERT INTO tblICMeasurement (strMeasurementName, strDescription, strMeasurementType) VALUES ('Totalizer Reading','Totalizer Reading','F')
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblICReadingPoint WHERE strReadingPoint = 'Both')
BEGIN
	INSERT INTO tblICReadingPoint (strReadingPoint) VALUES ('Both')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblICReadingPoint WHERE strReadingPoint = 'Consume')
BEGIN
	INSERT INTO tblICReadingPoint (strReadingPoint) VALUES ('Consume')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblICReadingPoint WHERE strReadingPoint = 'Produce')
BEGIN
	INSERT INTO tblICReadingPoint (strReadingPoint) VALUES ('Produce')
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblICEquipmentLength WHERE strEquipmentLength = '02000')
BEGIN
	INSERT INTO tblICEquipmentLength (strEquipmentLength, strDescription, intSort) VALUES ('02000', '20 ft container', 1)
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblICEquipmentLength WHERE strEquipmentLength = '02400')
BEGIN
	INSERT INTO tblICEquipmentLength (strEquipmentLength, strDescription, intSort) VALUES ('02400', '24 ft container', 2)
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblICEquipmentLength WHERE strEquipmentLength = '04500')
BEGIN
	INSERT INTO tblICEquipmentLength (strEquipmentLength, strDescription, intSort) VALUES ('04500', '45 ft trailer/container', 3)
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblICEquipmentLength WHERE strEquipmentLength = '04800')
BEGIN
	INSERT INTO tblICEquipmentLength (strEquipmentLength, strDescription, intSort) VALUES ('04800', '48 ft trailer', 4)
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblICEquipmentLength WHERE strEquipmentLength = '05300')
BEGIN
	INSERT INTO tblICEquipmentLength (strEquipmentLength, strDescription, intSort) VALUES ('05300', '53 ft trailer', 5)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblICCompanyPreference)
BEGIN
	INSERT INTO tblICCompanyPreference(intInheritSetup, intSort)
	VALUES (1, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblICRestriction WHERE strInternalCode = 'STOCK' AND strDisplayMember = 'STOCK')
BEGIN
	INSERT INTO tblICRestriction(strInternalCode, strDisplayMember, ysnDefault, ysnLocked, strLastUpdateBy, dtmLastUpdateOn) VALUES ('STOCK','STOCK',1,1,'dbo',GETDATE())
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblICRestriction WHERE strInternalCode = 'RESTRICTED' AND strDisplayMember = 'RESTRICTED')
BEGIN
	INSERT INTO tblICRestriction(strInternalCode, strDisplayMember, ysnDefault, ysnLocked, strLastUpdateBy, dtmLastUpdateOn) VALUES ('RESTRICTED','RESTRICTED',0,1,'dbo',GETDATE())
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblICRestriction WHERE strInternalCode = 'RESTRICTED' AND strDisplayMember = 'HOLD')
BEGIN
	INSERT INTO tblICRestriction(strInternalCode, strDisplayMember, ysnDefault, ysnLocked, strLastUpdateBy, dtmLastUpdateOn) VALUES ('RESTRICTED','HOLD',0,1,'dbo',GETDATE())
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblICRestriction WHERE strInternalCode = 'RESTRICTED' AND strDisplayMember = 'DAMAGED')
BEGIN
	INSERT INTO tblICRestriction(strInternalCode, strDisplayMember, ysnDefault, ysnLocked, strLastUpdateBy, dtmLastUpdateOn) VALUES ('RESTRICTED','DAMAGED',0,1,'dbo',GETDATE())
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblICRestriction WHERE strInternalCode = 'RESTRICTED' AND strDisplayMember = 'QUARANTINED')
BEGIN
	INSERT INTO tblICRestriction(strInternalCode, strDisplayMember, ysnDefault, ysnLocked, strLastUpdateBy, dtmLastUpdateOn) VALUES ('RESTRICTED','QUARANTINED',0,1,'dbo',GETDATE())
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblICRestriction WHERE strInternalCode = 'RESTRICTED' AND strDisplayMember = 'QA-HOLD')
BEGIN
	INSERT INTO tblICRestriction(strInternalCode, strDisplayMember, ysnDefault, ysnLocked, strLastUpdateBy, dtmLastUpdateOn) VALUES ('RESTRICTED','QA-HOLD',0,1,'dbo',GETDATE())
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblICRestriction WHERE strInternalCode = 'RESTRICTED' AND strDisplayMember = 'REPACK')
BEGIN
	INSERT INTO tblICRestriction(strInternalCode, strDisplayMember, ysnDefault, ysnLocked, strLastUpdateBy, dtmLastUpdateOn) VALUES ('RESTRICTED','REPACK',0,1,'dbo',GETDATE())
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblICRestriction WHERE strInternalCode = 'BONDED' AND strDisplayMember = 'BONDED')
BEGIN
	INSERT INTO tblICRestriction(strInternalCode, strDisplayMember, ysnDefault, ysnLocked, strLastUpdateBy, dtmLastUpdateOn) VALUES ('BONDED','BONDED',0,1,'dbo',GETDATE())
END


