CREATE PROCEDURE uspMFGetUOMByLot (@intLotId INT)
AS
BEGIN
	SELECT L.intItemUOMId
		,UM.strUnitMeasure
	FROM tblICLot L
	JOIN tblICItemUOM IU ON IU.intItemUOMId = L.intItemUOMId
	JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	WHERE intLotId = @intLotId
	
	UNION ALL
	
	SELECT IU.intItemUOMId
		,UM.strUnitMeasure
	FROM tblICLot L
	JOIN tblICItemUOM IU ON IU.intItemUOMId = L.intWeightUOMId
	JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	WHERE intLotId = @intLotId
END
