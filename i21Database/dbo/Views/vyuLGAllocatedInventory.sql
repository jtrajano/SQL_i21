CREATE VIEW vyuLGAllocatedInventory
AS
SELECT SCH.intContractHeaderId
	   ,SCD.intContractDetailId
	   ,SCH.strContractNumber AS strSContractNumber
       ,SCD.intContractSeq AS intSContractSeq
       ,SCD.dtmStartDate AS dtmSStartDate
       ,SCD.dtmEndDate AS dtmSEndDate
       ,CUS.strName AS strCustomer
       ,SOI.strItemNo AS strSItemNo
       ,SOI.strDescription AS strSItemDescription
       ,SCH.strCustomerContract AS strSCustomerContract
       ,SCD.dblQuantity AS dblSQty
       ,ALD.dblSAllocatedQty
       ,PCH.strContractNumber AS strPContractNumber
       ,PCD.intContractSeq AS intPContractSeq
       ,PCD.dtmStartDate AS dtmPStartDate
       ,PCD.dtmEndDate AS dtmPEndDate
       ,VEN.strName AS strVendor
       ,POI.strItemNo AS strPItemNo
       ,POI.strDescription AS strPItemDescription
       ,PCH.strCustomerContract AS strPCustomerContract
       ,PCD.dblQuantity AS dblPQty
       ,ALD.dblPAllocatedQty
       ,PC.strCity AS strDestination
       ,IR.dtmReceiptDate
       ,LC.strContainerNumber
       ,LDCL.dblQuantity AS dblContainerQty
       ,L.dtmETAPOD
       ,strStatus = CASE 
              WHEN ISNULL(IR.ysnPosted, 0) = 1
                     THEN 'Spot'
              ELSE 'In-Transit'
              END COLLATE Latin1_General_CI_AS
       ,S.strSampleStatus
       ,S.dtmSampleReceivedDate
FROM tblLGAllocationDetail ALD 
JOIN tblCTContractDetail PCD ON PCD.intContractDetailId = ALD.intPContractDetailId
JOIN tblCTContractHeader PCH ON PCH.intContractHeaderId = PCD.intContractHeaderId
JOIN tblEMEntity VEN ON VEN.intEntityId = PCH.intEntityId
JOIN tblICItem POI ON POI.intItemId = PCD.intItemId
JOIN tblCTContractDetail SCD ON SCD.intContractDetailId = ALD.intSContractDetailId
JOIN tblCTContractHeader SCH ON SCH.intContractHeaderId = SCD.intContractHeaderId
JOIN tblEMEntity CUS ON CUS.intEntityId = SCH.intEntityId
JOIN tblICItem SOI ON SOI.intItemId = SCD.intItemId
JOIN tblLGLoadDetail LD ON LD.intPContractDetailId = PCD.intContractDetailId
JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId AND L.intPurchaseSale = 1
JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId
JOIN tblICInventoryReceiptItem IRI ON IRI.intContainerId = LC.intLoadContainerId
JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
JOIN tblICInventoryReceiptItemLot IRIL ON IRIL.intInventoryReceiptItemId = IRI.intInventoryReceiptItemId 
LEFT JOIN tblLGPickLotDetail PLD ON IRIL.intLotId = PLD.intLotId
LEFT JOIN tblLGPickLotHeader PLH ON PLD.intPickLotHeaderId = PLH.intPickLotHeaderId
LEFT JOIN tblSMCity PC ON PC.intCityId = CASE 
              WHEN PCD.strDestinationPointType = 'Port'
                     THEN PCD.intDestinationPortId
              ELSE PCD.intDestinationCityId
              END
LEFT JOIN (
       SELECT *
       FROM (
              SELECT ROW_NUMBER() OVER (
                           PARTITION BY S.intContractDetailId ORDER BY S.dtmTestingEndDate DESC, S.intSampleId DESC
                           ) intRowNum
                     ,S.intContractDetailId
                     ,S.strSampleNumber
                     ,S.strContainerNumber
                     ,ST.strSampleTypeName
                     ,SS.strStatus AS strSampleStatus
                     ,S.dtmTestingStartDate
                     ,S.dtmTestingEndDate
                     ,S.intCompanyLocationSubLocationId
                     ,CLSL.strSubLocationName
                     ,S.dblRepresentingQty
                     ,S.dtmSampleReceivedDate
              FROM tblQMSample S
              JOIN tblQMSampleType AS ST ON ST.intSampleTypeId = S.intSampleTypeId
              JOIN tblQMSampleStatus AS SS ON SS.intSampleStatusId = S.intSampleStatusId
              LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = S.intCompanyLocationSubLocationId
              WHERE S.intContractDetailId IS NOT NULL
              ) t
       WHERE intRowNum = 1
       ) S ON S.intContractDetailId = LD.intPContractDetailId
