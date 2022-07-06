CREATE VIEW [dbo].[vyuApiVendorRebateItem]
AS
SELECT
	x.intItemVendorXrefId
	, x.intItemId
	, i.strItemNo
	, x.intItemLocationId
	, x.intVendorId
	, ev.strName strVendorName
	, x.intVendorSetupId
	, x.strVendorProduct
	, x.strProductDescription
	, x.dblConversionFactor
	, x.intItemUnitMeasureId
FROM tblICItemVendorXref x
INNER JOIN tblICItem i ON i.intItemId = x.intItemId
LEFT JOIN tblEMEntity ev ON ev.intEntityId = x.intVendorId