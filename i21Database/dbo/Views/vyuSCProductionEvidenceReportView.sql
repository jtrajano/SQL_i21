CREATE VIEW [dbo].[vyuSCProductionEvidenceReportView]
	AS 
	SELECT 
		SC.intTicketId
		,strTicketStatusDescription =	(	CASE WHEN
											SC.strTicketStatus = 'O' THEN 'OPEN' WHEN
											SC.strTicketStatus = 'A' THEN 'PRINTED' WHEN
											SC.strTicketStatus = 'C' THEN 'COMPLETED' WHEN
											SC.strTicketStatus = 'V' THEN 'VOID' WHEN
											SC.strTicketStatus = 'R' THEN 'REOPENED' END
										) COLLATE Latin1_General_CI_AS  
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
		,SC.ysnGrossManual
		,SC.dblGrossWeight 
		,SC.dtmGrossDateTime
		,SC.ysnTareManual
		,SC.dblTareWeight
		,SC.dtmTareDateTime
		,SC.dblGrossUnits
		,SC.dblNetUnits
		,SC.strItemUOM
		,SC.intSplitId
		,SC.strDistributionOption
		,SC.intDiscountSchedule
		,SC.strDiscountLocation
		,SC.dtmDeferDate
		,SC.strContractNumber
		,SC.intContractSequence
		,SC.strContractLocation
		,SC.dblTicketFees
		,SC.intCurrencyId 
		,SC.dblCurrencyRate
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
		,SC.strPitNumber
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
		,SC.dblShrink
		,SC.dblConvertedUOMQty
		,SC.strCostMethod
		,(SC.dblUnitPrice + SC.dblUnitBasis) AS dblCashPrice
		,strStorageTypeDescription  = ISNULL(tblGRStorageType.strStorageTypeDescription, 
												CASE	WHEN SC.strDistributionOption = 'CNT' THEN 'Contract' 
														WHEN SC.strDistributionOption = 'LOD' THEN 'Load' 
														WHEN SC.strDistributionOption = 'SPT' THEN 'Spot Sale' 
														WHEN SC.strDistributionOption = 'SPL' THEN 'Split' 
														WHEN SC.strDistributionOption = 'HLD' THEN 'Hold' 
												END
											) 
		,EM.strEntityNo
		,EM.strName
		,EMLocation.strAddress
		,EMLocation.strCity
		,EMLocation.strCountry
		,EMLocation.strPhone
		,tblSCListTicketTypes.strTicketType
		,tblSMCompanyLocation.strLocationNumber
		,tblSMCompanyLocation.strLocationName
		,tblSMCompanyLocationSubLocation.strSubLocationName
		,tblEMEntitySplit.strSplitNumber
		,tblGRStorageScheduleRule.strScheduleId
		,ICCommodity.strCommodityCode
		,tblICStorageLocation.strDescription
		,vyuEMSearchShipVia.strName AS strHaulerName
		,QM.strDiscountCode
		,QM.dblGradeReading
		,tblSMCompanySetup.strCompanyName
		,tblSMCompanySetup.strCompanyAddress
		,tblSMCompanySetup.strCompanyPhone
		,tblSMCompanySetup.strCompanyCity
		,tblSMCompanySetup.strCompanyCountry
		,IR.intInventoryReceiptId
		,IRD.intInventoryReceiptItemId
		,IR.strReceiptNumber
		,IRD.dblGross
		,dblShrinkage = IRD.dblGross - IRD.dblNet
		,IRD.dblNet
		,dblLineGrossWeight =(IRD.dblNet / SC.dblNetUnits * (SC.dblGrossWeight + SC.dblGrossWeight1 + SC.dblGrossWeight2)) 
		,dblLineNetWeight = ((IRD.dblNet / SC.dblNetUnits) * (SC.dblTareWeight + SC.dblTareWeight1 + SC.dblTareWeight2)) 
		,tblGRDiscountId.strDiscountId
		,dtmReceiptDate = ISNULL(Voucher.dtmDate, IR.dtmReceiptDate) 
		,(SELECT intCurrencyDecimal FROM tblSMCompanyPreference) AS intDecimalPrecision
		,DS.strSplitDescription
		,DS.intDeliverySheetId
	FROM tblSCDeliverySheet DS
	INNER JOIN tblSCTicket SC 
		ON SC.intDeliverySheetId = DS.intDeliverySheetId
	INNER JOIN tblICInventoryReceiptItem IRD
		ON SC.intTicketId = IRD.intSourceId	
			AND SC.intItemId = IRD.intItemId
	INNER JOIN tblICInventoryReceipt IR
		ON IRD.intInventoryReceiptId = IR.intInventoryReceiptId
			AND IR.intSourceType = 1
	LEFT JOIN tblICCommodity ICCommodity ON ICCommodity.intCommodityId = SC.intCommodityId
	LEFT JOIN tblEMEntity EM 
		on IR.intEntityVendorId = EM.intEntityId
	LEFT JOIN tblEMEntityLocation EMLocation ON EMLocation.intEntityId = SC.intEntityId AND EMLocation.ysnDefaultLocation = 1
	LEFT JOIN vyuEMSearchShipVia vyuEMSearchShipVia on vyuEMSearchShipVia.intEntityId = SC.intHaulerId
	LEFT JOIN tblEMEntitySplit tblEMEntitySplit on tblEMEntitySplit.intSplitId = DS.intSplitId
	LEFT JOIN tblSMCompanyLocation tblSMCompanyLocation on tblSMCompanyLocation.intCompanyLocationId = SC.intProcessingLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation tblSMCompanyLocationSubLocation on tblSMCompanyLocationSubLocation.intCompanyLocationSubLocationId = SC.intSubLocationId
	LEFT JOIN tblSCListTicketTypes tblSCListTicketTypes on (tblSCListTicketTypes.intTicketType = SC.intTicketType AND tblSCListTicketTypes.strInOutIndicator = SC.strInOutFlag)
	LEFT JOIN tblGRStorageType tblGRStorageType on tblGRStorageType.strStorageTypeCode = SC.strDistributionOption
	LEFT JOIN tblGRDiscountId tblGRDiscountId on tblGRDiscountId.intDiscountId = SC.intDiscountId
	LEFT JOIN tblGRStorageScheduleRule tblGRStorageScheduleRule on tblGRStorageScheduleRule.intStorageScheduleRuleId = SC.intStorageScheduleId
	LEFT JOIN tblICStorageLocation tblICStorageLocation on tblICStorageLocation.intStorageLocationId = SC.intStorageLocationId
	LEFT JOIN vyuSCGradeReadingReport QM ON QM.intTicketId = SC.intTicketId AND QM.ysnDryingDiscount = 1
	OUTER APPLY(
		SELECT TOP 1 AP.dtmDate from tblAPBillDetail APD 
		INNER JOIN tblAPBill AP ON AP.intBillId = APD.intBillId
		WHERE APD.intInventoryReceiptItemId = IRD.intInventoryReceiptItemId
	) Voucher
	,(	SELECT TOP 1
			strCompanyName
			,strAddress AS strCompanyAddress
			,strPhone AS strCompanyPhone
			,strCity AS strCompanyCity
			,strCountry AS strCompanyCountry
		FROM tblSMCompanySetup
	) tblSMCompanySetup

  GO