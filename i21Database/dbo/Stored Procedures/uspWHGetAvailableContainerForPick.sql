
CREATE PROCEDURE uspWHGetAvailableContainerForPick  -- uspWHGetAvailableContainerForPick'BLR003040','CON-537'
				@strBOLNo NVARCHAR(32), 
				@strContainerNo VARCHAR(16)
AS

DECLARE @intItemId INT
DECLARE @intCompanyLocationId INT
DECLARE @intCompanyLocationSubLocationId INT
DECLARE @intAllowablePickDayRange INT
DECLARE @dtmProductionDate NVARCHAR(100)
DECLARE @ysnLifetimeUnitMonthEndofMonth BIT
DECLARE @intOrderHeaderId INT
DECLARE @intWarehouseId INT
DECLARE @strOrderType NVARCHAR(2)
DECLARE @strBlendProductionStagingLocation NVARCHAR(MAX)

--Get the  Value of  Required Variables.
SELECT @intOrderHeaderId = OH.intOrderHeaderId, @strOrderType = OT.strInternalCode
FROM tblWHOrderHeader OH
JOIN tblWHOrderType OT ON OT.intOrderTypeId = OH.intOrderTypeId
WHERE strBOLNo = @strBOLNo

SELECT @intCompanyLocationId = u.intLocationId, 
	   @intCompanyLocationSubLocationId = u.intSubLocationId, 
	   @intWarehouseId = u.intLocationId
FROM tblICStorageLocation u
JOIN tblSMCompanyLocationSubLocation l ON l.intCompanyLocationSubLocationId = u.intSubLocationId
JOIN tblWHContainer c ON c.intStorageLocationId = u.intStorageLocationId
	AND c.strContainerNo = @strContainerNo

SELECT @intAllowablePickDayRange = intAllowablePickDayRange
FROM tblWHCompanyPreference 
WHERE intCompanyLocationId = @intCompanyLocationId

SELECT @intItemId = m.intItemId
FROM tblICItem m
JOIN tblWHSKU s ON s.intItemId = m.intItemId
JOIN tblWHContainer c ON c.intContainerId = s.intContainerId
WHERE c.strContainerNo = @strContainerNo

---Get the Production Date
SELECT @dtmProductionDate = MIN(s.dtmProductionDate)
FROM tblWHSKU s
INNER JOIN tblWHContainer c ON c.intContainerId = s.intContainerId
INNER JOIN tblICStorageLocation u ON u.intStorageLocationId = c.intStorageLocationId
INNER JOIN tblSMCompanyLocationSubLocation loc ON u.intSubLocationId = loc.intCompanyLocationSubLocationId
INNER JOIN tblICStorageUnitType t ON u.intStorageUnitTypeId = t.intStorageUnitTypeId --AND t.ysnAllowPick = 1
INNER JOIN tblICRestriction r ON u.intRestrictionId = r.intRestrictionId
	AND r.strInternalCode = 'STOCK'
INNER JOIN tblICItem m ON m.intItemId = s.intItemId
INNER JOIN tblWHOrderLineItem li ON li.intItemId = m.intItemId
INNER JOIN tblWHOrderHeader h ON h.intOrderHeaderId = li.intOrderHeaderId
	AND h.intOrderHeaderId = @intOrderHeaderId
WHERE (
		(
			(
				s.intSKUStatusId = 1
				OR s.intSKUStatusId = 2
				)
			AND @strOrderType = 'SS'
			)
		OR (
			s.intSKUStatusId = 1
			AND @strOrderType <> 'SS'
			)
		)
	AND NOT EXISTS (
		SELECT *
		FROM tblWHOrderManifest m
		INNER JOIN tblWHOrderLineItem li2 ON li2.intOrderLineItemId = m.intOrderLineItemId
		INNER JOIN tblWHOrderHeader h2 ON h2.intOrderHeaderId = li2.intOrderHeaderId
			AND h2.intOrderDirectionId = 2
			AND h2.intOrderStatusId IN (1,5,6,7)
		WHERE m.intSKUId = s.intSKUId
		)
	--                  AND (SELECT min(Original) - SUM(isnull(QTY,0)) FROM (select CASE WHEN tt.TaskTypeKey=13 Then ts.dblQty-tt.dblQty ELSE tt.dblQty END dblQty,ts.dblQty Original from  wm_sku ts left join wm_task tt on tt.skukey =ts.skukey where ts.skukey = s.skukey) T )> 0  
	AND s.intItemId = @intItemId
	AND s.strLotCode = (
		CASE 
			WHEN @strOrderType IN (
					'PS'
					,'SS'
					)
				AND li.strLotAlias IS NOT NULL
				AND li.strLotAlias <> ''
				THEN li.strLotAlias
			ELSE s.strLotCode
			END
		)
	AND s.ysnIsSanitized = (
		CASE 
			WHEN @strOrderType IN (
					'PS'
					,'SS'
					)
				THEN 0
			ELSE s.ysnIsSanitized
			END
		)

