CREATE FUNCTION [dbo].[fnTMGetFirstTankSiteDeviceTable](
	@intSiteId INT
)
RETURNS @tblTableReturn TABLE(
	strSerialNumber NVARCHAR(50)
	,strTankType NVARCHAR(50)
)
AS
BEGIN 
	INSERT INTO @tblTableReturn (strTankType,strSerialNumber)
	SELECT TOP 1
		D.strTankType
		,C.strSerialNumber
	FROM tblTMSite A
	INNER JOIN tblTMSiteDevice B
		ON A.intSiteID = B.intSiteID
	INNER JOIN tblTMDevice C
		ON B.intDeviceId = C.intDeviceId
	LEFT JOIN tblTMTankType D
		ON C.intTankTypeId  = D.intTankTypeId
	WHERE A.intSiteID = @intSiteId
		AND intDeviceTypeId = (SELECT TOP 1 intDeviceTypeId 
								FROM tblTMDeviceType 
								WHERE strDeviceType = 'Tank')
	ORDER BY B.intSiteDeviceID ASC

	RETURN 

END	