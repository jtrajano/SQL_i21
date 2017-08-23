﻿IF NOT EXISTS(SELECT TOP 1 1 FROM tblICMeasurement WHERE strMeasurementName = 'Pulse Reading')
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

IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblICInventoryReceiptItem') AND name = 'dblUnitRetail')
BEGIN
	EXEC ('
	UPDATE tblICInventoryReceiptItem
	SET dblUnitRetail = dblUnitCost
	WHERE ISNULL(dblUnitRetail, 0) = 0
	')
END

IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblICItem') AND name = 'strType')
BEGIN
	EXEC ('
	UPDATE tblICItem
	SET strType = ''Finished Good''
	WHERE strType = ''Manufacturing''
	')

	EXEC ('
	UPDATE tblICItem
	SET strType = ''Finished Good''
	WHERE strType = ''Finished Goods''
	')
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblICCompanyPreference)
BEGIN
	INSERT INTO tblICCompanyPreference(intInheritSetup, intSort)
	VALUES (1, 1)
END

-- Ensure the preference is filled-in. 
IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblICCompanyPreference') AND name = 'strIRUnpostMode')
BEGIN
	UPDATE	icPref 
	SET		icPref.strIRUnpostMode = 'Default'
	FROM	tblICCompanyPreference icPref 
	WHERE	strIRUnpostMode IS NULL
END

-- Ensure the preference is filled-in. 
IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblICCompanyPreference') AND name = 'strReturnPostMode')
BEGIN
	IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblSMCompanySetup'))
	BEGIN 		
		EXEC ('
			-- If it is for JDE DB, set it to "Allow Return After Qty Change".
			IF EXISTS(SELECT * FROM tblSMCompanySetup WHERE strCompanyName LIKE ''%Koninklijke Douwe Egberts B.V.%'' )
			BEGIN 
				UPDATE	icPref 
				SET		icPref.strReturnPostMode = ''Allow Return After Qty Change''
				FROM	tblICCompanyPreference icPref 
				WHERE	strReturnPostMode IS NULL		
			END 
			ELSE 
			BEGIN 
				UPDATE	icPref 
				SET		icPref.strReturnPostMode = ''Default''
				FROM	tblICCompanyPreference icPref 
				WHERE	strReturnPostMode IS NULL		
			END 
		')
	END 
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