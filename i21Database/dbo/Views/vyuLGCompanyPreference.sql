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
	,CASE CP.intDefaultShipmentTransType
		WHEN 1
			THEN 'Inbound'
		WHEN 2
			THEN 'Outbound'
		WHEN 3
			THEN 'Drop Ship'
		END AS strDefaultShipmentTransType
	,CP.intDefaultShipmentSourceType
	,CASE CP.intDefaultShipmentSourceType
		WHEN 1
			THEN 'None'
		WHEN 2
			THEN 'Contracts'
		WHEN 3
			THEN 'Orders'
		END AS strDefaultShipmentSourceType
	,CP.intCreateShipmentDefaultSourceType
	,CASE CP.intCreateShipmentDefaultSourceType
		WHEN 2
			THEN 'Contracts'
		WHEN 5
			THEN 'Picked Lots'
		WHEN 6
			THEN 'Pick Lots'
		END AS strCreateShipmentDefaultSourceType
	,CP.intDefaultTransportationMode
	,CASE CP.intDefaultTransportationMode
		WHEN 1
			THEN 'Truck'
		WHEN 2
			THEN 'Ocean Vessel'
		END AS strDefaultTransportationMode
	,CP.intDefaultPositionId
	,PO.strPosition
	,PO.strPositionType
	,CP.intDefaultFreightTermId
	,FT.strFreightTerm AS strDefaultFreightTerm
	,CP.intDefaultLeastCostSourceType
	,CASE CP.intDefaultLeastCostSourceType
		WHEN 1
			THEN 'LG Loads - Outbound'
		WHEN 2
			THEN 'TM Orders'
		WHEN 3
			THEN 'LG Loads - Inbound'
		WHEN 4
			THEN 'TM Sites'
		WHEN 5
			THEN 'Entities'
		END AS strDefaultLeastCostSourceType
	,CP.strALKMapKey
	,CP.intTransUsedBy
	,CASE CP.intTransUsedBy
		WHEN 1
			THEN 'None'
		WHEN 2
			THEN 'Scale Ticket'
		WHEN 3
			THEN 'Transport Load'
		END AS strTransUsedBy
	,CP.ysnAlertApprovedQty
	,CP.ysnUpdateVesselInfo
	,CP.ysnValidateExternalPONo
	,CP.ysnETAMandatory
	,CP.ysnPOETAFeedToERP
	--,CP.ysnContractSlspnOnEmail
	--,CP.strSignature
	,CP.strCarrierShipmentStandardText
	,CP.strShippingInstructionText
	,CP.dblRouteHours
	,CP.intShippingMode
	,SM.strShippingMode
	,CP.intHaulerEntityId
	,EN.strName AS strHaulerEntityName
	,CP.intDefaultShipmentType
	,CASE CP.intDefaultShipmentType
		WHEN 1
			THEN 'Shipment'
		WHEN 2
			THEN 'Shipping Instructions'
		END strDefaultShipmentType
	,CP.intCompanyLocationId
	,CL.strLocationName AS strCompanyLocationName
	,CP.intShippingInstructionReportFormat
	,CASE CP.intShippingInstructionReportFormat
		WHEN 1
			THEN 'Shipping Instruction Report Format - 1'
		WHEN 2
			THEN 'Shipping Instruction Report Format - 2'
		WHEN 3
			THEN 'Shipping Instruction Report Format - 3'
		END AS strShippingInstructionReportFormat
	,CP.intDeliveryOrderReportFormat
	,CASE CP.intDeliveryOrderReportFormat
		WHEN 1
			THEN 'Delivery Order Report Format - 1'
		WHEN 2
			THEN ''
		END strDeliveryOrderReportFormat
	,CP.intInStoreLetterReportFormat
	,CASE CP.intInStoreLetterReportFormat
		WHEN 1
			THEN 'In-Store Letter Report Format - 1'
		WHEN 2
			THEN 'In-Store Letter Report Format - 2'
		WHEN 3
			THEN 'In-Store Letter Report Format - 3'
		END strInStoreLetterReportFormat
	,CP.intShippingAdviceReportFormat
	,CASE CP.intShippingAdviceReportFormat
		WHEN 1
			THEN 'Shipping Advice Report Format - 1'
		WHEN 2
			THEN 'Shipping Advice Report Format - 2'
		END strShippingAdviceReportFormat
	,CP.intInsuranceLetterReportFormat
	,CASE CP.intInsuranceLetterReportFormat
		WHEN 1
			THEN 'Insurance Letter Report Format - 1'
		WHEN 2
			THEN ''
		END strInsuranceLetterReportFormat
	,CP.intCarrierShipmentOrderReportFormat
	,CASE CP.intCarrierShipmentOrderReportFormat
		WHEN 1
			THEN 'Carrier Shipment Order Report Format - 1'
		WHEN 2
			THEN ''
		END strCarrierShipmentOrderReportFormat
	,CP.intDebitNoteReportFormat
	,CASE CP.intDebitNoteReportFormat
		WHEN 1
			THEN 'Debit Note Report Format - 1'
		WHEN 2
			THEN 'Debit Note Report Format - 2'
		END strDebitNoteReportFormat
	,CP.intCreditNoteReportFormat
	,CASE CP.intCreditNoteReportFormat
		WHEN 1
			THEN 'Credit Note Report Format - 1'
		WHEN 2
			THEN 'Credit Note Report Format - 2'
		END strCreditNoteReportFormat
	,CP.intOrganicDeclarationReportFormat
	,CASE CP.intOrganicDeclarationReportFormat
		WHEN 1
			THEN 'Organic Declaration Report Format - 1'
		WHEN 2
			THEN ''
		END strOrganicDeclarationReportFormat
	,CP.intPreArrivalNotificationReportFormat
	,CASE CP.intPreArrivalNotificationReportFormat
		WHEN 1
			THEN 'Pre Arrival Notification Report Format - 1'
		END strPreArrivalNotificationReportFormat
	,CP.strSignature
	,CP.ysnContractSlspnOnEmail
	,CP.ysnHighwayOnly
	,CP.ysnInclTollData
	,CP.intVehicleType
	,CP.intRoutingType
	,CP.intHazMatType
	,CP.intRouteOptimizationType
	,CASE CP.intVehicleType
		WHEN 0
			THEN 'Truck'
		WHEN 1
			THEN 'Light Truck'
		WHEN 2
			THEN 'Automobile'
		END strVehicleType
	,CASE CP.intRoutingType
		WHEN 0
			THEN 'Practical'
		WHEN 1
			THEN 'Shortest'
		END strRoutingType
	,CASE CP.intHazMatType
		WHEN 0
			THEN 'None'
		WHEN 1
			THEN 'General'
		WHEN 2
			THEN 'Caustic'
		WHEN 3
			THEN 'Explosives'
		WHEN 4
			THEN 'Flammable'
		WHEN 5
			THEN 'Inhalants'
		WHEN 6
			THEN 'Radioactive'
		END strHazMatType
	,CASE CP.intRouteOptimizationType
		WHEN 0
			THEN 'None'
		WHEN 1
			THEN 'Optimize All Stops'
		WHEN 2
			THEN 'Optimize Intermediate Stops'
		END strRouteOptimizationType
	,CAST(ISNULL(ysnUpdateCompanyLocation,0) AS BIT) ysnUpdateCompanyLocation
	,CAST(ISNULL(ysnLoadContainerTypeByOrigin,0) AS BIT) ysnLoadContainerTypeByOrigin
	,CAST(ISNULL(ysnRestrictIncreaseSeqQty,0) AS BIT) ysnRestrictIncreaseSeqQty
	,ISNULL(CP.intNumberOfDecimalPlaces,4) intNumberOfDecimalPlaces
	,CP.ysnFullHeaderLogo
	,CP.ysnContainerNoUnique
FROM tblLGCompanyPreference CP
LEFT JOIN tblICCommodity CO ON CO.intCommodityId = CP.intCommodityId
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CP.intWeightUOMId
LEFT JOIN tblCTPosition PO ON PO.intPositionId = CP.intDefaultPositionId
LEFT JOIN tblLGShippingMode SM ON SM.intShippingModeId = CP.intShippingMode
LEFT JOIN tblEMEntity EN ON EN.intEntityId = CP.intHaulerEntityId
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CP.intCompanyLocationId
LEFT JOIN tblSMFreightTerms FT ON FT.intFreightTermId = CP.intDefaultFreightTermId