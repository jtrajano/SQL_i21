
print N'BEGIN Migration of Tank Monitor from device table to Device Tank Monitor table'
IF EXISTS(SELECT TOP 1 1 FROM sys.tables WHERE name = N'tblTMDeviceTankMonitor')
BEGIN


	EXEC('
		insert into tblTMDeviceTankMonitor (intDeviceId)
		(
		select distinct intDeviceId 
		from tblTMDevice 
		where intDeviceTypeId = 4 
		and intDeviceId not in (select intDeviceId from tblTMDeviceTankMonitor)
		)

		insert into tblTMSiteDeviceTankMonitor (intSiteId,intDeviceTankMonitorId)
		select a.intSiteID,b.intDeviceTankMonitorId
		from tblTMSiteDevice as a join 
			tblTMDeviceTankMonitor as b on a.intDeviceId = b.intDeviceId
		where a.intDeviceId in (select intDeviceId from tblTMDeviceTankMonitor)
		
		DELETE from tblTMSiteDevice where intDeviceId in (select intDeviceId from tblTMDeviceTankMonitor)
	')

END
print N'END Migration of Tank Monitor from device table to Device Tank Monitor table'