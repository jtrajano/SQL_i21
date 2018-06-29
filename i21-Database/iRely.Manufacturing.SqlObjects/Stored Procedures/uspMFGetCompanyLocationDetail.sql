CREATE PROCEDURE uspMFGetCompanyLocationDetail @strStorageLocation NVARCHAR(50)
	,@strSubLocationName NVARCHAR(50)
	,@intLocationId INT
	,@strNewCompanyLocationName NVARCHAR(50)
AS
BEGIN
	SELECT TOP 1 SL.intStorageLocationId
		,SL.intSubLocationId
		,SL.intLocationId
		,COUNT(SL.intLocationId) OVER () AS intCompanyLocationCount
	FROM tblICStorageLocation SL
	JOIN tblSMCompanyLocationSubLocation CSL ON CSL.intCompanyLocationSubLocationId = SL.intSubLocationId
	JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CSL.intCompanyLocationId
		AND SL.strName = @strStorageLocation
		AND CSL.strSubLocationName = @strSubLocationName
		AND SL.intLocationId = (
			CASE 
				WHEN @intLocationId = 0
					THEN SL.intLocationId
				ELSE @intLocationId
				END
			)
		AND CL.strLocationName = (
			CASE 
				WHEN ISNULL(@strNewCompanyLocationName, '') = ''
					THEN CL.strLocationName
				ELSE @strNewCompanyLocationName
				END
			)
END
