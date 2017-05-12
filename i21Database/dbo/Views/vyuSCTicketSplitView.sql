CREATE VIEW [dbo].[vyuSCTicketSplitView]
	AS select tblSCTicket.intTicketId,
	   (CASE 
			WHEN tblSCTicket.strTicketStatus = 'O' THEN 'OPEN'
			WHEN tblSCTicket.strTicketStatus = 'A' THEN 'PRINTED'
			WHEN tblSCTicket.strTicketStatus = 'C' THEN 'COMPLETED'
			WHEN tblSCTicket.strTicketStatus = 'V' THEN 'VOID'
			WHEN tblSCTicket.strTicketStatus = 'R' THEN 'REOPENED'
		END) AS strTicketStatusDescription,
	   tblSCTicket.strTicketStatus,
       tblSCTicket.strTicketNumber,
       tblSCTicket.intScaleSetupId,
       tblSCTicket.intTicketPoolId,
       tblSCTicket.intTicketLocationId,
       tblSCTicket.intTicketType,
       tblSCTicket.strInOutFlag,
       tblSCTicket.dtmTicketDateTime,
       tblSCTicket.dtmTicketTransferDateTime,
       tblSCTicket.dtmTicketVoidDateTime,
       tblSCTicket.intProcessingLocationId,
       tblSCTicket.strScaleOperatorUser,
       tblSCTicket.intEntityScaleOperatorId,
       tblSCTicket.strPurchaseOrderNumber,
       tblSCTicket.strTruckName,
       tblSCTicket.strDriverName,
       tblSCTicket.ysnDriverOff,
       tblSCTicket.ysnSplitWeightTicket,
       tblSCTicket.ysnGrossManual,
       tblSCTicket.dblGrossWeight,
       tblSCTicket.dblGrossWeightOriginal,
       tblSCTicket.dblGrossWeightSplit1,
       tblSCTicket.dblGrossWeightSplit2,
       tblSCTicket.dtmGrossDateTime,
       tblSCTicket.intGrossUserId,
       tblSCTicket.ysnTareManual,
       tblSCTicket.dblTareWeight,
       tblSCTicket.dblTareWeightOriginal,
       tblSCTicket.dblTareWeightSplit1,
       tblSCTicket.dblTareWeightSplit2,
       tblSCTicket.dtmTareDateTime,
       tblSCTicket.intTareUserId,
       tblSCTicket.dblGrossUnits,
       tblSCTicket.dblNetUnits,
	   (tblSCTicket.dblGrossWeight - tblSCTicket.dblTareWeight) AS dblNetWeight,
       tblSCTicket.strItemNumber,
       tblSCTicket.strItemUOM,
       tblSCTicket.intCustomerId,
       tblSCTicket.intSplitId,
       tblSCTicket.strDistributionOption,
       tblSCTicket.intDiscountSchedule,
       tblSCTicket.strDiscountLocation,
       tblSCTicket.dtmDeferDate,
       tblSCTicket.strContractNumber,
       tblSCTicket.intContractSequence,
       tblSCTicket.strContractLocation,
       tblSCTicket.dblUnitPrice,
       tblSCTicket.dblUnitBasis,
       tblSCTicket.dblTicketFees,
       tblSCTicket.intCurrencyId,
       tblSCTicket.dblCurrencyRate,
       tblSCTicket.strTicketComment,
       tblSCTicket.strCustomerReference,
       tblSCTicket.ysnTicketPrinted,
       tblSCTicket.ysnPlantTicketPrinted,
       tblSCTicket.ysnGradingTagPrinted,
       tblSCTicket.intHaulerId,
       tblSCTicket.intFreightCarrierId,
       tblSCTicket.dblFreightRate,
       tblSCTicket.dblFreightAdjustment,
       tblSCTicket.intFreightCurrencyId,
       tblSCTicket.dblFreightCurrencyRate,
       tblSCTicket.strFreightCContractNumber,
       tblSCTicket.ysnFarmerPaysFreight,
       tblSCTicket.strLoadNumber,
       tblSCTicket.intLoadLocationId,
       tblSCTicket.intAxleCount,
       tblSCTicket.strBinNumber,
       tblSCTicket.strPitNumber,
       tblSCTicket.intGradingFactor,
       tblSCTicket.strVarietyType,
       tblSCTicket.strFarmNumber,
       tblSCTicket.strFieldNumber,
       tblSCTicket.strDiscountComment,
       tblSCTicket.strCommodityCode,
       tblSCTicket.intCommodityId,
       tblSCTicket.intDiscountId,
       tblSCTicket.intContractId,
       tblSCTicket.intDiscountLocationId,
       tblSCTicket.intItemId,
       tblSCTicket.intEntityId,
       tblSCTicket.intLoadId,
       tblSCTicket.intMatchTicketId,
       tblSCTicket.intSubLocationId,
       tblSCTicket.intStorageLocationId,
       tblSCTicket.intFarmFieldId,
       tblSCTicket.intDistributionMethod,
       tblSCTicket.intSplitInvoiceOption,
       tblSCTicket.intDriverEntityId,
       tblSCTicket.intStorageScheduleId,
       tblSCTicket.intConcurrencyId,
       tblSCTicket.dblNetWeightDestination,
       tblSCTicket.ysnUseDestinationWeight,
       tblSCTicket.ysnUseDestinationGrades,
       tblSCTicket.ysnHasGeneratedTicketNumber,
       tblSCTicket.intInventoryTransferId,
       tblSCTicket.dblShrink,
       tblSCTicket.dblConvertedUOMQty,
	   tblSCTicket.strFreightSettlement,
       tblEMEntity.strName,
       tblSCListTicketTypes.strTicketType,
	   tblSMCompanyLocation.strLocationName,
	   tblSMCompanyLocationSubLocation.strSubLocationName,
	   ISNULL(tblGRStorageType.strStorageTypeDescription, 
	   CASE 
			WHEN tblSCTicket.strDistributionOption = 'CNT' THEN 'Contract'
			WHEN tblSCTicket.strDistributionOption = 'LOD' THEN 'Load'
			WHEN tblSCTicket.strDistributionOption = 'SPT' THEN 'Spot Sale'
			WHEN tblSCTicket.strDistributionOption = 'SPL' THEN 'Split'
			WHEN tblSCTicket.strDistributionOption = 'HLD' THEN 'Hold'
		END) AS strStorageTypeDescription,
	   tblSCScaleSetup.strStationShortDescription,
	   [tblEMEntitySplit].strSplitNumber,
	   tblSCTicketPool.strTicketPool,
	   tblGRDiscountId.strDiscountId,
	   tblICStorageLocation.strDescription,
	   tblGRStorageScheduleRule.strScheduleId,
	   tblICInventoryReceipt.intInventoryReceiptId,
	   tblICInventoryReceipt.strReceiptNumber,
	   tblICInventoryShipment.intInventoryShipmentId,
	   tblICInventoryShipment.strShipmentNumber,
	   tblEMEntityFarm.strFarmDescription,
	   (SELECT strName from tblEMEntity WHERE intEntityId = tblSCTicketSplit.intCustomerId) AS strSplitEntityName,
	   (CASE 
			WHEN ISNULL(tblSCTicketSplit.intStorageScheduleTypeId,0) != 0 THEN 
			(SELECT strStorageTypeDescription FROM tblGRStorageType WHERE intStorageScheduleTypeId = tblSCTicketSplit.intStorageScheduleTypeId)
			WHEN tblSCTicketSplit.strDistributionOption = 'CNT' THEN 'Contract'
			WHEN tblSCTicketSplit.strDistributionOption = 'SPT' THEN 'Spot Sale'
		END) AS strSplitEntityDistribution,
	   tblSCTicketSplit.dblSplitPercent,
	   ((tblSCTicket.dblNetUnits * tblSCTicketSplit.dblSplitPercent) / 100) as dblSplitUnit,
	   tblICItem.strDescription as strItemDescription
  from tblSCTicketSplit tblSCTicketSplit
	left join tblSCTicket tblSCTicket on tblSCTicketSplit.intTicketId = tblSCTicket.intTicketId
	left join tblICItem tblICItem on tblICItem.intItemId = tblSCTicket.intItemId
	left join tblEMEntity tblEMEntity on tblEMEntity.intEntityId = tblSCTicket.intEntityId
	left join tblEMEntitySplit tblEMEntitySplit on [tblEMEntitySplit].intSplitId = tblSCTicket.intSplitId
	left join tblSCScaleSetup tblSCScaleSetup on tblSCScaleSetup.intScaleSetupId = tblSCTicket.intScaleSetupId
	left join tblSMCompanyLocation tblSMCompanyLocation on tblSMCompanyLocation.intCompanyLocationId = tblSCTicket.intProcessingLocationId
	left join tblSCListTicketTypes tblSCListTicketTypes on tblSCListTicketTypes.intTicketType = tblSCTicket.intTicketType AND tblSCListTicketTypes.strInOutIndicator = tblSCTicket.strInOutFlag
	left join tblGRStorageType tblGRStorageType on tblGRStorageType.strStorageTypeCode = tblSCTicket.strDistributionOption
	left join tblSMCompanyLocationSubLocation tblSMCompanyLocationSubLocation on tblSMCompanyLocationSubLocation.intCompanyLocationSubLocationId = tblSCTicket.intSubLocationId
	left join tblSCTicketPool tblSCTicketPool on tblSCTicketPool.intTicketPoolId = tblSCTicket.intTicketPoolId
	left join tblGRDiscountId tblGRDiscountId on tblGRDiscountId.intDiscountId = tblSCTicket.intDiscountId
	left join tblICStorageLocation tblICStorageLocation on tblICStorageLocation.intStorageLocationId = tblSCTicket.intStorageLocationId
	left join tblGRStorageScheduleRule tblGRStorageScheduleRule on tblGRStorageScheduleRule.intStorageScheduleRuleId = tblSCTicket.intStorageScheduleId
	left join tblICInventoryReceipt tblICInventoryReceipt on  tblICInventoryReceipt.intInventoryReceiptId = tblSCTicket.intInventoryReceiptId
	left join tblICInventoryShipment tblICInventoryShipment on  tblICInventoryShipment.intInventoryShipmentId = tblSCTicket.intInventoryShipmentId
	left join tblEMEntityFarm tblEMEntityFarm on tblEMEntityFarm.intFarmFieldId = tblSCTicket.intFarmFieldId

