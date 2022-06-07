CREATE VIEW [dbo].[vyuLGDispatchSupplyPoint]
AS
SELECT 
	intKeyColumn = ROW_NUMBER() OVER (ORDER BY strLocationName ASC)
	,LOC.* 
FROM
   (SELECT 
		strLocationType = 'Bulk Location' COLLATE Latin1_General_CI_AS
		,intEntityId = CL.intCompanyLocationId
		,strEntityName = CL.strLocationName
		,intLocationId = CLSL.intCompanyLocationSubLocationId
		,strLocationName = CLSL.strSubLocationName
		,strAddress = CLSL.strAddress
		,strZipPostalCode = CLSL.strZipCode
		,strCity = CLSL.strCity
		,strStateProvince = CLSL.strState
		,strCountry = CL.strCountry
	FROM tblSMCompanyLocationSubLocation CLSL
	INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CLSL.intCompanyLocationId
	LEFT JOIN tblEMEntity WV ON WV.intEntityId = CLSL.intVendorId
	UNION ALL
	SELECT 
		strLocationType = 'Supplier Terminal' COLLATE Latin1_General_CI_AS
		,intEntityId = E.intEntityId
		,strEntityName = E.strName
		,intLocationId = EL.intEntityLocationId
		,strLocationName = EL.strLocationName
		,strAddress = EL.strAddress
		,strZipPostalCode = EL.strZipCode
		,strCity = EL.strCity
		,strStateProvince = EL.strState
		,strCountry = EL.strCountry
	FROM tblEMEntityLocation EL
	INNER JOIN tblEMEntity E ON E.intEntityId = EL.intEntityId 
		AND E.intEntityId IN (SELECT intEntityId FROM tblEMEntityType WHERE strType = 'Vendor')
	INNER JOIN tblAPVendor V ON V.intEntityId = E.intEntityId AND V.ysnTransportTerminal = 1
	) LOC

GO