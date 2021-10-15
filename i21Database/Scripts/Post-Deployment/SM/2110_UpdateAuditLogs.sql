GO
print('/*******************  BEGIN UPDATING AUDIT LOG FOR 21.1 *******************/')

-- Update Source Screen (User, Customers, Vendor and etc..) from Entity Audit Logs

UPDATE tblSMLog  
SET intOriginalScreenId = D.intOriginalScreenId
FROM tblSMLog A
	INNER JOIN tblSMTransaction B ON A.intTransactionId = B.intTransactionId
	INNER JOIN tblSMScreen C ON B.intScreenId = C.intScreenId
CROSS APPLY (
	SELECT 
		intScreenId intOriginalScreenId,
		strNamespace
	FROM tblSMScreen 
	WHERE 
		strRoute LIKE ('[#][/]%[/]' + REVERSE(SUBSTRING(REVERSE(strNamespace), 1, CHARINDEX('.', REVERSE(strNamespace)) - 1)) COLLATE Latin1_General_CI_AS + '[/|?]%')
		AND ysnSearch = 0
) D
WHERE ISNULL(A.intOriginalScreenId, 0) = 0 AND C.strNamespace = 'EntityManagement.view.Entity' AND ISNULL(A.strRoute, '') <> '' AND A.strRoute NOT LIKE '?activeTab%'

-- Update Entity Transaction No
UPDATE tblSMTransaction
SET strTransactionNo = ISNULL(C.strEntityNo, strTransactionNo)
FROM tblSMTransaction A 
	INNER JOIN tblSMScreen B ON A.intScreenId = B.intScreenId
	LEFT JOIN tblEMEntity C ON A.intRecordId = C.intEntityId
WHERE ISNULL(strTransactionNo, '') = '' AND B.strNamespace = 'EntityManagement.view.Entity'

-- Update Contract Transaction No
UPDATE tblSMTransaction
SET strTransactionNo = ISNULL(C.strContractNumber, strTransactionNo)
FROM tblSMTransaction A 
	INNER JOIN tblSMScreen B ON A.intScreenId = B.intScreenId
	LEFT JOIN tblCTContractHeader C ON A.intRecordId = C.intContractHeaderId
WHERE ISNULL(strTransactionNo, '') = '' AND B.strNamespace = 'ContractManagement.view.Contract'


--Update TimeOff Request Transaction
UPDATE tblSMTransaction
SET strTransactionNo = ISNULL(C.strRequestId, strTransactionNo),
    dtmDate = C.dtmDateFrom,
    intEntityId = C.intEntityEmployeeId
FROM tblSMTransaction A
INNER JOIN tblSMScreen B ON A.intScreenId = B.intScreenId
LEFT JOIN tblPRTimeOffRequest C ON A.intRecordId = C.intPaycheckId
WHERE ISNULL(strTransactionNo, '') = '' AND B.strNamespace = 'Payroll.view.TimeOffRequest'

--Update Employee Transaction 
UPDATE tblSMTransaction
SET strTransactionNo = ISNULL(C.strEmployeeId, strTransactionNo),
    intEntityId = C.intEntityId
FROM tblSMTransaction A
INNER JOIN tblSMScreen B ON A.intScreenId = B.intScreenId
LEFT JOIN tblPREmployee C ON A.intRecordId = C.intEntityId
WHERE ISNULL(strTransactionNo, '') = '' AND B.strNamespace = 'Payroll.view.EntityEmployee' 


print('/*******************  END UPDATING AUDIT LOG FOR 21.1  *******************/')

GO