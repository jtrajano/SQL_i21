CREATE VIEW [dbo].[vyuApiTransportFreightSurcharge]
	AS 
SELECT 
     CAST(ROW_NUMBER() OVER(ORDER BY C.intShipViaId ASC) AS INT) AS [intId]
	,CF.intFreightXRefId
	,C.intShipViaId
	,ShipVia.strName AS strShipViaName
	,CF.intCategoryId
	,CAT.strCategoryCode AS strCategoryCode
	,AR.intEntityTariffTypeId
	,CF.intEntityCustomerId
	,Customer.strName AS strCustomerName
	,C.dtmEffectiveDateTime
	,CF.intEntityLocationId
	,LOC.strLocationName AS strCustomerLocation
	,CONVERT(int,CF.dblFreightMiles) intFreightMiles
	,C.dblReceiptFreightRate
	,C.dblInvoiceFreightRate
	,C.dtmSurchargeEffectiveDateTime
	,C.dblSurchargePercentage
	,SupplyPointLoc.intEntityLocationId AS intSupplyPointId
	,SupplyPointLoc.strLocationName AS strSupplyPoint
	,Vendor.intEntityId AS intEntityVendorId
	,Vendor.strName  AS strVendorName
FROM tblARCustomerFreightXRef CF 
	INNER JOIN tblARCustomer AR on AR.intEntityId = CF.intEntityCustomerId
	INNER JOIN tblICCategory CAT ON CAT.intCategoryId = CF.intCategoryId
	INNER JOIN tblEMEntity Customer ON Customer.intEntityId = CF.intEntityCustomerId
	INNER JOIN tblEMEntityLocation LOC ON LOC.intEntityLocationId = CF.intEntityLocationId  AND LOC.intEntityId = CF.intEntityCustomerId
	INNER JOIN tblEMEntityLocation SupplyPointLoc ON SupplyPointLoc.strZipCode = CF.strZipCode
	INNER JOIN tblAPVendor Supplier ON Supplier.intEntityId = SupplyPointLoc.intEntityId
	INNER JOIN tblEMEntity Vendor ON Vendor.intEntityId = Supplier.intEntityId
CROSS APPLY (
	SELECT  * FROM dbo.fnTRGetFreightSurcharge(CF.strFreightType, CF.intCategoryId, AR.intEntityTariffTypeId, CF.dblFreightRate, CONVERT(int,CF.dblFreightMiles))
) C
	INNER JOIN tblEMEntity ShipVia ON ShipVia.intEntityId = C.intShipViaId
