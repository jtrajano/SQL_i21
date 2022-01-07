CREATE VIEW vyuLGLoadDetailViewSearch
AS
SELECT   L.intLoadId
		,L.intConcurrencyId
		,L.[strLoadNumber]
		,L.intPurchaseSale
		,L.intEquipmentTypeId
		,L.intHaulerEntityId
		,L.intTicketId
		,L.intGenerateLoadId
		,L.intUserSecurityId
		,L.intTransportLoadId
		,L.intLoadHeaderId
		,L.intDriverEntityId
		,L.intDispatcherId
        ,L.strExternalLoadNumber
		,L.strExternalShipmentNumber
		,L.dtmETAPOD
		,L.dtmETAPOL
		,L.dtmETSPOL
		,L.[ysnArrivedInPort]
		,L.[ysnDocumentsApproved]
		,L.[ysnCustomsReleased]
		,L.[dtmArrivedInPort]
		,L.[dtmDocumentsApproved]
		,L.[dtmCustomsReleased]
		,POS.strPosition
		,POS.strPositionType
        ,strType = CASE L.intPurchaseSale 
			WHEN 1 THEN 'Inbound' 
			WHEN 2 THEN 'Outbound' 
			WHEN 3 THEN 'Drop Ship'
			END COLLATE Latin1_General_CI_AS
        ,intGenerateSequence = L.intGenerateSequence
        ,L.dtmScheduledDate
        ,ysnInProgress = IsNull(L.ysnInProgress, 0)
        ,L.dtmDeliveredDate
        ,L.strCustomerReference
        ,L.strTruckNo
        ,L.strTrailerNo1
        ,L.strTrailerNo2
        ,L.strTrailerNo3
        ,L.strCarNumber
        ,L.strEmbargoNo
        ,L.strEmbargoPermitNo
        ,L.strComments
		,L.strBOLInstructions
        ,ysnDispatched = CASE WHEN L.ysnDispatched = 1 THEN CAST(1 AS bit) ELSE CAST(0 AS Bit) END
		,L.dtmDispatchedDate
		,L.ysnDispatchMailSent
		,L.dtmDispatchMailSent
		,L.dtmCancelDispatchMailSent
		,L.intCompanyLocationId
		,L.intTransUsedBy
		,strTransUsedBy = CASE L.intTransUsedBy
			WHEN 1 THEN 'None'
			WHEN 2 THEN 'Scale Ticket'
			WHEN 3 THEN 'Transport Load'
			END COLLATE Latin1_General_CI_AS
		,L.intSourceType
		,L.ysnPosted
		,LoadDetail.intLoadDetailId
		,LoadDetail.intItemId
		,LoadDetail.dblQuantity
		,LoadDetail.intItemUOMId
		,LoadDetail.dblGross
		,LoadDetail.dblTare
		,LoadDetail.dblNet
		,LoadDetail.intWeightItemUOMId
		,LoadDetail.dblDeliveredQuantity
		,LoadDetail.dblDeliveredGross
		,LoadDetail.dblDeliveredTare
		,LoadDetail.dblDeliveredNet
		,LoadDetail.intVendorEntityId
		,LoadDetail.intVendorEntityLocationId
		,LoadDetail.intPContractDetailId
		,LoadDetail.intPCompanyLocationId
		,LoadDetail.intCustomerEntityId
		,LoadDetail.intCustomerEntityLocationId
		,LoadDetail.intSContractDetailId
		,LoadDetail.intSCompanyLocationId
		,LoadDetail.strScheduleInfoMsg
		,LoadDetail.ysnUpdateScheduleInfo
		,LoadDetail.ysnPrintScheduleInfo
		,LoadDetail.strLoadDirectionMsg
		,LoadDetail.ysnUpdateLoadDirections
		,LoadDetail.ysnPrintLoadDirections
		,LoadDetail.strExternalShipmentItemNumber
		,LoadDetail.strExternalBatchNo
		,strSampleStatus = ISNULL(LSS.strStatus, CSS.strStatus)
        ,intGenerateReferenceNumber = GLoad.intReferenceNumber
        ,intNumberOfLoads = GLoad.intNumberOfLoads
		,intContractHeaderId = CASE WHEN L.intPurchaseSale = 2 THEN SHeader.intContractHeaderId ELSE PHeader.intContractHeaderId END 
		,PHeader.intContractHeaderId AS intPContractHeaderId 
		,L.ysnLoadBased

