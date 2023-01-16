CREATE VIEW [dbo].[vyuTMCompanyConsumptionSite]
	AS 
SELECT 
	A.intCustomerID
	,A.intSiteID
	,B.intCompanyLocationId
	,B.strLocationName strCompanyLocationName
	,B.strPhone strCompanyLocationPhone
	,B.strAddress strCompanyLocationAddress
	,A.strBillingBy
	,A.ysnActive
	,A.intSiteNumber
	,A.intCompanyLocationSubLocationId
	,C.strSubLocationName
	,A.strDescription
	,A.strSiteAddress
	,A.strZipCode
	,A.strCity
	,A.strState
	,A.strCountry
	,A.dblLatitude
	,A.dblLongitude
	,intDriverId = A.intDriverID 
	,SP.strName strDriverName
	,A.intRouteId
	,R.strRouteId strRoute
	,strSequenceId = A.strSequenceID
	,A.dtmLastDeliveryDate
	,dblLastGalInTank = A.dblLastGalsInTank
	,A.dblLastDeliveredGal
	,A.strComment
	,A.strInstruction
	,A.intConcurrencyId
	,intItemId = A.intProduct
	,I.strItemNo
	,I.strDescription strItemDescription
	,A.intFillMethodId
	,FM.strFillMethod
	,A.intFillGroupId
	,FG.strFillGroupCode
	,A.intGlobalJulianCalendarId
	,JC.strDescription strJulianCalendar
FROM tblTMSite A
INNER JOIN tblSMCompanyLocation B
	ON A.intLocationId = B.intCompanyLocationId
LEFT JOIN tblSMCompanyLocationSubLocation C
	ON A.intCompanyLocationSubLocationId = C.intCompanyLocationSubLocationId
LEFT JOIN tblICItem I ON I.intItemId = A.intProduct
LEFT JOIN tblEMEntity SP ON SP.intEntityId = A.intDriverID
LEFT JOIN tblTMRoute R ON R.intRouteId = A.intRouteId
LEFT JOIN tblTMFillMethod FM ON FM.intFillMethodId = A.intFillMethodId
LEFT JOIN tblTMFillGroup FG ON FG.intFillGroupId = A.intFillGroupId
LEFT JOIN tblTMGlobalJulianCalendar JC ON JC.intGlobalJulianCalendarId = A.intGlobalJulianCalendarId
WHERE A.ysnCompanySite = 1