LEFT JOIN tblLGLoadDetail DOD ON DOD.intPickLotDetailId = PLD.intPickLotDetailId
LEFT JOIN tblLGLoad DO ON DO.intLoadId = DOD.intLoadId 
WHERE ISNULL(DO.intShipmentStatus,0) NOT IN (6, 11) AND L.intShipmentStatus <> 3 

UNION ALL

SELECT
       SCH.intContractHeaderId
	   ,SCD.intContractDetailId
	   ,SCH.strContractNumber AS strSContractNumber
       ,SCD.intContractSeq AS intSContractSeq
       ,SCD.dtmStartDate AS dtmSStartDate
       ,SCD.dtmEndDate AS dtmSEndDate
       ,CUS.strName AS strCustomer
       ,SOI.strItemNo AS strSItemNo
       ,SOI.strDescription AS strSItemDescription
       ,SCH.strCustomerContract AS strSCustomerContract
       ,SCD.dblQuantity AS dblSQty
       ,ALD.dblSAllocatedQty
       ,PCH.strContractNumber AS strPContractNumber
       ,PCD.intContractSeq AS intPContractSeq
       ,PCD.dtmStartDate AS dtmPStartDate
       ,PCD.dtmEndDate AS dtmPEndDate
       ,VEN.strName AS strVendor
       ,POI.strItemNo AS strPItemNo
       ,POI.strDescription AS strPItemDescription
       ,PCH.strCustomerContract AS strPCustomerContract
       ,PCD.dblQuantity AS dblPQty
       ,ALD.dblPAllocatedQty
       ,PC.strCity AS strDestination
       ,L.dtmBLDate
       ,'' strContainerNumber
       ,0.0 dblContainerQty
       ,L.dtmETAPOD
       ,strStatus = 'In-Transit' COLLATE Latin1_General_CI_AS
       ,S.strSampleStatus
       ,S.dtmSampleReceivedDate
FROM tblLGAllocationDetail ALD 
JOIN tblCTContractDetail PCD ON PCD.intContractDetailId = ALD.intPContractDetailId
JOIN tblCTContractHeader PCH ON PCH.intContractHeaderId = PCD.intContractHeaderId
JOIN tblLGLoadDetail LD ON LD.intPContractDetailId = PCD.intContractDetailId
JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId AND L.intPurchaseSale = 1 
JOIN tblEMEntity VEN ON VEN.intEntityId = PCH.intEntityId
JOIN tblICItem POI ON POI.intItemId = PCD.intItemId
JOIN tblCTContractDetail SCD ON SCD.intContractDetailId = ALD.intSContractDetailId
JOIN tblCTContractHeader SCH ON SCH.intContractHeaderId = SCD.intContractHeaderId
JOIN tblEMEntity CUS ON CUS.intEntityId = SCH.intEntityId
JOIN tblICItem SOI ON SOI.intItemId = SCD.intItemId
LEFT JOIN tblSMCity PC ON PC.intCityId = CASE 
              WHEN PCD.strDestinationPointType = 'Port'
                     THEN PCD.intDestinationPortId
              ELSE PCD.intDestinationCityId
              END
LEFT JOIN (
       SELECT *
       FROM (
              SELECT ROW_NUMBER() OVER (
                           PARTITION BY S.intContractDetailId ORDER BY S.dtmTestingEndDate DESC, S.intSampleId DESC
                           ) intRowNum
                     ,S.intContractDetailId
                     ,S.strSampleNumber
                     ,S.strContainerNumber
                     ,ST.strSampleTypeName
                     ,SS.strStatus AS strSampleStatus
                     ,S.dtmTestingStartDate
                     ,S.dtmTestingEndDate
                     ,S.intCompanyLocationSubLocationId
                     ,CLSL.strSubLocationName
                     ,S.dblRepresentingQty
                     ,S.dtmSampleReceivedDate
              FROM tblQMSample S
              JOIN tblQMSampleType AS ST ON ST.intSampleTypeId = S.intSampleTypeId
              JOIN tblQMSampleStatus AS SS ON SS.intSampleStatusId = S.intSampleStatusId
              LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = S.intCompanyLocationSubLocationId
              WHERE S.intContractDetailId IS NOT NULL
              ) t
       WHERE intRowNum = 1
       ) S ON S.intContractDetailId = LD.intPContractDetailId
