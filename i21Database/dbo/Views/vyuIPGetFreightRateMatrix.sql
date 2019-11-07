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
FROM tblLGFreightRateMatrix F
JOIN tblSMCurrency C ON C.intCurrencyID = F.intCurrencyId
JOIN tblLGContainerType CT ON CT.intContainerTypeId = F.intContainerTypeId
JOIN tblEMEntity E ON E.intEntityId = F.intEntityId
