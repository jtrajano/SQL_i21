CREATE VIEW vyuIPPriceContract
AS
SELECT PC.intPriceContractId
	,PC.strPriceContractNo
	,UM.strUnitMeasure
	,C.strCurrency
	,Comm.strCommodityCode
	,PC.intPriceContractRefId
	,PC.dtmCreated
	,PC.dtmLastModified
	,EC.strName AS strCreatedBy
	,EU.strName AS strLastModifiedBy
FROM tblCTPriceContract PC
JOIN tblICCommodityUnitMeasure CUM ON CUM.intCommodityUnitMeasureId = PC.intFinalPriceUOMId
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CUM.intUnitMeasureId
LEFT JOIN tblSMCurrency C ON C.intCurrencyID = PC.intFinalCurrencyId
LEFT JOIN tblICCommodity Comm ON Comm.intCommodityId = PC.intCommodityId
LEFT JOIN tblEMEntity EC ON EC.intEntityId = PC.intCreatedById
LEFT JOIN tblEMEntity EU ON EU.intEntityId = PC.intLastModifiedById

