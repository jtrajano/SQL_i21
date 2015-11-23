﻿CREATE PROCEDURE uspWHGetLotDetail 
				 @intLotKey INT
AS
BEGIN
	SELECT DISTINCT l.intLotId, 
					l.strLotNumber, 
					l.strLotAlias LotAlias, 
					l.dtmDateCreated CreateDate, 
					us.strUserName CreatedBy, 
					i.strItemNo, 
					i.strDescription AS MaterialDescription, 
					l.dblQty,
					l.dblWeight,
					iu.intItemUOMId [PrimaryUOMKey], 
					um.strUnitMeasure, 
					l.dtmExpiryDate ExpiryDate, 
					ls.strPrimaryStatus PrimaryStatusCode, 
					ls.strSecondaryStatus SecondaryStatusCode, 
					ls.strSecondaryStatus AS LotStatus,
					sl.strName AS Unit
	FROM tblICLot l
	JOIN tblICItem i ON l.intItemId = i.intItemId
	JOIN tblICItemUOM iu ON iu.intItemUOMId = l.intItemUOMId 
	JOIN tblICUnitMeasure um ON um.intUnitMeasureId = iu.intUnitMeasureId
	JOIN tblICCategory c ON c.intCategoryId = i.intCategoryId
	JOIN tblICStorageLocation sl ON sl.intStorageLocationId = l.intStorageLocationId
	LEFT JOIN tblICLotStatus ls ON ls.intLotStatusId = l.intLotStatusId
	LEFT JOIN tblSMUserSecurity us ON us.intEntityUserSecurityId = l.intCreatedUserId
	WHERE l.intLotId = @intLotKey
END