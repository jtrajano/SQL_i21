CREATE VIEW dbo.vyuSCPrintPreviewTicketView
AS SELECT 
	SC.intTicketId
	,(CASE WHEN
		SC.strTicketStatus = 'O' THEN 'OPEN' WHEN
		SC.strTicketStatus = 'A' THEN 'PRINTED' WHEN
		SC.strTicketStatus = 'C' THEN 'COMPLETED' WHEN
		SC.strTicketStatus = 'V' THEN 'VOID' WHEN
		SC.strTicketStatus = 'R' THEN 'REOPENED' WHEN
		SC.strTicketStatus = 'H' THEN 'HOLD' END) 
	AS strTicketStatusDescription
	,SC.strTicketStatus
    ,SC.strTicketNumber
	,SC.intScaleSetupId
    ,SC.intTicketPoolId
	,SC.intTicketLocationId
    ,SC.intTicketType
	,SC.strInOutFlag
	,SC.dtmTicketDateTime
	,SC.dtmTicketTransferDateTime
	,SC.dtmTicketVoidDateTime
	,SC.intProcessingLocationId
	,SC.strScaleOperatorUser
	,SC.intEntityScaleOperatorId
	,SC.strTruckName
	,SC.ysnDriverOff
	,SC.ysnSplitWeightTicket
	,SC.ysnGrossManual
	,SC.ysnGross1Manual
	,SC.ysnGross2Manual
	,SC.dblGrossWeight 
	,SC.dblGrossWeight1
	,SC.dblGrossWeight2
	,SC.dblGrossWeightOriginal
	,SC.dblGrossWeightSplit1
	,SC.dblGrossWeightSplit2
	,SC.dtmGrossDateTime
	,SC.dtmGrossDateTime1
	,SC.dtmGrossDateTime2
	,SC.intGrossUserId
	,SC.ysnTareManual
	,SC.ysnTare1Manual
	,SC.ysnTare2Manual
	,SC.dblTareWeight
	,SC.dblTareWeight1
	,SC.dblTareWeight2
	,SC.dblTareWeightOriginal
	,SC.dblTareWeightSplit1
	,SC.dblTareWeightSplit2
	,SC.dtmTareDateTime
	,SC.dtmTareDateTime1
	,SC.dtmTareDateTime2
	,SC.intTareUserId
	,SC.dblGrossUnits
	,SC.dblNetUnits
	,SC.strItemUOM
	,SC.intCustomerId
	,SC.intSplitId
	,SC.strDistributionOption
	,SC.intDiscountSchedule
	,SC.strDiscountLocation
	,SC.dtmDeferDate
	,SC.strContractNumber
	,SC.intContractSequence
	,SC.strContractLocation
	,SC.dblUnitPrice
	,SC.dblUnitBasis
	,SC.dblTicketFees
	,SC.intCurrencyId
	,SC.dblCurrencyRate
	,SC.strTicketComment
	,SC.strCustomerReference
	,SC.ysnTicketPrinted
	,SC.ysnPlantTicketPrinted
	,SC.ysnGradingTagPrinted
	,SC.intHaulerId
	,SC.intFreightCarrierId
	,SC.dblFreightRate
	,SC.dblFreightAdjustment
	,SC.intFreightCurrencyId
	,SC.dblFreightCurrencyRate
	,SC.strFreightCContractNumber
	,SC.strFreightSettlement
	,SC.ysnFarmerPaysFreight
	,SC.strLoadNumber
	,SC.intLoadLocationId
	,SC.intAxleCount
	,SC.intAxleCount1
	,SC.intAxleCount2
	,SC.strBinNumber
	,SC.strPitNumber
	,SC.intGradingFactor
	,SC.strVarietyType
	,SC.strFarmNumber
	,SC.strFieldNumber
	,SC.strDiscountComment
	,SC.intCommodityId
	,SC.intDiscountId
	,SC.intContractId
	,SC.intDiscountLocationId
	,SC.intItemId
	,SC.intEntityId
	,SC.intLoadId
	,SC.intMatchTicketId
	,SC.intSubLocationId
	,SC.intStorageLocationId
	,SC.intFarmFieldId
	,SC.intDistributionMethod
	,SC.intSplitInvoiceOption
	,SC.intDriverEntityId
	,SC.intStorageScheduleId
	,SC.intConcurrencyId
	,SC.dblNetWeightDestination
	,SC.ysnHasGeneratedTicketNumber
	,SC.intInventoryTransferId
	,SC.dblShrink
	,SC.dblConvertedUOMQty
	,SC.strCostMethod
	,SC.strElevatorReceiptNumber
	,SC.intEntityContactId
	,(ISNULL(SC.dblUnitPrice,0) + ISNULL(SC.dblUnitBasis,0)) AS dblCashPrice
	,SC.intSalesOrderId
	,SC.intDeliverySheetId
	,SC.dtmTransactionDateTime
	,ISNULL (tblGRStorageType.strStorageTypeDescription, 
	(CASE WHEN
		SC.strDistributionOption = 'CNT' THEN 'Contract' WHEN
		SC.strDistributionOption = 'LOD' THEN 'Load' WHEN
		SC.strDistributionOption = 'SPT' THEN 'Spot Sale' WHEN
		SC.strDistributionOption = 'SPL' THEN 'Split' WHEN
		SC.strDistributionOption = 'HLD' THEN 'Hold' END
	)) AS strStorageTypeDescription
	,tblSCListTicketTypes.strTicketType

	,tblSCScaleSetup.strStationShortDescription
	,tblSCScaleSetup.strWeightDescription
	,tblSCScaleSetup.ysnMultipleWeights
	,tblSCTicketFormat.strTicketFooter
	,tblSCTicketFormat.strTicketHeader
	,tblSCTicketFormat.ysnSuppressCompanyName
	,tblSCTicketFormat.intSuppressDiscountOptionId
	,tblSCTicketFormat.ysnSuppressSplit
	,tblSCTicketPrintOption.intTicketFormatId
	,tblSCTicketPool.strTicketPool

	,SCMatch.strStationShortDescription AS strScaleMatchTicket
	,SCMatch.strTicketNumber AS strMatchTicketNumber
	,SCMatch.strLocationName AS strMatchLocation

	,SCD.strDeliverySheetNumber
	,SCD.strSplitDescription

	,tblEMEntity.strName
	,tblEMEntitySplit.strSplitNumber
	,vyuEMSearchShipVia.strName AS strHaulerName
	,EMDriver.strName AS strDriverName
	
	,tblSMCompanyLocation.strLocationName
	,tblSMCompanyLocationSubLocation.strSubLocationName

	,tblGRDiscountId.strDiscountId
	,(CASE
		WHEN SC.intSalesOrderId > 0 THEN SOD.strStorageLocation
		ELSE tblICStorageLocation.strDescription
	END) AS strDescription
	,tblGRStorageScheduleRule.strScheduleId

	,(CASE
		WHEN SC.intSalesOrderId > 0 THEN SOD.strItemNumber
		ELSE IC.strItemNo
	END) AS strItemNumber
	,IC.strDescription AS strItemDescription
	,ICC.strCommodityCode
	,ICC.strDescription AS strCommodityDescription
	,ICCA.strDescription AS strGrade
	,tblICInventoryReceipt.intInventoryReceiptId
	,tblICInventoryReceipt.strReceiptNumber
	,vyuICGetInventoryShipmentItem.intInventoryShipmentId
	,vyuICGetInventoryShipmentItem.strShipmentNumber
	,SO.strSalesOrderNumber

	,SMCompanySetup.strCompanyName
	,SMCompanySetup.strAddress
	,SMS.blbDetail AS blbSignature
	,SMS.intEntityId AS intUserId
	,(SELECT intCurrencyDecimal FROM tblSMCompanyPreference) AS intDecimalPrecision
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
  LEFT JOIN tblICCommodityAttribute ICCA on ICCA.intCommodityAttributeId = SC.intCommodityAttributeId
  LEFT JOIN tblSCTicketPrintOption tblSCTicketPrintOption ON tblSCTicketPrintOption.intScaleSetupId = tblSCScaleSetup.intScaleSetupId
  LEFT JOIN tblSCTicketFormat ON tblSCTicketFormat.intTicketFormatId = tblSCTicketPrintOption.intTicketFormatId
  LEFT JOIN tblICItem IC ON IC.intItemId = SC.intItemId
  LEFT JOIN tblICCommodity ICC ON ICC.intCommodityId = IC.intCommodityId
  LEFT JOIN tblEMEntity EMDriver ON EMDriver.intEntityId = SC.intEntityContactId
  LEFT JOIN tblEMEntitySignature EM ON EM.intEntityId = SC.intEntityScaleOperatorId
  LEFT JOIN tblSMSignature SMS ON SMS.intSignatureId = EM.intElectronicSignatureId
  LEFT JOIN tblSCDeliverySheet SCD ON SCD.intDeliverySheetId = SC.intDeliverySheetId
  LEFT JOIN tblSOSalesOrder SO on SO.intSalesOrderId = SC.intSalesOrderId
  OUTER APPLY(
		SELECT SCSM.strStationShortDescription
		,SCM.strTicketNumber
		,SMCompany.strLocationName
		 FROM tblSCTicket SCM
		INNER JOIN tblSCScaleSetup SCSM ON SCSM.intScaleSetupId = SCM.intScaleSetupId
		INNER JOIN tblSMCompanyLocation SMCompany on SMCompany.intCompanyLocationId = SCSM.intLocationId
		WHERE intTicketId = SC.intMatchTicketId
  ) SCMatch
  OUTER APPLY(
	SELECT 
		strSalesOrderNumber,
		strItemNumber = STUFF(( SELECT ', ' + IC.strItemNo FROM tblSOSalesOrderDetail SOD
			INNER JOIN tblICItem IC ON IC.intItemId = SOD.intItemId AND ysnUseWeighScales = 1
			WHERE intSalesOrderId = x.intSalesOrderId FOR XML PATH(''), TYPE).value('.[1]', 'nvarchar(max)'), 1, 2, ''),
		strStorageLocation = STUFF(( SELECT ', ' + ICS.strDescription FROM tblSOSalesOrderDetail SOD
			LEFT JOIN tblICStorageLocation ICS on ICS.intStorageLocationId = SOD.intStorageLocationId
			INNER JOIN tblICItem IC ON IC.intItemId = SOD.intItemId AND ysnUseWeighScales = 1
			WHERE SOD.intSalesOrderId = x.intSalesOrderId FOR XML PATH(''), TYPE).value('.[1]', 'nvarchar(max)'), 1, 2, '')
	FROM tblSOSalesOrderDetail AS x
	INNER JOIN tblICItem IC ON IC.intItemId = x.intItemId
	WHERE x.intSalesOrderId = SC.intSalesOrderId
	AND IC.ysnUseWeighScales = 1
	GROUP BY intSalesOrderId
  ) SOD
  CROSS APPLY(
	SELECT strCompanyName,strAddress FROM tblSMCompanySetup
  ) SMCompanySetup
