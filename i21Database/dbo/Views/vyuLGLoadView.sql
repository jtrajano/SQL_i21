CREATE VIEW vyuLGLoadView
AS
SELECT Load.intLoadId
		,Load.intLoadNumber
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
        ,Load.dtmScheduledDate
        ,Load.dblQuantity
        ,Load.ysnInProgress
        ,strScaleTicketNo = ST.intTicketNumber
        ,Load.dblDeliveredQuantity
        ,Load.dtmDeliveredDate
        ,strEquipmentType = EQ.strEquipmentType
        ,Load.strCustomerReference
        ,strShipFromTo = EL.strAddress
        ,Load.strDriver
        ,Load.strTruckNo
        ,Load.strTrailerNo1
        ,Load.strTrailerNo2
        ,Load.strTrailerNo3
        ,strCounterPartyName = (SELECT Entity1.strName From tblLGLoad L LEFT JOIN tblEntity Entity1 ON Entity1.intEntityId = L.intEntityId WHERE L.intLoadNumber = Load.intLoadNumber AND L.intPurchaseSale <> Load.intPurchaseSale)
        ,strCounterPartyAddress = (SELECT EL1.strAddress From tblLGLoad L LEFT JOIN tblEntityLocation EL1 ON EL1.intEntityLocationId = L.intEntityLocationId WHERE L.intLoadNumber = Load.intLoadNumber AND L.intPurchaseSale <> Load.intPurchaseSale)
        ,dtmCounterPartyScheduleDate = (SELECT L.dtmScheduledDate FROM tblLGLoad L WHERE L.intLoadNumber = Load.intLoadNumber and L.intPurchaseSale <> Load.intPurchaseSale)
        ,strCounterPartyContractSeq = (SELECT CAST (CT.intContractNumber AS VARCHAR(100)) + '/' + CAST (CT.intContractSeq AS VARCHAR(100)) FROM tblLGLoad L LEFT JOIN vyuCTContractDetailView CT ON CT.intContractDetailId = L.intContractDetailId WHERE L.intLoadNumber = Load.intLoadNumber AND L.intPurchaseSale <> Load.intPurchaseSale)
        ,strCounterPartyExternalLoadNumber = (SELECT L.strExternalLoadNumber FROM tblLGLoad L WHERE L.intLoadNumber = Load.intLoadNumber and L.intPurchaseSale <> Load.intPurchaseSale)
        ,Load.strComments
FROM tblLGLoad Load
LEFT JOIN tblLGGenerateLoad GLoad ON GLoad.intGenerateLoadId = Load.intGenerateLoadId
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = Load.intCompanyLocationId
LEFT JOIN tblEntity EN ON EN.intEntityId = Load.intEntityId
LEFT JOIN tblEntityLocation EL ON EL.intEntityLocationId = Load.intEntityLocationId
LEFT JOIN tblEntity Hauler ON Hauler.intEntityId = Load.intHaulerEntityId
LEFT JOIN vyuCTContractDetailView CDetail ON CDetail.intContractDetailId = Load.intContractDetailId
LEFT JOIN tblSCTicket ST ON ST.intTicketId = Load.intTicketId
LEFT JOIN tblLGEquipmentType EQ ON EQ.intEquipmentTypeId = Load.intEquipmentTypeId
