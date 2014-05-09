GO
	PRINT N'BEGIN INSERT DEFAULT TM PREFERENCE COMPANY'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMPreferenceCompany]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[tblTMPreferenceCompany])
	BEGIN
		IF((SELECT TOP 1 coctl_pt FROM coctlmst) = 'Y')
		BEGIN 
			INSERT INTO [tblTMPreferenceCompany] (strSummitIntegration) VALUES ('Petro')
		END
		ELSE
		BEGIN
			INSERT INTO [tblTMPreferenceCompany] (strSummitIntegration) VALUES ('AG')
		END
	END
END

GO
	PRINT N'END INSERT DEFAULT TM PREFERENCE COMPANY'
GO