-- Inbound Company Location
        ,strPLocationName = PCL.strLocationName
		,strPLocationAddress = PCL.strAddress
		,strPLocationCity = PCL.strCity
		,strPLocationCountry = PCL.strCountry
		,strPLocationState = PCL.strStateProvince
		,strPLocationZipCode = PCL.strZipPostalCode
		,strPLocationMail = PCL.strEmail
		,strPLocationFax = PCL.strFax
		,strPLocationPhone = PCL.strPhone
		,PCLSL.strSubLocationName AS strPSubLocationName
		,SCLSL.strSubLocationName AS strSSubLocationName
        ,strVendor = VEN.strName
        ,strShipFrom = VEL.strLocationName
		,strShipFromAddress = VEL.strAddress
		,strShipFromCity = VEL.strCity
		,strShipFromCountry = VEL.strCountry
		,strShipFromState = VEL.strState
		,strShipFromZipCode = VEL.strZipCode
		,strVendorNo = VEN.strEntityNo
		,strVendorEmail = VEN.strEmail
		,strVendorFax = VEN.strFax
		,strVendorMobile = VEN.strMobile
		,strVendorPhone = VEN.strPhone
		,LoadDetail.intSellerId
		,strSeller = Seller.strName

		,strPContractNumber = PHeader.strContractNumber
		,intPContractSeq = PDetail.intContractSeq
		,strPERPPONumber = PDetail.strERPPONumber
		,ysnPLoad = PHeader.ysnLoad
		,ysnBundle = CONVERT(BIT, CASE Item.strType WHEN 'Bundle' THEN 1 ELSE 0 END)
		,strCustomer = CEN.strName
        ,strShipTo = CEL.strLocationName

		,intSContractHeaderId = SHeader.intContractHeaderId
        ,strSContractNumber = SHeader.strContractNumber
        ,intSContractSeq = SDetail.intContractSeq
		,strSERPPONumber = SDetail.strERPPONumber
		,ysnSLoad = SHeader.ysnLoad

        ,strSLocationName = SCL.strLocationName
		,strSLocationAddress = SCL.strAddress
		,strSLocationCity = SCL.strCity
		,strSLocationCountry = SCL.strCountry
		,strSLocationState = SCL.strStateProvince
		,strSLocationZipCode = SCL.strZipPostalCode
		,strSLocationMail = SCL.strEmail
		,strSLocationFax = SCL.strFax
		,strSLocationPhone = SCL.strPhone
		,LoadDetail.intSalespersonId
		,strSalesperson = Salesperson.strName

		,Commodity.strCommodityCode AS strCommodity
		,Item.strItemNo
		,Item.strDescription AS strItemDescription
		,strBundleItemNo = ISNULL(PBundle.strItemNo, SBundle.strItemNo)
		,ysnUseWeighScales = CONVERT(BIT,ISNULL(Item.ysnUseWeighScales,0)) 
		,UOM.strUnitMeasure AS strItemUOM
		,UOM.intUnitMeasureId AS intItemUnitMeasureId
		,WeightUOM.strUnitMeasure AS strWeightItemUOM
        ,strEquipmentType = EQ.strEquipmentType
        ,strHauler = Hauler.strName
        ,strDriver = Driver.strName
		,strDispatcher = US.strUserName 
		,strShippingLine = ShippingLine.strName
		,strForwardingAgent = ForwardingAgent.strName
		,L.strBookingReference
        ,strScaleTicketNo = CASE WHEN IsNull(L.intTicketId, 0) <> 0 
									THEN CAST(ST.strTicketNumber AS VARCHAR(100))
								 WHEN IsNull(L.intLoadHeaderId, 0) <> 0 
									THEN TR.strTransaction
								 ELSE NULL END
		,PLH.intPickLotHeaderId
		,PLH.strPickLotNumber
		,ALH.intAllocationHeaderId
		,ALH.strAllocationNumber
		,L.intLoadShippingInstructionId
		,LSI.strLoadNumber AS strShippingInstructionNo
		,L.intShipmentType
		,strShipmentType = CASE L.intShipmentType
			WHEN 1 THEN 'Shipment'
			WHEN 2 THEN 'Shipping Instructions'
			WHEN 3 THEN 'Vessel Nomination'
			ELSE '' END COLLATE Latin1_General_CI_AS
		,Item.intCommodityId
		,CA.intCommodityAttributeId
		,CO.strCountry AS strOrigin
		,LoadDetail.intNumberOfContainers
		,strShipmentStatus = CASE L.intShipmentStatus
			WHEN 1 THEN 
				CASE WHEN (L.dtmLoadExpiration IS NOT NULL AND GETDATE() > L.dtmLoadExpiration AND L.intShipmentType = 1
						AND L.intTicketId IS NULL AND L.intLoadHeaderId IS NULL)
				THEN 'Expired'
				ELSE 'Scheduled' END
			WHEN 2 THEN 'Dispatched'
			WHEN 3 THEN 
				CASE WHEN (L.ysnDocumentsApproved = 1 
						AND L.dtmDocumentsApproved IS NOT NULL
						AND ((L.dtmDocumentsApproved > L.dtmArrivedInPort OR L.dtmArrivedInPort IS NULL)
						AND (L.dtmDocumentsApproved > L.dtmCustomsReleased OR L.dtmCustomsReleased IS NULL))) 
						THEN 'Documents Approved'
					WHEN (L.ysnCustomsReleased = 1) THEN 'Customs Released'
					WHEN (L.ysnArrivedInPort = 1) THEN 'Arrived in Port'
					ELSE 'Inbound Transit' END
			WHEN 4 THEN 'Received'
			WHEN 5 THEN 
				CASE WHEN (L.ysnDocumentsApproved = 1 
						AND L.dtmDocumentsApproved IS NOT NULL
						AND ((L.dtmDocumentsApproved > L.dtmArrivedInPort OR L.dtmArrivedInPort IS NULL)
						AND (L.dtmDocumentsApproved > L.dtmCustomsReleased OR L.dtmCustomsReleased IS NULL))) 
						THEN 'Documents Approved'
					WHEN (L.ysnCustomsReleased = 1) THEN 'Customs Released'
					WHEN (L.ysnArrivedInPort = 1) THEN 'Arrived in Port'
					ELSE 'Outbound Transit' END
			WHEN 6 THEN 
				CASE WHEN (L.ysnDocumentsApproved = 1 
						AND L.dtmDocumentsApproved IS NOT NULL
						AND ((L.dtmDocumentsApproved > L.dtmArrivedInPort OR L.dtmArrivedInPort IS NULL)
						AND (L.dtmDocumentsApproved > L.dtmCustomsReleased OR L.dtmCustomsReleased IS NULL))) 
						THEN 'Documents Approved'
					WHEN (L.ysnCustomsReleased = 1) THEN 'Customs Released'
					WHEN (L.ysnArrivedInPort = 1) THEN 'Arrived in Port'
					ELSE 'Delivered' END
			WHEN 7 THEN 
				CASE WHEN (ISNULL(L.strBookingReference, '') <> '') THEN 'Booked'
						ELSE 'Shipping Instruction Created' END
			WHEN 8 THEN 'Partial Shipment Created'
			WHEN 9 THEN 'Full Shipment Created'
			WHEN 10 THEN 'Cancelled'
			WHEN 11 THEN 'Invoiced'
			ELSE '' END COLLATE Latin1_General_CI_AS
		,strTransportationMode = CASE L.intTransportationMode
			WHEN 1 THEN 'Truck'
			WHEN 2 THEN 'Ocean Vessel'
			WHEN 3 THEN 'Rail'
			END COLLATE Latin1_General_CI_AS
		,strPCompanyLocation = PCL.strLocationName
		,strSCompanyLocation = SCL.strLocationName
		,ICI.strContractItemNo
		,ICI.strContractItemName
		,PDetail.intPricingTypeId AS intPPricingTypeId
		,PTP.strPricingType AS strPPricingType
		,SDetail.intPricingTypeId AS intSPricingTypeId
		,PTS.strPricingType AS strSPricingType
		,L.intBookId
		,BO.strBook
		,L.intSubBookId
		,SB.strSubBook
		,strETAPOLReasonCode = ETAPOLRC.strReasonCode
		,strETSPOLReasonCode = ETSPOLRC.strReasonCode
		,strETAPODReasonCode = ETAPODRC.strReasonCode
		,strETAPOLReasonCodeDescription = ETAPOLRC.strReasonCodeDescription
		,strETSPOLReasonCodeDescription = ETSPOLRC.strReasonCodeDescription
		,strETAPODReasonCodeDescription = ETAPODRC.strReasonCodeDescription
