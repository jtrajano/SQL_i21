CREATE VIEW [dbo].[vyuSCProductionHistoryReportView]
	AS SELECT SC.intTicketId, (CASE WHEN
    SC.strTicketStatus = 'O' THEN 'OPEN' WHEN
    SC.strTicketStatus = 'A' THEN 'PRINTED' WHEN
    SC.strTicketStatus = 'C' THEN 'COMPLETED' WHEN
    SC.strTicketStatus = 'V' THEN 'VOID' WHEN
    SC.strTicketStatus = 'R' THEN 'REOPENED' END) COLLATE Latin1_General_CI_AS AS
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
	SC.ysnGrossManual,
	SC.dblGrossWeight, 
	SC.dtmGrossDateTime,
	SC.ysnTareManual,
	SC.dblTareWeight, 
	SC.dtmTareDateTime,
	SC.dblGrossUnits,
	SC.dblNetUnits, 
	SC.strItemUOM, 
	SC.intSplitId, 
	SC.strDistributionOption,
	SC.intDiscountSchedule,
	SC.strDiscountLocation, 
	SC.dtmDeferDate,
	SC.strContractNumber, 
	SC.intContractSequence,
	SC.strContractLocation, 
	SC.dblTicketFees,
	SC.intCurrencyId, 
	SC.dblCurrencyRate,
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
	SC.strPitNumber,
	SC.strFarmNumber,
	SC.strFieldNumber,
	SC.strDiscountComment,
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
	EMLocation.strAddress,
	EMLocation.strCity,
	EMLocation.strCountry,
	EMLocation.strPhone,
	tblSCListTicketTypes.strTicketType,
	tblSMCompanyLocation.strLocationName,
	tblSMCompanyLocationSubLocation.strSubLocationName, 
	tblEMEntitySplit.strSplitNumber,
	tblGRStorageScheduleRule.strScheduleId,
	ICCommodity.strCommodityCode,
	tblICStorageLocation.strDescription,
	vyuEMSearchShipVia.strName AS strHaulerName,
	QM.strDiscountCode,
	QM.dblGradeReading,
	tblSMCompanySetup.strCompanyName,
	tblSMCompanySetup.strCompanyAddress,
	tblSMCompanySetup.strCompanyPhone,
	tblSMCompanySetup.strCompanyCity,
	tblSMCompanySetup.strCompanyCountry,
	ReceiptItem.strReceiptNumber,
	ReceiptItem.intInventoryReceiptId,
	ReceiptItem.dblGross,
	ReceiptItem.dblNet,
	ReceiptItem.dblShrinkage,
	ReceiptItem.totalTicket,
	ISNULL(Voucher.dtmDate, ReceiptItem.dtmReceiptDate) AS dtmReceiptDate,
	(SELECT intCurrencyDecimal FROM tblSMCompanyPreference) AS intDecimalPrecision
  FROM tblSCTicket SC
  LEFT JOIN tblICCommodity ICCommodity ON ICCommodity.intCommodityId = SC.intCommodityId
  LEFT JOIN tblEMEntity tblEMEntity on tblEMEntity.intEntityId = SC.intEntityId
  LEFT JOIN tblEMEntityLocation EMLocation ON EMLocation.intEntityId = SC.intEntityId AND EMLocation.ysnDefaultLocation = 1
  LEFT JOIN vyuEMSearchShipVia vyuEMSearchShipVia on vyuEMSearchShipVia.intEntityId = SC.intHaulerId
  LEFT JOIN tblEMEntitySplit tblEMEntitySplit on tblEMEntitySplit.intSplitId = SC.intSplitId
  LEFT JOIN tblSMCompanyLocation tblSMCompanyLocation on tblSMCompanyLocation.intCompanyLocationId = SC.intProcessingLocationId
  LEFT JOIN tblSMCompanyLocationSubLocation tblSMCompanyLocationSubLocation on tblSMCompanyLocationSubLocation.intCompanyLocationSubLocationId = SC.intSubLocationId
  LEFT JOIN tblSCListTicketTypes tblSCListTicketTypes on (tblSCListTicketTypes.intTicketType = SC.intTicketType AND tblSCListTicketTypes.strInOutIndicator = SC.strInOutFlag)
  LEFT JOIN tblGRStorageType tblGRStorageType on tblGRStorageType.strStorageTypeCode = SC.strDistributionOption
  LEFT JOIN tblGRDiscountId tblGRDiscountId on tblGRDiscountId.intDiscountId = SC.intDiscountId
  LEFT JOIN tblGRStorageScheduleRule tblGRStorageScheduleRule on tblGRStorageScheduleRule.intStorageScheduleRuleId = SC.intStorageScheduleId
  LEFT JOIN tblICStorageLocation tblICStorageLocation on tblICStorageLocation.intStorageLocationId = SC.intStorageLocationId
  LEFT JOIN vyuSCGradeReadingReport QM ON QM.intTicketId = SC.intTicketId AND QM.ysnDryingDiscount = 1
  OUTER APPLY(
	SELECT strCompanyName
		,strAddress AS strCompanyAddress
		,strPhone AS strCompanyPhone
		,strCity AS strCompanyCity
		,strCountry AS strCompanyCountry
	 FROM tblSMCompanySetup
  )AS tblSMCompanySetup
  OUTER APPLY(
	SELECT IC.intInventoryReceiptId
		,IC.strReceiptNumber
		,IC.dtmReceiptDate 
		,ICI.intInventoryReceiptItemId
		,ICI.dblGross
		,ICI.dblNet
		,(ICI.dblGross - ICI.dblNet) [dblShrinkage]
		,LineCtr.totalTicket
	FROM tblICInventoryReceipt IC 
	INNER JOIN tblICInventoryReceiptItem ICI ON IC.intInventoryReceiptId = ICI.intInventoryReceiptId
	OUTER APPLY(
		SELECT COUNT(*) as totalTicket FROM tblICInventoryReceipt IR
		INNER JOIN tblICInventoryReceiptItem IRI ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
		WHERE intSourceId = SC.intTicketId AND IR.intSourceType = 1
	)LineCtr
	WHERE ICI.intSourceId = SC.intTicketId AND IC.intSourceType = 1
  )AS ReceiptItem
  OUTER APPLY(
	SELECT TOP 1 AP.dtmDate from tblAPBillDetail APD 
	INNER JOIN tblAPBill AP ON AP.intBillId = APD.intBillId
	WHERE APD.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
  )AS Voucher
  WHERE SC.strTicketStatus = 'C' AND SC.intEntityId > 0 AND ISNULL(ReceiptItem.intInventoryReceiptId, 0) > 0
