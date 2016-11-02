GO
PRINT 'START TF tblTFIntegrationSystem'
GO

DECLARE @IntegrationSystemId INT

SELECT TOP 1 @IntegrationSystemId = intIntegrationSystemId FROM tblTFIntegrationSystem
IF (@IntegrationSystemId IS NULL)
	BEGIN
		INSERT [tblTFIntegrationSystem] ([str3rdPartyCompany], [strSystem]) VALUES (N'iRely', 'Origin pxrptmst')
	END
GO
	PRINT 'END TF tblTFIntegrationSystem'
GO




