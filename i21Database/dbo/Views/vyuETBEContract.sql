CREATE VIEW [dbo].[vyuETBEContract]  
AS 
	SELECT
		C.strEntityNo 
		,E.strItemNo
		,B.dblCashPrice
		,B.dblBalance
		,E.intItemId
		,C.intEntityId
		,B.intContractDetailId
	FROM tblCTContractHeader A
	INNER JOIN tblCTContractDetail B
		ON A.intContractHeaderId = B.intContractHeaderId
	INNER JOIN tblEMEntity C
		ON A.intEntityId = C.intEntityId
	INNER JOIN tblICItem E
		ON B.intItemId = E.intItemId	
	WHERE DATEADD(dd, DATEDIFF(dd, 0, B.dtmStartDate), 0) <= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0)
		AND DATEADD(dd, DATEDIFF(dd, 0, B.dtmEndDate), 0) >= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0)
		AND B.dblBalance > 0
		AND B.intContractDetailId IN (SELECT MIN(intContractDetailId) FROM tblCTContractDetail WHERE intContractHeaderId = A.intContractHeaderId AND intItemId = E.intItemId)
		AND B.intContractHeaderId IN (SELECT MIN(intContractHeaderId) FROM tblCTContractHeader WHERE intEntityId = A.intEntityId)
		AND (E.ysnAvailableTM = 1 OR E.strType = 'Service')

GO