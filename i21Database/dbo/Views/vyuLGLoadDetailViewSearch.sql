﻿CREATE VIEW vyuLGLoadDetailViewSearch
AS
SELECT   Load.intLoadId
		,Load.intConcurrencyId
		,Load.[strLoadNumber]
		,Load.intPurchaseSale
		,Load.intEquipmentTypeId
		,Load.intHaulerEntityId
		,Load.intTicketId
		,Load.intGenerateLoadId
		,Load.intUserSecurityId
		,Load.intTransportLoadId
		,Load.intLoadHeaderId
		,Load.intDriverEntityId
		,Load.intDispatcherId
        ,Load.strExternalLoadNumber
        ,strType = CASE WHEN Load.intPurchaseSale = 1 THEN 
						'Inbound' 
						ELSE 
							CASE WHEN Load.intPurchaseSale = 2 THEN 
							'Outbound' 
							ELSE
							'Drop Ship'
							END
						END
        ,intGenerateSequence = Load.intGenerateSequence
        ,Load.dtmScheduledDate
        ,ysnInProgress = IsNull(Load.ysnInProgress, 0)
        ,Load.dtmDeliveredDate
        ,Load.strCustomerReference
        ,Load.strTruckNo
        ,Load.strTrailerNo1
        ,Load.strTrailerNo2
        ,Load.strTrailerNo3
        ,Load.strComments
        ,ysnDispatched = CASE WHEN Load.ysnDispatched = 1 THEN CAST(1 AS bit) ELSE CAST(0 AS Bit) END
		,Load.dtmDispatchedDate
		,Load.ysnDispatchMailSent
		,Load.dtmDispatchMailSent
		,Load.dtmCancelDispatchMailSent
		,Load.intCompanyLocationId
		,Load.intTransUsedBy
		,strTransUsedBy = CASE 
			WHEN Load.intTransUsedBy = 1 
				THEN 'None'
			WHEN Load.intTransUsedBy = 2
				THEN 'Scale Ticket'
			WHEN Load.intTransUsedBy = 3
				THEN 'Transport Load'
			END
		,Load.intSourceType
		,Load.ysnPosted
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
        ,intGenerateReferenceNumber = GLoad.intReferenceNumber
        ,intNumberOfLoads = GLoad.intNumberOfLoads

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

		,strPContractNumber = PHeader.strContractNumber
		,intPContractSeq = PDetail.intContractSeq
		,ysnPLoad = PHeader.ysnLoad
		,ysnBundle = CONVERT(BIT,CASE Item.strType 
					 WHEN 'Bundle' THEN 1
					 ELSE 0 END)
		,strCustomer = CEN.strName
        ,strShipTo = CEL.strLocationName

		,intSContractHeaderId = SHeader.intContractHeaderId
        ,strSContractNumber = SHeader.strContractNumber
        ,intSContractSeq = SDetail.intContractSeq
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

		,Item.strItemNo
		,Item.strDescription AS strItemDescription
		,UOM.strUnitMeasure AS strItemUOM
		,UOM.intUnitMeasureId AS intItemUnitMeasureId
		,WeightUOM.strUnitMeasure AS strWeightItemUOM
        ,strEquipmentType = EQ.strEquipmentType
        ,strHauler = Hauler.strName
        ,strDriver = Driver.strName
		,strDispatcher = US.strUserName 
        ,strScaleTicketNo = CASE WHEN IsNull(Load.intTicketId, 0) <> 0 
								 THEN 
									CAST(ST.strTicketNumber AS VARCHAR(100))
								 ELSE 
									CASE WHEN IsNull(Load.intLoadHeaderId, 0) <> 0 
										THEN 
											TR.strTransaction
										ELSE 
											NULL 
										END 
								 END
		,PLH.intPickLotHeaderId
		,PLH.strPickLotNumber
		,ALH.intAllocationHeaderId
		,ALH.strAllocationNumber
		,Load.intLoadShippingInstructionId
		,LSI.strLoadNumber AS strShippingInstructionNo
		,Load.intShipmentType
		,strShipmentType = CASE Load.intShipmentType
			WHEN 1
				THEN 'Shipment'
			WHEN 2
				THEN 'Shipping Instructions'
			WHEN 3
				THEN 'Vessel Nomination'
			ELSE ''
			END COLLATE Latin1_General_CI_AS
		,Item.intCommodityId
		,CA.intCommodityAttributeId
		,CA.strDescription AS strOrigin
		,LoadDetail.intNumberOfContainers
FROM tblLGLoadDetail LoadDetail
JOIN tblLGLoad Load ON Load.intLoadId = LoadDetail.intLoadId
LEFT JOIN tblLGGenerateLoad GLoad ON GLoad.intGenerateLoadId = Load.intGenerateLoadId
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
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LoadDetail.intItemUOMId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN tblICItemUOM WeightItemUOM ON WeightItemUOM.intItemUOMId = LoadDetail.intWeightItemUOMId
LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = WeightItemUOM.intUnitMeasureId
LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = Item.intOriginId
LEFT JOIN tblTRLoadHeader TR ON TR.intLoadHeaderId = Load.intLoadHeaderId
LEFT JOIN tblLGEquipmentType EQ ON EQ.intEquipmentTypeId = Load.intEquipmentTypeId
LEFT JOIN tblEMEntity Hauler ON Hauler.intEntityId = Load.intHaulerEntityId
LEFT JOIN tblEMEntity Driver ON Driver.intEntityId = Load.intDriverEntityId
LEFT JOIN tblSCTicket ST ON ST.intTicketId = Load.intTicketId
LEFT JOIN tblSMUserSecurity US ON US.[intEntityUserSecurityId]	= Load.intDispatcherId
LEFT JOIN tblLGPickLotDetail PLD ON PLD.intPickLotDetailId = LoadDetail.intPickLotDetailId
LEFT JOIN tblLGPickLotHeader PLH ON PLH.intPickLotHeaderId = PLD.intPickLotHeaderId
LEFT JOIN tblLGAllocationDetail ALD ON ALD.intAllocationDetailId = LoadDetail.intAllocationDetailId
LEFT JOIN tblLGAllocationHeader ALH ON ALH.intAllocationHeaderId = ALD.intAllocationHeaderId	
LEFT JOIN tblLGLoad LSI ON LSI.intLoadId = Load.intLoadShippingInstructionId