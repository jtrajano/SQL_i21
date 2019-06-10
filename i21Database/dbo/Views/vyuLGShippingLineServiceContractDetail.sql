CREATE VIEW vyuLGShippingLineServiceContractDetail
AS
SELECT
	SLSCD.intShippingLineServiceContractDetailId 
	,SLSCD.intShippingLineServiceContractId 
	,SLSCD.strServiceContractNumber
	,SLSCD.dtmContractDate
	,SLSCD.dtmValidFrom
	,SLSCD.dtmValidTo
	,SLSCD.strAmendmentNumber 
	,SLSCD.dtmAmendmentDate
	,SLSCD.intOriginId
	,strOrigin = OG.strDescription
	,SLSCD.strOwner
	,SLSCD.strFreightClause
	,SLSC.intEntityId
	,strShippingLine = E.strName
	,SLSC.dtmDate
FROM 
tblLGShippingLineServiceContractDetail SLSCD
JOIN tblLGShippingLineServiceContract SLSC ON SLSCD.intShippingLineServiceContractId = SLSC.intShippingLineServiceContractId
JOIN tblEMEntity E ON E.intEntityId = SLSC.intEntityId
LEFT JOIN tblICCommodityAttribute OG ON OG.intCommodityAttributeId = SLSCD.intOriginId