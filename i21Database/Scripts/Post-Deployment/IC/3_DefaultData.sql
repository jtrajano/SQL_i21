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