--Get The Required SelectList
IF @strOrderType IN ('PS')
BEGIN
	SELECT UnitName, strContainerNo, dblQty, strLotCode, UOM
	FROM (
		SELECT u.UnitName, c.strContainerNo, s.dblQty, s.intSKUId, s.strSKUNo, s.dblQty OriginalQty, (
				CASE 
					WHEN DP.Abbreviations = 'yy'
						THEN DATEADD(yy, m.LifeTime, ISNull(s.Productiondate, s.ReceiveDate))
					WHEN DP.Abbreviations = 'mm'
						THEN CASE 
								WHEN @ysnLifetimeUnitMonthEndofMonth = 1
									THEN DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, DATEADD(mm, m.LifeTime, ISNull(s.Productiondate, s.ReceiveDate))) + 1, 0))
								ELSE DATEADD(mm, m.LifeTime, ISNull(s.Productiondate, s.ReceiveDate))
								END
					WHEN DP.Abbreviations = 'dd'
						THEN DATEADD(dd, m.LifeTime, ISNull(s.Productiondate, s.ReceiveDate))
					WHEN DP.Abbreviations = 'hh'
						THEN DATEADD(hh, m.LifeTime, ISNull(s.Productiondate, s.ReceiveDate))
					WHEN DP.Abbreviations = 'mi'
						THEN DATEADD(mi, m.LifeTime, ISNull(s.Productiondate, s.ReceiveDate))
					END
				) ExpiryDate, CASE 
				WHEN ABS(DateDiff(d, s.dtmProductionDate, Cast(@dtmProductionDate AS DATETIME))) <= @intAllowablePickDayRange
					THEN @dtmProductionDate
				ELSE s.dtmProductionDate
				END [dtmProductionDate], m.intItemId, m.MaterialName, m.Description, ISNULL(m.UnitsPerLayer, 1) * ISNULL(m.LayersPerPallet, 1) AS ItemsPerPallet, CASE 
				WHEN (
						SELECT COUNT(*)
						FROM tblWHSKU
						WHERE intContainerId = c.intContainerId
							AND intSKUId <> s.intSKUId
						) > 0
					THEN 1
				ELSE 0
				END MixedContainer, s.strLotCode, uc.strUnitMeasure AS UOM
		FROM tblWHSKU s
		INNER JOIN tblWHContainer c ON c.intContainerId = s.intContainerId
		INNER JOIN tblICStorageLocation u ON u.intStorageLocationId = c.intStorageLocationId
		INNER JOIN tblICUnitMeasure uc ON uc.intUnitMeasureId = s.intUOMId
		INNER JOIN tblSMCompanyLocationSubLocation loc ON u.intSubLocationId = loc.intCompanyLocationSubLocationId
		INNER JOIN tblICStorageUnitType t ON u.intStorageUnitTypeId = t.intStorageUnitTypeId
			AND t.ysnAllowPick = 1
		INNER JOIN tblICRestriction r ON u.intRestrictionId = r.intRestrictionId
			AND r.strInternalCode = 'STOCK'
		INNER JOIN tblICItem m ON m.intItemId = s.intItemId
		JOIN dbo.iMake_DatePart DP ON DP.DatepartKey = m.LifeTimeDatePartKey
		INNER JOIN tblWHOrderLineItem li ON li.intItemId = m.intItemId
		INNER JOIN tblWHOrderHeader h ON h.intOrderHeaderId = li.intOrderHeaderId
			AND h.intOrderHeaderId = @intOrderHeaderId
		WHERE (
				(
					CASE 
						WHEN DP.Abbreviations = 'yy'
							THEN DATEADD(yy, m.LifeTime, ISNull(s.Productiondate, s.ReceiveDate))
						WHEN DP.Abbreviations = 'mm'
							THEN CASE 
									WHEN @ysnLifetimeUnitMonthEndofMonth = 1
										THEN DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, DATEADD(mm, m.LifeTime, ISNull(s.Productiondate, s.ReceiveDate))) + 1, 0))
									ELSE DATEADD(mm, m.LifeTime, ISNull(s.Productiondate, s.ReceiveDate))
									END
						WHEN DP.Abbreviations = 'dd'
							THEN DATEADD(dd, m.LifeTime, ISNull(s.Productiondate, s.ReceiveDate))
						WHEN DP.Abbreviations = 'hh'
							THEN DATEADD(hh, m.LifeTime, ISNull(s.Productiondate, s.ReceiveDate))
						WHEN DP.Abbreviations = 'mi'
							THEN DATEADD(mi, m.LifeTime, ISNull(s.Productiondate, s.ReceiveDate))
						END
					) > GetUTCDate()
				OR m.MaterialControlKey = 3
				)
			AND (
				(
					(
						s.intSKUStatusId = 1
						OR s.intSKUStatusId = 2
						)
					AND @strOrderType = 'SS'
					)
				OR (
					s.intSKUStatusId = 1
					AND @strOrderType <> 'SS'
					)
				)
			AND NOT EXISTS (
				SELECT *
				FROM tblWHOrderManifest m
				INNER JOIN tblWHOrderLineItem li2 ON li2.intOrderLineItemId = m.intOrderLineItemId
				INNER JOIN tblWHOrderHeader h2 ON h2.intOrderHeaderId = li2.intOrderHeaderId
					AND h2.intOrderDirectionId = 2
					AND h2.intOrderStatusId IN (
						1
						,16
						,32
						,64
						)
				WHERE m.intSKUId = s.intSKUId
				)
			AND (
				SELECT min(Original) - SUM(isnull(QTY, 0))
				FROM (
					SELECT CASE 
							WHEN tt.TaskTypeKey = 13
								THEN ts.dblQty - tt.dblQty
							ELSE tt.dblQty
							END dblQty, ts.dblQty Original
					FROM wm_sku ts
					LEFT JOIN wm_task tt ON tt.skukey = ts.skukey
					WHERE ts.skukey = s.skukey
					) T
				) = s.dblQty
			AND s.intItemId = @intItemId
			AND s.dtmProductionDate <= (
				CASE 
					WHEN @strOrderType IN (
							'PS'
							,'SS'
							)
						THEN s.dtmProductionDate
					ELSE DATEADD(d, @intAllowablePickDayRange, @dtmProductionDate)
					END
				)
			AND s.strLotCode = (
				CASE 
					WHEN @strOrderType IN (
							'PS'
							,'SS'
							)
						AND li.strLotAlias IS NOT NULL
						AND li.strLotAlias <> ''
						THEN li.strLotAlias
					ELSE s.strLotCode
					END
				)
			AND s.ysnSanitized = (
				CASE 
					WHEN @strOrderType IN (
							'PS'
							,'SS'
							)
						THEN 0
					ELSE s.ysnSanitized
					END
				)
			--AND c.intStorageLocationId <> @ProductionStaging
		) t
	ORDER BY 4
