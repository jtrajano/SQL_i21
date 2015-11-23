﻿CREATE PROCEDURE uspWHGetLotDetailByLotNo
     @strLotNo NVARCHAR(100),
     @intCompanyLocationId INT
AS  
BEGIN  
	DECLARE @intLotId AS INT
	
	SELECT @intLotId = intLotId
	FROM tblICLot
	WHERE strLotNumber = @strLotNo
		AND intLocationId = @intCompanyLocationId

	SELECT DISTINCT l.intLotId,   
		 l.strLotNumber,   
		 l.strLotAlias LotAlias,   
		 l.dtmDateCreated CreateDate,   
		 us.strUserName CreatedBy,   
		 i.strItemNo,   
		 i.strDescription AS MaterialDescription,   
		 l.dblQty,  
		 l.strVendorLotNo,
		 l.dblWeight,  
		 iu.intItemUOMId [PrimaryUOMKey],   
		 um.strUnitMeasure,   
		 l.dtmExpiryDate ExpiryDate,   
		 ls.strPrimaryStatus PrimaryStatusCode,   
		 ls.strSecondaryStatus SecondaryStatusCode,   
		 ls.strSecondaryStatus AS LotStatus,  
		 sl.strName AS Unit,
		 ISNULL(i.intUnitPerLayer,1) * ISNULL(i.intLayerPerPallet,1) AS intCasesPerPallet,
		 l.intSubLocationId,
		 l.intLocationId,
		 l.intStorageLocationId
	FROM tblICLot l  
	JOIN tblICItem i ON l.intItemId = i.intItemId  
	JOIN tblICItemUOM iu ON iu.intItemUOMId = l.intItemUOMId   
	JOIN tblICUnitMeasure um ON um.intUnitMeasureId = iu.intUnitMeasureId  
	JOIN tblICCategory c ON c.intCategoryId = i.intCategoryId  
	JOIN tblICStorageLocation sl ON sl.intStorageLocationId = l.intStorageLocationId  
	LEFT JOIN tblICLotStatus ls ON ls.intLotStatusId = l.intLotStatusId  
	LEFT JOIN tblSMUserSecurity us ON us.intEntityUserSecurityId = l.intCreatedUserId  
	WHERE l.intLotId = @intLotId
END  