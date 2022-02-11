CREATE VIEW vyuLGCompanyPreference
AS
SELECT CP.intCompanyPreferenceId
	,CP.intCommodityId
	,CO.strCommodityCode
	,CP.intWeightUOMId
	,UM.strUnitMeasure AS strWeightUOM
	,CP.ysnDropShip
	,CP.ysnContainersRequired
	,CP.intDefaultShipmentTransType
	,strDefaultShipmentTransType = CASE CP.intDefaultShipmentTransType
		WHEN 1 THEN 'Inbound'
		WHEN 2 THEN 'Outbound'
		WHEN 3 THEN 'Drop Ship'
		END COLLATE Latin1_General_CI_AS
	,CP.intDefaultShipmentSourceType
	,strDefaultShipmentSourceType = CASE CP.intDefaultShipmentSourceType
		WHEN 1 THEN 'None'
		WHEN 2 THEN 'Contracts'
		WHEN 3 THEN 'Orders'
		END COLLATE Latin1_General_CI_AS
	,CP.intCreateShipmentDefaultSourceType
	,strCreateShipmentDefaultSourceType = CASE CP.intCreateShipmentDefaultSourceType
		WHEN 2 THEN 'Contracts'
		WHEN 5 THEN 'Picked Lots'
		WHEN 6 THEN 'Pick Lots'
		END COLLATE Latin1_General_CI_AS
	,CP.intDefaultTransportationMode
	,strDefaultTransportationMode = CASE CP.intDefaultTransportationMode
		WHEN 1 THEN 'Truck'
		WHEN 2 THEN 'Ocean Vessel'
		WHEN 3 THEN 'Rail'
		END COLLATE Latin1_General_CI_AS
	,CP.intDefaultPositionId
	,PO.strPosition
	,PO.strPositionType
	,CP.intDefaultFreightTermId
	,FT.strFreightTerm AS strDefaultFreightTerm
	,CP.intDefaultLeastCostSourceType
	,strDefaultLeastCostSourceType = CASE CP.intDefaultLeastCostSourceType
		WHEN 1 THEN 'LG Loads - Outbound'
		WHEN 2 THEN 'TM Orders'
		WHEN 3 THEN 'LG Loads - Inbound'
		WHEN 4 THEN 'TM Sites'
		WHEN 5 THEN 'Entities'
		WHEN 6 THEN 'Sales/Transfer Orders'
		END COLLATE Latin1_General_CI_AS
	,CP.strALKMapKey
	,CP.intTransUsedBy
	,strTransUsedBy = CASE CP.intTransUsedBy
		WHEN 1 THEN 'None'
		WHEN 2 THEN 'Scale Ticket'
		WHEN 3 THEN 'Transport Load'
		END COLLATE Latin1_General_CI_AS
	,CP.ysnAlertApprovedQty
	,CP.ysnUpdateVesselInfo
	,CP.ysnValidateExternalPONo
	,CP.ysnETAMandatory
	,CP.ysnPOETAFeedToERP
	,CP.ysnFeedETAToUpdatedAvailabilityDate
	--,CP.ysnContractSlspnOnEmail
	--,CP.strSignature
	,CP.strCarrierShipmentStandardText
	,CP.strShippingInstructionText
	,CP.strInvoiceText
	,CP.strBOLText
	,CP.strReleaseOrderText
	,CP.dblRouteHours
	,CP.intShippingMode
	,SM.strShippingMode
	,CP.intHaulerEntityId
	,EN.strName AS strHaulerEntityName
	,CP.intDefaultFreightItemId
	,strFreightItem = FI.strItemNo
	,CP.intDefaultSurchargeItemId
	,strSurchargeItem = SI.strItemNo
	,CP.intDefaultInsuranceItemId
	,strInsuranceItem = II.strItemNo
	,CP.intDefaultShipmentType
	,strDefaultShipmentType = CASE CP.intDefaultShipmentType
		WHEN 1 THEN 'Shipment'
		WHEN 2 THEN 'Shipping Instructions'
		END COLLATE Latin1_General_CI_AS 
	,CP.intCompanyLocationId
	,CL.strLocationName AS strCompanyLocationName
	,CP.intShippingInstructionReportFormat
	,strShippingInstructionReportFormat = CASE WHEN CP.intShippingInstructionReportFormat IS NOT NULL 
		THEN 'Shipping Instruction Report Format - ' + CAST(CP.intShippingInstructionReportFormat AS NVARCHAR(10)) 
		ELSE '' END COLLATE Latin1_General_CI_AS
	,CP.intDeliveryOrderReportFormat
	,strDeliveryOrderReportFormat = CASE WHEN CP.intDeliveryOrderReportFormat IS NOT NULL 
		THEN 'Delivery Order Report Format - ' + CAST(CP.intDeliveryOrderReportFormat AS NVARCHAR(10)) 
		ELSE '' END COLLATE Latin1_General_CI_AS
	,CP.intInStoreLetterReportFormat
	,strInStoreLetterReportFormat = CASE WHEN CP.intInStoreLetterReportFormat IS NOT NULL 
		THEN 'In-Store Letter Report Format - ' + CAST(CP.intInStoreLetterReportFormat AS NVARCHAR(10)) 
		ELSE '' END COLLATE Latin1_General_CI_AS
	,CP.intShippingAdviceReportFormat
	,strShippingAdviceReportFormat = CASE WHEN CP.intShippingAdviceReportFormat IS NOT NULL 
		THEN 'Shipping Advice Report Format - ' + CAST(CP.intShippingAdviceReportFormat AS NVARCHAR(10)) 
		ELSE '' END COLLATE Latin1_General_CI_AS
	,CP.intInsuranceLetterReportFormat
	,strInsuranceLetterReportFormat = CASE WHEN CP.intInsuranceLetterReportFormat IS NOT NULL 
		THEN 'Insurance Letter Report Format - ' + CAST(CP.intInsuranceLetterReportFormat AS NVARCHAR(10)) 
		ELSE '' END COLLATE Latin1_General_CI_AS
	,CP.intCarrierShipmentOrderReportFormat
	,strCarrierShipmentOrderReportFormat = CASE WHEN CP.intCarrierShipmentOrderReportFormat IS NOT NULL 
		THEN 'Carrier Shipment Order Report Format - ' + CAST(CP.intCarrierShipmentOrderReportFormat AS NVARCHAR(10)) 
		ELSE '' END COLLATE Latin1_General_CI_AS
	,CP.intDebitNoteReportFormat
	,strDebitNoteReportFormat = CASE WHEN CP.intDebitNoteReportFormat IS NOT NULL 
		THEN 'Debit Note Report Format - ' + CAST(CP.intDebitNoteReportFormat AS NVARCHAR(10)) 
		ELSE '' END COLLATE Latin1_General_CI_AS
	,CP.intCreditNoteReportFormat
	,strCreditNoteReportFormat = CASE WHEN CP.intCreditNoteReportFormat IS NOT NULL 
		THEN 'Credit Note Report Format - ' + CAST(CP.intCreditNoteReportFormat AS NVARCHAR(10)) 
		ELSE '' END COLLATE Latin1_General_CI_AS
	,CP.intOrganicDeclarationReportFormat
	,strOrganicDeclarationReportFormat = CASE WHEN CP.intOrganicDeclarationReportFormat IS NOT NULL 
		THEN 'Organic Declaration Report Format - ' + CAST(CP.intOrganicDeclarationReportFormat AS NVARCHAR(10)) 
		ELSE '' END COLLATE Latin1_General_CI_AS
	,CP.intPreArrivalNotificationReportFormat
	,strPreArrivalNotificationReportFormat = CASE WHEN CP.intPreArrivalNotificationReportFormat IS NOT NULL 
		THEN 'Pre Arrival Notification Report Format - ' + CAST(CP.intPreArrivalNotificationReportFormat AS NVARCHAR(10)) 
		ELSE '' END COLLATE Latin1_General_CI_AS
	,CP.intBOLReportFormat
	,strBOLReportFormat = CASE WHEN CP.intBOLReportFormat IS NOT NULL 
		THEN 'BOL Report Format - ' + CAST(CP.intBOLReportFormat AS NVARCHAR(10)) 
		ELSE '' END COLLATE Latin1_General_CI_AS
	,CP.strSignature
	,CP.ysnContractSlspnOnEmail
	,CP.ysnHighwayOnly
	,CP.ysnInclTollData
	,CP.intVehicleType
	,CP.intRoutingType
	,CP.intHazMatType
	,CP.intRouteOptimizationType
	,strVehicleType = CASE CP.intVehicleType
		WHEN 0 THEN 'Truck'
		WHEN 1 THEN 'Light Truck'
		WHEN 2 THEN 'Automobile'
		END COLLATE Latin1_General_CI_AS 
	,strRoutingType = CASE CP.intRoutingType
		WHEN 0 THEN 'Practical'
		WHEN 1 THEN 'Shortest'
		END COLLATE Latin1_General_CI_AS 
	,strHazMatType = CASE CP.intHazMatType
		WHEN 0 THEN 'None'
		WHEN 1 THEN 'General'
		WHEN 2 THEN 'Caustic'
		WHEN 3 THEN 'Explosives'
		WHEN 4 THEN 'Flammable'
		WHEN 5 THEN 'Inhalants'
		WHEN 6 THEN 'Radioactive'
		END COLLATE Latin1_General_CI_AS 
	,strRouteOptimizationType = CASE CP.intRouteOptimizationType
		WHEN 0 THEN 'None'
		WHEN 1 THEN 'Optimize All Stops'
		WHEN 2 THEN 'Optimize Intermediate Stops'
		END COLLATE Latin1_General_CI_AS 
	,ysnUpdateCompanyLocation = CAST(ISNULL(ysnUpdateCompanyLocation,0) AS BIT) 
	,ysnLoadContainerTypeByOrigin = CAST(ISNULL(ysnLoadContainerTypeByOrigin,0) AS BIT)
	,ysnRestrictIncreaseSeqQty = CAST(ISNULL(ysnRestrictIncreaseSeqQty,0) AS BIT)
	,intNumberOfDecimalPlaces = ISNULL(CP.intNumberOfDecimalPlaces,4) 
	,CP.ysnFullHeaderLogo
	,CP.ysnContainerNoUnique
	,CP.intReportLogoHeight
	,CP.intReportLogoWidth
	,CP.ysnEnableAccrualsForInbound
	,CP.ysnEnableAccrualsForOutbound
	,CP.ysnEnableAccrualsForDropShip
	,CP.ysnMatchItemAllocation
	,CP.ysnMatchFuturesAllocation
	,CP.ysnMatchBookAllocation
	,CP.ysnAllowInvoiceForPartialPriced
	,CP.intPnLReportReserveACategoryId
	,strReserveACategory = RA.strCategoryCode
	,CP.intPnLReportReserveBCategoryId
	,strReserveBCategory = RB.strCategoryCode
	,CP.intPurchaseContractBasisItemId
	,strPurchaseContractBasisItem = PCBI.strItemNo
	,CP.intDefaultPickType
	,strDefaultPickType = CASE WHEN CP.intDefaultPickType = 2 THEN 'Containers' ELSE 'Lots' END COLLATE Latin1_General_CI_AS
	,CP.ysnIncludeOpenContractsOnInventoryView
	,CP.ysnIncludeArrivedInPortStatus
	,CP.ysnIncludeStrippingInstructionStatus
	,CP.ysnWeightClaimsByContainer
	,CP.intExpirationDays
	,CP.intExpirationDateBasis
	,strExpirationDateBasis = CASE CP.intExpirationDateBasis
		WHEN 1 THEN 'Scheduled Date' 
		WHEN 2 THEN 'Contract End Date'
		ELSE '' END COLLATE Latin1_General_CI_AS 
	,CP.strFullCalendarKey
