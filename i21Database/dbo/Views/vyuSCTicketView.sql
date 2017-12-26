CREATE VIEW [dbo].[vyuSCTicketView]
	AS select SCT.intTicketId,
	   (CASE
			
			WHEN SCT.strTicketStatus = 'O' THEN 'OPEN'
			WHEN SCT.strTicketStatus = 'A' THEN 'PRINTED'
			WHEN SCT.strTicketStatus = 'C' THEN 'COMPLETED'
			WHEN SCT.strTicketStatus = 'V' THEN 'VOID'
			WHEN SCT.strTicketStatus = 'R' THEN 'REOPENED'
			WHEN SCT.strTicketStatus = 'H'  THEN
			CASE
				wHEN SCT.ysnDeliverySheetPost = 1 THEN 'COMPLETED' 
				ELSE 'HOLD'
			END
		END) AS strTicketStatusDescription
	   ,SCT.strTicketStatus
       ,SCT.strTicketNumber
       ,SCT.intScaleSetupId
       ,SCT.intTicketPoolId
       ,SCT.intTicketLocationId
       ,SCT.intTicketType
       ,SCT.strInOutFlag
       ,SCT.dtmTicketDateTime
       ,SCT.dtmTicketTransferDateTime
       ,SCT.dtmTicketVoidDateTime
       ,SCT.intProcessingLocationId
       ,SCT.strScaleOperatorUser
       ,SCT.intEntityScaleOperatorId
       ,SCT.strPurchaseOrderNumber
       ,SCT.strTruckName
       ,SCT.strDriverName
       ,SCT.ysnDriverOff
       ,SCT.ysnSplitWeightTicket
       ,SCT.ysnGrossManual
       ,SCT.ysnGross1Manual
       ,SCT.ysnGross2Manual
       ,SCT.dblGrossWeight
       ,SCT.dblGrossWeight1
       ,SCT.dblGrossWeight2
       ,SCT.dblGrossWeightOriginal
       ,SCT.dblGrossWeightSplit1
       ,SCT.dblGrossWeightSplit2
       ,SCT.dtmGrossDateTime
       ,SCT.dtmGrossDateTime1
       ,SCT.dtmGrossDateTime2
       ,SCT.intGrossUserId
       ,SCT.ysnTareManual
       ,SCT.ysnTare1Manual
       ,SCT.ysnTare2Manual
       ,SCT.dblTareWeight
       ,SCT.dblTareWeight1
       ,SCT.dblTareWeight2
       ,SCT.dblTareWeightOriginal
       ,SCT.dblTareWeightSplit1
       ,SCT.dblTareWeightSplit2
       ,SCT.dtmTareDateTime
       ,SCT.dtmTareDateTime1
       ,SCT.dtmTareDateTime2
       ,SCT.intTareUserId
       ,SCT.dblGrossUnits
       ,SCT.dblNetUnits
	   ,(SCT.dblGrossWeight - SCT.dblTareWeight) AS dblNetWeight
       ,SCT.strItemNumber
       ,SCT.strItemUOM
       ,SCT.intCustomerId
       ,SCT.intSplitId
       ,SCT.strDistributionOption
       ,SCT.intDiscountSchedule
       ,SCT.strDiscountLocation
       ,SCT.dtmDeferDate
       ,SCT.strContractNumber
       ,SCT.intContractSequence
       ,SCT.strContractLocation
       ,SCT.dblUnitPrice
       ,SCT.dblUnitBasis
       ,SCT.dblTicketFees
       ,SCT.intCurrencyId
       ,SCT.dblCurrencyRate
       ,SCT.strTicketComment
       ,SCT.strCustomerReference
       ,SCT.ysnTicketPrinted
       ,SCT.ysnPlantTicketPrinted
       ,SCT.ysnGradingTagPrinted
       ,SCT.intHaulerId
       ,SCT.intFreightCarrierId
       ,SCT.dblFreightRate
       ,SCT.dblFreightAdjustment
       ,SCT.intFreightCurrencyId
       ,SCT.dblFreightCurrencyRate
       ,SCT.strFreightCContractNumber
       ,SCT.ysnFarmerPaysFreight
       ,SCT.strLoadNumber
       ,SCT.intLoadLocationId
       ,SCT.intAxleCount
	   ,SCT.intAxleCount1
	   ,SCT.intAxleCount2
       ,SCT.strBinNumber
       ,SCT.strPitNumber
       ,SCT.intGradingFactor
       ,SCT.strVarietyType
       ,SCT.strFarmNumber
       ,SCT.strFieldNumber
       ,SCT.strDiscountComment
       ,SCT.strCommodityCode
       ,SCT.intCommodityId
       ,SCT.intDiscountId
       ,SCT.intContractId
       ,SCT.intDiscountLocationId
       ,SCT.intItemId
       ,SCT.intEntityId
       ,SCT.intLoadId
       ,SCT.intMatchTicketId
       ,SCT.intSubLocationId
       ,SCT.intStorageLocationId
       ,SCT.intFarmFieldId
       ,SCT.intDistributionMethod
       ,SCT.intSplitInvoiceOption
       ,SCT.intDriverEntityId
       ,SCT.intStorageScheduleId
       ,SCT.dblNetWeightDestination
       ,SCT.ysnUseDestinationWeight
       ,SCT.ysnUseDestinationGrades
       ,SCT.ysnHasGeneratedTicketNumber
       ,SCT.intInventoryTransferId
       ,SCT.dblShrink
       ,SCT.dblConvertedUOMQty
	   ,SCT.strFreightSettlement
	   ,SCT.intDeliverySheetId
	   ,SCT.strElevatorReceiptNumber
	   ,(SCT.dblGrossWeight + ISNULL(SCT.dblGrossWeight1, 0) + ISNULL(SCT.dblGrossWeight2, 0)) AS dblTotalGrossWeight
	   ,(SCT.dblTareWeight + ISNULL(SCT.dblTareWeight1, 0) + ISNULL(SCT.dblTareWeight2, 0)) AS dblTotalTareWeight
	   ,((SCT.dblGrossWeight + ISNULL(SCT.dblGrossWeight1, 0) + ISNULL(SCT.dblGrossWeight2, 0)) - (SCT.dblTareWeight + ISNULL(SCT.dblTareWeight1, 0) + ISNULL(SCT.dblTareWeight2, 0))) AS dblTotalNetWeight
	   ,(SCT.dblUnitPrice + SCT.dblUnitBasis) AS dblCashPrice
	   ,SCD.strDeliverySheetNumber
       ,EMEntity.strName
       ,SCListTicket.strTicketType
	   ,SMC.strLocationName
	   ,SMCSubLocation.strSubLocationName
	   ,ISNULL(GRStorage.strStorageTypeDescription, 
	   CASE 
			WHEN SCT.strDistributionOption = 'CNT' THEN 'Contract'
			WHEN SCT.strDistributionOption = 'LOD' THEN 'Load'
			WHEN SCT.strDistributionOption = 'SPT' THEN 'Spot Sale'
			WHEN SCT.strDistributionOption = 'SPL' THEN 'Split'
			WHEN SCT.strDistributionOption = 'HLD' THEN 'Hold'
		END) AS strStorageTypeDescription
	   ,SCSetup.strStationShortDescription
	   ,[EMSplit].strSplitNumber
	   ,SCTPool.strTicketPool
	   ,GRDiscountId.strDiscountId
	   ,ICStorageLocation.strDescription
	   ,GRSSR.strScheduleId
	   ,IR.intInventoryReceiptId
	   ,IR.strReceiptNumber
	   ,ICIS.intInventoryShipmentId
	   ,ICIS.strShipmentNumber
	   ,EMEntityFarm.strFarmDescription
	   ,ICCA.strDescription AS strGrade
  from ((tblSCTicket SCT
	left join tblEMEntity EMEntity
       on (EMEntity.intEntityId = SCT.intEntityId)
	left join tblEMEntitySplit EMSplit
       on ([EMSplit].intSplitId = SCT.intSplitId)
	left join tblSCScaleSetup SCSetup
       on (SCSetup.intScaleSetupId = SCT.intScaleSetupId)
	left join tblSMCompanyLocation SMC
       on (SMC.intCompanyLocationId = SCT.intProcessingLocationId))
	left join tblSCListTicketTypes SCListTicket
       on (SCListTicket.intTicketType = SCT.intTicketType AND SCListTicket.strInOutIndicator = SCT.strInOutFlag)
	left join tblGRStorageType GRStorage
       on (GRStorage.strStorageTypeCode = SCT.strDistributionOption)
	left join tblSMCompanyLocationSubLocation SMCSubLocation
       on (SMCSubLocation.intCompanyLocationSubLocationId = SCT.intSubLocationId))
	left join tblSCTicketPool SCTPool
       on SCTPool.intTicketPoolId = SCT.intTicketPoolId
	left join tblGRDiscountId GRDiscountId
       on GRDiscountId.intDiscountId = SCT.intDiscountId
	left join tblICStorageLocation ICStorageLocation
       on ICStorageLocation.intStorageLocationId = SCT.intStorageLocationId
	left join tblGRStorageScheduleRule GRSSR
       on GRSSR.intStorageScheduleRuleId = SCT.intStorageScheduleId
	left join tblICInventoryReceipt IR
	   on  IR.intInventoryReceiptId = SCT.intInventoryReceiptId
	left join tblICInventoryShipment ICIS
	   on  ICIS.intInventoryShipmentId = SCT.intInventoryShipmentId
	left join tblEMEntityFarm EMEntityFarm
	   on EMEntityFarm.intFarmFieldId = SCT.intFarmFieldId
	left join tblSCDeliverySheet SCD
	   on SCD.intDeliverySheetId = SCT.intDeliverySheetId
	left join tblICCommodityAttribute ICCA 
	   on ICCA.intCommodityAttributeId = SCT.intCommodityAttributeId
