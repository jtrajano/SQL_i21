CREATE VIEW vyuLGInsuranceCalculatorNotMapped
AS
SELECT INC.*
	,SCU.strCurrency AS strShipmentValueCurrency
	,BCU.strCurrency AS strBrokerageCurrency
	,RCU.strCurrency AS strRatePerContainerCurrency
	,FCU.strCurrency AS strFreightCurrency
	,ICU.strCurrency AS strInsuranceValueCurrency
	,L.intShippingLineEntityId
	,SE.strName AS strShippingLineEntity
FROM tblLGInsuranceCalculator INC
JOIN tblLGLoad L ON L.intLoadId = INC.intLoadId
JOIN tblSMCurrency SCU ON SCU.intCurrencyID = INC.intShipmentValueCurrencyId
JOIN tblSMCurrency BCU ON BCU.intCurrencyID = INC.intBrokerageCurrencyId
JOIN tblSMCurrency RCU ON RCU.intCurrencyID = INC.intRatePerContainerCurrencyId
JOIN tblSMCurrency FCU ON FCU.intCurrencyID = INC.intFreightCurrencyId
JOIN tblSMCurrency ICU ON ICU.intCurrencyID = INC.intInsuranceValueCurrencyId
JOIN tblEMEntity SE ON SE.intEntityId = L.intShippingLineEntityId