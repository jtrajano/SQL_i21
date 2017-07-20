CREATE VIEW [dbo].[vyuSCTicketView]
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
       tblSCTicket.ysnGross1Manual,
       tblSCTicket.ysnGross2Manual,
       tblSCTicket.dblGrossWeight,
       tblSCTicket.dblGrossWeight1,
       tblSCTicket.dblGrossWeight2,
       tblSCTicket.dblGrossWeightOriginal,
       tblSCTicket.dblGrossWeightSplit1,
       tblSCTicket.dblGrossWeightSplit2,
       tblSCTicket.dtmGrossDateTime,
       tblSCTicket.dtmGrossDateTime1,
       tblSCTicket.dtmGrossDateTime2,
       tblSCTicket.intGrossUserId,
       tblSCTicket.ysnTareManual,
       tblSCTicket.ysnTare1Manual,
       tblSCTicket.ysnTare2Manual,
       tblSCTicket.dblTareWeight,
       tblSCTicket.dblTareWeight1,
       tblSCTicket.dblTareWeight2,
       tblSCTicket.dblTareWeightOriginal,
       tblSCTicket.dblTareWeightSplit1,
       tblSCTicket.dblTareWeightSplit2,
       tblSCTicket.dtmTareDateTime,
       tblSCTicket.dtmTareDateTime1,
       tblSCTicket.dtmTareDateTime2,
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
	   tblSCTicket.intAxleCount1,
	   tblSCTicket.intAxleCount2,
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
       tblSCTicket.dblNetWeightDestination,
       tblSCTicket.ysnUseDestinationWeight,
       tblSCTicket.ysnUseDestinationGrades,
       tblSCTicket.ysnHasGeneratedTicketNumber,
       tblSCTicket.intInventoryTransferId,
       tblSCTicket.dblShrink,
       tblSCTicket.dblConvertedUOMQty,
	   tblSCTicket.strFreightSettlement,
	   tblSCTicket.intDeliverySheetId,
	   tblSCTicket.strElevatorReceiptNumber,
	   tblSCDeliverySheet.strDeliverySheetNumber,
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
	   tblEMEntityFarm.strFarmDescription
  from ((tblSCTicket tblSCTicket
	left join tblEMEntity tblEMEntity
       on (tblEMEntity.intEntityId = tblSCTicket.intEntityId)
	left join tblEMEntitySplit tblEMEntitySplit
       on ([tblEMEntitySplit].intSplitId = tblSCTicket.intSplitId)
	left join tblSCScaleSetup tblSCScaleSetup
       on (tblSCScaleSetup.intScaleSetupId = tblSCTicket.intScaleSetupId)
	left join tblSMCompanyLocation tblSMCompanyLocation
       on (tblSMCompanyLocation.intCompanyLocationId = tblSCTicket.intProcessingLocationId))
	left join tblSCListTicketTypes tblSCListTicketTypes
       on (tblSCListTicketTypes.intTicketType = tblSCTicket.intTicketType AND tblSCListTicketTypes.strInOutIndicator = tblSCTicket.strInOutFlag)
	left join tblGRStorageType tblGRStorageType
       on (tblGRStorageType.strStorageTypeCode = tblSCTicket.strDistributionOption)
	left join tblSMCompanyLocationSubLocation tblSMCompanyLocationSubLocation
       on (tblSMCompanyLocationSubLocation.intCompanyLocationSubLocationId = tblSCTicket.intSubLocationId))
	left join tblSCTicketPool tblSCTicketPool
       on tblSCTicketPool.intTicketPoolId = tblSCTicket.intTicketPoolId
	left join tblGRDiscountId tblGRDiscountId
       on tblGRDiscountId.intDiscountId = tblSCTicket.intDiscountId
	left join tblICStorageLocation tblICStorageLocation
       on tblICStorageLocation.intStorageLocationId = tblSCTicket.intStorageLocationId
	left join tblGRStorageScheduleRule tblGRStorageScheduleRule
       on tblGRStorageScheduleRule.intStorageScheduleRuleId = tblSCTicket.intStorageScheduleId
	left join tblICInventoryReceipt tblICInventoryReceipt
	   on  tblICInventoryReceipt.intInventoryReceiptId = tblSCTicket.intInventoryReceiptId
	left join tblICInventoryShipment tblICInventoryShipment
	   on  tblICInventoryShipment.intInventoryShipmentId = tblSCTicket.intInventoryShipmentId
	left join tblEMEntityFarm tblEMEntityFarm
	   on tblEMEntityFarm.intFarmFieldId = tblSCTicket.intFarmFieldId
	left join tblSCDeliverySheet tblSCDeliverySheet
	   on tblSCDeliverySheet.intDeliverySheetId = tblSCTicket.intDeliverySheetId
