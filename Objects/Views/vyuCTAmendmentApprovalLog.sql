CREATE VIEW [dbo].[vyuCTAmendmentApprovalLog]
AS
SELECT 
 intAmendmentApprovalLogId      = AAH.intAmendmentApprovalLogId
,dtmHistoryCreated				= AAH.dtmHistoryCreated
,strDataField					= AAH.strDataField    
,ysnOldValue					= AAH.ysnOldValue	 
,ysnNewValue					= AAH.ysnNewValue
,strUser						= Entity.strName
FROM tblCTAmendmentApprovalLog AAH
JOIN tblEMEntity Entity ON Entity.intEntityId = AAH.intLastModifiedById
