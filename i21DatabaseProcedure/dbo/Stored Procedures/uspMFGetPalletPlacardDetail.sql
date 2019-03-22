CREATE PROCEDURE uspMFGetPalletPlacardDetail (@strLotNumber nvarchar(50),@intLocationId INT)
AS
BEGIN
	SELECT PL.strParentLotNumber
		,SUM(L.dblQty) AS dblPhysicalCount
		,UM.strUnitMeasure
		,L.strLotNumber
		,L.intLocationId
	FROM tblICLot L
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = L.intItemUOMId 
	JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	JOIN tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
	WHERE L.strLotNumber = @strLotNumber and L.intLocationId =@intLocationId
		AND L.ysnProduced = 0
	GROUP BY PL.strParentLotNumber
		,UM.strUnitMeasure
		,L.strLotNumber
		,L.intLocationId
	
	UNION
	
	SELECT DT.strParentLotNumber
		,DT.dblPhysicalCount
		,DT.strUnitMeasure
		,DT.strLotNumber
		,DT.intLocationId
	FROM (
		SELECT strParentLotNumber
			,SUM(WP.dblPhysicalCount) AS dblPhysicalCount
			,UM.strUnitMeasure
			,L.strLotNumber
			,L.intLocationId
		FROM tblMFWorkOrderProducedLot WP
		JOIN tblICLot L ON L.intLotId = WP.intLotId
			AND WP.ysnProductionReversed = 0
		JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = WP.intPhysicalItemUOMId 
		JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
		WHERE L.strLotNumber = @strLotNumber and L.intLocationId =@intLocationId
			AND L.ysnProduced = 1
		GROUP BY strParentLotNumber
			,UM.strUnitMeasure
			,L.strLotNumber
			,L.intLocationId
		) AS DT
END
