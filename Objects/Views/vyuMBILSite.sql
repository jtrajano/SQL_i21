CREATE VIEW [dbo].[vyuMBILSite]
	AS

SELECT Customer.intEntityId
	, Customer.strCustomerNumber
	, Entity.strName
	, intSiteId = Site.intSiteID
	, strSiteDescription = Site.strDescription
	, Site.intSiteNumber
	, Site.strSiteAddress
	, Site.strCity
	, Site.strState
	, Site.strZipCode
	, Site.strCountry
	, SiteDevice.strSerialNumber
	, SiteDevice.dblTankCapacity
	, strDeviceDescription = SiteDevice.strDescription
FROM tblTMSite Site
LEFT JOIN tblARCustomer Customer ON Customer.intEntityId = Site.intSiteID
LEFT JOIN tblEMEntity Entity ON Entity.intEntityId = Customer.intEntityId
LEFT JOIN (
	SELECT AA.intSiteID
		, AA.intDeviceId
		, BB.strDescription
		, BB.strSerialNumber
		, BB.dblTankCapacity
		, intRecNo = ROW_NUMBER() OVER (PARTITION BY intSiteID ORDER BY intSiteDeviceID)
	FROM tblTMSiteDevice AA
	INNER JOIN tblTMDevice BB ON AA.intDeviceId = BB.intDeviceId
	INNER JOIN tblTMDeviceType CC ON CC.intDeviceTypeId = BB.intDeviceTypeId
	WHERE CC.strDeviceType = 'Tank' AND BB.ysnAppliance = 0
	) SiteDevice ON SiteDevice.intSiteID = Site.intSiteID AND intRecNo = 1