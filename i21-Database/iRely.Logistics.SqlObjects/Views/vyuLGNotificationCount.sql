CREATE VIEW vyuLGNotificationCount
AS
SELECT *
FROM (
	SELECT COUNT(1) intCount
		,'intContractWithoutShippingInstructionCount' AS strNotificationCount
	FROM vyuLGNotifications
	WHERE strType = 'Contracts w/o shipping instruction'
	
	UNION ALL
	
	SELECT COUNT(1) intCount
		,'intContractsWithoutTCCount' AS strNotificationCount
	FROM vyuLGNotifications
	WHERE strType = 'Contracts w/o TC'
	
	UNION ALL
	
	SELECT COUNT(1) intCount
		,'intContractsWithout4CCount' AS strNotificationCount
	FROM vyuLGNotifications
	WHERE strType = 'Contracts w/o 4C'
	
	UNION ALL
	
	SELECT COUNT(1) intCount
		,'intWeightClaimsWithoutDebitNoteCount' AS strNotificationCount
	FROM vyuLGNotifications
	WHERE strType = 'Weight claims w/o debit note'
	
	UNION ALL
	
	SELECT COUNT(1) intCount
		,'intContractsWithoutWeightClaimCount' AS strNotificationCount
	FROM vyuLGNotifications
	WHERE strType = 'Contracts w/o weight claim'
	
	UNION ALL
	
	SELECT COUNT(1) intCount
		,'intContractsWithoutDocumentCount' AS strNotificationCount
	FROM vyuLGNotifications
	WHERE strType = 'Contracts w/o document'
	
	UNION ALL
	
	SELECT COUNT(1) intCount
		,'intContractsWithoutShippingAdvice' AS strNotificationCount
	FROM vyuLGNotifications
	WHERE strType = 'Contracts w/o shipping advice'
	) t
PIVOT(MIN(intCount) FOR strNotificationCount IN (
			intContractsWithout4CCount
			,intContractsWithoutTCCount
			,intContractWithoutShippingInstructionCount
			,intWeightClaimsWithoutDebitNoteCount
			,intContractsWithoutWeightClaimCount
			,intContractsWithoutDocumentCount
			,intContractsWithoutShippingAdvice
			)) g
