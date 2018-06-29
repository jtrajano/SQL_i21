
CREATE VIEW [dbo].[vyuCTContractChart]
AS


SELECT 
	DATEPART(wk,tblCTContractDetail.dtmEndDate) weekno,
	SUM(CASE WHEN tblCTContractType.strContractType='Purchase' THEN dblBalance ELSE 0 END) purchasebalance,
	SUM(CASE WHEN tblCTContractType.strContractType='Sale' THEN dblBalance ELSE 0 END) salesbalance
FROM  tblCTContractHeader
	INNER JOIN tblCTContractDetail ON tblCTContractHeader.intContractHeaderId = tblCTContractDetail.intContractHeaderId
	INNER JOIN tblCTContractType ON tblCTContractHeader.intContractTypeId = tblCTContractType.intContractTypeId
GROUP BY DATEPART(wk,tblCTContractDetail.dtmEndDate)

