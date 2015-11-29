CREATE PROCEDURE uspMFGetLotHistory 
		@intLotId INT
AS
BEGIN
	SELECT *
	FROM (
		SELECT ilt.dtmCreated AS dtmDateTime, 
			   l.strLotNumber AS strLotNo, 
			   i.strItemNo AS strItem, 
			   i.strDescription AS strDescription, 
			   clsl.strSubLocationName AS strSubLocation, 
			   sl.strName AS strStorageLocation, 
			   itt.strName AS strTransaction, 
			   iad.dblWeight AS dblQuantity, 
			   ilt.dblQty AS dblTransactionQty, 
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
		FROM tblICLot l
		LEFT JOIN tblICInventoryTransaction ilt ON ilt.intLotId = l.intLotId
		LEFT JOIN tblICInventoryTransactionType itt ON itt.intTransactionTypeId = ilt.intTransactionTypeId
		LEFT JOIN tblICInventoryAdjustmentDetail iad ON ilt.intTransactionDetailId = iad.intInventoryAdjustmentDetailId
		LEFT JOIN tblICItem i ON i.intItemId = l.intItemId
		LEFT JOIN tblICItemUOM iu ON iu.intItemUOMId = iad.intItemUOMId
		LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = iu.intItemUOMId
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
			   iad.dblWeight AS dblQuantity, 
			   ISNULL(dblNewQuantity - dblQuantity, 0) AS dblTransactionQty, 
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
		LEFT JOIN tblSMCompanyLocationSubLocation clsl ON clsl.intCompanyLocationSubLocationId = l.intSubLocationId
		LEFT JOIN tblICStorageLocation sl ON sl.intStorageLocationId = l.intStorageLocationId
		LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = iad.intItemUOMId
		LEFT JOIN tblICItem i1 ON i1.intItemId = iad.intItemId
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
		) lotHistorytbl
	ORDER BY dtmDateTime
END