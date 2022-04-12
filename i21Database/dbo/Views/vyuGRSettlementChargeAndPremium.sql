CREATE VIEW [dbo].[vyuGRSettlementChargeAndPremium]
AS
SELECT
    [intAppliedChargeAndPremiumId]	    =   ACAP.intAppliedChargeAndPremiumId
    ,[intTransactionId]                 =   SS.intSettleStorageId
    ,[intTransactionDetailId]		    =   SST.intSettleStorageTicketId
    ,[intParentSettleStorageId]         =   SS.intParentSettleStorageId
    ,[strTransactionType]			    =   'Settlement'
    ,[intCustomerStorageId]             =   CS.intCustomerStorageId
    ,[strStorageTicketNumber]           =   CS.strStorageTicketNumber
    ,[intChargeAndPremiumId]		    =   ACAP.intChargeAndPremiumId
    ,[strChargeAndPremiumId]		    =   ACAP.strChargeAndPremiumId
    ,[intChargeAndPremiumDetailId]	    =   ACAP.intChargeAndPremiumDetailId
    ,[intChargeAndPremiumItemId]	    =   ACAP.intChargeAndPremiumItemId
    ,[strChargeAndPremiumItemNo]        =   CAP_ITEM.strItemNo
    ,[intCalculationTypeId]			    =   CT.intCalculationTypeId
    ,[strCalculationType]			    =   CT.strCalculationType
    ,[dblRate]						    =   ACAP.dblRate
    ,[strRateType]					    =   ACAP.strRateType
    ,[dblQty]						    =   ACAP.dblQty
    ,[intChargeAndPremiumItemUOMId]	    =   ACAP.intChargeAndPremiumItemUOMId
    ,[strChargeAndPremiumItemUOM]       =   UOM.strUnitMeasure
    ,[dblCost]						    =   ACAP.dblCost
    ,[dblAmount]					    =   ACAP.dblQty * ACAP.dblCost
    ,[intOtherChargeItemId]			    =   ACAP.intOtherChargeItemId
    ,[strOtherChargeItemNo]			    =   OC_ITEM.strItemNo
    ,[intInventoryItemId]			    =   ACAP.intInventoryItemId
    ,[strInventoryItemNo]			    =   INV_ITEM.strItemNo
    ,[dblInventoryItemNetUnits]		    =   ACAP.dblInventoryItemNetUnits
    ,[dblInventoryItemGrossUnits]	    =   ACAP.dblInventoryItemGrossUnits
    ,[intCtOtherChargeItemId]			=   ACAP.intCtOtherChargeItemId
    ,[strCtOtherChargeItemNo]			=   CT_OC_ITEM.strItemNo
    --,[dblCtOtherChargeRate]				=	ACAP.dblCtOtherChargeRate
    ,[dblGradeReading]                  =   TD.dblGradeReading
FROM tblGRAppliedChargeAndPremium ACAP
INNER JOIN tblICItem CAP_ITEM
    ON CAP_ITEM.intItemId = ACAP.intChargeAndPremiumItemId
INNER JOIN tblGRCalculationType CT
    ON CT.intCalculationTypeId = ACAP.intCalculationTypeId
INNER JOIN tblICItemUOM CAP_ITEM_UOM
    ON CAP_ITEM_UOM.intItemUOMId = ACAP.intChargeAndPremiumItemUOMId
INNER JOIN tblICUnitMeasure UOM
    ON UOM.intUnitMeasureId = CAP_ITEM_UOM.intUnitMeasureId
INNER JOIN tblGRSettleStorage SS
    ON SS.intSettleStorageId = ACAP.intTransactionId
    AND ACAP.strTransactionType = 'Settlement'
INNER JOIN tblGRSettleStorageTicket SST
    ON SST.intSettleStorageId = SS.intSettleStorageId
    AND ACAP.intTransactionDetailId = SST.intSettleStorageTicketId
INNER JOIN tblGRCustomerStorage CS
    ON CS.intCustomerStorageId = SST.intCustomerStorageId
LEFT JOIN (tblQMTicketDiscount TD
			INNER JOIN tblGRDiscountScheduleCode DSC
				ON DSC.intDiscountScheduleCodeId = TD.intDiscountScheduleCodeId
	)
	ON TD.intTicketFileId = CS.intCustomerStorageId
		AND TD.strSourceType = 'Storage'
		AND DSC.intItemId = ACAP.intCtOtherChargeItemId
		AND CT.intCalculationTypeId = 2 --range by grade reading
LEFT JOIN tblICItem INV_ITEM
    ON INV_ITEM.intItemId = ACAP.intInventoryItemId
LEFT JOIN tblICItem OC_ITEM
    ON OC_ITEM.intItemId = ACAP.intOtherChargeItemId
LEFT JOIN tblICItem CT_OC_ITEM
    ON CT_OC_ITEM.intItemId = ACAP.intCtOtherChargeItemId

GO