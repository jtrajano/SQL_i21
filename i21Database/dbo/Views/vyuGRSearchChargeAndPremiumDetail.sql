CREATE VIEW [dbo].[vyuGRSearchChargeAndPremiumDetail]
AS
SELECT
	CAPD.intChargeAndPremiumDetailId
	,CAP.strChargeAndPremiumId
	,CAPD.intChargeAndPremiumId
	,CAP_ITEM.strItemNo AS strChargeAndPremiumItemNo
	,CAP_ITEM.intItemId AS intChargeAndPremiumItemId
	,CAP_ITEM.strDescription AS strChargeAndPremiumItemDescription
	,CT.intCalculationTypeId
	,CT.strCalculationType
	,DISC_ITEM.strItemNo AS strOtherChargeItemNo
	,DISC_ITEM.intItemId AS intOtherChargeItemId
	,INV_ITEM.strItemNo AS strInventoryItemNo
	,INV_ITEM.intItemId AS intInventoryItemId
	,CAPD.dblRate
	,CAPD.strRateType
	,CAPD.dtmEffectiveDate
	,CAPD.dtmTerminationDate
	,CAPD.intConcurrencyId
	,CAPD.ysnDeductVendor
FROM tblGRChargeAndPremiumDetail CAPD
INNER JOIN tblGRChargeAndPremiumId CAP
	ON CAP.intChargeAndPremiumId = CAPD.intChargeAndPremiumId
INNER JOIN tblGRCalculationType CT
	ON CT.intCalculationTypeId = CAPD.intCalculationTypeId
LEFT JOIN tblICItem CAP_ITEM
	ON CAP_ITEM.intItemId = CAPD.intChargeAndPremiumItemId
LEFT JOIN tblICItem DISC_ITEM
	ON DISC_ITEM.intItemId = CAPD.intOtherChargeItemId
LEFT JOIN tblICItem INV_ITEM
	ON INV_ITEM.intItemId = CAPD.intInventoryItemId