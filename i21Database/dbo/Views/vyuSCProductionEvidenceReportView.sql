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
		,EM.intEntityId
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
		,strDiscountCode = ISNULL(QM.strDiscountCode,'')
		,dblGradeReading = ISNULL(QM.dblGradeReading,0.0)
		,tblSMCompanySetup.strCompanyName
		,tblSMCompanySetup.strCompanyAddress
		,tblSMCompanySetup.strCompanyPhone
		,tblSMCompanySetup.strCompanyCity
		,tblSMCompanySetup.strCompanyCountry
		,IR.intInventoryReceiptId
		,IRD.intInventoryReceiptItemId
		,IR.strReceiptNumber
		,IRD.dblGross
		,dblShrinkage = CASE WHEN ISNULL(DS.dblGross,0) = 0 THEN 0 ELSE (DS.dblShrink / DS.dblGross) * IRD.dblGross END
		,dblNet = IRD.dblGross - (CASE WHEN ISNULL(DS.dblGross,0) = 0 THEN 0 ELSE (DS.dblShrink / DS.dblGross) * IRD.dblGross END)
		,dblLineGrossWeight =(IRD.dblNet / SC.dblNetUnits * (SC.dblGrossWeight + SC.dblGrossWeight1 + SC.dblGrossWeight2)) 
		,dblLineNetWeight = ((IRD.dblNet / SC.dblNetUnits) * (SC.dblTareWeight + SC.dblTareWeight1 + SC.dblTareWeight2)) 
		,tblGRDiscountId.strDiscountId
		,dtmReceiptDate = ISNULL(Voucher.dtmDate, IR.dtmReceiptDate) 
		,DS.strSplitDescription
		,DS.intDeliverySheetId
		,CASE WHEN DS.ysnPost = 0 
			THEN SUBSTRING((
					SELECT ','+ ICI2.strItemNo + '=' + CONVERT(varchar,QMD2.dblGradeReading) FROM tblSCDeliverySheet DSS2
					INNER JOIN tblSCTicket SC2
						ON DSS2.intDeliverySheetId = SC2.intDeliverySheetId
					INNER JOIN tblQMTicketDiscount QMD2
						ON QMD2.intTicketId = SC2.intTicketId and QMD2.strSourceType = 'Scale'
					INNER JOIN tblGRDiscountScheduleCode DSC2
						ON QMD2.intDiscountScheduleCodeId = DSC2.intDiscountScheduleCodeId
					INNER JOIN tblICItem ICI2
						ON ICI2.intItemId = DSC2.intItemId
					WHERE QMD2.dblGradeReading > 0 and SC2.intTicketId = SC.intTicketId
					FOR XML PATH('')
				),2,1000) 
			ELSE SUBSTRING((
					SELECT ','+ ICI2.strItemNo + '=' + CONVERT(varchar,QMD2.dblGradeReading) FROM tblSCDeliverySheet DSS2
					INNER JOIN tblSCTicket SC2
						ON DSS2.intDeliverySheetId = SC2.intDeliverySheetId
					INNER JOIN tblQMTicketDiscount QMD2
						ON QMD2.intTicketFileId = DSS2.intDeliverySheetId and QMD2.strSourceType = 'Delivery Sheet'
					INNER JOIN tblGRDiscountScheduleCode DSC2
						ON QMD2.intDiscountScheduleCodeId = DSC2.intDiscountScheduleCodeId
					INNER JOIN tblICItem ICI2
						ON ICI2.intItemId = DSC2.intItemId
					WHERE QMD2.dblGradeReading > 0 and SC2.intTicketId = SC.intTicketId
					FOR XML PATH('')
				),2,1000)
		END  COLLATE Latin1_General_CI_AS strGradeReading
		,1 ysnDisplayGradeReading
		,SC.intCropYearId
		,CYR.strCropYear
	FROM tblSCDeliverySheet DS
	INNER JOIN tblSCDeliverySheetSplit DSS
		ON DS.intDeliverySheetId = DSS.intDeliverySheetId
	INNER JOIN tblSCTicket SC 
		ON SC.intDeliverySheetId = DS.intDeliverySheetId
	INNER JOIN tblICInventoryReceiptItem IRD
		ON SC.intTicketId = IRD.intSourceId	
			AND SC.intItemId = IRD.intItemId
	INNER JOIN tblICInventoryReceipt IR
		ON IRD.intInventoryReceiptId = IR.intInventoryReceiptId
			AND IR.intSourceType = 1
			AND IR.intEntityVendorId = DSS.intEntityId
	LEFT JOIN tblICCommodity ICCommodity ON ICCommodity.intCommodityId = SC.intCommodityId
	LEFT JOIN tblEMEntity EM 
		on IR.intEntityVendorId = EM.intEntityId
	LEFT JOIN tblEMEntityLocation EMLocation ON EMLocation.intEntityId = IR.intEntityId AND EMLocation.ysnDefaultLocation = 1
	LEFT JOIN vyuEMSearchShipVia vyuEMSearchShipVia on vyuEMSearchShipVia.intEntityId = SC.intHaulerId
	LEFT JOIN tblEMEntitySplit tblEMEntitySplit on tblEMEntitySplit.intSplitId = DS.intSplitId
	LEFT JOIN tblSMCompanyLocation tblSMCompanyLocation on tblSMCompanyLocation.intCompanyLocationId = SC.intProcessingLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation tblSMCompanyLocationSubLocation on tblSMCompanyLocationSubLocation.intCompanyLocationSubLocationId = SC.intSubLocationId
	LEFT JOIN tblSCListTicketTypes tblSCListTicketTypes on (tblSCListTicketTypes.intTicketType = SC.intTicketType AND tblSCListTicketTypes.strInOutIndicator = SC.strInOutFlag)
	LEFT JOIN tblGRStorageType tblGRStorageType on tblGRStorageType.strStorageTypeCode = SC.strDistributionOption
	LEFT JOIN tblGRDiscountId tblGRDiscountId on tblGRDiscountId.intDiscountId = SC.intDiscountId
	LEFT JOIN tblGRStorageScheduleRule tblGRStorageScheduleRule on tblGRStorageScheduleRule.intStorageScheduleRuleId = SC.intStorageScheduleId
	LEFT JOIN tblICStorageLocation tblICStorageLocation on tblICStorageLocation.intStorageLocationId = SC.intStorageLocationId
	left join tblCTCropYear CYR
		on CYR.intCropYearId = SC.intCropYearId
	--LEFT JOIN vyuSCGradeReadingReport QM ON QM.intTicketId = SC.intTicketId AND QM.ysnDryingDiscount = 1
	OUTER APPLY(
		SELECT TOP 1 AP.dtmDate from tblAPBillDetail APD 
		INNER JOIN tblAPBill AP ON AP.intBillId = APD.intBillId
		WHERE APD.intInventoryReceiptItemId = IRD.intInventoryReceiptItemId
	) Voucher
	OUTER APPLY
	(	
		SELECT 
			strDiscountCode = MAX(GR.strDiscountChargeType)
			,dblGradeReading = SUM(ISNULL(QM.dblGradeReading,0.0)) 
		FROM tblQMTicketDiscount QM 
		INNER JOIN tblGRDiscountScheduleCode GR 
			ON QM.intDiscountScheduleCodeId = GR.intDiscountScheduleCodeId
		WHERE GR.ysnDryingDiscount = 1
			AND QM.intTicketFileId = DS.intDeliverySheetId
			AND QM.strSourceType = 'Delivery Sheet'
	) QM
	,(	SELECT TOP 1
			strCompanyName
			,strAddress AS strCompanyAddress
			,strPhone AS strCompanyPhone
			,strCity AS strCompanyCity
			,strCountry AS strCompanyCountry
		FROM tblSMCompanySetup
	) tblSMCompanySetup

  GO