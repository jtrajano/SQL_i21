CREATE VIEW [dbo].vyuTMCustomerContractSubReport  
AS 
	SELECT 
		intCustomerId = C.intCustomerID
		,strContractNumber = A.strContractNumber
		,dblUnitBalance = ISNULL(B.dblBalance,0.0)
		,dblUnitPrice =  ISNULL(B.dblCashPrice,0.0)
		,strItemNo = E.strItemNo
	FROM tblCTContractHeader A
	INNER JOIN tblCTContractDetail B
		ON A.intContractHeaderId = B.intContractHeaderId
	INNER JOIN tblEMEntity D
		ON A.intEntityId = D.intEntityId
	INNER JOIN tblTMCustomer C
		ON D.intEntityId = C.intCustomerNumber
	LEFT JOIN tblICItem E
		ON B.intItemId = E.intItemId
	WHERE DATEADD(dd, DATEDIFF(dd, 0, B.dtmEndDate), 0) >= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0)
		AND ISNULL(B.dblBalance,0.0) > 0
GO