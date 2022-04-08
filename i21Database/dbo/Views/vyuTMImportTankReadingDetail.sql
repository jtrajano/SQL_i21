CREATE VIEW [dbo].[vyuTMImportTankReadingDetail]
	AS
SELECT TRD.intImportTankReadingDetailId
	, TRD.intImportTankReadingId
	, TR.intInterfaceTypeId
	, I.strInterfaceType
	, TRD.strEsn
	, TRD.intCustomerId
	, E.strName strCustomerName
	, TRD.strCustomerNumber
	, TRD.intSiteId
	, S.intSiteNumber
	, S.strDescription AS strSiteDescription
	, TRD.dtmReadingDate
	, TRD.ysnValid
	, TRD.strMessage
	, TRD.intRecord
FROM tblTMImportTankReadingDetail TRD
INNER JOIN tblTMImportTankReading TR ON TR.intImportTankReadingId = TRD.intImportTankReadingId
LEFT JOIN tblEMEntity E ON E.intEntityId = TRD.intCustomerId
LEFT JOIN tblTMSite S ON S.intSiteID = TRD.intSiteId
LEFT JOIN tblTMTankMonitorInterfaceType I ON I.intInterfaceTypeId = TR.intInterfaceTypeId