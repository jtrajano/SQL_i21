﻿
CREATE VIEW [dbo].[vyuAPContractDistinct]
AS
SELECT 
		DISTINCT
		A.intContractHeaderId, 
		A.strContractNumber,
		A.intEntityId,
		A.intContractTypeId,
		MIN(dblCashPrice) dblCashPriceMin ,
		A.dblHeaderQuantity,
		A.strContractStatus  
	FROM vyuCTContractDetailView A
	WHERE A.intContractStatusId != 5
	GROUP BY 	
		A.intContractHeaderId,
		A.strContractNumber, 
		A.intEntityId,
		A.intContractTypeId,
		A.dblHeaderQuantity,
		A.strContractStatus
GO