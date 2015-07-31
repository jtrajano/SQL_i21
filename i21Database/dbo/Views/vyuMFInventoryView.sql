CREATE VIEW vyuMFInventoryView        
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
			l.dblWeight,
			l.intWeightUOMId,
			l.intOriginId,
			l.strBOLNo,
			l.strVessel,
			l.strReceiptNumber,
			l.strMarkings,
			l.strNotes,
			l.intEntityVendorId,
			l.intVendorLocationId,
			l.strVendorLocation,
			l.strContractNo,
			l.dtmManufacturedDate,
			l.ysnReleasedToWarehouse,
			l.ysnProduced,
			l.ysnInCustody,
			l.intOwnershipType,
			l.intGradeId,
			l.intCreatedUserId,
			l.intConcurrencyId,


			i.strItemNo,         
			i.strDescription strItemDescription,         
			i.strType strItemType,         
          
			ic.strCategoryCode strItemCategory,         
			c.strCustomerNumber strVendor,        
          
			ls.strPrimaryStatus,         
			ls.strSecondaryStatus,        
			us.strUserName,        
			um.strUnitMeasure strQtyUOM,        
			clsl.strSubLocationName,        
			clsl.intCompanyLocationSubLocationId,      
			sl.strName strStorageLocationName,        
			cl.strLocationName strCompanyLocationName ,        
			cl.intCompanyLocationId,      
			um1.strUnitMeasure strWeightUOM,
			pl.strParentLotNumber,
			c1.strCustomerNumber strOwner,    
		    '' AS strCurrency,    
		    '' AS strCostUOM,    
		    0 AS intContainerId,    
		    '' AS strContainerNo    
	FROM tblICLot l
	LEFT JOIN tblICItem i ON i.intItemId = l.intItemId
	LEFT JOIN tblICCategory ic ON ic.intCategoryId = i.intCategoryId
	LEFT JOIN tblICLotStatus ls ON ls.intLotStatusId=l.intLotStatusId
	LEFT JOIN tblSMUserSecurity us ON us.intUserSecurityID = l.intCreatedUserId
	LEFT JOIN tblICItemUOM ium ON ium.intItemUOMId = l.intItemUOMId
	LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = ium.intUnitMeasureId
	LEFT JOIN tblSMCompanyLocationSubLocation clsl ON clsl.intCompanyLocationSubLocationId = l.intSubLocationId
	LEFT JOIN tblICStorageLocation sl ON sl.intStorageLocationId = l.intStorageLocationId
	LEFT JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = clsl.intCompanyLocationId
	LEFT JOIN tblICItemUOM ium1 ON ium1.intItemUOMId = l.intWeightUOMId
	LEFT JOIN tblICUnitMeasure um1 ON um1.intUnitMeasureId = ium1.intItemUOMId
	LEFT JOIN tblICParentLot pl ON pl.intParentLotId = l.intParentLotId
	LEFT JOIN tblICItemOwner ito ON ito.intItemId = i.intItemId
	LEFT JOIN tblARCustomer c1 ON c1. intEntityCustomerId = ito.intOwnerId
	LEFT JOIN tblARCustomer c ON c.intEntityCustomerId = l.intEntityVendorId