END
ELSE
BEGIN
	SELECT strStorageLocationName, strContainerNo, dblQty, strLotCode, UOM
	FROM (
		SELECT u.strName AS strStorageLocationName, c.strContainerNo, s.dblQty, s.intSKUId, s.strSKUNo, s.dblQty OriginalQty, s.strLotCode, uc.strUnitMeasure AS UOM
		FROM tblWHSKU s
		INNER JOIN tblWHContainer c ON c.intContainerId = s.intContainerId
		INNER JOIN tblICStorageLocation u ON u.intStorageLocationId = c.intStorageLocationId
		INNER JOIN tblICUnitMeasure uc ON uc.intUnitMeasureId = s.intUOMId
		INNER JOIN tblSMCompanyLocationSubLocation loc ON u.intSubLocationId = loc.intCompanyLocationSubLocationId
		INNER JOIN tblICStorageUnitType t ON u.intStorageUnitTypeId = t.intStorageUnitTypeId --AND t.ysnAllowPick = 1 
		INNER JOIN tblICRestriction r ON u.intRestrictionId = r.intRestrictionId
			AND r.strInternalCode = 'STOCK'
		INNER JOIN tblICItem m ON m.intItemId = s.intItemId
		INNER JOIN tblWHOrderLineItem li ON li.intItemId = m.intItemId
		INNER JOIN tblWHOrderHeader h ON h.intOrderHeaderId = li.intOrderHeaderId
			AND h.intOrderHeaderId = @intOrderHeaderId
		WHERE NOT EXISTS (
				SELECT *
				FROM tblWHOrderManifest m
				INNER JOIN tblWHOrderLineItem li2 ON li2.intOrderLineItemId = m.intOrderLineItemId
				INNER JOIN tblWHOrderHeader h2 ON h2.intOrderHeaderId = li2.intOrderHeaderId
					AND h2.intOrderDirectionId = 2
					AND h2.intOrderStatusId IN (
						1
						,5
						,6
						,7
						)
				WHERE m.intSKUId = s.intSKUId
				)
			--AND (SELECT MIN(Original) - SUM(ISNULL(QTY,0)) FROM (select CASE WHEN tt.TaskTypeKey=13 Then ts.dblQty-tt.dblQty ELSE tt.dblQty END dblQty,ts.dblQty Original from  wm_sku ts left join wm_task tt on tt.skukey =ts.skukey where ts.skukey = s.skukey) T ) = s.dblQty 
			AND s.intItemId = @intItemId
			AND s.dtmProductionDate <= (
				CASE 
					WHEN @strOrderType IN (
							'PS'
							,'SS'
							)
						THEN s.dtmProductionDate
					ELSE DATEADD(d, @intAllowablePickDayRange, @dtmProductionDate)
					END
				)
			AND s.strLotCode = (
				CASE 
					WHEN @strOrderType IN (
							'PS'
							,'SS'
							)
						AND li.strLotAlias IS NOT NULL
						AND li.strLotAlias <> ''
						THEN li.strLotAlias
					ELSE s.strLotCode
					END
				)
			AND s.ysnIsSanitized = (
				CASE 
					WHEN @strOrderType IN (
							'PS'
							,'SS'
							)
						THEN 0
					ELSE s.ysnIsSanitized
					END
				)
		) t
	ORDER BY 4
END
GO