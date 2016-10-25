GO
PRINT 'START TF tblTFIntegrationSystem'
GO

DECLARE @IntegrationSystemId INT

SELECT TOP 1 @OriginDestinationStateId = intIntegrationSystemId FROM tblTFIntegrationSystem
IF (@OriginDestinationStateId IS NULL)
	BEGIN
		INSERT [tblTFIntegrationSystem] ([str3rdPartyCompany], [strSystem]) VALUES (N'iRely', 'Origin pxrptmst')
	END

GO
	PRINT 'END TF tblTFIntegrationSystem'
GO




