print N'BEGIN Migration of lease from device table to lease device table'
IF EXISTS(SELECT TOP 1 1 FROM sys.tables WHERE name = N'tblTMLeaseDevice')
BEGIN
	EXEC ('
		INSERT INTO tblTMLeaseDevice 
			(
				intLeaseId
				,intDeviceId
			)
			(
				SELECT DISTINCT
					intLeaseId
					,intDeviceId
				FROM tblTMDevice
				WHERE intLeaseId IS NOT NULL
					AND intDeviceId NOT IN (SELECT intDeviceId FROM tblTMLeaseDevice)
			)
	')

	
END
print N'END Migration of lease from device table to lease device table'