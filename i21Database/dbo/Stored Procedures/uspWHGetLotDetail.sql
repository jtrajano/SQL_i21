CREATE PROCEDURE uspWHGetLotDetail 
				 @intLotKey INT
AS
BEGIN
	SELECT DISTINCT l.intLotId, 
					l.strLotNumber, 
					l.strLotAlias LotAlias, 
					l.dtmDateCreated CreateDate, 
					us.strUserName CreatedBy, 
					l.intSubLocationId,
					l.intStorageLocationId,
					i.strItemNo, 
					i.strDescription AS MaterialDescription, 
					l.dblQty,
					l.dblWeight,
					iu.intItemUOMId [PrimaryUOMKey], 
					l.intWeightUOMId,
					wum.strUnitMeasure AS strWeightUnitMeasure,
					um.strUnitMeasure, 
					l.dtmExpiryDate ExpiryDate, 
					ls.strPrimaryStatus PrimaryStatusCode, 
					ls.strSecondaryStatus SecondaryStatusCode, 
					ls.strSecondaryStatus AS LotStatus,
					sl.strName AS Unit,
					ISNULL(i.intUnitPerLayer,1) * ISNULL(i.intLayerPerPallet,1) AS intCasesPerPallet
	FROM tblICLot l
	JOIN tblICItem i ON l.intItemId = i.intItemId
	JOIN tblICItemUOM iu ON iu.intItemUOMId = l.intItemUOMId 
	JOIN tblICUnitMeasure um ON um.intUnitMeasureId = iu.intUnitMeasureId
	JOIN tblICCategory c ON c.intCategoryId = i.intCategoryId
	JOIN tblICStorageLocation sl ON sl.intStorageLocationId = l.intStorageLocationId
	LEFT JOIN tblICItemUOM wu ON wu.intItemUOMId = l.intWeightUOMId 
	LEFT JOIN tblICUnitMeasure wum ON wum.intUnitMeasureId = wu.intUnitMeasureId
	LEFT JOIN tblICLotStatus ls ON ls.intLotStatusId = l.intLotStatusId
	LEFT JOIN tblSMUserSecurity us ON us.intEntityUserSecurityId = l.intCreatedUserId
	WHERE l.intLotId = @intLotKey
END