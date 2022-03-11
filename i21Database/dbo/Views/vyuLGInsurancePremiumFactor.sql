CREATE VIEW vyuLGInsurancePremiumFactor

AS

SELECT IP.intInsurancePremiumFactorId
	, IP.strPolicyNumber
	, IP.intEntityId
	, E.strName AS strInsurer
	, IP.dtmValidFrom
	, IP.dtmValidTo
	, IP.dblSalesPercent
	, IP.dblPurchasePercent
	, IP.dblInboundWarehouse	
FROM tblLGInsurancePremiumFactor IP
JOIN tblEMEntity E ON E.intEntityId = IP.intEntityId
