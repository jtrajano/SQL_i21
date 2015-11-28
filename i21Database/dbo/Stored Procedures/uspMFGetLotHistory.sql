CREATE PROCEDURE uspMFGetLotHistory 
	@intLotId INT
AS
BEGIN
	SELECT *
	FROM (
		SELECT	ilt.dtmDate AS dtmDateTime, 
				l.strLotNumber AS strLotNo, 
				i.strItemNo AS strItem, 
				i.strDescription AS strDescription, 
				clsl.strSubLocationName AS strSubLocation, 
				sl.strName AS strStorageLocation, 
				itt.strName AS strTransaction, 
				l.dblQty AS dblQuantity, 
				ilt.dblQty AS dblTransactionQty, 
				um.strUnitMeasure AS strUOM, 
				'' AS strRelatedLotId, 
				'' AS strPreviousItem, 
				'' AS strSourceSubLocation, 
				'' AS strSourceStorageLocation, 
				'' AS strNewStatus, 
				'' AS strOldStatus, 
				'' AS strNewLotAlias, 
				'' AS strOldLotAlias, 
				NULL AS dtmNewExpiryDate, 
				NULL AS dtmOldExpiryDate, 
				'' AS strNewVendorNo, 
				'' AS strOldVendorNo, 
				'' AS strNewVendorLotNo, 
				'' AS strOldVendorLotNo, 
				'' AS strNotes, 
				us.strUserName AS strUser
		FROM tblICLot l
		LEFT JOIN tblICInventoryLotTransaction ilt ON ilt.intLotId = l.intLotId
		LEFT JOIN tblICInventoryTransactionType itt ON itt.intTransactionTypeId = ilt.intTransactionTypeId
		LEFT JOIN tblICItem i ON i.intItemId = l.intItemId
		LEFT JOIN tblSMCompanyLocationSubLocation clsl ON clsl.intCompanyLocationSubLocationId = l.intSubLocationId
		LEFT JOIN tblICStorageLocation sl ON sl.intStorageLocationId = l.intStorageLocationId
		LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = ilt.intItemUOMId
		LEFT JOIN tblSMUserSecurity us ON us.[intEntityUserSecurityId] = ilt.intCreatedEntityId
		WHERE l.intLotId = @intLotId
		
		UNION
		
		SELECT	ia.dtmAdjustmentDate, 
				l.strLotNumber AS strLotNo, 
				i.strItemNo AS strItemNo, 
				i.strDescription AS strDescription, 
				clsl.strSubLocationName AS strSubLocation, 
				sl.strName AS strStorageLocation, 
				CASE WHEN iad.intLotStatusId <> iad.intNewLotStatusId THEN 'Inventory Adjustment - Lot Status Change'
					 WHEN iad.dtmExpiryDate <> iad.dtmNewExpiryDate THEN 'Inventory Adjustment - Expiry Date Change'
					 ELSE '' END  AS strTransaction, 
				l.dblQty AS dblQuantity, 
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
		) lotHistorytbl
	ORDER BY dtmDateTime DESC
END