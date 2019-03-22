CREATE PROCEDURE uspMFValidateDockdoorLocation (
	@strPickNo NVARCHAR(50)
	,@strDockDoorLocation NVARCHAR(50)
	,@intUserId INT
	,@intLocationId INT
	)
AS
BEGIN
	IF NOT EXISTS (
			SELECT *
			FROM tblICStorageLocation S
			JOIN tblICStorageUnitType UT ON UT.intStorageUnitTypeId = S.intStorageUnitTypeId
				AND UT.strInternalCode = 'WH_DOCK_DOOR'
			WHERE UPPER(strName) = @strDockDoorLocation
				AND S.intLocationId = @intLocationId
			)
	BEGIN
		RAISERROR (
				'INVALID DOCK DOOR LOCATION.'
				,16
				,1
				)

		RETURN
	END
END
