﻿CREATE VIEW [dbo].[vyuICGetSubLocationBinDetails]
AS
SELECT
	  intItemId					= i.intItemId
	, intCompanyLocationId		= il.intLocationId
	, intItemLocationId			= il.intItemLocationId
	, intSubLocationId			= CASE WHEN (i.ysnSeparateStockForUOMs = 1 AND i.strLotTracking = 'No') THEN stockUOM1.intSubLocationId ELSE stockUOM2.intSubLocationId END 								
	, strSubLocationName		= CASE WHEN (i.ysnSeparateStockForUOMs = 1 AND i.strLotTracking = 'No') THEN stockUOM1.strSubLocationName ELSE stockUOM2.strSubLocationName END 
	, intStorageLocationId		= NULL 
	, strLocation				= c.strLocationName
	, strStorageLocation		= NULL 
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
	, dblCapacity				= ISNULL(sl.dblCapacity, 0)
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
				dblOnHand = SUM(
					dbo.fnICConvertUOMtoStockUnit (
						sm.intItemId
						,sm.intItemUOMId
						,ISNULL(sm.dblOnHand, 0)
					)
				)						
				,dblUnitStorage = SUM(
					dbo.fnICConvertUOMtoStockUnit (
						sm.intItemId
						,sm.intItemUOMId
						,ISNULL(sm.dblUnitStorage, 0)
					)
				)						
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
			AND i.ysnSeparateStockForUOMs = 1
			AND (i.strLotTracking = 'No' OR i.strLotTracking IS NULL) 
		GROUP BY
			sm.intSubLocationId
			,sc.strSubLocationName
	) stockUOM1

	OUTER APPLY (
		SELECT 
				dblOnHand = SUM(
					ISNULL(sm.dblOnHand, 0)
				)
				,dblUnitStorage = SUM(
					ISNULL(sm.dblUnitStorage, 0)
				)
				,sm.intSubLocationId
				,sc.strSubLocationName
		FROM 
			tblICItemStockUOM sm LEFT JOIN tblSMCompanyLocationSubLocation sc 
				ON sc.intCompanyLocationSubLocationId = sm.intSubLocationId
		WHERE		
			sm.intItemLocationId = il.intItemLocationId
			AND sm.intItemId = il.intItemId
			AND sm.intItemUOMId = stockUOM.intItemUOMId
			AND (
				ISNULL(i.ysnSeparateStockForUOMs, 1) = 0 
				OR i.strLotTracking Like 'Yes%' 
			)
			
		GROUP BY
			sm.intSubLocationId
			,sc.strSubLocationName
	) stockUOM2

	-- Get the total "storage" capacity of a company-location and storage-location (formerly known as sub-location). 
	OUTER APPLY (
		SELECT 
			dblCapacity = SUM(ISNULL(sl.dblEffectiveDepth,0) *  ISNULL(sl.dblUnitPerFoot, 0))
		FROM 
			tblICStorageLocation sl inner join tblICItemStockUOM sm
				ON sl.intStorageLocationId = sm.intStorageLocationId
		WHERE
			sm.intItemId = i.intItemId	
			AND sm.intItemLocationId = il.intItemLocationId
			AND sl.intSubLocationId = COALESCE(stockUOM1.intSubLocationId, stockUOM2.intSubLocationId)
	) sl

	LEFT OUTER JOIN tblICCommodity com ON com.intCommodityId = i.intCommodityId
WHERE 
	i.strType = 'Inventory'