WHERE L.intShipmentStatus = 3 

UNION ALL 

SELECT SCH.intContractHeaderId
	   ,SCD.intContractDetailId
	   ,SCH.strContractNumber AS strSContractNumber
       ,SCD.intContractSeq AS intSContractSeq
       ,SCD.dtmStartDate AS dtmSStartDate
       ,SCD.dtmEndDate AS dtmSEndDate
       ,CUS.strName AS strCustomer
       ,SOI.strItemNo AS strSItemNo
       ,SOI.strDescription AS strSItemDescription
       ,SCH.strCustomerContract AS strSCustomerContract
       ,SCD.dblQuantity AS dblSQty
       ,ALD.dblSAllocatedQty
       ,PCH.strContractNumber AS strPContractNumber
       ,PCD.intContractSeq AS intPContractSeq
       ,PCD.dtmStartDate AS dtmPStartDate
       ,PCD.dtmEndDate AS dtmPEndDate
       ,VEN.strName AS strVendor
       ,POI.strItemNo AS strPItemNo
       ,POI.strDescription AS strPItemDescription
       ,PCH.strCustomerContract AS strPCustomerContract
       ,PCD.dblQuantity AS dblPQty
       ,ALD.dblPAllocatedQty
       ,PC.strCity AS strDestination
       ,L.dtmBLDate
       ,LC.strContainerNumber
       ,LDCL.dblQuantity AS dblContainerQty
       ,L.dtmETAPOD
       ,'In-Transit' strStatus
       ,S.strSampleStatus
       ,S.dtmSampleReceivedDate
FROM tblLGAllocationDetail ALD 
JOIN tblLGLoadDetail LD ON LD.intAllocationDetailId = ALD.intAllocationDetailId
JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId AND L.intPurchaseSale = 3
JOIN tblCTContractDetail PCD ON PCD.intContractDetailId = LD.intPContractDetailId
JOIN tblCTContractHeader PCH ON PCH.intContractHeaderId = PCD.intContractHeaderId
JOIN tblEMEntity VEN ON VEN.intEntityId = PCH.intEntityId
JOIN tblICItem POI ON POI.intItemId = PCD.intItemId
JOIN tblCTContractDetail SCD ON SCD.intContractDetailId = ALD.intSContractDetailId
JOIN tblCTContractHeader SCH ON SCH.intContractHeaderId = SCD.intContractHeaderId
JOIN tblEMEntity CUS ON CUS.intEntityId = SCH.intEntityId
JOIN tblICItem SOI ON SOI.intItemId = SCD.intItemId
JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId
LEFT JOIN tblSMCity PC ON PC.intCityId = CASE 
              WHEN PCD.strDestinationPointType = 'Port'
                     THEN PCD.intDestinationPortId
              ELSE PCD.intDestinationCityId
              END
LEFT JOIN (
       SELECT *
       FROM (
              SELECT ROW_NUMBER() OVER (
                           PARTITION BY S.intContractDetailId ORDER BY S.dtmTestingEndDate DESC, S.intSampleId DESC
                           ) intRowNum
                     ,S.intContractDetailId
                     ,S.strSampleNumber
                     ,S.strContainerNumber
                     ,ST.strSampleTypeName
                     ,SS.strStatus AS strSampleStatus
                     ,S.dtmTestingStartDate
                     ,S.dtmTestingEndDate
                     ,S.intCompanyLocationSubLocationId
                     ,CLSL.strSubLocationName
                     ,S.dblRepresentingQty
                     ,S.dtmSampleReceivedDate
              FROM tblQMSample S
              JOIN tblQMSampleType AS ST ON ST.intSampleTypeId = S.intSampleTypeId
              JOIN tblQMSampleStatus AS SS ON SS.intSampleStatusId = S.intSampleStatusId
              LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = S.intCompanyLocationSubLocationId
              WHERE S.intContractDetailId IS NOT NULL
              ) t
       WHERE intRowNum = 1
       ) S ON S.intContractDetailId = LD.intPContractDetailId
WHERE L.intShipmentStatus <> 11