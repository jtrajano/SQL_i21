GO
print N'BEGIN TM Populate Location Id for Origin Integrated..'
GO

IF((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1
	AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwlocmst') = 1
)
BEGIN
	UPDATE tblTMSite
	SET intLocationId = A.A4GLIdentity
	FROM vwlocmst A
	WHERE tblTMSite.strLocation = A.vwloc_loc_no COLLATE Latin1_General_CI_AS
		AND intLocationId IS NULL
END

GO
print N'END TM Populate Location Id for Origin Integrated'
GO

GO
print N'BEGIN TM Populate Location Id for Origin Integrated..'
GO

IF((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1
	AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwlocmst') = 1
)
BEGIN
	UPDATE tblTMDevice
	SET intLocationId = A.A4GLIdentity
	FROM vwlocmst A
	WHERE tblTMDevice.strBulkPlant = A.vwloc_loc_no COLLATE Latin1_General_CI_AS
		AND intLocationId IS NULL
END

GO
print N'END TM Populate Location Id for Origin Integrated'
GO