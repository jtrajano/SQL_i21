CREATE VIEW [dbo].[vyuTMOrderApprovalTransaction]  
AS  

	SELECT 
		A.intTransactionId
		,A.intRecordId
		,ysnApproved = CAST((CASE WHEN (ISNULL(A.strApprovalStatus,'') = '' OR A.strApprovalStatus = 'No Need for Approval' OR A.strApprovalStatus = 'Approved')
							THEN
								1
							ELSE
								0
							END) AS BIT)
		,A.intConcurrencyId
	FROM tblSMTransaction A
	INNER JOIN tblSMScreen B
		ON A.intScreenId = B.intScreenId
	WHERE strScreenName = 'TM Order'
		AND strNamespace = 'TankManagement.view.Order'
		AND strModule = 'Tank Management'

GO