CREATE VIEW [dbo].[vyuTFFreightSurcharge]
	AS 
SELECT CF.intFreightXRefId
	,C.intShipViaId
	,ShipVia.strName AS strShipViaName
	,CF.intCategoryId
	,CAT.strCategoryCode AS strCategoryCode
	,AR.intEntityTariffTypeId
	,CF.intEntityCustomerId
	,Customer.strName AS strCustomerName
	,C.dtmEffectiveDateTime
	,CONVERT(int,CF.dblFreightMiles) intFreightMiles
	,C.dblReceiptFreightRate
	,C.dblInvoiceFreightRate
	,C.dtmSurchargeEffectiveDateTime
	,C.dblInvoiceSurchargePercentage
	,C.dblReceiptSurchargePercentage
FROM tblARCustomerFreightXRef CF 
	INNER JOIN tblARCustomer AR on AR.intEntityId = CF.intEntityCustomerId
	INNER JOIN tblICCategory CAT ON CAT.intCategoryId = CF.intCategoryId
	INNER JOIN tblEMEntity Customer ON Customer.intEntityId = CF.intEntityCustomerId
CROSS APPLY (
	SELECT  * FROM dbo.fnTRGetFreightSurcharge(CF.strFreightType, CF.intCategoryId, AR.intEntityTariffTypeId, CF.dblFreightRate, CONVERT(int,CF.dblFreightMiles))
) C
	INNER JOIN tblEMEntity ShipVia ON ShipVia.intEntityId = C.intShipViaId
