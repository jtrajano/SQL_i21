PRINT N'BEGIN Update of data in tblTMDevice Populate intLocationId'
GO

IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwlocmst') 
	AND EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intLocationId' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice'))
BEGIN
		EXEC ('
				UPDATE tblTMDevice
				SET intLocationId = A.A4GLIdentity
				FROM vwlocmst A
				WHERE tblTMDevice.strBulkPlant = A.vwloc_loc_no COLLATE Latin1_General_CI_AS
				AND tblTMDevice.intLocationId IS NULL 
			  ')
END
GO

PRINT N'END Update of data in tblTMDevice Populate intLocationId'