FROM tblLGLoadDetail LoadDetail
JOIN tblLGLoad L ON L.intLoadId = LoadDetail.intLoadId
LEFT JOIN tblLGGenerateLoad GLoad ON GLoad.intGenerateLoadId = L.intGenerateLoadId
LEFT JOIN tblSMCompanyLocation PCL ON PCL.intCompanyLocationId = LoadDetail.intPCompanyLocationId
LEFT JOIN tblSMCompanyLocation SCL ON SCL.intCompanyLocationId = LoadDetail.intSCompanyLocationId
LEFT JOIN tblSMCompanyLocationSubLocation PCLSL ON PCLSL.intCompanyLocationSubLocationId = LoadDetail.intPSubLocationId
LEFT JOIN tblSMCompanyLocationSubLocation SCLSL ON SCLSL.intCompanyLocationSubLocationId = LoadDetail.intSSubLocationId
LEFT JOIN tblEMEntity VEN ON VEN.intEntityId = LoadDetail.intVendorEntityId
LEFT JOIN tblEMEntityLocation VEL ON VEL.intEntityLocationId = LoadDetail.intVendorEntityLocationId
LEFT JOIN tblEMEntity CEN ON CEN.intEntityId = LoadDetail.intCustomerEntityId
LEFT JOIN tblEMEntityLocation CEL ON CEL.intEntityLocationId = LoadDetail.intCustomerEntityLocationId
LEFT JOIN tblCTContractDetail PDetail ON PDetail.intContractDetailId = LoadDetail.intPContractDetailId
LEFT JOIN tblCTContractHeader PHeader ON PHeader.intContractHeaderId = PDetail.intContractHeaderId
LEFT JOIN tblCTContractDetail SDetail ON SDetail.intContractDetailId = LoadDetail.intSContractDetailId
LEFT JOIN tblCTContractHeader SHeader ON SHeader.intContractHeaderId = SDetail.intContractHeaderId
LEFT JOIN tblICItem Item On Item.intItemId = LoadDetail.intItemId
LEFT JOIN tblICCommodity Commodity ON Commodity.intCommodityId = Item.intCommodityId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LoadDetail.intItemUOMId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN tblICItemUOM WeightItemUOM ON WeightItemUOM.intItemUOMId = LoadDetail.intWeightItemUOMId
LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = WeightItemUOM.intUnitMeasureId
LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = Item.intOriginId
LEFT JOIN tblICItem PBundle ON PBundle.intItemId = PDetail.intItemBundleId  
LEFT JOIN tblICItem SBundle ON SBundle.intItemId = SDetail.intItemBundleId  
LEFT JOIN tblTRLoadHeader TR ON TR.intLoadHeaderId = L.intLoadHeaderId
LEFT JOIN tblLGEquipmentType EQ ON EQ.intEquipmentTypeId = L.intEquipmentTypeId
LEFT JOIN tblEMEntity Hauler ON Hauler.intEntityId = L.intHaulerEntityId
LEFT JOIN tblEMEntity Driver ON Driver.intEntityId = L.intDriverEntityId
LEFT JOIN tblEMEntity Seller ON Seller.intEntityId = LoadDetail.intSellerId
LEFT JOIN tblEMEntity Salesperson ON Salesperson.intEntityId = LoadDetail.intSalespersonId
LEFT JOIN tblEMEntity ShippingLine ON ShippingLine.intEntityId = L.intShippingLineEntityId
LEFT JOIN tblEMEntity ForwardingAgent ON ForwardingAgent.intEntityId = L.intForwardingAgentEntityId
LEFT JOIN tblCTPricingType PTP ON PTP.intPricingTypeId = PDetail.intPricingTypeId
LEFT JOIN tblCTPricingType PTS ON PTS.intPricingTypeId = SDetail.intPricingTypeId
LEFT JOIN tblSCTicket ST ON ST.intTicketId = L.intTicketId
LEFT JOIN tblSMUserSecurity US ON US.[intEntityId]	= L.intDispatcherId
LEFT JOIN tblLGPickLotDetail PLD ON PLD.intPickLotDetailId = LoadDetail.intPickLotDetailId
LEFT JOIN tblLGPickLotHeader PLH ON PLH.intPickLotHeaderId = PLD.intPickLotHeaderId
LEFT JOIN tblLGAllocationDetail ALD ON ALD.intAllocationDetailId = LoadDetail.intAllocationDetailId
LEFT JOIN tblLGAllocationHeader ALH ON ALH.intAllocationHeaderId = ALD.intAllocationHeaderId	
LEFT JOIN tblLGLoad LSI ON LSI.intLoadId = L.intLoadShippingInstructionId
LEFT JOIN tblICItemContract ICI ON ICI.intItemId = Item.intItemId
	AND PDetail.intItemContractId = ICI.intItemContractId
