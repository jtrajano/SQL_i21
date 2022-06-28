CREATE VIEW [dbo].[vyuLGDispatchSupplyPoint]
AS
SELECT 
	EL.intEntityLocationId
	,EL.strLocationName
	,E.intEntityId
	,strEntityName = E.strName
	,EL.strAddress
	,EL.strZipCode
	,EL.strCity
	,EL.strState
	,EL.strCountry
	,EL.dblLongitude
	,EL.dblLatitude
	,ysnTransportTerminal = ISNULL(ysnTransportTerminal, 0)
FROM tblEMEntityLocation EL
INNER JOIN tblEMEntity E ON E.intEntityId = EL.intEntityId 
	AND E.intEntityId IN (SELECT intEntityId FROM tblEMEntityType WHERE strType = 'Vendor')
INNER JOIN tblAPVendor V ON V.intEntityId = E.intEntityId

GO