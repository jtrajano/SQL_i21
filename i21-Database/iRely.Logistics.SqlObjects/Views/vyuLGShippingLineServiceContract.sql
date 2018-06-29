CREATE VIEW vyuLGShippingLineServiceContract
AS
SELECT SLSC.intShippingLineServiceContractId
	,SLSC.intEntityId
	,SLSC.dtmDate
	,E.strName AS strShippingLine
FROM tblLGShippingLineServiceContract SLSC
JOIN tblEMEntity E ON E.intEntityId = SLSC.intEntityId
