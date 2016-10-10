CREATE VIEW [dbo].[vyuETBEExportContract]  
AS 
	SELECT
		account=C.strEntityNo 
		,productCode= E.strItemNo
		,preBuyPrice= CAST(ISNULL(B.dblCashPrice,0.0) AS NUMERIC(18,4))
		,preBuyQty= CAST(ISNULL(B.dblBalance,0.0) AS NUMERIC(18,2))
		,contractPrice= CAST(0.0 AS NUMERIC(18,4))
		,contractQty= CAST(0.0 AS NUMERIC(18,2))
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