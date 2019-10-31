

PRINT N'INSERT DEFAULT - TRANSPORT CROSS REFERENCE'
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM tblTRCrossReference WHERE strName = 'TPVision')
BEGIN
		SET IDENTITY_INSERT tblTRCrossReference ON

		INSERT INTO tblTRCrossReference (intCrossReferenceId,strName, dtmDateCreated) VALUES(1,'TPVision', GETDATE())
		
		SET IDENTITY_INSERT tblTRCrossReference OFF
END
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM tblTRCrossReference WHERE strName = 'DTN Cross Reference')
BEGIN
		SET IDENTITY_INSERT tblTRCrossReference ON

		INSERT INTO tblTRCrossReference (intCrossReferenceId,strName, dtmDateCreated) VALUES(2,'DTN Cross Reference', GETDATE())
		
		SET IDENTITY_INSERT tblTRCrossReference OFF
END
GO