FROM tblLGCompanyPreference CP
LEFT JOIN tblICCommodity CO ON CO.intCommodityId = CP.intCommodityId
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CP.intWeightUOMId
LEFT JOIN tblCTPosition PO ON PO.intPositionId = CP.intDefaultPositionId
LEFT JOIN tblLGShippingMode SM ON SM.intShippingModeId = CP.intShippingMode
LEFT JOIN tblEMEntity EN ON EN.intEntityId = CP.intHaulerEntityId
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CP.intCompanyLocationId
LEFT JOIN tblSMFreightTerms FT ON FT.intFreightTermId = CP.intDefaultFreightTermId
LEFT JOIN tblICItem FI ON CP.intDefaultFreightItemId = FI.intItemId
LEFT JOIN tblICItem SI ON CP.intDefaultSurchargeItemId = SI.intItemId
LEFT JOIN tblICItem II ON CP.intDefaultInsuranceItemId = II.intItemId
LEFT JOIN tblICCategory RA ON RA.intCategoryId = CP.intPnLReportReserveACategoryId
LEFT JOIN tblICCategory RB ON RB.intCategoryId = CP.intPnLReportReserveBCategoryId
LEFT JOIN tblICItem PCBI ON PCBI.intItemId = CP.intPurchaseContractBasisItemId