﻿CREATE VIEW [dbo].[vyuSCTicketScreenView]
	AS select 
	SCT.intTicketId
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

	,SMC.strLocationName AS strProcessingLocationName
	,SMC.strDiscountScheduleType AS strDefaultLocationSchedule
	,SMCSubLocation.strSubLocationName
	,SMCur.strCurrency
	,CAST(
		CASE WHEN ISNULL(SMCSubLocation.intCompanyLocationSubLocationId,0) = 0 THEN 0
		ELSE 1 END
	 AS BIT) AS ysnHasSubLocation

	,GRStorage.strStorageTypeDescription
	,GRDiscountId.strDiscountId
	,GRSSR.strScheduleId
	,GRSSR.strScheduleDescription
	,ISNULL(GRStorage.ysnDPOwnedType, CAST(0 AS BIT)) AS ysnDPOwnedType
	,ISNULL(GRStorage.ysnCustomerStorage, CAST(0 AS BIT)) AS ysnCustomerStorage

	,EMSplit.strSplitNumber
	,EMEntityFarm.strFarmDescription
	,EMEntityFarm.strFieldNumber AS strFarmField
	,EMEntity.strName AS strCustomerNumber
	,EMEntity.strName AS strCustomerName

	,ICItem.strItemNo
	,ICCA.strDescription AS strGrade
	,ICStorageLocation.strName AS strStorageLocation
	,ICUM.strUnitMeasure
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
	 ,SCSetup.ysnActive AS ysnScaleStationActive
	 
	,CT.strShowContractNumber
	,CT.intContractDetailSequence
	,CT.strContractDetailLocation
	,CT.intContractHeaderId
	,CTEntity.strEntityName AS strHaulerName
	,CTGrade.strWeightGradeDesc AS strGradeOrigDes
	,CTWeight.strWeightGradeDesc AS strWeightOrigDes
	,CTCost.intItemUOMId AS intContractItemUOMId

	,(CASE 
		WHEN SCT.strInOutFlag = 'I' THEN LGD.strLoadNumber + ' - ' + LGD.strShipFrom 
		ELSE LGD.strLoadNumber + ' - ' + LGD.strShipTo
		END) strLoadInfo

	,CAST (0 AS BIT) ysnDateModified
	,SCT.intConcurrencyId
	,SCT.strOfflineGuid
  FROM tblSCTicket SCT
	LEFT JOIN tblSCTicketPool SCTPool on SCTPool.intTicketPoolId = SCT.intTicketPoolId
	LEFT JOIN tblSCScaleSetup SCSetup on SCSetup.intScaleSetupId = SCT.intScaleSetupId
	LEFT JOIN tblSCListTicketTypes SCListTicket on SCListTicket.intTicketType = SCT.intTicketType AND SCListTicket.strInOutIndicator = SCT.strInOutFlag
	LEFT JOIN tblSCDeliverySheet SCD on SCD.intDeliverySheetId = SCT.intDeliverySheetId

	LEFT JOIN tblSMCompanyLocation SMC on SMC.intCompanyLocationId = SCT.intProcessingLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation SMCSubLocation on SMCSubLocation.intCompanyLocationSubLocationId = SCT.intSubLocationId
	LEFT JOIN tblSMCurrency SMCur on SMCur.intCurrencyID = SCT.intCurrencyId

	LEFT JOIN tblEMEntity EMEntity on EMEntity.intEntityId = SCT.intEntityId
	LEFT JOIN tblEMEntitySplit EMSplit on EMSplit.intSplitId = SCT.intSplitId
	LEFT JOIN tblEMEntityFarm EMEntityFarm on EMEntityFarm.intFarmFieldId = SCT.intFarmFieldId

	LEFT JOIN tblICItem ICItem on ICItem.intItemId = SCT.intItemId
	LEFT JOIN tblICCommodity ICCommodity on ICCommodity.intCommodityId = SCT.intCommodityId
	LEFT JOIN tblICStorageLocation ICStorageLocation on ICStorageLocation.intStorageLocationId = SCT.intStorageLocationId
	LEFT JOIN tblICCommodityAttribute ICCA  on ICCA.intCommodityAttributeId = SCT.intCommodityAttributeId
	LEFT JOIN tblICItem ICFreight on ICFreight.intItemId = SCSetup.intFreightItemId
	LEFT JOIN tblICItem ICFees on ICFees.intItemId = SCSetup.intDefaultFeeItemId
	LEFT JOIN tblICItemUOM ICIUOM on ICIUOM.intItemUOMId = intItemUOMIdTo
	LEFT JOIN tblICItemUOM ICIUOMFrom on ICIUOMFrom.intItemUOMId = intItemUOMIdFrom
	LEFT JOIN tblICUnitMeasure ICUM on ICUM.intUnitMeasureId = ICIUOM.intUnitMeasureId

	LEFT JOIN tblGRStorageType GRStorage on GRStorage.strStorageTypeCode = SCT.strDistributionOption
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
	LEFT JOIN vyuCTEntity CTEntity on CTEntity.intEntityId = SCT.intHaulerId
	LEFT JOIN tblCTWeightGrade CTGrade on CTGrade.intWeightGradeId = SCT.intGradeId
	LEFT JOIN tblCTWeightGrade CTWeight on CTWeight.intWeightGradeId = SCT.intWeightId
	LEFT JOIN tblCTContractCost CTCost on CTCost.intContractCostId = SCT.intContractCostId

	LEFT JOIN (SELECT L.intLoadId
				,L.strLoadNumber
				,LD.intLoadDetailId
				,PCD.intContractDetailId AS intPContractDetailId
				,PCD.intContractHeaderId AS intPContractHeaderId
				,SCD.intContractDetailId AS intSContractDetailId
				,SCD.intContractHeaderId AS intSContractHeaderId
				,EV.intEntityId AS intVendorId
				,EV.strName AS strVendorName
				,EC.intEntityId AS intCustomerId
				,EC.strName AS strCustomerName
				,LD.intItemId
				,LD.intItemUOMId
				,LD.dblGross
				,LD.dblTare
				,LD.dblNet
				,UM.strUnitMeasure AS strItemUOM
				,WIU.intItemUOMId AS intWeightUOMId
				,WUM.strUnitMeasure AS strWeightUOM
				,VEL.intEntityLocationId AS intVendorLocationId
				,VEL.strLocationName AS strShipFrom
				,VEL.strLocationName AS strVendorLocationName
				,CEL.intEntityLocationId AS intCustomerLocationId
				,CEL.strLocationName AS strShipTo
				,CEL.strLocationName AS strCustomerLocationName
			FROM tblLGLoad L
			JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
			LEFT JOIN tblCTContractDetail PCD ON PCD.intContractDetailId = LD.intPContractDetailId
			LEFT JOIN tblCTContractDetail SCD ON SCD.intContractDetailId = LD.intSContractDetailId
			LEFT JOIN tblEMEntity EV ON EV.intEntityId = LD.intVendorEntityId
			LEFT JOIN tblEMEntityLocation VEL ON VEL.intEntityLocationId = LD.intVendorEntityLocationId
			LEFT JOIN tblEMEntity EC ON EC.intEntityId = LD.intCustomerEntityId
			LEFT JOIN tblEMEntityLocation CEL ON CEL.intEntityLocationId = LD.intVendorEntityLocationId
			LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = LD.intItemUOMId
			LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
			LEFT JOIN tblICItemUOM WIU ON WIU.intItemUOMId = LD.intWeightItemUOMId
			LEFT JOIN tblICUnitMeasure WUM ON WUM.intUnitMeasureId = WIU.intUnitMeasureId
	) LGD on LGD.intLoadId = SCT.intLoadId
	
