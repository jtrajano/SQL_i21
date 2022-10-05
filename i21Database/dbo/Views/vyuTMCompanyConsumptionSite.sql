CREATE VIEW [dbo].[vyuTMCompanyConsumptionSite]
	AS 
SELECT CS.intCompanyConsumptionSiteId, 
C.intCompanyLocationId,
C.strLocationName strCompanyLocationName,
C.strPhone strCompanyLocationPhone,
C.strAddress strCompanyLocationAddress,
CS.strBillingBy, 
CS.ysnActive, 
CS.intSiteNumber,
CS.intCompanyLocationSubLocationId,
SL.strSubLocationName,
CS.strDescription,
CS.strSiteAddress,
CS.strZipCode,
CS.strCity,
CS.strState,
CS.strCountry,
CS.dblLatitude,
CS.dblLongitude,
CS.intDriverId,
SP.strName strDriverName,
CS.intRouteId,
R.strRouteId strRoute,
CS.strSequenceId,
CS.dtmLastDeliveryDate,
CS.dblLastGalInTank,
CS.dblLastDeliveredGal,
CS.strComment,
CS.strInstruction,
CS.intConcurrencyId,
CS.intItemId,
I.strItemNo,
I.strDescription strItemDescription,
CS.intFillMethodId,
FM.strFillMethod,
CS.intFillGroupId,
FG.strFillGroupCode,
CS.intGlobalJulianCalendarId,
JC.strDescription strJulianCalendar
FROM tblSMCompanyLocation C
INNER JOIN tblTMCompanyConsumptionSite CS ON CS.intCompanyLocationId = C.intCompanyLocationId
LEFT JOIN tblSMCompanyLocationSubLocation SL ON SL.intCompanyLocationSubLocationId = CS.intCompanyLocationSubLocationId
LEFT JOIN tblICItem I ON I.intItemId = CS.intItemId
LEFT JOIN vyuEMSalesperson SP ON SP.intEntityId = CS.intDriverId
LEFT JOIN tblTMRoute R ON R.intRouteId = CS.intRouteId
LEFT JOIN tblTMFillMethod FM ON FM.intFillMethodId = CS.intFillMethodId
LEFT JOIN tblTMFillGroup FG ON FG.intFillGroupId = CS.intFillGroupId
LEFT JOIN tblTMGlobalJulianCalendar JC ON JC.intGlobalJulianCalendarId = CS.intGlobalJulianCalendarId