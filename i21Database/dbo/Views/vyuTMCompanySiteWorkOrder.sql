CREATE VIEW [dbo].[vyuTMCompanySiteWorkOrder]    
    AS  
SELECT WO.intWorkOrderID
, WO.strWorkOrderNumber
, WO.intWorkStatusTypeID
, WS.strWorkStatus
, WO.intPerformerID
, ESP.strName strPerformerName
, WO.strAdditionalInfo
, WO.intEnteredByID
, S.strUserName strEnteredBy
, WO.dtmDateCreated
, WO.dtmDateClosed
, WO.dtmDateScheduled
, WO.intCloseReasonID
, CR.strCloseReason
, WO.strComments
, WO.intWorkOrderCategoryId
, WC.strWorkOrderCategory
, WO.intCompanyConsumptionSiteId
, WO.intConcurrencyId
FROM tblTMWorkOrder WO
INNER JOIN tblTMCompanyConsumptionSite CS ON CS.intCompanyConsumptionSiteId = WO.intCompanyConsumptionSiteId
LEFT JOIN tblARSalesperson SP ON SP.intEntityId = WO.intPerformerID
LEFT JOIN tblEMEntity ESP ON ESP.intEntityId = SP.intEntityId
LEFT JOIN tblSMUserSecurity S ON S.intEntityId = WO.intEnteredByID
LEFT JOIN tblTMWorkCloseReason CR ON CR.intCloseReasonID = WO.intCloseReasonID
LEFT JOIN tblTMWorkStatusType WS ON WS.intWorkStatusID = WO.intWorkStatusTypeID
LEFT JOIN tblTMWorkOrderCategory WC ON WC.intWorkOrderCategoryId = WO.intWorkOrderCategoryId
