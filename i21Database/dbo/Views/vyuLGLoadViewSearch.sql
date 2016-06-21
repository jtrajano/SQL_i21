CREATE VIEW vyuLGLoadViewSearch
AS
SELECT L.intLoadId
	,LD.intLoadDetailId
	,L.intGenerateLoadId
	,LD.intVendorEntityId
	,LD.intCustomerEntityId
	,LD.intPContractDetailId
	,LD.intSContractDetailId
	,L.intHaulerEntityId
	,L.strLoadNumber
	,L.strExternalLoadNumber
	,strType = CASE L.intPurchaseSale
		WHEN 1
			THEN 'Inbound'
		WHEN 2
			THEN 'Outbound'
		WHEN 3
			THEN 'Drop Ship'
		END
	,intGenerateReferenceNumber = GL.intReferenceNumber
	,L.intGenerateSequence
	,intNumberOfLoads = GL.intNumberOfLoads
	,strPLocationName = PCL.strLocationName
	,strVendor = VEN.strName
	,strShipFrom = VEL.strLocationName
	,strPContractNumber = PCH.strContractNumber
	,intPContractSeq = PCD.intContractSeq
	,strCustomer = CEN.strName
	,strShipTo = CEL.strLocationName
	,strSContractNumber = SCH.strContractNumber
	,intSContractSeq = SCD.intContractSeq
	,strSLocationName = SCL.strLocationName
	,strItemNo = I.strDescription
	,L.dtmScheduledDate
	,LD.dblQuantity
	,strHauler = Hauler.strName
	,strDriver = Driver.strName
	,L.strComments
	,ysnDispatched = CASE 
		WHEN L.ysnDispatched = 1
			THEN CAST(1 AS BIT)
		ELSE CAST(0 AS BIT)
		END
	,strScaleTicketNo = CASE WHEN IsNull(L.intTicketId, 0) <> 0 
							THEN 
							CAST(ST.strTicketNumber AS VARCHAR(100))
							ELSE 
							CASE WHEN IsNull(L.intTransportLoadId, 0) <> 0 
								THEN 
									TL.strTransaction
								ELSE 
									CASE WHEN IsNull(L.intLoadHeaderId, 0) <> 0 
										THEN 
											TR.strTransaction
										ELSE 
											NULL 
										END 
								END 
							END
FROM tblLGLoad L
JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
LEFT JOIN tblICItem I ON I.intItemId = LD.intItemId
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = LD.intItemUOMId
LEFT JOIN tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblICItemUOM WU ON WU.intItemUOMId = LD.intWeightItemUOMId
LEFT JOIN tblICUnitMeasure WUM ON WUM.intUnitMeasureId = WU.intUnitMeasureId
LEFT JOIN tblLGGenerateLoad GL ON GL.intGenerateLoadId = L.intGenerateLoadId
LEFT JOIN tblSMCompanyLocation PCL ON PCL.intCompanyLocationId = LD.intPCompanyLocationId
LEFT JOIN tblSMCompanyLocation SCL ON SCL.intCompanyLocationId = LD.intSCompanyLocationId
LEFT JOIN tblEntity VEN ON VEN.intEntityId = LD.intVendorEntityId
LEFT JOIN tblEntityLocation VEL ON VEL.intEntityLocationId = LD.intVendorEntityLocationId
LEFT JOIN tblCTContractDetail PCD ON PCD.intContractDetailId = LD.intPContractDetailId
LEFT JOIN tblCTContractDetail SCD ON SCD.intContractDetailId = LD.intSContractDetailId
LEFT JOIN tblCTContractHeader PCH ON PCH.intContractHeaderId = PCD.intContractHeaderId
LEFT JOIN tblCTContractHeader SCH ON SCH.intContractHeaderId = SCD.intContractHeaderId
LEFT JOIN tblEntity CEN ON CEN.intEntityId = LD.intCustomerEntityId
LEFT JOIN tblEntityLocation CEL ON CEL.intEntityLocationId = LD.intCustomerEntityLocationId
LEFT JOIN tblEntity Hauler ON Hauler.intEntityId = L.intHaulerEntityId
LEFT JOIN tblEntity Driver ON Driver.intEntityId = L.intDriverEntityId
LEFT JOIN tblSCTicket ST ON ST.intTicketId = L.intTicketId
LEFT JOIN tblTRTransportLoad TL ON TL.intTransportLoadId = L.intTransportLoadId
LEFT JOIN tblTRLoadHeader TR ON TR.intLoadHeaderId = L.intLoadHeaderId