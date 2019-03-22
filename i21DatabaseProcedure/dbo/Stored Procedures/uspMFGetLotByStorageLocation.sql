CREATE PROCEDURE uspMFGetLotByStorageLocation (@intStorageLocationId INT)
AS
BEGIN
	DECLARE @dtmCurrentDate DATETIME

	SELECT @dtmCurrentDate = Getdate()

	SELECT TOP 1 L.intLotId
		,L.strLotNumber
		,I.intItemId
		,I.strItemNo
		,I.strDescription
		,(
			CASE 
				WHEN L.intWeightUOMId IS NOT NULL
					THEN L.dblWeight
				ELSE L.dblQty
				END
			) AS dblWeight
		,ISNULL(L.intWeightUOMId, L.intItemUOMId) AS intWeightUOMId
		,U.strUnitMeasure
		,IU.intUnitMeasureId
		,L.dtmDateCreated
		,L.strLotAlias
	FROM dbo.tblICLot L
	JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
		AND L.intStorageLocationId = @intStorageLocationId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = ISNULL(L.intWeightUOMId, L.intItemUOMId)
	JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
	JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
					AND SL.ysnAllowConsume = 1
	JOIN dbo.tblICRestriction R on R.intRestrictionId =SL.intRestrictionId and R.strInternalCode ='STOCK'
	WHERE L.intLotStatusId = 1
		AND ISNULL(dtmExpiryDate,@dtmCurrentDate) >= @dtmCurrentDate
		AND L.dblQty > 0
		AND I.strStatus = 'Active'
	ORDER BY L.dtmDateCreated ASC
END