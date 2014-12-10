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