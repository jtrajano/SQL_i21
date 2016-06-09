CREATE PROCEDURE uspMFGetLotHistory @intLotId INT
AS
BEGIN
	IF OBJECT_ID('tempdb..#tempLotHistory') IS NOT NULL
		DROP TABLE #tempLotHistory

	DECLARE @dblPrimaryQty NUMERIC(38, 20)
		,@dblPrimaryWeight NUMERIC(38, 20)

	SELECT @dblPrimaryQty = 0
		,@dblPrimaryWeight = 0

	SELECT CASE 
			WHEN Convert(DATETIME, Convert(CHAR, dtmDate, 101)) = Convert(DATETIME, Convert(CHAR, dtmCreated, 101))
				THEN dtmCreated
			ELSE dtmDate
			END AS dtmDateTime
		,l.strLotNumber AS strLotNo
		,CASE 
			WHEN iad.intNewItemId IS NULL
				THEN i.strItemNo
			ELSE i1.strItemNo
			END AS strItem
		,CASE 
			WHEN iad.intNewItemId IS NULL
				THEN i.strDescription
			ELSE i1.strDescription
			END AS strDescription
		,c.strCategoryCode
		,clsl.strSubLocationName AS strSubLocation
		,sl.strName AS strStorageLocation
		,CASE 
			WHEN itt.strName = 'Produce'
				AND ilt.dblQty < 0
				THEN 'Produce Reversal'
			WHEN itt.strName = 'Consume'
				AND ilt.dblQty > 0
				THEN 'Consume Reversal'
			ELSE itt.strName
			END AS strTransaction
		,CONVERT(NUMERIC(38, 20), 0.0) AS dblWeight
		,CONVERT(NUMERIC(38, 20), ilt.dblQty) AS dblTransactionWeight
		,uwm.strUnitMeasure AS strTransactionWeightUOM
		,CONVERT(NUMERIC(38, 20), 0.0) AS dblQuantity
		,CONVERT(NUMERIC(38, 20), ilt.dblQty / CASE 
				WHEN l.dblWeightPerQty = 0
					THEN 1
				ELSE l.dblWeightPerQty
				END) AS dblTransactionQty
		,um.strUnitMeasure AS strTransactionQtyUOM
		,CASE 
			WHEN iad.intNewLotId = @intLotId
				THEN L1.strLotNumber
			ELSE iad.strNewLotNumber
			END AS strRelatedLotId
		,CASE 
			WHEN iad.intNewItemId IS NULL
				THEN NULL
			ELSE i.strItemNo
			END AS strPreviousItem
		,CASE 
			WHEN iad.intNewLotId = @intLotId
				THEN clsl2.strSubLocationName
			ELSE clsl1.strSubLocationName
			END AS strSourceSubLocation
		,CASE 
			WHEN iad.intNewLotId = @intLotId
				THEN sl2.strName
			ELSE sl1.strName
			END AS strSourceStorageLocation
		,NULL AS strNewStatus
		,NULL AS strOldStatus
		,NULL AS strNewLotAlias
		,NULL AS strOldLotAlias
		,iad.dtmNewExpiryDate AS dtmNewExpiryDate
		,iad.dtmExpiryDate AS dtmOldExpiryDate
		,'' AS strNewVendorNo
		,'' AS strOldVendorNo
		,'' AS strNewVendorLotNo
		,'' AS strOldVendorLotNo
		,'' AS strNotes
		,us.strUserName AS strUser
	INTO #tempLotHistory
	FROM tblICLot l
	LEFT JOIN tblICInventoryTransaction ilt ON ilt.intLotId = l.intLotId
	LEFT JOIN tblICInventoryTransactionType itt ON itt.intTransactionTypeId = ilt.intTransactionTypeId
	LEFT JOIN tblICInventoryAdjustmentDetail iad ON ilt.intTransactionDetailId = iad.intInventoryAdjustmentDetailId
	LEFT JOIN tblICItem i ON i.intItemId = ISNULL((
				CASE 
					WHEN ilt.intTransactionTypeId = 15
						THEN iad.intItemId
					ELSE ilt.intItemId
					END
				), ilt.intItemId)
	JOIN tblICItemUOM iu ON iu.intItemUOMId = l.intItemUOMId
	JOIN tblICUnitMeasure um ON um.intUnitMeasureId = iu.intUnitMeasureId
	LEFT JOIN tblICItemUOM iwu ON iwu.intItemUOMId = IsNULL(l.intWeightUOMId, l.intItemUOMId)
	LEFT JOIN tblICUnitMeasure uwm ON uwm.intUnitMeasureId = iwu.intUnitMeasureId
	LEFT JOIN tblICCategory c ON c.intCategoryId = i.intCategoryId
	LEFT JOIN tblSMCompanyLocationSubLocation clsl ON clsl.intCompanyLocationSubLocationId = ilt.intSubLocationId
	LEFT JOIN tblICStorageLocation sl ON sl.intStorageLocationId = ilt.intStorageLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation clsl1 ON clsl1.intCompanyLocationSubLocationId = iad.intNewSubLocationId
	LEFT JOIN tblICStorageLocation sl1 ON sl1.intStorageLocationId = iad.intNewStorageLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation clsl2 ON clsl2.intCompanyLocationSubLocationId = iad.intSubLocationId
	LEFT JOIN tblICStorageLocation sl2 ON sl2.intStorageLocationId = iad.intStorageLocationId
	LEFT JOIN tblSMUserSecurity us ON us.[intEntityUserSecurityId] = ilt.intCreatedEntityId
	LEFT JOIN dbo.tblICLot L1 ON L1.intLotId = iad.intLotId
	LEFT JOIN tblICItem i1 ON i1.intItemId = iad.intNewItemId
	WHERE l.intLotId = @intLotId
	
	UNION ALL
	
	SELECT ia.dtmPostedDate
		,l.strLotNumber AS strLotNo
		,i.strItemNo AS strItemNo
		,i.strDescription AS strDescription
		,c.strCategoryCode
		,clsl.strSubLocationName AS strSubLocation
		,sl.strName AS strStorageLocation
		,CASE 
			WHEN iad.intLotStatusId <> iad.intNewLotStatusId
				THEN 'Inventory Adjustment - Lot Status Change'
			WHEN iad.dtmExpiryDate <> iad.dtmNewExpiryDate
				THEN 'Inventory Adjustment - Expiry Date Change'
			ELSE ''
			END AS strTransaction
		,CONVERT(NUMERIC(38, 20), 0.0) AS dblWeight
		,CONVERT(NUMERIC(38, 20), ISNULL(iad.dblWeight, 0)) AS dblTransactionWeight
		,um.strUnitMeasure AS strTransactionWeightUOM
		,CONVERT(NUMERIC(38, 20), 0.0) AS dblQuantity
		,CONVERT(NUMERIC(38, 20), ISNULL(iad.dblWeight / (
					CASE 
						WHEN l.dblWeightPerQty = 0
							THEN 1
						ELSE l.dblWeightPerQty
						END
					), 0)) AS dblTransactionQty
		,um1.strUnitMeasure AS strTransactionQtyUOM
		,iad.strNewLotNumber AS strRelatedLotId
		,i1.strItemNo AS strPreviousItem
		,clsl1.strSubLocationName AS strSourceSubLocation
		,sl1.strName AS strSourceStorageLocation
		,ls1.strSecondaryStatus AS strNewStatus
		,ls.strSecondaryStatus AS strOldStatus
		,'' AS strNewLotAlias
		,'' AS strOldLotAlias
		,iad.dtmNewExpiryDate AS dtmNewExpiryDate
		,iad.dtmExpiryDate AS dtmOldExpiryDate
		,'' AS strNewVendorNo
		,'' AS strOldVendorNo
		,'' AS strNewVendorLotNo
		,'' AS strOldVendorLotNo
		,'' AS strNotes
		,us.strUserName AS strUser
	FROM tblICInventoryAdjustment ia
	LEFT JOIN tblICInventoryAdjustmentDetail iad ON ia.intInventoryAdjustmentId = iad.intInventoryAdjustmentId
	LEFT JOIN tblICLot l ON l.intLotId = iad.intLotId
	LEFT JOIN tblICItem i ON i.intItemId = l.intItemId
	LEFT JOIN tblICItemUOM ium ON ium.intItemUOMId = l.intItemUOMId
	LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = ium.intUnitMeasureId
	LEFT JOIN tblICItemUOM ium1 ON ium1.intItemUOMId = IsNULL(l.intWeightUOMId, l.intItemUOMId)
	LEFT JOIN tblICUnitMeasure um1 ON um1.intUnitMeasureId = ium1.intUnitMeasureId
	LEFT JOIN tblICCategory c ON c.intCategoryId = i.intCategoryId
	LEFT JOIN tblSMCompanyLocationSubLocation clsl ON clsl.intCompanyLocationSubLocationId = l.intSubLocationId
	LEFT JOIN tblICStorageLocation sl ON sl.intStorageLocationId = l.intStorageLocationId
	LEFT JOIN tblICItem i1 ON i1.intItemId = iad.intNewItemId
	LEFT JOIN tblSMCompanyLocationSubLocation clsl1 ON clsl1.intCompanyLocationSubLocationId = iad.intSubLocationId
	LEFT JOIN tblICStorageLocation sl1 ON sl1.intStorageLocationId = iad.intStorageLocationId
	LEFT JOIN tblICLotStatus ls ON ls.intLotStatusId = iad.intLotStatusId
	LEFT JOIN tblICLotStatus ls1 ON ls1.intLotStatusId = iad.intNewLotStatusId
	LEFT JOIN tblSMUserSecurity us ON us.intEntityUserSecurityId = ia.intEntityId
	WHERE l.intLotId = @intLotId
		AND (
			(
				iad.dtmNewExpiryDate IS NOT NULL
				AND iad.dtmExpiryDate IS NOT NULL
				)
			OR (
				iad.intLotStatusId IS NOT NULL
				AND iad.intNewLotStatusId IS NOT NULL
				)
			)
	ORDER BY 1

	UPDATE #tempLotHistory
	SET @dblPrimaryQty = dblQuantity = CASE 
			WHEN (
					((@dblPrimaryQty + dblTransactionQty) < 0.01)
					AND ((@dblPrimaryQty + dblTransactionQty) > 0)
					)
				THEN 0
			ELSE @dblPrimaryQty + dblTransactionQty
			END
		,@dblPrimaryWeight = dblWeight = CASE 
			WHEN (
					((@dblPrimaryWeight + dblTransactionWeight) < 0.01)
					AND ((@dblPrimaryWeight + dblTransactionWeight) > 0)
					)
				THEN 0
			ELSE @dblPrimaryWeight + dblTransactionWeight
			END

	SELECT *
	FROM #tempLotHistory
END
