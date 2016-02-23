﻿CREATE VIEW vyuMFInventoryView        
AS        
	SELECT	l.intLotId,         
			l.strLotNumber,         
			l.dblLastCost,         
			l.dtmDateCreated,        
			l.dtmExpiryDate,        
			l.strLotAlias,        
			l.dblQty,        
			l.dblWeightPerQty,        
			l.strVendorLotNo,        
          
			l.intItemId,
			l.intLocationId,
			l.intItemLocationId,
			l.intItemUOMId,
			l.intSubLocationId,
			l.intStorageLocationId,
			l.intLotStatusId,
			l.intParentLotId,
			l.intSplitFromLotId,
			CASE WHEN l.intWeightUOMId IS NULL THEN l.dblQty ELSE l.dblWeight END AS  dblWeight,
			l.intWeightUOMId,
			l.intOriginId,
			l.strBOLNo,
			l.strVessel,
			l.strReceiptNumber,
			l.strMarkings,
			l.strNotes,
			l.intEntityVendorId,
			l.strGarden,
			l.strContractNo,
			l.dtmManufacturedDate,
			l.ysnReleasedToWarehouse,
			l.ysnProduced,
			l.ysnStorage,
			l.intOwnershipType,
			l.intGradeId,
			l.intCreatedUserId,
			l.intConcurrencyId,

			i.strItemNo,         
			i.strDescription strItemDescription,         
			i.strType strItemType,         
          
			ic.strCategoryCode strItemCategory,         
			ic.intCategoryId,
			e.strName strVendor,
          
			ls.strPrimaryStatus,         
			ls.strSecondaryStatus,        
			us.strUserName,        
			um.strUnitMeasure AS strQtyUOM,
			clsl.strSubLocationName,        
			clsl.intCompanyLocationSubLocationId,      
			sl.strName strStorageLocationName,        
			cl.strLocationName strCompanyLocationName ,        
			cl.intCompanyLocationId,      
			um1.strUnitMeasure AS strWeightUOM,
			pl.strParentLotNumber,
			c1.strCustomerNumber strOwner,    
		    '' AS strCurrency,    
		    '' AS strCostUOM,    
		    0 AS intContainerId,    
		    '' AS strContainerNo,
			ISNULL((SELECT SUM(dblQty) FROM tblICStockReservation WHERE intLotId = l.intLotId),0) dblReservedQty,
			ISNULL(((SELECT SUM(dblQty) FROM tblICStockReservation WHERE intLotId = l.intLotId)/CASE WHEN ISNULL(l.dblWeightPerQty,0)=0 THEN 1 ELSE l.dblWeightPerQty END),0) dblReservedNoOfPacks,
			l.dblWeight-ISNULL((SELECT SUM(dblQty) FROM tblICStockReservation WHERE intLotId = l.intLotId),0) dblAvailableQty,
			((l.dblWeight-ISNULL((SELECT SUM(dblQty) FROM tblICStockReservation WHERE intLotId = l.intLotId),0))/CASE WHEN ISNULL(l.dblWeightPerQty,0)=0 THEN 1 ELSE l.dblWeightPerQty END) dblAvailableNoOfPacks,
			'' strReservedQtyUOM
	FROM tblICLot l
	LEFT JOIN tblICItem i ON i.intItemId = l.intItemId
	LEFT JOIN tblICCategory ic ON ic.intCategoryId = i.intCategoryId
	LEFT JOIN tblICLotStatus ls ON ls.intLotStatusId=l.intLotStatusId
	LEFT JOIN tblSMUserSecurity us ON us.[intEntityUserSecurityId] = l.intCreatedUserId
	LEFT JOIN tblICItemUOM ium ON ium.intItemUOMId = l.intItemUOMId
	LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = ium.intUnitMeasureId
	LEFT JOIN tblSMCompanyLocationSubLocation clsl ON clsl.intCompanyLocationSubLocationId = l.intSubLocationId
	LEFT JOIN tblICStorageLocation sl ON sl.intStorageLocationId = l.intStorageLocationId
	LEFT JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = clsl.intCompanyLocationId
	LEFT JOIN tblICItemUOM ium1 ON ium1.intItemUOMId = ISNULL(l.intWeightUOMId,l.intItemUOMId)
	LEFT JOIN tblICUnitMeasure um1 ON um1.intUnitMeasureId = ium1.intUnitMeasureId
	LEFT JOIN tblICParentLot pl ON pl.intParentLotId = l.intParentLotId
	LEFT JOIN tblICItemOwner ito ON ito.intItemId = i.intItemId
	LEFT JOIN tblARCustomer c1 ON c1. intEntityCustomerId = ito.intOwnerId
	LEFT JOIN tblEntity e ON e.intEntityId = l.intEntityVendorId
