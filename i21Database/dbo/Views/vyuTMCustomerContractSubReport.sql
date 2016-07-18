CREATE VIEW [dbo].vyuTMCustomerContractSubReport  
AS 
	SELECT 
		intCustomerId = C.intCustomerID
		,strContractNumber = A.strContractNumber
		,dblUnitBalance = B.dblBalance
		,dblUnitPrice =  B.dblCashPrice
	FROM tblCTContractHeader A
	INNER JOIN tblCTContractDetail B
		ON A.intContractHeaderId = B.intContractHeaderId
	INNER JOIN tblEMEntity B
		ON A.intEntityId = B.intEntityId
	INNER JOIN tblTMCustomer C
		ON B.intEntityId = C.intCustomerNumber
	WHERE DATEADD(dd, DATEDIFF(dd, 0, B.dtmEndDate), 0) >= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0)
GO