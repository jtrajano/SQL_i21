PRINT N'DEALER CREDIT CARD - DEFAULT CROSS REFERENCE'
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM tblCCCrossReference WHERE strName = 'IrelyEnterprise-Vendor')
BEGIN
		SET IDENTITY_INSERT tblCCCrossReference ON

		INSERT INTO tblCCCrossReference (intCrossReferenceId,strName, dtmDateCreated) VALUES(1,'IrelyEnterprise-Vendor', GETDATE())
		
		SET IDENTITY_INSERT tblCCCrossReference OFF
END
GO