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
		A.strContractStatus,
		A.ysnUnlimitedQuantity AS  ysnUnlimitedContract
	FROM vyuCTContractDetailView A
	WHERE A.intContractStatusId != 5
	GROUP BY 	
		A.intContractHeaderId,
		A.strContractNumber, 
		A.intEntityId,
		A.intContractTypeId,
		A.dblHeaderQuantity,
		A.strContractStatus,
		A.ysnUnlimitedQuantity
GO