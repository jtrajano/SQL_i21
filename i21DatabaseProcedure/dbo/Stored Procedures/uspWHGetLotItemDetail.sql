CREATE PROCEDURE uspWHGetLotItemDetail
      
 @strLotNo NVARCHAR(30),     
 @intCompanyLocationId INT    
      
AS        
      
SET NOCOUNT ON         
        
SELECT	l.intLotId,
		l.strLotNumber,
		m.strItemNo, 
		m.strDescription, 
		um.strUnitMeasure [strIssueUOM], 
		um1.strUnitMeasure [strReceiveUOM], 
		um1.strUnitMeasure [strStandardUOM], 
		d.strCategoryCode, 
		m.intLifeTime, 
		m.intUnitPerLayer * m.intLayerPerPallet AS intCasesPerPallet, 
		m.dblWeight, 
		l.dblQty , 
		u.intStorageLocationId, 
		u.strName AS strStorageLocationName,
		l.strVendorLotNo, 
		l.intLocationId
FROM tblICItem m
INNER JOIN tblICLot l ON m.intItemId = l.intItemId
LEFT JOIN tblICStorageLocation u ON u.intStorageLocationId = l.intStorageLocationId
LEFT JOIN tblICCategory d ON m.intCategoryId = d.intCategoryId
LEFT JOIN tblICItemUOM iu ON iu.intItemId = m.intItemId AND iu.ysnStockUnit = 1
LEFT JOIN tblICItemUOM iu1 ON iu1.intItemUOMId = l.intItemUOMId
LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = iu.intUnitMeasureId
LEFT JOIN tblICUnitMeasure um1 ON um1.intUnitMeasureId = iu1.intUnitMeasureId
 WHERE l.strLotNumber = @strLotNo 	AND l.intLocationId = @intCompanyLocationId
	
RETURN