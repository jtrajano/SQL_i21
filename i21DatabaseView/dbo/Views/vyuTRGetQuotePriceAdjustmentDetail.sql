CREATE VIEW [dbo].[vyuTRGetQuotePriceAdjustmentDetail]
	AS

SELECT QPADetail.intQuotePriceAdjustmentDetailId
	, QPADetail.intQuotePriceAdjustmentHeaderId
	, QPAHeader.intCustomerGroupId
	, QPAHeader.strCustomerGroup
	, QPAHeader.intEntityCustomerId
	, QPAHeader.strCustomerName
	, QPAHeader.intEntityVendorId
	, QPAHeader.strFuelSupplier
	, QPAHeader.intEntityLocationId
	, QPAHeader.strSupplyPoint
	, QPADetail.intItemId
	, Item.strItemNo
	, strItemDescription = Item.strDescription
	, QPADetail.intCategoryId
	, strCategory = Category.strCategoryCode
	, QPADetail.dblAdjustment
	, QPADetail.dblTermsPerUnit
	, QPADetail.dblMiscPerUnit
	, QPADetail.dtmFromEffectiveDateTime
	, QPADetail.dtmToEffectiveDateTime
FROM tblTRQuotePriceAdjustmentDetail QPADetail
LEFT JOIN vyuTRGetQuotePriceAdjustmentHeader QPAHeader ON QPAHeader.intQuotePriceAdjustmentHeaderId = QPADetail.intQuotePriceAdjustmentHeaderId
LEFT JOIN tblICItem Item ON Item.intItemId = QPADetail.intItemId
LEFT JOIN tblICCategory Category ON Category.intCategoryId = QPADetail.intCategoryId