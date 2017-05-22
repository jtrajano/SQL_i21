CREATE VIEW dbo.vyuSCPrintPreviewTicketView
AS SELECT SC.intTicketId, (CASE WHEN
    SC.strTicketStatus = 'O' THEN 'OPEN' WHEN
    SC.strTicketStatus = 'A' THEN 'PRINTED' WHEN
    SC.strTicketStatus = 'C' THEN 'COMPLETED' WHEN
    SC.strTicketStatus = 'V' THEN 'VOID' WHEN
    SC.strTicketStatus = 'R' THEN 'REOPENED' END) AS
    strTicketStatusDescription, 
	SC.strTicketStatus,
    SC.strTicketNumber, 
	SC.intScaleSetupId,
    SC.intTicketPoolId, 
	SC.intTicketLocationId,
    SC.intTicketType, 
	SC.strInOutFlag,
	SC.dtmTicketDateTime,
	SC.dtmTicketTransferDateTime,
	SC.dtmTicketVoidDateTime,
	SC.intProcessingLocationId,
	SC.strScaleOperatorUser,
	SC.intEntityScaleOperatorId,
	SC.strPurchaseOrderNumber,
	SC.strTruckName,
	SC.strDriverName, 
	SC.ysnDriverOff,
	SC.ysnSplitWeightTicket,
	SC.ysnGrossManual,
	SC.dblGrossWeight, 
	SC.dblGrossWeightOriginal,
	SC.dblGrossWeightSplit1,
	SC.dblGrossWeightSplit2, 
	SC.dtmGrossDateTime,
	SC.intGrossUserId, 
	SC.ysnTareManual,
	SC.dblTareWeight, 
	SC.dblTareWeightOriginal,
	SC.dblTareWeightSplit1,
	SC.dblTareWeightSplit2, 
	SC.dtmTareDateTime,
	SC.intTareUserId, 
	SC.dblGrossUnits,
	SC.dblNetUnits, 
	SC.strItemNumber,
	SC.strItemUOM, 
	SC.intCustomerId,
	SC.intSplitId, 
	SC.strDistributionOption,
	SC.intDiscountSchedule,
	SC.strDiscountLocation, 
	SC.dtmDeferDate,
	SC.strContractNumber, 
	SC.intContractSequence,
	SC.strContractLocation, 
	SC.dblUnitPrice,
	SC.dblUnitBasis, 
	SC.dblTicketFees,
	SC.intCurrencyId, 
	SC.dblCurrencyRate,
	SC.strTicketComment, 
	SC.strCustomerReference,
	SC.ysnTicketPrinted,
	SC.ysnPlantTicketPrinted,
	SC.ysnGradingTagPrinted,
	SC.intHaulerId,
	SC.intFreightCarrierId,
	SC.dblFreightRate,
	SC.dblFreightAdjustment,
	SC.intFreightCurrencyId,
	SC.dblFreightCurrencyRate,
	SC.strFreightCContractNumber,
	SC.strFreightSettlement,
	SC.ysnFarmerPaysFreight,
	SC.strLoadNumber,
	SC.intLoadLocationId,
	SC.intAxleCount,
	SC.strBinNumber,
	SC.strPitNumber,
	SC.intGradingFactor,
	SC.strVarietyType,
	SC.strFarmNumber,
	SC.strFieldNumber,
	SC.strDiscountComment,
	SC.strCommodityCode,
	SC.intCommodityId,
	SC.intDiscountId,
	SC.intContractId,
	SC.intDiscountLocationId,
	SC.intItemId,
	SC.intEntityId,
	SC.intLoadId,
	SC.intMatchTicketId,
	SC.intSubLocationId,
	SC.intStorageLocationId,
	SC.intFarmFieldId,
	SC.intDistributionMethod,
	SC.intSplitInvoiceOption,
	SC.intDriverEntityId,
	SC.intStorageScheduleId,
	SC.intConcurrencyId,
	SC.dblNetWeightDestination,
	SC.ysnUseDestinationWeight,
	SC.ysnUseDestinationGrades,
	SC.ysnHasGeneratedTicketNumber,
	SC.intInventoryTransferId,
	SC.dblShrink,
	SC.dblConvertedUOMQty,
	SC.strCostMethod,
	(SC.dblUnitPrice + SC.dblUnitBasis) AS dblCashPrice,
	ISNULL (tblGRStorageType.strStorageTypeDescription, CASE WHEN
	SC.strDistributionOption = 'CNT' THEN 'Contract' WHEN
	SC.strDistributionOption = 'LOD' THEN 'Load' WHEN
	SC.strDistributionOption = 'SPT' THEN 'Spot Sale' WHEN
	SC.strDistributionOption = 'SPL' THEN 'Split' WHEN
	SC.strDistributionOption = 'HLD' THEN 'Hold' END) AS
	strStorageTypeDescription,
	tblEMEntity.strName,
	tblSCListTicketTypes.strTicketType,
	tblSMCompanyLocation.strLocationName,
	tblSMCompanyLocationSubLocation.strSubLocationName, 
	tblSCScaleSetup.strStationShortDescription,
	tblSCScaleSetup.strWeightDescription,
	tblEMEntitySplit.strSplitNumber,
	tblSCTicketPool.strTicketPool, tblGRDiscountId.strDiscountId,
	tblICStorageLocation.strDescription,
	tblGRStorageScheduleRule.strScheduleId,
	tblICInventoryReceipt.intInventoryReceiptId,
	tblICInventoryReceipt.strReceiptNumber,
	vyuICGetInventoryShipmentItem.intInventoryShipmentId,
	vyuICGetInventoryShipmentItem.strShipmentNumber,
	(SELECT strCompanyName FROM tblSMCompanySetup) AS strCompanyName,
	(SELECT strAddress FROM tblSMCompanySetup) AS strAddress,
	vyuEMSearchShipVia.strName AS strHaulerName,
	(SELECT intCurrencyDecimal FROM tblSMCompanyPreference) AS intDecimalPrecision
  FROM tblSCTicket SC
  LEFT JOIN tblEMEntity tblEMEntity on tblEMEntity.intEntityId = SC.intEntityId
  LEFT JOIN vyuEMSearchShipVia vyuEMSearchShipVia on vyuEMSearchShipVia.intEntityId = SC.intHaulerId
  LEFT JOIN tblEMEntitySplit tblEMEntitySplit on tblEMEntitySplit.intSplitId = SC.intSplitId
  LEFT JOIN tblSCScaleSetup tblSCScaleSetup on tblSCScaleSetup.intScaleSetupId = SC.intScaleSetupId
  LEFT JOIN tblSMCompanyLocation tblSMCompanyLocation on tblSMCompanyLocation.intCompanyLocationId = SC.intProcessingLocationId
  LEFT JOIN tblSCListTicketTypes tblSCListTicketTypes on (tblSCListTicketTypes.intTicketType = SC.intTicketType AND tblSCListTicketTypes.strInOutIndicator = SC.strInOutFlag)
  LEFT JOIN tblGRStorageType tblGRStorageType on tblGRStorageType.strStorageTypeCode = SC.strDistributionOption
  LEFT JOIN tblSMCompanyLocationSubLocation tblSMCompanyLocationSubLocation on tblSMCompanyLocationSubLocation.intCompanyLocationSubLocationId = SC.intSubLocationId
  LEFT JOIN tblSCTicketPool tblSCTicketPool on tblSCTicketPool.intTicketPoolId = SC.intTicketPoolId
  LEFT JOIN tblGRDiscountId tblGRDiscountId on tblGRDiscountId.intDiscountId = SC.intDiscountId
  LEFT JOIN tblICStorageLocation tblICStorageLocation on tblICStorageLocation.intStorageLocationId = SC.intStorageLocationId
  LEFT JOIN tblGRStorageScheduleRule tblGRStorageScheduleRule on tblGRStorageScheduleRule.intStorageScheduleRuleId = SC.intStorageScheduleId
  LEFT JOIN tblICInventoryReceipt tblICInventoryReceipt on tblICInventoryReceipt.intInventoryReceiptId = SC.intInventoryReceiptId
  LEFT JOIN vyuICGetInventoryShipmentItem vyuICGetInventoryShipmentItem on vyuICGetInventoryShipmentItem.intSourceId = SC.intTicketId
