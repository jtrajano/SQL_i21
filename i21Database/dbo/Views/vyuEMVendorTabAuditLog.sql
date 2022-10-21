CREATE VIEW [dbo].[vyuEMVendorTabAuditLog]
AS
SELECT 
E.strName AS [Vendor]
, L.dtmDate AS [Date]
, CASE WHEN ISNULL(A.strAction, '') = '' AND ISNULL(ParentAudit.strChange,'') LIKE 'Updated%' THEN 'Updated' ELSE A.strAction END AS [Action]
, CASE WHEN ISNULL(SecondParent.strChange, '') != '' AND ISNULL(SecondParent.strChange, '') LIKE 'Updated -%' AND (ISNULL(A.strChange, '') LIKE 'Created -%' OR ISNULL(A.strChange, '') LIKE 'Deleted -%')
		THEN A.strChange + ' - ' + REPLACE(REPLACE(ISNULL(ParentAudit.strChange, ''), 'tblAP', ''), 'tblCC', '')
		ELSE ISNULL(A.strAlias, A.strChange) 
  END AS [Field]
, ISNULL(A.strFrom, '') AS [Original Value]
, ISNULL(A.strTo, '') AS [New Value]
, CASE WHEN ISNULL(L.intEntityId, 0) = 0 THEN 'ADMIN' ELSE CB.strName END AS [Changed By]
--, A.ysnHidden
--, ParentAudit.strChange as [Parent Field]
--, SecondParent.strChange as [Second Parent Field]
FROM tblSMAudit A
INNER JOIN tblSMLog L on A.intLogId = L.intLogId
INNER JOIN tblSMTransaction T on T.intTransactionId = L.intTransactionId
INNER JOIN tblSMScreen S on S.intScreenId = T.intScreenId
INNER JOIN tblEMEntity E on T.intRecordId = E.intEntityId

LEFT OUTER JOIN tblEMEntity CB on L.intEntityId = CB.intEntityId
LEFT OUTER JOIN tblSMAudit ParentAudit ON A.intParentAuditId = ParentAudit.intAuditId
LEFT OUTER JOIN tblSMAudit SecondParent ON ParentAudit.intParentAuditId = SecondParent.intAuditId


WHERE L.strType = 'Audit' and L.strRoute like '%Vendor%'
AND S.strNamespace = 'EntityManagement.view.Entity'
AND (A.ysnHidden = 0 OR A.strAction = 'Created' OR A.strAction = 'Deleted')
AND ParentAudit.strChange NOT IN ('tblEMEntityLocations', 'tblEMEntityToContacts', 'tblEMEntityTypes')
AND (SecondParent.strChange NOT IN ('tblEMEntityLocations', 'tblEMEntityToContacts', 'tblEMEntityTypes') OR SecondParent.strChange IS NULL)


--and T.intTransactionId = 69244
--ORDER BY L.dtmDate DESC

