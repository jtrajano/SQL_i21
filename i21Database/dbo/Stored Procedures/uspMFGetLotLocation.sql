﻿CREATE PROCEDURE uspMFGetLotLocation (@strLotNo NVARCHAR(50))
AS
BEGIN
	DECLARE @intCount INT

	SELECT @intCount = COUNT(*)
	FROM tblICLot L
	JOIN tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
	WHERE L.strLotNumber = @strLotNo
		AND L.dblQty > 0

	SELECT TOP 1 L.intLotId
		,L.strLotNumber
		,L.intStorageLocationId
		,SL.strName AS strStorageLocationName
		,@intCount AS intLotCount
	FROM tblICLot L
	JOIN tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
	WHERE L.strLotNumber = @strLotNo
		AND L.dblQty > 0
END
