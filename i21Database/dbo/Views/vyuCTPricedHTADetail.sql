CREATE VIEW [dbo].[vyuCTPricedHTADetail]
AS 
SELECT dtmHistoryCreated = dbo.fnRemoveTimeOnDate(dtmHistoryCreated)
,dblQuantity
,strPricingType
,strContract
FROM
(
	SELECT dtmHistoryCreated = MAX(dtmHistoryCreated)
	,dblQuantity
	,strPricingType
	,strContract = strContractNumber + '-' + CAST(intContractSeq AS NVARCHAR(5))
	FROM tblCTSequenceHistory
	WHERE intPricingTypeId = 3
	GROUP BY dblQuantity,strPricingType,strContractNumber,intContractSeq

	UNION ALL

	SELECT dtmHistoryCreated = MAX(a.dtmHistoryCreated)
	,dblQuantity = a.dblQuantity * -1
	,b.strPricingType
	,strContract = a.strContractNumber + '-' + CAST(a.intContractSeq AS NVARCHAR(5))
	FROM tblCTSequenceHistory a
	INNER JOIN tblCTSequenceHistory b ON a.intContractDetailId = b.intContractDetailId
	AND a.intPricingTypeId = 1 AND b.intPricingTypeId = 3
	GROUP BY a.dblQuantity,b.strPricingType,a.strContractNumber,a.intContractSeq

	UNION ALL

	SELECT dtmHistoryCreated = MAX(a.dtmHistoryCreated)
	,a.dblQuantity
	,a.strPricingType
	,strContract = a.strContractNumber + '-' + CAST(a.intContractSeq AS NVARCHAR(5))
	FROM tblCTSequenceHistory a
	INNER JOIN tblCTSequenceHistory b ON a.intContractDetailId = b.intContractDetailId
	AND a.intPricingTypeId = 1 AND b.intPricingTypeId = 3
	GROUP BY a.dblQuantity,a.strPricingType,a.strContractNumber,a.intContractSeq
) tbl