CREATE VIEW [dbo].[vyuSCTicketScreenView]
	AS select 
	SCT.intTicketId
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
	,ISNULL(SCT.dblUnitPrice,0) dblUnitPrice
	,ISNULL(SCT.dblUnitBasis,0) dblUnitBasis
	,SCT.dblTicketFees
	,SCT.intCurrencyId
	,SCT.dblCurrencyRate
	,SCT.strTicketComment
	,SCT.strCustomerReference
	,SCT.ysnTicketPrinted
	,SCT.ysnPlantTicketPrinted
	,SCT.ysnGradingTagPrinted
	,SCT.intFreightCarrierId
	,SCT.dblFreightRate
	,SCT.dblFreightAdjustment
	,SCT.intFreightCurrencyId
	,SCT.dblFreightCurrencyRate
	,SCT.strFreightCContractNumber
	,SCT.intHaulerId
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
	,SCT.dblShrink
	,SCT.dblScheduleQty
	,SCT.dblConvertedUOMQty
	,SCT.intItemUOMIdFrom
	,SCT.intItemUOMIdTo
	,SCT.intTicketTypeId
	,SCT.intStorageScheduleTypeId
	,SCT.strCostMethod
	,SCT.strFreightSettlement
	,SCT.intGradeId
	,SCT.intWeightId
	,SCT.ysnCusVenPaysFees
	,SCT.intContractCostId
	,SCT.dblContractCostConvertedUOM
	,SCT.intDeliverySheetId
	,SCT.intCommodityAttributeId
	,SCT.strElevatorReceiptNumber
	,SCT.ysnRailCar
	,SCD.strDeliverySheetNumber
	,SCListTicket.strTicketType
	,SCT.ysnDeliverySheetPost
	,(SELECT SCMatch.strTicketNumber FROM tblSCTicket SCMatch WHERE SCMatch.intTicketId = SCT.intMatchTicketId) AS strMatchTicketNumber
    ,SCT.intLotId
    ,SCT.strLotNumber
    ,SCT.intSalesOrderId
	,SCT.ysnReadyToTransfer
	,SCT.ysnDestinationWeightGradePost
	,SCT.strPlateNumber COLLATE Latin1_General_CI_AS AS strPlateNumber
	,SCT.blbPlateNumber
	,SCT.strDriverName
	--,SCT.intEntityContactId
	,SCT.intTransferLocationId
	,SCT.intSubLocationToId
	,SCT.intStorageLocationToId
	,SCT.ysnExport
	,SMC.strLocationName AS strProcessingLocationName
	,SMCT.strLocationName AS strTransferLocationName
	,SMC.strDiscountScheduleType AS strDefaultLocationSchedule
	,SMCSubLocation.strSubLocationName
	,SMCSubLocationTransfer.strSubLocationName AS strTransferSubLocationName
	,SMCur.strCurrency
	,CAST(
		CASE WHEN ISNULL(SMCSubLocation.intCompanyLocationSubLocationId,0) = 0 THEN 0
		ELSE 1 END
	 AS BIT) AS ysnHasSubLocation
	 ,CAST(
		CASE WHEN ISNULL(SMCSubLocationTransfer.intCompanyLocationSubLocationId,0) = 0 THEN 0
		ELSE 1 END
	 AS BIT) AS ysnHasSubLocationTransfer

	,GRStorage.strStorageTypeDescription
	,GRDiscountId.strDiscountId
	,GRSSR.strScheduleId
	,strScheduleDescription = ISNULL(GRSSR.strScheduleDescription,'')
	,ISNULL(GRStorage.ysnDPOwnedType, CAST(0 AS BIT)) AS ysnDPOwnedType
	,ISNULL(GRStorage.ysnCustomerStorage, CAST(0 AS BIT)) AS ysnCustomerStorage

	,EMSplit.strSplitNumber
	,EMEntityFarm.strLocationDescription
	,EMEntityFarm.strLocationName AS strFarmField
	,EMEntity.strName AS strCustomerNumber
	,EMEntity.strName AS strCustomerName
	--,EMDriver.strName AS strDriverName

	,ICItem.strItemNo
	,ICCA.strDescription AS strGrade
	,ICStorageLocation.strName AS strStorageLocation
	,ICStorageLocationTransfer.strName AS strTransferStorageLocation
	,ICUM.strUnitMeasure
	,ICCommodity.strCommodityCode
	,ICCommodity.dblPriceCheckMin
	,ICCommodity.dblPriceCheckMax
	,ICCommodity.intScaleAutoDistId
	,ICCommodity.intScheduleStoreId
	,CAST(
		CASE WHEN ICItem.strLotTracking != 'No' THEN 1
		ELSE 0 END
	 AS BIT) AS ysnLotItem
	 ,CAST(
		CASE WHEN (SELECT COUNT(ICAttribute.intCommodityAttributeId) FROM tblICCommodityAttribute ICAttribute WHERE ICAttribute.intCommodityId = SCT.intCommodityId ) > 1 THEN 1
		ELSE 0 END
	 AS BIT) AS ysnHasCommodityGrade
	 ,ICIUOMFrom.dblUnitQty AS dblUnitQtyFrom
	 ,ICIUOM.dblUnitQty AS dblUnitQtyTo
	 ,ICCategory.intCategoryId
	 ,ICCategory.strCategoryCode
	 ,ICCategory.strDescription AS strCategoryDescription

	,SCSetup.strStationShortDescription
	,SCSetup.strWeightDescription
	,SCSetup.intFreightItemId
	,SCSetup.intDefaultFeeItemId
	,SCSetup.ysnMultipleWeights
	,CAST(
		CASE 
			WHEN ICFreight.strStatus = 'Active' THEN 1
			ELSE 0 
		END
	  AS BIT) AS ysnFreightActive
	 ,CAST (CASE 
		WHEN ICFees.strStatus = 'Active' THEN 1
		ELSE 0 
		END
	 AS BIT) AS ysnFeesActive
	 ,SCSetup.intScaleProcessing
	 ,SCSetup.intLocationId AS intScaleStationLocationId
	 ,SCSetup.ysnActive AS ysnScaleStationActive
	 
	,CT.strShowContractNumber
	,CT.intContractDetailSequence
	,CT.strContractDetailLocation
	,CT.intContractHeaderId
	,EMShipVia.strHaulerName
	,CTGrade.strWeightGradeDesc AS strGradeOrigDes
	,CTGrade.strWhereFinalized AS strGradeFinalized
	,CTWeight.strWeightGradeDesc AS strWeightOrigDes
	,CTWeight.strWhereFinalized AS strWeightFinalized
	,CTCost.intItemUOMId AS intContractItemUOMId

	,(CASE 
		WHEN SCT.strInOutFlag = 'I' THEN LGD.strLoadNumber + ' - ' + LGD.strShipFrom 
		ELSE LGD.strLoadNumber + ' - ' + LGD.strShipTo
		END) strLoadInfo

	,CAST (0 AS BIT) ysnDateModified
	,SCT.intConcurrencyId
	,SO.strSalesOrderNumber
	,(CASE WHEN SO.intCompanyLocationId > 0 THEN SMC.strLocationName ELSE '' END) AS strSOCompanyLocation
	,SO.intCompanyLocationId AS intSOCompanyLocation
	,Basis.intBillId AS intBasisAdvancedId
	,Basis.ysnRestricted AS ysnBasisAdvancedRestricted
	,APPayment.dblPayment
	,intSourceType as intLoadSourceType
	,strTicketSealNumber
	,SCT.intLoadDetailId
	,SCT.intCropYearId
	,CYR.strCropYear
	,SCT.ysnHasSpecialDiscount
	,SCT.ysnSpecialGradePosted
	,SCT.intItemContractDetailId
	,intItemContractSequence = ICD.intLineNo
	,strItemContractNumber = ICH.strContractNumber
	,SCT.ysnCertOfAnalysisPosted
	,SCT.ysnExportRailXML
	,SCT.strTrailerId
	,SCT.intParentTicketId
    ,SCT.intTicketTransactionType
	,SCT.ysnReversed
  FROM tblSCTicket SCT
	LEFT JOIN tblSCTicketPool SCTPool on SCTPool.intTicketPoolId = SCT.intTicketPoolId
	LEFT JOIN tblSCScaleSetup SCSetup on SCSetup.intScaleSetupId = SCT.intScaleSetupId
	LEFT JOIN tblSCListTicketTypes SCListTicket on SCListTicket.intTicketType = SCT.intTicketType AND SCListTicket.strInOutIndicator = SCT.strInOutFlag
	LEFT JOIN tblSCDeliverySheet SCD on SCD.intDeliverySheetId = SCT.intDeliverySheetId

	LEFT JOIN tblSMCompanyLocation SMC on SMC.intCompanyLocationId = SCT.intProcessingLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation SMCSubLocation on SMCSubLocation.intCompanyLocationSubLocationId = SCT.intSubLocationId
	LEFT JOIN tblSMCurrency SMCur on SMCur.intCurrencyID = SCT.intCurrencyId
	LEFT JOIN tblSMCompanyLocation SMCT on SMCT.intCompanyLocationId = SCT.intTransferLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation SMCSubLocationTransfer on SMCSubLocationTransfer.intCompanyLocationSubLocationId = SCT.intSubLocationToId

	LEFT JOIN tblEMEntity EMEntity on EMEntity.intEntityId = SCT.intEntityId
	LEFT JOIN tblEMEntitySplit EMSplit on EMSplit.intSplitId = SCT.intSplitId
	LEFT JOIN tblEMEntityLocation EMEntityFarm on EMEntityFarm.intEntityLocationId = SCT.intFarmFieldId

	LEFT JOIN tblICItem ICItem on ICItem.intItemId = SCT.intItemId
	LEFT JOIN tblICCommodity ICCommodity on ICCommodity.intCommodityId = SCT.intCommodityId
	LEFT JOIN tblICStorageLocation ICStorageLocation on ICStorageLocation.intStorageLocationId = SCT.intStorageLocationId
	LEFT JOIN tblICStorageLocation ICStorageLocationTransfer on ICStorageLocationTransfer.intStorageLocationId = SCT.intStorageLocationToId
	LEFT JOIN tblICCommodityAttribute ICCA  on ICCA.intCommodityAttributeId = SCT.intCommodityAttributeId
	LEFT JOIN tblICItem ICFreight on ICFreight.intItemId = SCSetup.intFreightItemId
	LEFT JOIN tblICItem ICFees on ICFees.intItemId = SCSetup.intDefaultFeeItemId
	LEFT JOIN tblICItemUOM ICIUOM on ICIUOM.intItemUOMId = intItemUOMIdTo
	LEFT JOIN tblICItemUOM ICIUOMFrom on ICIUOMFrom.intItemUOMId = intItemUOMIdFrom
	LEFT JOIN tblICUnitMeasure ICUM on ICUM.intUnitMeasureId = ICIUOM.intUnitMeasureId
	LEFT JOIN tblICCategory ICCategory on ICCategory.intCategoryId = ICItem.intCategoryId

	LEFT JOIN tblGRStorageType GRStorage on GRStorage.intStorageScheduleTypeId = SCT.intStorageScheduleTypeId 
	LEFT JOIN tblGRDiscountId GRDiscountId on GRDiscountId.intDiscountId = SCT.intDiscountId
	LEFT JOIN tblGRStorageScheduleRule GRSSR on GRSSR.intStorageScheduleRuleId = SCT.intStorageScheduleId

	LEFT JOIN (
		SELECT
			CTH.intContractHeaderId 
			,CTD.intContractDetailId
			,CTH.strContractNumber AS strShowContractNumber
			,CTD.intContractSeq AS intContractDetailSequence
			,SML.strLocationName AS strContractDetailLocation
		FROM tblCTContractDetail CTD 
		LEFT JOIN tblCTContractHeader CTH ON CTH.intContractHeaderId = CTD.intContractHeaderId
		LEFT JOIN tblSMCompanyLocation SML ON SML.intCompanyLocationId = CTD.intCompanyLocationId
	) CT ON CT.intContractDetailId = SCT.intContractId
	LEFT JOIN (
		SELECT	EY.intEntityId, EY.strName AS strHaulerName FROM tblEMEntity EY 
		INNER JOIN tblEMEntityType ET ON EY.intEntityId = ET.intEntityId
		WHERE	ET.strType = 'Ship Via'
	) EMShipVia on EMShipVia.intEntityId = SCT.intHaulerId
	LEFT JOIN tblCTWeightGrade CTGrade on CTGrade.intWeightGradeId = SCT.intGradeId
	LEFT JOIN tblCTWeightGrade CTWeight on CTWeight.intWeightGradeId = SCT.intWeightId
	LEFT JOIN tblCTContractCost CTCost on CTCost.intContractCostId = SCT.intContractCostId

	LEFT JOIN (SELECT L.intLoadId
				,L.strLoadNumber
				,LD.intLoadDetailId
				,LD.intItemId
				,LD.intItemUOMId
				,LD.dblGross
				,LD.dblTare	
				,LD.dblNet
				,VEL.intEntityLocationId AS intVendorLocationId
				,VEL.strLocationName AS strShipFrom
				,CEL.intEntityLocationId AS intCustomerLocationId
				,CEL.strLocationName AS strShipTo
				,L.intTicketId
				,L.intSourceType
			FROM tblLGLoad L
			INNER JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId 
			LEFT JOIN tblEMEntityLocation VEL ON VEL.intEntityLocationId = LD.intVendorEntityLocationId
			LEFT JOIN tblEMEntityLocation CEL ON CEL.intEntityLocationId = LD.intCustomerEntityLocationId
	) LGD on LGD.intLoadId = SCT.intLoadId AND  LGD.intLoadDetailId = SCT.intLoadDetailId
	LEFT JOIN tblSOSalesOrder SO on SO.intSalesOrderId = SCT.intSalesOrderId
	--LEFT JOIN tblEMEntity EMDriver ON EMDriver.intEntityId = SCT.intEntityContactId
	LEFT JOIN (
		SELECT TOP 1 * FROM vyuAPBasisAdvanceTicket
	) Basis ON Basis.intScaleTicketId = SCT.intTicketId
	LEFT JOIN (
		SELECT dblPayment = SUM(ISNULL(AP.dblPayment,0.0)), intScaleTicketId = APD.intScaleTicketId FROM tblAPBillDetail APD
		INNER JOIN tblAPBill AP ON AP.intBillId = APD.intBillId --AND AP.dblPayment > 0
		INNER JOIN tblAPPaymentDetail APPayDtl ON AP.intBillId = APPayDtl.intBillId
		INNER JOIN tblAPPayment APPay ON APPayDtl.intPaymentId = APPay.intPaymentId
		INNER JOIN tblCMBankTransaction BankTran ON APPay.strPaymentRecordNum = BankTran.strTransactionId
		WHERE ISNULL(APD.intScaleTicketId,0) <> 0 
		 AND BankTran.ysnCheckVoid = 0
		AND APPay.ysnPosted = 1
		GROUP BY intScaleTicketId
	) APPayment
		ON APPayment.intScaleTicketId = SCT.intTicketId
	outer apply ( SELECT TOP 1 TSN.intTicketId,SCN.strSealNumber strTicketSealNumber FROM tblSCTicketSealNumber TSN INNER JOIN tblSCSealNumber SCN ON SCN.intSealNumberId = TSN.intSealNumberId where TSN.intTicketId = SCT.intTicketId) TSCN 
	left join tblCTCropYear CYR
		on CYR.intCropYearId = SCT.intCropYearId
	--LEFT JOIN (SELECT TOP 1 TSN.intTicketId,SCN.strSealNumber strTicketSealNumber FROM tblSCTicketSealNumber TSN INNER JOIN tblSCSealNumber SCN ON SCN.intSealNumberId = TSN.intSealNumberId where ) TSCN ON TSCN.intTicketId = SCT.intTicketId
	LEFT JOIN tblCTItemContractDetail ICD ON ISNULL(SCT.intItemContractDetailId,0) = ICD.intItemContractDetailId
	LEFT JOIN tblCTItemContractHeader ICH ON ICD.intItemContractHeaderId = ICH.intItemContractHeaderId