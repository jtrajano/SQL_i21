CREATE VIEW vyuLGInsurancePremiumFactor
AS
SELECT IP.intInsurancePremiumFactorId
	,IP.intEntityId
	,IP.dtmDate
	,E.strName AS strInsurer
FROM tblLGInsurancePremiumFactor IP
JOIN tblEMEntity E ON E.intEntityId = IP.intEntityId
