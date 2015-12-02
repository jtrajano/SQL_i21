CREATE PROCEDURE uspMFGetLotHistory 
		@intLotId INT
AS
BEGIN

IF OBJECT_ID('tempdb..#tempLotHistory') IS NOT NULL
DROP TABLE  #tempLotHistory

 DECLARE @dblPrimaryQty NUMERIC(18,6)
 SET @dblPrimaryQty=0     

		SELECT ilt.dtmCreated AS dtmDateTime, 
			   l.strLotNumber AS strLotNo, 
			   i.strItemNo AS strItem, 
			   i.strDescription AS strDescription, 
			   clsl.strSubLocationName AS strSubLocation, 
			   sl.strName AS strStorageLocation, 
			   itt.strName AS strTransaction, 
			   CONVERT(NUMERIC(18,6),CASE WHEN iu.intItemUOMId = ilt.intItemUOMId THEN ilt.dblQty ELSE ilt.dblQty/ilt.dblUOMQty END) AS dblTransactionQty,
			   CONVERT(NUMERIC(18,6),0.0) AS dblQuantity,
			   um.strUnitMeasure AS strUOM, 
			   iad.strNewLotNumber AS strRelatedLotId, 
			   '' AS strPreviousItem, 
			   '' AS strSourceSubLocation, 
			   NULL AS strSourceStorageLocation, 
			   NULL AS strNewStatus, 
			   NULL AS strOldStatus, 
			   NULL AS strNewLotAlias, 
			   NULL AS strOldLotAlias, 
			   iad.dtmNewExpiryDate AS dtmNewExpiryDate, 
			   iad.dtmExpiryDate AS dtmOldExpiryDate, 
			   '' AS strNewVendorNo, 
			   '' AS strOldVendorNo, 
			   '' AS strNewVendorLotNo, 
			   '' AS strOldVendorLotNo, 
			   '' AS strNotes, 
			   us.strUserName AS strUser
		INTO #tempLotHistory
		FROM tblICLot l
		LEFT JOIN tblICInventoryTransaction ilt ON ilt.intLotId = l.intLotId
		LEFT JOIN tblICInventoryTransactionType itt ON itt.intTransactionTypeId = ilt.intTransactionTypeId
		LEFT JOIN tblICInventoryAdjustmentDetail iad ON ilt.intTransactionDetailId = iad.intInventoryAdjustmentDetailId
		LEFT JOIN tblICItem i ON i.intItemId = l.intItemId
		LEFT JOIN tblICItemUOM iu ON iu.intItemId = i.intItemId AND iu.ysnStockUnit=1
		LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = iu.intUnitMeasureId
		LEFT JOIN tblSMCompanyLocationSubLocation clsl ON clsl.intCompanyLocationSubLocationId = l.intSubLocationId
		LEFT JOIN tblICStorageLocation sl ON sl.intStorageLocationId = l.intStorageLocationId
		LEFT JOIN tblSMUserSecurity us ON us.[intEntityUserSecurityId] = ilt.intCreatedEntityId
		WHERE l.intLotId = @intLotId
		
		UNION ALL
		
		SELECT ia.dtmPostedDate, 
			   l.strLotNumber AS strLotNo, 
			   i.strItemNo AS strItemNo, 
			   i.strDescription AS strDescription, 
			   clsl.strSubLocationName AS strSubLocation, 
			   sl.strName AS strStorageLocation, 
			   CASE 
				WHEN iad.intLotStatusId <> iad.intNewLotStatusId
					THEN 'Inventory Adjustment - Lot Status Change'
				WHEN iad.dtmExpiryDate <> iad.dtmNewExpiryDate
					THEN 'Inventory Adjustment - Expiry Date Change'
				ELSE ''
				END AS strTransaction, 
			   CONVERT(NUMERIC(18,6),ISNULL(CASE WHEN ium.intItemUOMId = iad.intItemUOMId THEN iad.dblWeight  ELSE iad.dblWeight/iad.dblWeightPerQty END,0)) AS dblTransactionQty,
			   CONVERT(NUMERIC(18,6),0.0) AS dblQuantity,    
			   um.strUnitMeasure AS strUOM, 
			   iad.strNewLotNumber AS strRelatedLotId, 
			   i1.strItemNo AS strPreviousItem, 
			   clsl1.strSubLocationName AS strSourceSubLocation, 
			   sl1.strName AS strSourceStorageLocation, 
			   ls1.strSecondaryStatus AS strNewStatus, 
			   ls.strSecondaryStatus AS strOldStatus, 
			   '' AS strNewLotAlias, 
			   '' AS strOldLotAlias, 
			   iad.dtmNewExpiryDate AS dtmNewExpiryDate, 
			   iad.dtmExpiryDate AS dtmOldExpiryDate, 
			   '' AS strNewVendorNo, 
			   '' AS strOldVendorNo, 
			   '' AS strNewVendorLotNo, 
			   '' AS strOldVendorLotNo, 
			   '' AS strNotes, 
			   us.strUserName AS strUser
		FROM tblICInventoryAdjustment ia
		LEFT JOIN tblICInventoryAdjustmentDetail iad ON ia.intInventoryAdjustmentId = iad.intInventoryAdjustmentId
		LEFT JOIN tblICLot l ON l.intLotId = iad.intLotId
		LEFT JOIN tblICItem i ON i.intItemId = l.intItemId
		LEFT JOIN tblICItemUOM ium ON ium.intItemId = i.intItemId AND ium.ysnStockUnit=1
		LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = ium.intUnitMeasureId
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
	SET @dblPrimaryQty=dblQuantity = @dblPrimaryQty + dblTransactionQty

	SELECT * FROM #tempLotHistory
END