CREATE PROCEDURE uspMFGetLotHistory @intLotId INT
AS
BEGIN
	IF OBJECT_ID('tempdb..#tempLotHistory') IS NOT NULL
		DROP TABLE #tempLotHistory

	IF OBJECT_ID('tempdb..#tempLotHistoryFinal') IS NOT NULL
		DROP TABLE #tempLotHistoryFinal

	CREATE TABLE #tempLotHistory (
		dtmDateTime DATETIME
		,strLotNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strItem NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strDescription NVARCHAR(250) COLLATE Latin1_General_CI_AS
		,strCategoryCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strSubLocation NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strStorageLocation NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CS_AS
		,strTransaction NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,dblWeight NUMERIC(38, 20)
		,dblTransactionWeight NUMERIC(38, 20)
		,strTransactionWeightUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,dblQuantity NUMERIC(38, 20)
		,dblTransactionQty NUMERIC(38, 20)
		,strTransactionQtyUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strRelatedLotId NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strPreviousItem NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strSourceSubLocation NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strSourceStorageLocation NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strNewStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strOldStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strNewLotAlias NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strOldLotAlias NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,dtmNewExpiryDate DATETIME
		,dtmOldExpiryDate DATETIME
		,strNewVendorNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strOldVendorNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strNewVendorLotNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strOldVendorLotNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strNotes NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strUser NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strBatchId NVARCHAR(50) COLLATE Latin1_General_CI_AS
		)

	DECLARE @dblPrimaryQty NUMERIC(38, 20)
		,@dblPrimaryWeight NUMERIC(38, 20)

	SELECT @dblPrimaryQty = 0
		,@dblPrimaryWeight = 0

	INSERT INTO #tempLotHistory
	SELECT CASE 
			WHEN Convert(DATETIME, Convert(CHAR, dtmDate, 101)) = Convert(DATETIME, Convert(CHAR, ilt.dtmCreated, 101))
				THEN ilt.dtmCreated
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
			WHEN ilt.intTransactionTypeId = 8
				THEN ilt.strTransactionId
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
		,IA.strDescription  AS strNotes
		,us.strUserName AS strUser
		,ilt.strBatchId
	FROM tblICLot l
	LEFT JOIN tblICInventoryTransaction ilt ON ilt.intLotId = l.intLotId
	LEFT JOIN tblICInventoryTransactionType itt ON itt.intTransactionTypeId = ilt.intTransactionTypeId
	LEFT JOIN tblICInventoryAdjustmentDetail iad ON ilt.intTransactionDetailId = iad.intInventoryAdjustmentDetailId
	Left JOIN tblICInventoryAdjustment IA on IA.intInventoryAdjustmentId =iad.intInventoryAdjustmentId 
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
	LEFT JOIN tblSMUserSecurity us ON us.[intEntityId] = ilt.intCreatedEntityId
	LEFT JOIN dbo.tblICLot L1 ON L1.intLotId = iad.intLotId
	LEFT JOIN tblICItem i1 ON i1.intItemId = iad.intNewItemId
	WHERE l.intLotId = @intLotId

	DECLARE @ysnLotHistoryByStorageLocation BIT

	SELECT @ysnLotHistoryByStorageLocation = ysnLotHistoryByStorageLocation
	FROM dbo.tblMFCompanyPreference

	DECLARE @intSplitFromLotId INT
		,@intLotId1 INT
		,@intInventoryTransactionId INT
		,@intPrevLotId INT

	SELECT @intSplitFromLotId = NULL

	SELECT @intSplitFromLotId = intSplitFromLotId
	FROM dbo.tblICLot l
	WHERE l.intLotId = @intLotId

	SELECT @intPrevLotId = @intLotId

	WHILE @intSplitFromLotId IS NOT NULL
		AND @ysnLotHistoryByStorageLocation = 0
	BEGIN
		SELECT @intLotId1 = NULL

		SELECT @intLotId1 = @intSplitFromLotId

		SELECT @intInventoryTransactionId = NULL

		SELECT @intInventoryTransactionId = MIN(intInventoryTransactionId)
		FROM dbo.tblICInventoryTransaction
		WHERE intLotId = @intPrevLotId

		INSERT INTO #tempLotHistory
		SELECT CASE 
				WHEN Convert(DATETIME, Convert(CHAR, dtmDate, 101)) = Convert(DATETIME, Convert(CHAR, ilt.dtmCreated, 101))
					THEN ilt.dtmCreated
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
				WHEN ilt.intTransactionTypeId = 8
					THEN ilt.strTransactionId
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
			,IA.strDescription AS strNotes
			,us.strUserName AS strUser
			,ilt.strBatchId
		FROM tblICLot l
		JOIN tblICInventoryTransaction ilt ON ilt.intLotId = l.intLotId
		LEFT JOIN tblICInventoryTransactionType itt ON itt.intTransactionTypeId = ilt.intTransactionTypeId
		LEFT JOIN tblICInventoryAdjustmentDetail iad ON ilt.intTransactionDetailId = iad.intInventoryAdjustmentDetailId
		Left JOIN tblICInventoryAdjustment IA on IA.intInventoryAdjustmentId =iad.intInventoryAdjustmentId 
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
		LEFT JOIN tblSMUserSecurity us ON us.[intEntityId] = ilt.intCreatedEntityId
		LEFT JOIN dbo.tblICLot L1 ON L1.intLotId = iad.intLotId
		LEFT JOIN tblICItem i1 ON i1.intItemId = iad.intNewItemId
		WHERE l.intLotId = @intLotId1
			AND ilt.intInventoryTransactionId < @intInventoryTransactionId

		SELECT @intSplitFromLotId = NULL

		SELECT @intPrevLotId = @intLotId1

		SELECT @intSplitFromLotId = intSplitFromLotId
		FROM dbo.tblICLot l
		WHERE l.intLotId = @intLotId1
	END

	INSERT INTO #tempLotHistory
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
		,IA.strDescription AS strNotes
		,us.strUserName AS strUser
		,ia.strAdjustmentNo AS strBatchId
	FROM tblICInventoryAdjustment ia
	LEFT JOIN tblICInventoryAdjustmentDetail iad ON ia.intInventoryAdjustmentId = iad.intInventoryAdjustmentId
	Left JOIN tblICInventoryAdjustment IA on IA.intInventoryAdjustmentId =iad.intInventoryAdjustmentId 
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
	LEFT JOIN tblSMUserSecurity us ON us.[intEntityId] = ia.intEntityId
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

	SELECT *
	INTO #tempLotHistoryFinal
	FROM #tempLotHistory
	ORDER BY dtmDateTime

	DECLARE @strStorageLocation NVARCHAR(50)

	SELECT @strStorageLocation = ''

	IF @ysnLotHistoryByStorageLocation = 1
	BEGIN
		UPDATE #tempLotHistoryFinal
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
	END
	ELSE
	BEGIN
		UPDATE #tempLotHistoryFinal
		SET @dblPrimaryQty = dblQuantity = CASE 
				WHEN (
						((@dblPrimaryQty + dblTransactionQty) < 0.01)
						AND ((@dblPrimaryQty + dblTransactionQty) > 0)
						)
					THEN 0
				ELSE (
						CASE 
							WHEN @strStorageLocation = strStorageLocation
								THEN @dblPrimaryQty + dblTransactionQty
							ELSE dblTransactionQty
							END
						)
				END
			,@dblPrimaryWeight = dblWeight = CASE 
				WHEN (
						((@dblPrimaryWeight + dblTransactionWeight) < 0.01)
						AND ((@dblPrimaryWeight + dblTransactionWeight) > 0)
						)
					THEN 0
				ELSE (
						CASE 
							WHEN @strStorageLocation = strStorageLocation
								THEN @dblPrimaryWeight + dblTransactionWeight
							ELSE dblTransactionWeight
							END
						)
				END
			,@strStorageLocation = strStorageLocation = strStorageLocation
	END

	SELECT *
	FROM #tempLotHistoryFinal Order by dtmDateTime
END
