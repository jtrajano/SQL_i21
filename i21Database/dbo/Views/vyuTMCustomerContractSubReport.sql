CREATE VIEW [dbo].vyuTMCustomerContractSubReport  
AS 
	SELECT 
		intCustomerId = C.intCustomerID
		,strContractNumber = A.strContractNumber
		,dblUnitBalance = ISNULL(B.dblBalance,0.0)
		,dblUnitPrice =  ISNULL(B.dblCashPrice,0.0)
	FROM tblCTContractHeader A
	INNER JOIN tblCTContractDetail B
		ON A.intContractHeaderId = B.intContractHeaderId
	INNER JOIN tblEMEntity D
		ON A.intEntityId = D.intEntityId
	INNER JOIN tblTMCustomer C
		ON D.intEntityId = C.intCustomerNumber
	WHERE DATEADD(dd, DATEDIFF(dd, 0, B.dtmEndDate), 0) >= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0)
GO