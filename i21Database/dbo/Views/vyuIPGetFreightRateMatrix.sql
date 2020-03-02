CREATE VIEW vyuIPGetFreightRateMatrix
AS
SELECT F.intFreightRateMatrixId
	,F.intEntityId
	,F.intType
	,F.strServiceContractNo
	,F.dtmDate
	,F.dtmValidFrom
	,F.dtmValidTo
	,F.strOriginPort
	,F.strDestinationCity
	,F.intLeadTime
	,F.dblBasicCost
	,F.intCurrencyId
	,F.intContainerTypeId
	,F.dblFuelCost
	,F.dblAdditionalCost
	,F.dblTerminalHandlingCharges
	,F.dblDestinationDeliveryCharges
	,F.dblTotalCostPerContainer
	,F.intConcurrencyId
	,C.strCurrency
	,CT.strContainerType
	,E.strName
FROM tblLGFreightRateMatrix F WITH (NOLOCK)
LEFT JOIN tblSMCurrency C WITH (NOLOCK) ON C.intCurrencyID = F.intCurrencyId
LEFT JOIN tblLGContainerType CT WITH (NOLOCK) ON CT.intContainerTypeId = F.intContainerTypeId
LEFT JOIN tblEMEntity E WITH (NOLOCK) ON E.intEntityId = F.intEntityId
