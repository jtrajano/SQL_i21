CREATE PROCEDURE [dbo].[uspAPExportPO](
	@strPurchaseOrderNumber NVARCHAR(30)
)
AS
SELECT 
'H',
Vendor.strName ,
CONVERT(NVARCHAR(20), A.dtmDate, 101),
Term.strTerm,
shipFrom.strLocationName,
shipTo.strLocationName,
shipVia.strShipVia,
freightTerm.strFreightTerm,
orderBy.strUserName,
CONVERT(NVARCHAR(20), A.dtmExpectedDate, 101),
A.strReference,
A.strVendorOrderNumber
FROM 
tblPOPurchase A
left join tblEMEntity Vendor on Vendor.intEntityId = A.intEntityVendorId
left join tblEMEntityLocation shipFrom on shipFrom.intEntityLocationId = A.intShipFromId
left join tblSMCompanyLocation shipTo on shipTo.intCompanyLocationId = A.intShipToId
left join tblSMShipVia shipVia on shipVia.intEntityId = A.intShipViaId
left join vyuSMFreightTerms freightTerm on freightTerm.intFreightTermId = A.intFreightTermId
left join tblSMUserSecurity orderBy on orderBy.intEntityId = A.intOrderById
left join tblSMTerm Term on Term.intTermID = A.intTermsId
WHERE strPurchaseOrderNumber = @strPurchaseOrderNumber

SELECT 
'D',
iTem.strItemNo,
UOM.strUnitMeasure,
A.dblQtyOrdered,
A.dblCost
FROM 
tblPOPurchaseDetail A
join tblPOPurchase B on A.intPurchaseId = B.intPurchaseId
left join vyuICGetItemStock iTem on iTem.intItemId= A.intItemId and iTem.intLocationId =B.intShipToId
left join vyuICGetItemPricing UOM on UOM.intItemUnitMeasureId = A.intUnitOfMeasureId and UOM.intLocationId =B.intShipToId 
WHERE strPurchaseOrderNumber = @strPurchaseOrderNumber

GO