LEFT JOIN tblSMCountry CO ON CO.intCountryID = (
		CASE 
			WHEN ISNULL(ICI.intCountryId, 0) = 0
				THEN ISNULL(CA.intCountryID, 0)
			ELSE ICI.intCountryId
			END
		)
LEFT JOIN tblCTPosition POS ON POS.intPositionId = L.intPositionId
LEFT JOIN tblCTBook BO ON BO.intBookId = L.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = L.intSubBookId
LEFT JOIN tblLGReasonCode ETAPOLRC ON ETAPOLRC.intReasonCodeId = L.intETAPOLReasonCodeId
LEFT JOIN tblLGReasonCode ETSPOLRC ON ETSPOLRC.intReasonCodeId = L.intETSPOLReasonCodeId
LEFT JOIN tblLGReasonCode ETAPODRC ON ETAPODRC.intReasonCodeId = L.intETAPODReasonCodeId
OUTER APPLY (SELECT TOP 1 strStatus = CASE WHEN (SS.strStatus NOT IN ('Approved', 'Rejected')) THEN 'Sample Sent' ELSE SS.strStatus END
				FROM tblQMSample S JOIN tblQMSampleStatus SS ON SS.intSampleStatusId = S.intSampleStatusId
				WHERE (S.intContractDetailId = SDetail.intContractDetailId OR S.intContractDetailId = PDetail.intContractDetailId)
					AND S.intLoadDetailId IS NULL
				ORDER BY S.dtmTestingEndDate DESC, S.intSampleId DESC) CSS
OUTER APPLY (SELECT TOP 1 strStatus = CASE WHEN (SS.strStatus NOT IN ('Approved', 'Rejected')) THEN 'Sample Sent' ELSE SS.strStatus END
				FROM tblQMSample S JOIN tblQMSampleStatus SS ON SS.intSampleStatusId = S.intSampleStatusId
				WHERE S.intLoadDetailId = LoadDetail.intLoadDetailId
					AND SS.strStatus <> 'Rejected'
				ORDER BY S.dtmTestingEndDate DESC, S.intSampleId DESC) LSS