CREATE VIEW [dbo].[vyuICGetSubLocationBinDetails]
AS
SELECT
	  intItemId					= sm.intItemId
	, intCompanyLocationId		= il.intLocationId
	, intItemLocationId			= il.intItemLocationId
	, intSubLocationId			= sm.intSubLocationId
	, strSubLocationName		= sc.strSubLocationName
	, intStorageLocationId		= sl.intStorageLocationId
	, strLocation				= c.strLocationName
	, strStorageLocation		= sl.strName
	, strItemNo					= i.strItemNo
	, strItemDescription		= i.strDescription
	, strItemUOM				= um.strUnitMeasure
	, dblStock					= ISNULL(sm.dblOnHand, 0) + ISNULL(sm.dblUnitStorage, 0)
	, dblCapacity				= sl.dblCapacity
	, dblAvailable				= 
			CASE 
				WHEN ISNULL(sl.dblCapacity, 0) > 0 THEN 
					ISNULL(sl.dblCapacity, 0) - ISNULL(sm.dblOnHand, 0) - ISNULL(sm.dblUnitStorage, 0)
				ELSE	
					0.00
			END
	, strCommodityCode			= com.strCommodityCode
	, i.strStatus
FROM 
	tblICItem i 
	INNER JOIN tblICItemLocation il 
		ON il.intItemId = i.intItemId		
	INNER JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = il.intLocationId
	INNER JOIN tblICItemUOM im 
		ON im.intItemUOMId = i.intItemId 
		AND im.ysnStockUnit = 1
	INNER JOIN tblICUnitMeasure um 
		ON um.intUnitMeasureId = im.intUnitMeasureId
	CROSS APPLY (
		SELECT 
				dblOnHand = SUM(dbo.fnCalculateQtyBetweenUOM(sm.intItemUOMId, im.intItemUOMId, ISNULL(sm.dblOnHand, 0)))
				,dblUnitStorage = SUM(dbo.fnCalculateQtyBetweenUOM(sm.intItemUOMId, im.intItemUOMId, ISNULL(sm.dblUnitStorage, 0)))
				,sm.intItemId
				,sm.intItemLocationId
				,sm.intSubLocationId
				,sm.intStorageLocationId
		FROM 
			tblICItemStockUOM sm
			INNER JOIN tblICItemUOM im 
				ON im.intItemUOMId = sm.intItemId 
				AND im.ysnStockUnit = 1
		WHERE		
			sm.intItemId = i.intItemId	
			AND sm.intItemLocationId = il.intItemLocationId
		GROUP BY
			sm.intItemId
			,sm.intItemLocationId
			,sm.intSubLocationId
			,sm.intStorageLocationId
	) sm

	LEFT JOIN tblSMCompanyLocationSubLocation sc ON 
		sc.intCompanyLocationSubLocationId = sm.intSubLocationId

	OUTER APPLY (
		SELECT 
			dblCapacity = SUM(ISNULL(sl.dblEffectiveDepth,0) *  ISNULL(sl.dblUnitPerFoot, 0))
			,sl.intStorageLocationId
			,sl.strName 
		FROM 
			tblICStorageLocation sl
		WHERE
			sl.intItemId = i.intItemId
			AND sl.intLocationId = il.intLocationId
			AND sl.intStorageLocationId = sm.intStorageLocationId
		GROUP BY 
			sl.intStorageLocationId
			,sl.strName 	
	) sl

	LEFT OUTER JOIN tblICCommodity com ON com.intCommodityId = i.intCommodityId
WHERE 
	i.strType = 'Inventory'