
CREATE VIEW [dbo].[vyuAPContractDistinct]
AS
SELECT 
		DISTINCT
		A.intContractHeaderId, 
		A.strContractNumber,
		A.intEntityId,
		A.intContractTypeId,
		ISNULL(MIN(dblCashPrice),0) dblCashPriceMin ,
		A.dblHeaderQuantity,
		A.strContractStatus  
	FROM vyuCTContractDetailView A
	WHERE A.intContractStatusId != 5 AND A.intContractHeaderId NOT IN (SELECT intContractHeaderId FROM dbo.tblAPBill APB
		INNER JOIN  tblAPBillDetail APD ON APB.intBillId = APD.intBillId
		WHERE intTransactionType = 2)
	GROUP BY 	
		A.intContractHeaderId,
		A.strContractNumber, 
		A.intEntityId,
		A.intContractTypeId,
		A.dblHeaderQuantity,
		A.strContractStatus
GO