﻿CREATE VIEW [dbo].[vyuTMBEExportContract]  
AS 
	SELECT
		account=C.strEntityNo 
		,productCode= E.strItemNo
		,preBuyPrice= CAST(B.dblCashPrice AS NUMERIC(18,4))
		,preBuyQty= CAST(B.dblBalance AS NUMERIC(18,4))
		,contractPrice= CAST(0.0 AS NUMERIC(18,4))
		,contractQty= CAST(0.0 AS NUMERIC(18,4))	
	FROM tblCTContractHeader A
	INNER JOIN vyuCTContractHeaderNotMapped H
		ON A.intContractHeaderId = H.intContractHeaderId
	INNER JOIN tblCTContractDetail B
		ON A.intContractHeaderId = B.intContractHeaderId
	INNER JOIN tblEMEntity C
		ON A.intEntityId = C.intEntityId
	LEFT JOIN tblICItem E
		ON B.intItemId = E.intItemId	

GO