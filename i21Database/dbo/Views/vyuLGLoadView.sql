CREATE VIEW vyuLGLoadView
AS
SELECT Load.intLoadId
		,Load.intConcurrencyId
		,Load.intLoadNumber
		,Load.intCompanyLocationId
		,Load.intPurchaseSale
		,Load.intItemId
		,Load.intUnitMeasureId
		,Load.intEquipmentTypeId
		,Load.intEntityId
		,Load.intEntityLocationId
		,Load.intContractDetailId
		,Load.intHaulerEntityId
		,Load.intTicketId
		,Load.intGenerateLoadId
		,Load.intUserSecurityId
		,Load.intTransportLoadId
		,Load.intDriverEntityId
		,Load.intDispatcherId
        ,Load.strExternalLoadNumber
        ,strType = CASE WHEN Load.intPurchaseSale = 1 THEN 'Inbound' ELSE 'Outbound' END
        ,ysnDirectShip = CASE WHEN GLoad.intType = 3 THEN CAST(1 AS bit) ELSE CAST(0 AS Bit) END
        ,intGenerateReferenceNumber = GLoad.intReferenceNumber
        ,intGenerateSequence = Load.intGenerateSequence
        ,intNumberOfLoads = GLoad.intNumberOfLoads
        ,strLocationName = CL.strLocationName
        ,stCommodityCode = CDetail.strCommodityCode
        ,strCustomer = EN.strName
        ,strHauler = Hauler.strName
        ,intContractNumber = CDetail.intContractNumber
        ,intContractSeq = CDetail.intContractSeq
		,dblCashPrice = CDetail.dblCashPrice
		,strItemNo = CDetail.strItemNo
        ,Load.dtmScheduledDate
        ,Load.dblQuantity
        ,Load.ysnInProgress
        ,strScaleTicketNo = CASE WHEN IsNull(Load.intTicketId, 0) <> 0 
								 THEN 
									CAST(ST.intTicketNumber AS VARCHAR(100))
								 ELSE 
									CASE WHEN IsNull(Load.intTransportLoadId, 0) <> 0 
										THEN 
											TL.strTransaction
										ELSE 
											NULL 
										END 
								 END
        ,Load.dblDeliveredQuantity
        ,Load.dtmDeliveredDate
        ,strEquipmentType = EQ.strEquipmentType
        ,Load.strCustomerReference
        ,strShipFromTo = EL.strAddress
		,strShipFromToName = EL.strLocationName
        ,strDriver = Driver.strName
        ,Load.strTruckNo
        ,Load.strTrailerNo1
        ,Load.strTrailerNo2
        ,Load.strTrailerNo3
        ,Load.strComments
		,Load.ysnDispatched
		,Load.dtmDispatchedDate
		,strDispatcher = US.strUserName 
        ,strCounterPartyName = (SELECT Entity1.strName From tblLGLoad L LEFT JOIN tblEntity Entity1 ON Entity1.intEntityId = L.intEntityId WHERE L.intLoadNumber = Load.intLoadNumber AND L.intPurchaseSale <> Load.intPurchaseSale)
        ,strCounterPartyAddress = (SELECT EL1.strAddress From tblLGLoad L LEFT JOIN tblEntityLocation EL1 ON EL1.intEntityLocationId = L.intEntityLocationId WHERE L.intLoadNumber = Load.intLoadNumber AND L.intPurchaseSale <> Load.intPurchaseSale)
        ,dtmCounterPartyScheduleDate = (SELECT L.dtmScheduledDate FROM tblLGLoad L WHERE L.intLoadNumber = Load.intLoadNumber and L.intPurchaseSale <> Load.intPurchaseSale)
        ,strCounterPartyContractSeq = (SELECT CAST (CT.intContractNumber AS VARCHAR(100)) + '/' + CAST (CT.intContractSeq AS VARCHAR(100)) FROM tblLGLoad L LEFT JOIN vyuCTContractDetailView CT ON CT.intContractDetailId = L.intContractDetailId WHERE L.intLoadNumber = Load.intLoadNumber AND L.intPurchaseSale <> Load.intPurchaseSale)
        ,strCounterPartyExternalLoadNumber = (SELECT L.strExternalLoadNumber FROM tblLGLoad L WHERE L.intLoadNumber = Load.intLoadNumber and L.intPurchaseSale <> Load.intPurchaseSale)
		,intCounterPartyEntityId = (SELECT Entity1.intEntityId From tblLGLoad L LEFT JOIN tblEntity Entity1 ON Entity1.intEntityId = L.intEntityId WHERE L.intLoadNumber = Load.intLoadNumber AND L.intPurchaseSale <> Load.intPurchaseSale)
		,intCounterPartyEntityLocationId = (SELECT EL.intEntityLocationId From tblLGLoad L LEFT JOIN tblEntityLocation EL ON EL.intEntityLocationId = L.intEntityLocationId WHERE L.intLoadNumber = Load.intLoadNumber AND L.intPurchaseSale <> Load.intPurchaseSale)
		,strCounterPartyLocationName = (SELECT EL.strLocationName From tblLGLoad L LEFT JOIN tblEntityLocation EL ON EL.intEntityLocationId = L.intEntityLocationId WHERE L.intLoadNumber = Load.intLoadNumber AND L.intPurchaseSale <> Load.intPurchaseSale)
		,intCounterPartyContractDetailId = (SELECT CT.intContractDetailId From tblLGLoad L LEFT JOIN vyuCTContractDetailView CT ON CT.intContractDetailId = L.intContractDetailId WHERE L.intLoadNumber = Load.intLoadNumber AND L.intPurchaseSale <> Load.intPurchaseSale)
		,intCounterPartyContractNumber = (SELECT CT.intContractNumber From tblLGLoad L LEFT JOIN vyuCTContractDetailView CT ON CT.intContractDetailId = L.intContractDetailId WHERE L.intLoadNumber = Load.intLoadNumber AND L.intPurchaseSale <> Load.intPurchaseSale)
		,intCounterPartyContractSeq = (SELECT CT.intContractSeq From tblLGLoad L LEFT JOIN vyuCTContractDetailView CT ON CT.intContractDetailId = L.intContractDetailId WHERE L.intLoadNumber = Load.intLoadNumber AND L.intPurchaseSale <> Load.intPurchaseSale)
		,dblCounterPartyCashPrice = (SELECT CT.dblCashPrice From tblLGLoad L LEFT JOIN vyuCTContractDetailView CT ON CT.intContractDetailId = L.intContractDetailId WHERE L.intLoadNumber = Load.intLoadNumber AND L.intPurchaseSale <> Load.intPurchaseSale)
		,intCounterPartyItemId = (SELECT L.intItemId FROM tblLGLoad L WHERE L.intLoadNumber = Load.intLoadNumber and L.intPurchaseSale <> Load.intPurchaseSale)
		,intCounterPartyLoadId = (SELECT L.intLoadId FROM tblLGLoad L WHERE L.intLoadNumber = Load.intLoadNumber and L.intPurchaseSale <> Load.intPurchaseSale)
		,intCounterPartyCompanyLocationId = (SELECT L.intCompanyLocationId FROM tblLGLoad L WHERE L.intLoadNumber = Load.intLoadNumber and L.intPurchaseSale <> Load.intPurchaseSale)
FROM tblLGLoad Load
LEFT JOIN tblLGGenerateLoad GLoad ON GLoad.intGenerateLoadId = Load.intGenerateLoadId
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = Load.intCompanyLocationId
LEFT JOIN tblEntity EN ON EN.intEntityId = Load.intEntityId
LEFT JOIN tblEntityLocation EL ON EL.intEntityLocationId = Load.intEntityLocationId
LEFT JOIN tblEntity Hauler ON Hauler.intEntityId = Load.intHaulerEntityId
LEFT JOIN tblEntity Driver ON Driver.intEntityId = Load.intDriverEntityId
LEFT JOIN vyuCTContractDetailView CDetail ON CDetail.intContractDetailId = Load.intContractDetailId
LEFT JOIN tblSCTicket ST ON ST.intTicketId = Load.intTicketId
LEFT JOIN tblTRTransportLoad TL ON TL.intTransportLoadId = Load.intTransportLoadId
LEFT JOIN tblLGEquipmentType EQ ON EQ.intEquipmentTypeId = Load.intEquipmentTypeId
LEFT JOIN tblSMUserSecurity US ON US.intUserSecurityID	= Load.intDispatcherId
