GO
PRINT N'BEGIN Check Origin coctl config and tm preference'
GO

IF((SELECT TOP 1 coctl_ag FROM coctlmst) <> 'Y' AND (SELECT TOP 1 coctl_pt FROM coctlmst) <> 'Y')
BEGIN
	UPDATE tblTMPreferenceCompany
	SET ysnUseOriginIntegration = 0
END

GO
PRINT N'END Check Origin coctl config and tm preference'
GO