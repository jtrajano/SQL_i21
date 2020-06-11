CREATE VIEW [dbo].[vyuSCTicketView]
AS 
	select SCT.intTicketId,
	   (CASE
			
			WHEN SCT.strTicketStatus = 'O' THEN 'OPEN'
			WHEN SCT.strTicketStatus = 'A' THEN 'PRINTED'
			WHEN SCT.strTicketStatus = 'C' THEN 'COMPLETED'
			WHEN SCT.strTicketStatus = 'V' THEN 'VOID'
			WHEN SCT.strTicketStatus = 'R' THEN 'REOPENED'
			WHEN SCT.strTicketStatus = 'S' THEN 'STARTED' 
			WHEN SCT.strTicketStatus = 'I' THEN 'IN TRANSIT'
			WHEN SCT.strTicketStatus = 'D' THEN 'DELIVERED'  
			WHEN SCT.strTicketStatus = 'H'  THEN 'HOLD'
			--CASE
			--	wHEN SCT.ysnDeliverySheetPost = 1 THEN 'COMPLETED' 
			--	ELSE 'HOLD'
			--END
		END) COLLATE Latin1_General_CI_AS AS strTicketStatusDescription
	   ,SCT.strTicketStatus
       ,SCT.strTicketNumber
	   ,SCT.strOriginalTicketNumber
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
       ,SCT.strTruckName
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
       ,SCT.strPitNumber
       ,SCT.intGradingFactor
       ,SCT.strVarietyType
       ,SCT.strFarmNumber
       ,SCT.strFieldNumber
       ,SCT.strDiscountComment
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
       ,SCT.ysnHasGeneratedTicketNumber
	   ,CASE 
			WHEN SCT.ysnDestinationWeightGradePost = 1 THEN 'Posted' 
			WHEN lower(isnull(CTWGH.strWeightGradeDesc, '')) = 'destination' or lower(isnull(CTWGG.strWeightGradeDesc, '')) = 'destination' then 'Unposted'
			--WHEN CTH.intWeightId = 2 OR CTH.intGradeId = 2 THEN 'Unposted' 
		END COLLATE Latin1_General_CI_AS AS strWeightGradePostStatus   
      ,CASE WHEN CTH.intWeightId is not null OR CTH.intGradeId is not null 
         THEN isnull(CTWGH.strWeightGradeDesc, '') +'/' + isnull(CTWGG.strWeightGradeDesc, '') END AS strWeightGradeDest
       ,SCT.intInventoryTransferId
       ,SCT.dblShrink
       ,SCT.dblConvertedUOMQty
	   ,SCT.strFreightSettlement
	   ,SCT.intDeliverySheetId
	   ,SCT.strElevatorReceiptNumber
	   ,SCT.intSalesOrderId
	   --,SCT.intEntityContactId
	   ,SCT.strDriverName
	   ,SCT.dtmTransactionDateTime
	   ,(SCT.dblGrossWeight + ISNULL(SCT.dblGrossWeight1, 0) + ISNULL(SCT.dblGrossWeight2, 0)) AS dblTotalGrossWeight
	   ,(SCT.dblTareWeight + ISNULL(SCT.dblTareWeight1, 0) + ISNULL(SCT.dblTareWeight2, 0)) AS dblTotalTareWeight
	   ,((SCT.dblGrossWeight + ISNULL(SCT.dblGrossWeight1, 0) + ISNULL(SCT.dblGrossWeight2, 0)) - (SCT.dblTareWeight + ISNULL(SCT.dblTareWeight1, 0) + ISNULL(SCT.dblTareWeight2, 0))) AS dblTotalNetWeight
	   ,(SCT.dblUnitPrice + SCT.dblUnitBasis) AS dblCashPrice
	   ,SCT.ysnReadyToTransfer
	   ,SCT.ysnExport
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
		END) COLLATE Latin1_General_CI_AS AS strStorageTypeDescription
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
	   ,EMLocation.strLocationName as strFarmDescription
	   ,ICCA.strDescription AS strGrade
	   ,SO.strSalesOrderNumber
	   ,IC.strItemNo AS strItemNumber
	   --,EMDriver.strName AS strDriverName
     ,SCT.dtmImportedDate
	 ,ContractsApplied.strContractsApplied COLLATE Latin1_General_CI_AS AS strContractsApplied
    ,SCT.strTrailerId
	,SCT.ysnCertOfAnalysisPosted
	,SCT.ysnExportRailXML
  from tblSCTicket SCT
	LEFT JOIN tblEMEntity EMEntity on EMEntity.intEntityId = SCT.intEntityId
	LEFT JOIN tblEMEntitySplit EMSplit on [EMSplit].intSplitId = SCT.intSplitId
	LEFT JOIN tblSCScaleSetup SCSetup on SCSetup.intScaleSetupId = SCT.intScaleSetupId
	LEFT JOIN tblSMCompanyLocation SMC on SMC.intCompanyLocationId = SCT.intProcessingLocationId
	LEFT JOIN tblSCListTicketTypes SCListTicket on SCListTicket.intTicketType = SCT.intTicketType AND SCListTicket.strInOutIndicator = SCT.strInOutFlag
	LEFT JOIN tblGRStorageType GRStorage on GRStorage.strStorageTypeCode = SCT.strDistributionOption
	LEFT JOIN tblSMCompanyLocationSubLocation SMCSubLocation on SMCSubLocation.intCompanyLocationSubLocationId = SCT.intSubLocationId
	LEFT JOIN tblSCTicketPool SCTPool on SCTPool.intTicketPoolId = SCT.intTicketPoolId
	LEFT JOIN tblGRDiscountId GRDiscountId on GRDiscountId.intDiscountId = SCT.intDiscountId
	LEFT JOIN tblICStorageLocation ICStorageLocation on ICStorageLocation.intStorageLocationId = SCT.intStorageLocationId
	LEFT JOIN tblGRStorageScheduleRule GRSSR on GRSSR.intStorageScheduleRuleId = SCT.intStorageScheduleId
	LEFT JOIN tblICInventoryReceipt IR on  IR.intInventoryReceiptId = SCT.intInventoryReceiptId
	LEFT JOIN tblICInventoryShipment ICIS on  ICIS.intInventoryShipmentId = SCT.intInventoryShipmentId
	LEFT JOIN tblEMEntityFarm EMEntityFarm on EMEntityFarm.intFarmFieldId = SCT.intFarmFieldId
	LEFT JOIN tblSCDeliverySheet SCD on SCD.intDeliverySheetId = SCT.intDeliverySheetId
	LEFT JOIN tblICCommodityAttribute ICCA on ICCA.intCommodityAttributeId = SCT.intCommodityAttributeId
	LEFT JOIN tblSOSalesOrder SO on SO.intSalesOrderId = SCT.intSalesOrderId
	LEFT JOIN tblICItem IC ON IC.intItemId = SCT.intItemId
   LEFT JOIN tblEMEntityLocation EMLocation on EMLocation.intEntityLocationId = SCT.intFarmFieldId
	--LEFT JOIN tblEMEntity EMDriver ON EMDriver.intEntityId = SCT.intEntityContactId
	LEFT JOIN tblCTContractDetail CTD ON SCT.intContractId = CTD.intContractDetailId
	LEFT JOIN tblCTContractHeader CTH ON CTH.intContractHeaderId = CTD.intContractHeaderId
   LEFT JOIN tblCTWeightGrade CTWGG
      on CTWGG.intWeightGradeId = CTH.intGradeId
   LEFT JOIN tblCTWeightGrade CTWGH
      on CTWGH.intWeightGradeId = CTH.intWeightId
	OUTER APPLY(
		SELECT strContractsApplied =LEFT(strContractsApplied, LEN(strContractsApplied) - 1) FROM (
		SELECT ContractHeader.strContractNumber +'-'+ CAST(ContractDetail.intContractSeq AS VARCHAR(20)) + ', ' FROM tblSCTicketContractUsed ContractUsed
		INNER JOIN tblCTContractDetail ContractDetail
			ON ContractDetail.intContractDetailId = ContractUsed.intContractDetailId
		INNER JOIN tblCTContractHeader ContractHeader
			ON ContractDetail.intContractHeaderId = ContractHeader.intContractHeaderId
		WHERE ContractUsed.intTicketId = SCT.intTicketId
		FOR XML PATH ('')
	) ContractsApplied(strContractsApplied)
	) ContractsApplied