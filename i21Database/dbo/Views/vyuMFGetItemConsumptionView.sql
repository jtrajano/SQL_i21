CREATE VIEW [dbo].[vyuMFGetItemConsumptionView]
	AS
	SELECT  
		ROW_NUMBER() OVER(ORDER BY t.strItemNo) intRowNo
     , t.strItemNo
     , t.strDescription
     , t.strCategoryCode
     , t.strStorageLocationName
	 , SUM(ISNULL(t.dblQuantity,0)) AS dblConsumedQuantity
     , t.strUOM
	 , t.strLocationName
	 , t.intLocationId 
    FROM     
    (    
    SELECT
       i.strItemNo
     , i.strDescription
     , cg.strCategoryCode
     , sl.strName strStorageLocationName
     , wc.dblQuantity
     , um.strUnitMeasure strUOM
     , cl.strLocationName
	 , cl.intCompanyLocationId intLocationId
    FROM tblMFWorkOrderConsumedLot wc 
    JOIN tblICLot l on wc.intLotId=l.intLotId
	JOIN tblICItem i on l.intItemId=i.intItemId
    JOIN tblICStorageLocation sl on sl.intStorageLocationId=l.intStorageLocationId
    JOIN tblICCategory cg on cg.intCategoryId=i.intCategoryId
	JOIN tblICItemUOM iu on iu.intItemUOMId=wc.intItemUOMId
	JOIN tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=l.intLocationId
	) AS t  
  GROUP BY     
       t.strItemNo
     , t.strDescription
     , t.strCategoryCode
     , t.strStorageLocationName
     , t.strUOM
	 , t.strLocationName
	 , t.intLocationId
 
