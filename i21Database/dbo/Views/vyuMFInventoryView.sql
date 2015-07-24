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
          
			i.intItemId,         
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
			c1.strCustomerNumber strOwner
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