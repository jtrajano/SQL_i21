CREATE VIEW [dbo].[vyuCTBasisDelivery]
AS 
SELECT intUniqueId
,intContractHeaderId
,intContractDetailId
,intTransactionId
,strTransactionType
,intEntityId
,strContractType
,strContractNumber
,intContractSeq
,strCustomerVendor
,strCommodityCode
,dtmDate
,dblQuantity
,dblRunningBalance
,ysnOpenGetBasisDelivery
FROM [dbo].[fnCTGetBasisDelivery](NULL)
