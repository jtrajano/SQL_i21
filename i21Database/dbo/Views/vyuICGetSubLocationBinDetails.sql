﻿CREATE VIEW [dbo].[vyuICGetSubLocationBinDetails]
AS
SELECT
	 intItemId
	, intCompanyLocationId
	, intItemLocationId
	, intSubLocationId
	, strSubLocationName
	, intStorageLocationId
	, strLocation
	, strStorageLocation
	, strItemNo
	, strItemDescription
	, strItemUOM
	, dblStock
	, dblCapacity
	, dblAvailable
	, strCommodityCode
	, strStatus
	FROM (
	SELECT *,ROW_NUMBER() OVER(PARTITION BY intItemId,intItemLocationId,intSubLocationId ORDER BY intItemId DESC) AS intRowRecurrence 
		FROM (
		SELECT
			  intItemId					= i.intItemId
			, intCompanyLocationId		= il.intLocationId
			, intItemLocationId			= il.intItemLocationId
			, intSubLocationId			= CASE WHEN (i.ysnSeparateStockForUOMs = 1 AND i.strLotTracking = 'No') THEN stockUOM1.intSubLocationId ELSE stockUOM2.intSubLocationId END 								
			, strSubLocationName		= CASE WHEN (i.ysnSeparateStockForUOMs = 1 AND i.strLotTracking = 'No') THEN stockUOM1.strSubLocationName ELSE stockUOM2.strSubLocationName END 
			, intStorageLocationId		= sl.intStorageLocationId
			, strLocation				= c.strLocationName
			, strStorageLocation		= sl.strName
			, strItemNo					= i.strItemNo
			, strItemDescription		= i.strDescription
			, strItemUOM				= um.strUnitMeasure
			, dblStock					= 
				CAST(
					CASE 
						WHEN i.ysnSeparateStockForUOMs = 1 AND i.strLotTracking = 'No' THEN 
							ISNULL(stockUOM1.dblOnHand, 0) + ISNULL(stockUOM1.dblUnitStorage, 0) 
						ELSE 
							ISNULL(stockUOM2.dblOnHand, 0) + ISNULL(stockUOM2.dblUnitStorage, 0) 
					END 								
				 AS NUMERIC(28, 6))
			, dblCapacity				= CAST(sl.dblCapacity AS NUMERIC(28, 6)) 
			, dblAvailable				= 
				CAST(
					CASE 
						WHEN ISNULL(sl.dblCapacity, 0) > 0 THEN 
							CASE 
								WHEN i.ysnSeparateStockForUOMs = 1 AND i.strLotTracking = 'No' THEN 
									ISNULL(sl.dblCapacity, 0) 
									- ISNULL(stockUOM1.dblOnHand, 0) 
									- ISNULL(stockUOM1.dblUnitStorage, 0) 
								ELSE 
									ISNULL(sl.dblCapacity, 0) 
									- ISNULL(stockUOM2.dblOnHand, 0) 
									- ISNULL(stockUOM2.dblUnitStorage, 0) 
							END 
						ELSE	
							0.00
					END
				 AS NUMERIC(28, 6))
			, strCommodityCode			= com.strCommodityCode
			, i.strStatus
		FROM 
			tblICItem i 
			INNER JOIN tblICItemUOM stockUOM 
				ON stockUOM.intItemId = i.intItemId 
				AND stockUOM.ysnStockUnit = 1
			INNER JOIN tblICUnitMeasure um 
				ON um.intUnitMeasureId = stockUOM.intUnitMeasureId
			INNER JOIN tblICItemLocation il 
				ON il.intItemId = i.intItemId
				AND il.intLocationId IS NOT NULL 		
			INNER JOIN tblSMCompanyLocation c 
				ON c.intCompanyLocationId = il.intLocationId

			OUTER APPLY (
				SELECT 
						dblOnHand = SUM(dbo.fnCalculateQtyBetweenUOM(sm.intItemUOMId, stockUOM2.intItemUOMId, ISNULL(sm.dblOnHand, 0)))						
						,dblUnitStorage = SUM(dbo.fnCalculateQtyBetweenUOM(sm.intItemUOMId, stockUOM2.intItemUOMId, ISNULL(sm.dblUnitStorage, 0)))						
						,sm.intSubLocationId
						,sc.strSubLocationName
				FROM 
					tblICItemStockUOM sm 
					INNER JOIN tblICItemUOM stockUOM2 
						ON stockUOM2.intItemId = sm.intItemId
						AND stockUOM2.ysnStockUnit = 1				
					LEFT JOIN tblSMCompanyLocationSubLocation sc ON 
						sc.intCompanyLocationSubLocationId = sm.intSubLocationId
				WHERE		
					sm.intItemLocationId = il.intItemLocationId
					AND sm.intItemId = il.intItemId
					AND sm.intSubLocationId IS NOT NULL 
					AND i.ysnSeparateStockForUOMs = 1
					AND (i.strLotTracking = 'No' OR i.strLotTracking IS NULL) 
				GROUP BY
					sm.intSubLocationId
					,sc.strSubLocationName
			) stockUOM1

			OUTER APPLY (
				SELECT 
						dblOnHand = SUM(ISNULL(sm.dblOnHand, 0))
						,dblUnitStorage = SUM(ISNULL(sm.dblUnitStorage, 0))
						,sm.intSubLocationId
						,sc.strSubLocationName
				FROM 
					tblICItemStockUOM sm 
					LEFT JOIN tblSMCompanyLocationSubLocation sc ON 
						sc.intCompanyLocationSubLocationId = sm.intSubLocationId
				WHERE		
					sm.intItemLocationId = il.intItemLocationId
					AND sm.intItemId = il.intItemId
					AND sm.intSubLocationId IS NOT NULL 
					AND sm.intItemUOMId = stockUOM.intItemUOMId
					AND (
						ISNULL(i.ysnSeparateStockForUOMs, 1) = 0 
						OR i.strLotTracking Like 'Yes%' 
					)
			
				GROUP BY
					sm.intSubLocationId
					,sc.strSubLocationName
			) stockUOM2

			OUTER APPLY (
				SELECT 
					dblCapacity = SUM(ISNULL(sl.dblEffectiveDepth,0) *  ISNULL(sl.dblUnitPerFoot, 0))
					,sl.intStorageLocationId
					,sl.strName 
				FROM 
					tblICStorageLocation sl inner join tblICItemStockUOM sm
						ON sl.intStorageLocationId = sm.intStorageLocationId
				WHERE
					sm.intItemId = i.intItemId	
					AND sm.intItemLocationId = il.intItemLocationId
				GROUP BY 
					sl.intStorageLocationId
					,sl.strName 	
			) sl

			LEFT OUTER JOIN tblICCommodity com ON com.intCommodityId = i.intCommodityId
		WHERE 
			i.strType = 'Inventory'
		) AS ROWS
	) AS ROWS WHERE intRowRecurrence = 1;