print N'BEGIN CONVERSION - i21 TANK MANAGEMENT..'
GO
print N'BEGIN Migration of Data from preference company to lease code'
IF EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE name = N'intLeaseItemId' AND Object_ID = Object_ID(N'tblTMPreferenceCompany'))
BEGIN
	EXEC ('
		UPDATE tblTMLeaseCode
		SET intItemId = (SELECT TOP 1 intLeaseItemId FROM tblTMPreferenceCompany)
		WHERE intItemId IS NOT NULL
	')

	EXEC('
		ALTER TABLE tblTMPreferenceCompany DROP COLUMN intLeaseItemId 
	')
END
GO
print N'END Migration of Data from preference company to lease code'
GO

print N'BEGIN Populate global julian calendar for site'
GO
IF EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE name = N'intGlobalJulianCalendarId' AND Object_ID = Object_ID(N'tblTMSite'))
BEGIN
	EXEC ('
		UPDATE tblTMSite
		SET intGlobalJulianCalendarId = (SELECT TOP 1 intGlobalJulianCalendarId 
											FROM tblTMGlobalJulianCalendar
											WHERE ysnDefault = 1)
		WHERE intGlobalJulianCalendarId IS NULL 
			AND intFillMethodId = (SELECT TOP 1 
								intFillMethodId 
							FROM tblTMFillMethod 
							WHERE strFillMethod = ''Julian Calendar'')
	')

END
GO
print N'END Populate global julian calendar for site'
GO