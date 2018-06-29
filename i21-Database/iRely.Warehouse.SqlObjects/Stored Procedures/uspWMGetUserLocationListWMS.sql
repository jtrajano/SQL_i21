CREATE PROCEDURE uspWMGetUserLocationListWMS
 @UserName nvarchar(50)  = null
AS   
BEGIN  

 IF @UserName = '' OR @UserName IS NULL   
 BEGIN 
	 SELECT cl.strLocationName FactoryLocation,  -- + ' - ' + ISNULL(clsl.strSubLocationName,'') FactoryLocation,  
	  smus.strUserName UserName, 
	  smus.[intEntityId] UserKey, 
	  'Admin' UserGroupName,  
	  cl.intCompanyLocationId FactoryKey,  
	  cl.strLocationName FactoryName,  
	  --clsl.intCompanyLocationSubLocationId LocationKey,  
	  --ISNULL(clsl.strSubLocationName,'') LocationName,  
	  0 NewLotUnitKey,  
	  '' NewLotUnitName,  
	  0 AuditUnitKey,  
	  '' AuditUnitName,  
	  '' DefaultShipFromAddressTitle,  
	  0 DefaultShipFromAddressID,  
	  '' DefaultShipToAddressTitle,  
	  0 DefaultShipToAddressID,  
	  CONVERT(bit,0) IsDefault,  
	  0 WIPLocationKey,  
	  '' [language],  
	  '' ERPCompanyID,  
	  '' ERPWareHouseID,  
	  0 WarehouseID, '' AS WarehouseName, '' AS AddressType,
	  ISNULL(smus.intCompanyLocationId, 0) AS intDefaultCompanyLocationId
	 FROM tblSMUserSecurity smus,tblSMCompanyLocation cl --,tblSMCompanyLocationSubLocation clsl
	 --LEFT JOIN tblSMCompanyLocation cl ON smus.intCompanyLocationId = cl.intCompanyLocationId
	 --LEFT JOIN tblSMCompanyLocationSubLocation clsl ON clsl.intCompanyLocationId = cl.intCompanyLocationId

 END
 ELSE    
 BEGIN
	DECLARE @intDefaultCompanyLocationId INT

	SELECT @intDefaultCompanyLocationId = smus.intCompanyLocationId
	FROM tblSMUserSecurity smus
	JOIN tblSMUserSecurityCompanyLocationRolePermission CLP ON CLP.intEntityId = smus.intEntityId
		AND CLP.intCompanyLocationId = smus.intCompanyLocationId
	WHERE smus.strUserName = @UserName
	
	IF @intDefaultCompanyLocationId IS NULL
		SELECT @intDefaultCompanyLocationId = 0

 	  SELECT cl.strLocationName FactoryLocation, -- + ' - ' + ISNULL(clsl.strSubLocationName,'') FactoryLocation,  
	  smus.strUserName UserName,  
  	  smus.[intEntityId] UserKey, 
	  'Admin' UserGroupName,  
	  cl.intCompanyLocationId FactoryKey,  
	  cl.strLocationName FactoryName,  
	  --clsl.intCompanyLocationSubLocationId LocationKey,  
	  --ISNULL(clsl.strSubLocationName,'') LocationName,  
	  0 NewLotUnitKey,  
	  '' NewLotUnitName,  
	  0 AuditUnitKey,  
	  '' AuditUnitName,  
	  '' DefaultShipFromAddressTitle,  
	  0 DefaultShipFromAddressID,  
	  '' DefaultShipToAddressTitle,  
	  0 DefaultShipToAddressID,  
	  CONVERT(bit,0) IsDefault,  
	  0 WIPLocationKey,  
	  '' [language],  
	  '' ERPCompanyID,  
	  '' ERPWareHouseID,  
	  0 WarehouseID, '' AS WarehouseName, '' AS AddressType,
	  @intDefaultCompanyLocationId AS intDefaultCompanyLocationId
	 FROM tblSMUserSecurity smus
	 JOIN tblSMUserSecurityCompanyLocationRolePermission CLP ON CLP.intEntityId = smus.intEntityId
	 JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = CLP.intCompanyLocationId
	 WHERE smus.strUserName = @UserName
	 ORDER BY cl.strLocationName
 END
  
END  