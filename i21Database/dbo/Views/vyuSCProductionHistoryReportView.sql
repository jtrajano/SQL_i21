CREATE VIEW [dbo].[vyuSCProductionHistoryReportView]
	AS 	
		SELECT SC.intTicketId, (CASE WHEN
    SC.strTicketStatus = 'O' THEN 'OPEN' WHEN
    SC.strTicketStatus = 'A' THEN 'PRINTED' WHEN
    SC.strTicketStatus = 'C' THEN 'COMPLETED' WHEN
    SC.strTicketStatus = 'V' THEN 'VOID' WHEN
    SC.strTicketStatus = 'R' THEN 'REOPENED' END
	) COLLATE Latin1_General_CI_AS AS strTicketStatusDescription, 
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
	EFM.strFarmNumber,
	EFM.strFarmDescription,
	SC.strFieldNumber,
	SC.strDiscountComment,
	SC.intCommodityId,
	SC.intDiscountId,
	SC.intContractId,
	SC.intDiscountLocationId,
	SC.intItemId,
	IR.intEntityVendorId AS intEntityId,
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
	tblEMEntity.strEntityNo,
	tblEMEntity.strName,
	EMLocation.strAddress,
	EMLocation.strCity,
	EMLocation.strCountry,
	EMLocation.strPhone,
	tblSCListTicketTypes.strTicketType,
	tblSMCompanyLocation.strLocationNumber,
	tblSMCompanyLocation.strLocationName,
	tblSMCompanyLocationSubLocation.strSubLocationName, 
	strSplitNumber = ISNULL(DS.strSplitNumber, tblEMEntitySplit.strSplitNumber),
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
	--ReceiptItem.intInventoryReceiptId,
	----ReceiptItem.intInventoryReceiptItemId,
	--ReceiptItem.strReceiptNumber,
    IRD.dblGross,
    dblNet =  CASE WHEN DS.intDeliverySheetId IS NULL
			THEN IRD.dblNet
			ELSE IRD.dblGross - (CASE WHEN ISNULL(DS.dblGross,0) = 0 THEN 0 ELSE (DS.dblShrink / DS.dblGross) * IRD.dblGross END)
			END,
	(SC.dblGrossWeight + SC.dblGrossWeight1 + SC.dblGrossWeight2) * (CASE WHEN TS.intTicketSplitId IS NULL THEN 1 ELSE TS.dblSplitPercent / 100 END) AS dblLineGrossWeight,
	(SC.dblTareWeight + SC.dblTareWeight1 + SC.dblTareWeight2) * (CASE WHEN TS.intTicketSplitId IS NULL THEN 1 ELSE TS.dblSplitPercent / 100 END) AS dblLineNetWeight,
	tblGRDiscountId.strDiscountId,
	ISNULL(Voucher.dtmDate, IR.dtmReceiptDate) AS dtmReceiptDate,
	(SELECT intCurrencyDecimal FROM tblSMCompanyPreference) AS intDecimalPrecision,
    dblShrinkage = CASE WHEN DS.intDeliverySheetId IS NULL
			THEN 
				CASE WHEN ISNULL(SC.dblShrink,0) = 0 THEN 0
				ELSE 
					SC.dblShrink * (CASE WHEN TS.intTicketSplitId IS NULL THEN 1 ELSE TS.dblSplitPercent / 100 END)
				END
			ELSE CASE WHEN ISNULL(DS.dblGross,0) = 0 THEN 0 ELSE (DS.dblShrink / DS.dblGross) * IRD.dblGross END
			END,
	CASE WHEN SC.intDeliverySheetId IS NULL 
		THEN SUBSTRING((
				SELECT ','+ ICI2.strItemNo + '=' + LTRIM(STR(QMD2.dblGradeReading, 10, 2))
				FROM tblSCTicket SC2
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
				SELECT ','+ ICI2.strItemNo + '=' + LTRIM(STR(QMD2.dblGradeReading, 10, 2)) FROM tblSCDeliverySheet DSS2
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
	END COLLATE Latin1_General_CI_AS AS  strGradeReading
	,IR.intEntityVendorId
	,DS.intDeliverySheetId
	,DS.strDeliverySheetNumber
	,DS.strSplitDescription
  FROM tblSCTicket SC
  INNER JOIN tblICCommodity ICCommodity ON ICCommodity.intCommodityId = SC.intCommodityId
  LEFT JOIN tblICInventoryReceiptItem IRD
		ON SC.intTicketId = IRD.intSourceId	
        AND SC.intItemId = IRD.intItemId
  LEFT JOIN tblICInventoryReceipt IR
		ON IRD.intInventoryReceiptId = IR.intInventoryReceiptId
        AND IR.intSourceType = 1
  LEFT JOIN tblEMEntity tblEMEntity ON tblEMEntity.intEntityId = IR.intEntityVendorId
  LEFT JOIN tblSCTicketSplit TS ON TS.intTicketId = SC.intTicketId AND TS.intCustomerId = IR.intEntityVendorId
  LEFT JOIN tblEMEntityLocation EMLocation ON EMLocation.intEntityId = tblEMEntity.intEntityId AND EMLocation.ysnDefaultLocation = 1
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
  LEFT JOIN tblEMEntityFarm EFM ON EFM.intFarmFieldId = SC.intFarmFieldId
  OUTER APPLY(
	SELECT strCompanyName
		,strAddress AS strCompanyAddress
		,strPhone AS strCompanyPhone
		,strCity AS strCompanyCity
		,strCountry AS strCompanyCountry
	 FROM tblSMCompanySetup
  )AS tblSMCompanySetup
  OUTER APPLY
	(	
		SELECT
			DS.strSplitDescription
			,DS.strDeliverySheetNumber
			,DS.intDeliverySheetId
			,DS.dblShrink
			,DS.dblGross
			,DS.ysnPost
			,tblEMEntitySplit.strSplitNumber
			,DSS.intEntityId
		FROM tblSCDeliverySheet DS
		INNER JOIN tblSCDeliverySheetSplit DSS
			ON DS.intDeliverySheetId = DSS.intDeliverySheetId
		LEFT JOIN tblEMEntitySplit tblEMEntitySplit
			ON tblEMEntitySplit.intSplitId = DS.intSplitId
		WHERE DS.intDeliverySheetId = SC.intDeliverySheetId
			AND DSS.intEntityId = IR.intEntityVendorId
	) DS
  OUTER APPLY(
	SELECT TOP 1 AP.dtmDate from tblAPBillDetail APD 
	INNER JOIN tblAPBill AP ON AP.intBillId = APD.intBillId
	WHERE APD.intInventoryReceiptItemId = IRD.intInventoryReceiptItemId
  )AS Voucher
  WHERE SC.strTicketStatus = 'C' AND SC.intEntityId > 0
