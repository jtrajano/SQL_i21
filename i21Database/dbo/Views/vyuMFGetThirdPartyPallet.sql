CREATE VIEW vyuMFGetThirdPartyPallet
AS
SELECT L.dtmDateCreated
	,US.strUserName
	,L.strLotNumber
	,L.strLotAlias
	,I.strItemNo
	,I.strDescription AS strItemDescription
	,C.strCategoryCode AS strCategory
	,E.strName AS strOwner
	,L.dblQty
	,UM.strUnitMeasure AS strQtyUOM
	,L.dblWeightPerQty
	,CASE 
		WHEN L.intWeightUOMId IS NULL
			THEN L.dblQty
		ELSE L.dblWeight
		END AS dblWeight
	,UM1.strUnitMeasure AS strWeightUOM
	,SL.strName AS strStorageLocationName
	,LS.strSecondaryStatus AS strLotStatus
	,L.dtmExpiryDate
	,L.dtmManufacturedDate
	,L.dblLastCost
	,PL.strParentLotNumber
	,L.strBOLNo
	,L.strVessel
	,L.strReceiptNumber
	,L.strMarkings
	,L.strNotes
	,L.strVendorLotNo
	,CL.strLocationName AS strCompanyLocationName
	,CASE 
		WHEN WP.intSpecialPalletLotId IS NULL
			THEN 'Available'
		ELSE (
				CASE 
					WHEN IL.intLotId IS NULL
						THEN 'Unavailable'
					ELSE 'Shipped out'
					END
				)
		END AS strPalletStatus
	,L1.strLotNumber AS strUsedIn
FROM dbo.tblICLot AS L
JOIN dbo.tblICItem AS I ON I.intItemId = L.intItemId
	AND L.dblQty > 0
JOIN dbo.tblICCategory AS C ON C.intCategoryId = I.intCategoryId
JOIN dbo.tblICLotStatus AS LS ON LS.intLotStatusId = L.intLotStatusId
JOIN dbo.tblICParentLot AS PL ON PL.intParentLotId = L.intParentLotId
JOIN dbo.tblICItemUOM AS IU ON IU.intItemUOMId = L.intItemUOMId
JOIN dbo.tblICUnitMeasure AS UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
JOIN dbo.tblSMCompanyLocation AS CL ON CL.intCompanyLocationId = L.intLocationId
LEFT JOIN dbo.tblICStorageLocation AS SL ON SL.intStorageLocationId = L.intStorageLocationId
LEFT JOIN dbo.tblSMUserSecurity AS US ON US.intEntityUserSecurityId = L.intCreatedEntityId
LEFT JOIN dbo.tblICItemUOM AS IU1 ON IU1.intItemUOMId = ISNULL(L.intWeightUOMId, L.intItemUOMId)
LEFT JOIN dbo.tblICUnitMeasure AS UM1 ON UM1.intUnitMeasureId = IU1.intUnitMeasureId
LEFT JOIN dbo.tblMFLotInventory AS LI ON LI.intLotId = L.intLotId
LEFT JOIN dbo.tblICItemOwner AS O ON O.intItemOwnerId = LI.intItemOwnerId
LEFT JOIN dbo.tblEMEntity AS E ON E.intEntityId = O.intOwnerId
LEFT JOIN dbo.tblMFWorkOrderProducedLot WP ON WP.intSpecialPalletLotId = L.intLotId
	AND WP.ysnProductionReversed = 0
LEFT JOIN dbo.tblICLot AS L1 ON L1.intLotId = WP.intLotId
LEFT JOIN dbo.tblICInventoryShipmentItemLot IL ON IL.intLotId = L1.intLotId
WHERE I.intItemId IN (
		SELECT strAttributeValue
		FROM tblMFManufacturingProcessAttribute
		WHERE intAttributeId = 88
			AND strAttributeValue <> ''
		)

UNION

SELECT L.dtmDateCreated
	,US.strUserName
	,L.strLotNumber
	,L.strLotAlias
	,I.strItemNo
	,I.strDescription AS strItemDescription
	,C.strCategoryCode AS strCategory
	,E.strName AS strOwner
	,L.dblQty
	,UM.strUnitMeasure AS strQtyUOM
	,L.dblWeightPerQty
	,CASE 
		WHEN L.intWeightUOMId IS NULL
			THEN L.dblQty
		ELSE L.dblWeight
		END AS dblWeight
	,UM1.strUnitMeasure AS strWeightUOM
	,SL.strName AS strStorageLocationName
	,LS.strSecondaryStatus AS strLotStatus
	,L.dtmExpiryDate
	,L.dtmManufacturedDate
	,L.dblLastCost
	,PL.strParentLotNumber
	,L.strBOLNo
	,L.strVessel
	,L.strReceiptNumber
	,L.strMarkings
	,L.strNotes
	,L.strVendorLotNo
	,CL.strLocationName AS strCompanyLocationName
	,CASE 
		WHEN WP.intSpecialPalletLotId IS NULL
			THEN 'Available'
		ELSE (
				CASE 
					WHEN IL.intLotId IS NULL
						THEN 'Not Available'
					ELSE 'Shipped out'
					END
				)
		END AS strPalletStatus
	,L1.strLotNumber AS strUsedIn
FROM dbo.tblICLot AS L
JOIN dbo.tblICItem AS I ON I.intItemId = L.intItemId
	AND L.dblQty = 0
JOIN dbo.tblICCategory AS C ON C.intCategoryId = I.intCategoryId
JOIN dbo.tblICLotStatus AS LS ON LS.intLotStatusId = L.intLotStatusId
JOIN dbo.tblICParentLot AS PL ON PL.intParentLotId = L.intParentLotId
JOIN dbo.tblICItemUOM AS IU ON IU.intItemUOMId = L.intItemUOMId
JOIN dbo.tblICUnitMeasure AS UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
JOIN dbo.tblSMCompanyLocation AS CL ON CL.intCompanyLocationId = L.intLocationId
LEFT JOIN dbo.tblICStorageLocation AS SL ON SL.intStorageLocationId = L.intStorageLocationId
LEFT JOIN dbo.tblSMUserSecurity AS US ON US.intEntityUserSecurityId = L.intCreatedEntityId
LEFT JOIN dbo.tblICItemUOM AS IU1 ON IU1.intItemUOMId = ISNULL(L.intWeightUOMId, L.intItemUOMId)
LEFT JOIN dbo.tblICUnitMeasure AS UM1 ON UM1.intUnitMeasureId = IU1.intUnitMeasureId
LEFT JOIN dbo.tblMFLotInventory AS LI ON LI.intLotId = L.intLotId
LEFT JOIN dbo.tblICItemOwner AS O ON O.intItemOwnerId = LI.intItemOwnerId
LEFT JOIN dbo.tblEMEntity AS E ON E.intEntityId = O.intOwnerId
JOIN dbo.tblMFWorkOrderProducedLot WP ON WP.intSpecialPalletLotId = L.intLotId
	AND WP.ysnProductionReversed = 0
LEFT JOIN dbo.tblICLot AS L1 ON L1.intLotId = WP.intLotId
LEFT JOIN dbo.tblICInventoryShipmentItemLot IL ON IL.intLotId = L1.intLotId
WHERE I.intItemId IN (
		SELECT strAttributeValue
		FROM tblMFManufacturingProcessAttribute
		WHERE intAttributeId = 88
			AND strAttributeValue <> ''
		)
