﻿CREATE PROCEDURE [dbo].[uspTMInventoryLastReading]
	@intSiteId int
AS
BEGIN

	WITH CTE AS
	(
		SELECT distinct
					intConcurrencyId = B.intConcurrencyId,
					intTankMonitorId = B.intTankMonitorId,
					dtmDateTime = B.dtmDateTime,
					strReadingSource = B.strReadingSource,
					intTankNumber = B.intTankNumber,
					strTankStatus = B.strTankStatus,
					intFuelGrade = B.intFuelGrade,
					dblFuelVolume = B.dblFuelVolume,
					dblTempCompensatedVolume = B.dblTempCompensatedVolume,
					dblFuelTemp = B.dblFuelTemp,
					dblFuelHeight = B.dblFuelHeight,
					dblWaterHeight = B.dblWaterHeight,
					dblWaterVolume = B.dblWaterVolume,
					dblUllage = B.dblUllage,
					strSerialNumber = B.strSerialNumber,
					intDeviceId = B.intDeviceId,
					intSiteId = B.intSiteId,
					dblInventoryReading = B.dblInventoryReading,
					ysnManual = B.ysnManual
			,dtmdate = CONVERT(VARCHAR(10), B.dtmDateTime, 111)
			,dtmHour = DATEPART(HOUR, B.dtmDateTime)
			,RowNumber = ROW_NUMBER() OVER (PARTITION BY DATEPART(HOUR, B.dtmDateTime) ORDER BY dtmDateTime DESC) 
		FROM tblTMSite A
			INNER JOIN tblTMTankMonitor B
			ON B.intSiteId = A.intSiteID
		where A.intSiteID = @intSiteId and ((DATEDIFF (day, B.dtmDateTime, getdate())) <= 28)
	)
	SELECT 
			intConcurrencyId
			,intTankMonitorId
			,dtmDateTime
			,strReadingSource
			,intTankNumber
			,strTankStatus
			,intFuelGrade
			,dblFuelVolume
			,dblTempCompensatedVolume
			,dblFuelTemp
			,dblFuelHeight
			,dblWaterHeight
			,dblWaterVolume
			,dblUllage
			,strSerialNumber
			,intDeviceId
			,intSiteId
			,dblInventoryReading
			,ysnManual
	FROM CTE 
	WHERE RowNumber = 1
	order by dtmDateTime desc
END