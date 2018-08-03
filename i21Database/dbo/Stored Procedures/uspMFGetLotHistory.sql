CREATE PROCEDURE uspMFGetLotHistory @intLotId INT
AS
BEGIN
	IF OBJECT_ID('tempdb..#tempLotHistory') IS NOT NULL
		DROP TABLE #tempLotHistory

	IF OBJECT_ID('tempdb..#tempLotHistoryFinal') IS NOT NULL
		DROP TABLE #tempLotHistoryFinal

	CREATE TABLE #tempLotHistory (
		intRecordId INT identity(1, 1) PRIMARY KEY CLUSTERED
		,dtmDateTime DATETIME
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
		,strNotes NVARCHAR(1000) COLLATE Latin1_General_CI_AS
		,strUser NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strBatchId NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,dtmTransactionDate DATETIME
		,strOldOwnerName NVARCHAR(100)
		,strNewOwnerName NVARCHAR(100)
		)

	CREATE TABLE #tempLotHistoryFinal (
		intRecordId INT identity(1, 1) PRIMARY KEY CLUSTERED
		,dtmDateTime DATETIME
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
		,strNotes NVARCHAR(1000) COLLATE Latin1_General_CI_AS
		,strUser NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strBatchId NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,dtmTransactionDate DATETIME
		,strOldOwnerName NVARCHAR(100)
		,strNewOwnerName NVARCHAR(100)
		)

	DECLARE @dblPrimaryQty NUMERIC(38, 20)
		,@dblPrimaryWeight NUMERIC(38, 20)

	SELECT @dblPrimaryQty = 0
		,@dblPrimaryWeight = 0

	INSERT INTO #tempLotHistory
	SELECT ilt.dtmCreated AS dtmDateTime
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
		,CONVERT(NUMERIC(38, 20), (Case When ilt.intItemUOMId=IsNULL(l.intWeightUOMId, l.intItemUOMId) then  ilt.dblQty else ilt.dblQty*l.dblWeightPerQty End)) AS dblTransactionWeight
		,uwm.strUnitMeasure AS strTransactionWeightUOM
		,CONVERT(NUMERIC(38, 20), 0.0) AS dblQuantity
		,CONVERT(NUMERIC(38, 20), (Case When ilt.intItemUOMId=IsNULL(l.intWeightUOMId, l.intItemUOMId) then  ilt.dblQty / (CASE 
				WHEN l.dblWeightPerQty = 0
					THEN 1
				ELSE l.dblWeightPerQty
				END) Else ilt.dblQty End)) AS dblTransactionQty
		,um.strUnitMeasure AS strTransactionQtyUOM
		,CASE 
			WHEN ilt.intTransactionTypeId IN (
					4
					,5
					,8
					,9
					,23
					)
				THEN ilt.strTransactionId
			WHEN ilt.intTransactionTypeId IN (
					17
					,19
					,20
					)
				THEN (
						CASE 
							WHEN iad.intNewLotId = @intLotId
								THEN L1.strLotNumber
							ELSE iad.strNewLotNumber
							END
						)
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
		,ilt.dtmDate AS dtmTransactionDate
		,NULL AS strOldOwnerName
		,NULL AS strNewOwnerName
	FROM tblICLot l
	JOIN tblICInventoryTransaction ilt ON ilt.intLotId = l.intLotId
	JOIN tblICInventoryTransactionType itt ON itt.intTransactionTypeId = ilt.intTransactionTypeId
	LEFT JOIN tblICInventoryAdjustmentDetail iad ON ilt.intTransactionDetailId = iad.intInventoryAdjustmentDetailId
	LEFT JOIN tblICInventoryAdjustment IA ON IA.intInventoryAdjustmentId = iad.intInventoryAdjustmentId
	JOIN tblICItem i ON i.intItemId = ISNULL((
				CASE 
					WHEN ilt.intTransactionTypeId = 15
						THEN iad.intItemId
					ELSE ilt.intItemId
					END
				), ilt.intItemId)
	JOIN tblICItemUOM iu ON iu.intItemUOMId = l.intItemUOMId
	JOIN tblICUnitMeasure um ON um.intUnitMeasureId = iu.intUnitMeasureId
	JOIN tblICItemUOM iwu ON iwu.intItemUOMId = IsNULL(l.intWeightUOMId, l.intItemUOMId)
	JOIN tblICUnitMeasure uwm ON uwm.intUnitMeasureId = iwu.intUnitMeasureId
	JOIN tblICCategory c ON c.intCategoryId = i.intCategoryId
	JOIN tblSMCompanyLocationSubLocation clsl ON clsl.intCompanyLocationSubLocationId = ilt.intSubLocationId
	LEFT JOIN tblICStorageLocation sl ON sl.intStorageLocationId = ilt.intStorageLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation clsl1 ON clsl1.intCompanyLocationSubLocationId = iad.intNewSubLocationId
	LEFT JOIN tblICStorageLocation sl1 ON sl1.intStorageLocationId = iad.intNewStorageLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation clsl2 ON clsl2.intCompanyLocationSubLocationId = iad.intSubLocationId
	LEFT JOIN tblICStorageLocation sl2 ON sl2.intStorageLocationId = iad.intStorageLocationId
	LEFT JOIN tblSMUserSecurity us ON us.[intEntityId] = ilt.intCreatedEntityId
	LEFT JOIN dbo.tblICLot L1 ON L1.intLotId = iad.intLotId
	LEFT JOIN tblICItem i1 ON i1.intItemId = iad.intNewItemId
	WHERE l.intLotId = @intLotId

	INSERT INTO #tempLotHistory
	SELECT ilt.dtmCreated AS dtmDateTime
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
			WHEN ilt.intTransactionTypeId IN (
					4
					,5
					,8
					,9
					,23
					)
				THEN ilt.strTransactionId
			WHEN ilt.intTransactionTypeId IN (
					17
					,19
					,20
					)
				THEN (
						CASE 
							WHEN iad.intNewLotId = @intLotId
								THEN L1.strLotNumber
							ELSE iad.strNewLotNumber
							END
						)
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
		,ilt.dtmDate AS dtmTransactionDate
		,NULL AS strOldOwnerName
		,NULL AS strNewOwnerName
	FROM tblICLot l
	JOIN tblICInventoryTransactionStorage ilt ON ilt.intLotId = l.intLotId
	JOIN tblICInventoryTransactionType itt ON itt.intTransactionTypeId = ilt.intTransactionTypeId
	LEFT JOIN tblICInventoryAdjustmentDetail iad ON ilt.intTransactionDetailId = iad.intInventoryAdjustmentDetailId
	LEFT JOIN tblICInventoryAdjustment IA ON IA.intInventoryAdjustmentId = iad.intInventoryAdjustmentId
	JOIN tblICItem i ON i.intItemId = ISNULL((
				CASE 
					WHEN ilt.intTransactionTypeId = 15
						THEN iad.intItemId
					ELSE ilt.intItemId
					END
				), ilt.intItemId)
	JOIN tblICItemUOM iu ON iu.intItemUOMId = l.intItemUOMId
	JOIN tblICUnitMeasure um ON um.intUnitMeasureId = iu.intUnitMeasureId
	JOIN tblICItemUOM iwu ON iwu.intItemUOMId = IsNULL(l.intWeightUOMId, l.intItemUOMId)
	JOIN tblICUnitMeasure uwm ON uwm.intUnitMeasureId = iwu.intUnitMeasureId
	JOIN tblICCategory c ON c.intCategoryId = i.intCategoryId
	JOIN tblSMCompanyLocationSubLocation clsl ON clsl.intCompanyLocationSubLocationId = ilt.intSubLocationId
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
		AND @intPrevLotId > @intSplitFromLotId
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
			,CONVERT(NUMERIC(38, 20), (Case When ilt.intItemUOMId=IsNULL(l.intWeightUOMId, l.intItemUOMId) then  ilt.dblQty else ilt.dblQty*l.dblWeightPerQty End)) AS dblTransactionWeight
			,uwm.strUnitMeasure AS strTransactionWeightUOM
			,CONVERT(NUMERIC(38, 20), 0.0) AS dblQuantity
			,CONVERT(NUMERIC(38, 20), (Case When ilt.intItemUOMId=IsNULL(l.intWeightUOMId, l.intItemUOMId) then  ilt.dblQty / (CASE 
				WHEN l.dblWeightPerQty = 0
					THEN 1
				ELSE l.dblWeightPerQty
				END) Else ilt.dblQty End)) AS dblTransactionQty
			,um.strUnitMeasure AS strTransactionQtyUOM
			,CASE 
				WHEN ilt.intTransactionTypeId IN (
						4
						,5
						,8
						,9
						,23
						)
					THEN ilt.strTransactionId
				WHEN ilt.intTransactionTypeId IN (
						17
						,19
						,20
						)
					THEN (
							CASE 
								WHEN iad.intNewLotId = @intLotId
									THEN L1.strLotNumber
								ELSE iad.strNewLotNumber
								END
							)
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
			,ilt.dtmDate AS dtmTransactionDate
			,NULL AS strOldOwnerName
			,NULL AS strNewOwnerName
		FROM tblICLot l
		JOIN tblICInventoryTransaction ilt ON ilt.intLotId = l.intLotId
		JOIN tblICInventoryTransactionType itt ON itt.intTransactionTypeId = ilt.intTransactionTypeId
		LEFT JOIN tblICInventoryAdjustmentDetail iad ON ilt.intTransactionDetailId = iad.intInventoryAdjustmentDetailId
		LEFT JOIN tblICInventoryAdjustment IA ON IA.intInventoryAdjustmentId = iad.intInventoryAdjustmentId
		JOIN tblICItem i ON i.intItemId = ISNULL((
					CASE 
						WHEN ilt.intTransactionTypeId = 15
							THEN iad.intItemId
						ELSE ilt.intItemId
						END
					), ilt.intItemId)
		JOIN tblICItemUOM iu ON iu.intItemUOMId = l.intItemUOMId
		JOIN tblICUnitMeasure um ON um.intUnitMeasureId = iu.intUnitMeasureId
		JOIN tblICItemUOM iwu ON iwu.intItemUOMId = IsNULL(l.intWeightUOMId, l.intItemUOMId)
		JOIN tblICUnitMeasure uwm ON uwm.intUnitMeasureId = iwu.intUnitMeasureId
		JOIN tblICCategory c ON c.intCategoryId = i.intCategoryId
		JOIN tblSMCompanyLocationSubLocation clsl ON clsl.intCompanyLocationSubLocationId = ilt.intSubLocationId
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
			WHEN ia.intAdjustmentType = 4
				THEN 'Inventory Adjustment - Lot Status Change'
			WHEN ia.intAdjustmentType = 6
				THEN 'Inventory Adjustment - Expiry Date Change'
			WHEN ia.intAdjustmentType = 9
				THEN 'Inventory Adjustment - Owner Change'
			ELSE ''
			END AS strTransaction
		,CONVERT(NUMERIC(38, 20), 0.0) AS dblWeight
		,CONVERT(NUMERIC(38, 20), ISNULL(iad.dblWeight, 0)) AS dblTransactionWeight
		,um1.strUnitMeasure AS strTransactionWeightUOM
		,CONVERT(NUMERIC(38, 20), 0.0) AS dblQuantity
		,CONVERT(NUMERIC(38, 20), ISNULL(iad.dblWeight / (
					CASE 
						WHEN l.dblWeightPerQty = 0
							THEN 1
						ELSE l.dblWeightPerQty
						END
					), 0)) AS dblTransactionQty
		,um.strUnitMeasure AS strTransactionQtyUOM
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
		,ia.strDescription AS strNotes
		,us.strUserName AS strUser
		,ia.strAdjustmentNo AS strBatchId
		,ia.dtmAdjustmentDate AS dtmTransactionDate
		,e1.strEntityNo + ' - ' + e1.strName AS strOldOwnerName
		,e2.strEntityNo + ' - ' + e2.strName AS strNewOwnerName
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
	LEFT JOIN tblSMUserSecurity us ON us.[intEntityId] = ia.intEntityId
	LEFT JOIN tblICItemOwner ito1 ON ito1.intItemOwnerId = iad.intItemOwnerId
	LEFT JOIN tblEMEntity e1 ON e1.intEntityId = ito1.intOwnerId
	LEFT JOIN tblICItemOwner ito2 ON ito2.intItemOwnerId = iad.intNewItemOwnerId
	LEFT JOIN tblEMEntity e2 ON e2.intEntityId = ito2.intOwnerId
	WHERE l.intLotId = @intLotId
		AND (
			ia.intAdjustmentType = 4
			OR ia.intAdjustmentType = 6
			OR ia.intAdjustmentType = 9
			)

	INSERT INTO #tempLotHistory
	SELECT IA.dtmDate
		,L.strLotNumber AS strLotNo
		,I.strItemNo AS strItemNo
		,I.strDescription AS strDescription
		,C.strCategoryCode
		,CLSL.strSubLocationName AS strSubLocation
		,SL.strName AS strStorageLocation
		,CASE 
			WHEN IA.intTransactionTypeId = 101
				THEN 'Inventory Adjustment - Lot Alias Change'
			WHEN IA.intTransactionTypeId = 102
				THEN 'Inventory Adjustment - Vendor Lot Number Change'
			END AS strTransaction
		,CONVERT(NUMERIC(38, 20), 0.0) AS dblWeight
		,CONVERT(NUMERIC(38, 20), ISNULL(IA.dblQty, 0)) * L.dblWeightPerQty AS dblTransactionWeight
		,UM1.strUnitMeasure AS strTransactionWeightUOM
		,CONVERT(NUMERIC(38, 20), 0.0) AS dblQuantity
		,CONVERT(NUMERIC(38, 20), ISNULL(IA.dblQty, 0)) AS dblTransactionQty
		,UM.strUnitMeasure AS strTransactionQtyUOM
		,NULL AS strRelatedLotId
		,NULL AS strPreviousItem
		,NULL AS strSourceSubLocation
		,NULL AS strSourceStorageLocation
		,NULL AS strNewStatus
		,NULL AS strOldStatus
		,IA.strNewLotAlias AS strNewLotAlias
		,IA.strOldLotAlias AS strOldLotAlias
		,NULL AS dtmNewExpiryDate
		,NULL AS dtmOldExpiryDate
		,'' AS strNewVendorNo
		,'' AS strOldVendorNo
		,IA.strNewVendorLotNumber AS strNewVendorLotNo
		,IA.strOldVendorLotNumber AS strOldVendorLotNo
		,isNULL(IA.strReason, '') + ' ' + isNULL(IA.strNote, '') AS strNotes
		,US.strUserName AS strUser
		,NULL AS strBatchId
		,IA.dtmDate AS dtmTransactionDate
		,NULL AS strOldOwnerName
		,NULL AS strNewOwnerName
	FROM tblMFInventoryAdjustment IA
	JOIN tblICLot L ON L.intLotId = IA.intSourceLotId
	JOIN tblICItem I ON I.intItemId = L.intItemId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = L.intItemUOMId
	JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	JOIN tblICItemUOM IU1 ON IU1.intItemUOMId = IsNULL(L.intWeightUOMId, L.intItemUOMId)
	JOIN tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = IU1.intUnitMeasureId
	JOIN tblICCategory C ON C.intCategoryId = I.intCategoryId
	JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = L.intSubLocationId
	LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
	LEFT JOIN tblSMUserSecurity US ON US.[intEntityId] = IA.intUserId
	WHERE L.intLotId = @intLotId
		AND (
			IA.intTransactionTypeId = 101
			OR IA.intTransactionTypeId = 102
			)

	INSERT INTO #tempLotHistoryFinal (
		dtmDateTime
		,strLotNo
		,strItem
		,strDescription
		,strCategoryCode
		,strSubLocation
		,strStorageLocation
		,strTransaction
		,dblWeight
		,dblTransactionWeight
		,strTransactionWeightUOM
		,dblQuantity
		,dblTransactionQty
		,strTransactionQtyUOM
		,strRelatedLotId
		,strPreviousItem
		,strSourceSubLocation
		,strSourceStorageLocation
		,strNewStatus
		,strOldStatus
		,strNewLotAlias
		,strOldLotAlias
		,dtmNewExpiryDate
		,dtmOldExpiryDate
		,strNewVendorNo
		,strOldVendorNo
		,strNewVendorLotNo
		,strOldVendorLotNo
		,strNotes
		,strUser
		,strBatchId
		,dtmTransactionDate
		,strOldOwnerName
		,strNewOwnerName
		)
	SELECT dtmDateTime
		,strLotNo
		,strItem
		,strDescription
		,strCategoryCode
		,strSubLocation
		,strStorageLocation
		,strTransaction
		,dblWeight
		,dblTransactionWeight
		,strTransactionWeightUOM
		,dblQuantity
		,dblTransactionQty
		,strTransactionQtyUOM
		,strRelatedLotId
		,strPreviousItem
		,strSourceSubLocation
		,strSourceStorageLocation
		,strNewStatus
		,strOldStatus
		,strNewLotAlias
		,strOldLotAlias
		,dtmNewExpiryDate
		,dtmOldExpiryDate
		,strNewVendorNo
		,strOldVendorNo
		,strNewVendorLotNo
		,strOldVendorLotNo
		,strNotes
		,strUser
		,strBatchId
		,dtmTransactionDate
		,strOldOwnerName
		,strNewOwnerName
	FROM #tempLotHistory LH
	ORDER BY LH.dtmDateTime ASC

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
	FROM #tempLotHistoryFinal
END
