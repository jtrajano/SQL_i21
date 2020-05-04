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
print N'BEGIN Syncing Site Tank Capacity and Device Tank Capacity.'
GO
IF EXISTS(SELECT top 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'tblTMSite')
BEGIN
	EXEC ('
			update
				s
			set
				s.dblTotalCapacity = t.dblDeviceTotalTankCapacity
				,s.dblTotalReserve = t.dblDeviceTotalTankReserve
			from
				tblTMSite s
				,(
				select
					s.intSiteID
					,dblDeviceTotalTankCapacity = sum(d.dblTankCapacity)
					,dblDeviceTotalTankReserve = sum(d.dblTankReserve)
				from
					tblTMSite s
					,tblTMSiteDevice sd
					,tblTMDevice d
					,tblTMDeviceType dt
				where
					sd.intSiteID = s.intSiteID
					and d.intDeviceId = sd.intDeviceId
					and dt.intDeviceTypeId = d.intDeviceTypeId
					and dt.strDeviceType = ''Tank''
				group by
					s.intSiteID
				) t
			where
				s.intSiteID = t.intSiteID
				and s.dblTotalCapacity <> t.dblDeviceTotalTankCapacity
	')

END
GO
print N'END Syncing Site Tank Capacity and Device Tank Capacity.'
GO