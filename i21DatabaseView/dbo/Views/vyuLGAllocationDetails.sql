CREATE VIEW vyuLGAllocationDetails
AS
SELECT AH.intAllocationHeaderId
	,AH.strAllocationNumber
	,AD.intAllocationDetailId
	,PCH.intContractHeaderId AS intPContractHeaderId
	,PCH.strContractNumber AS strPContractNumber
	,PCH.intEntityId AS intPEntityId
	,PE.strName AS strPName
	,PCD.intContractDetailId AS intPContractDetailId
	,PCD.intContractSeq AS intPContractSeq
	,PCD.dtmStartDate AS dtmPStartDate
	,PCD.dtmEndDate AS dtmPEndDate
	,PCD.dblQuantity AS dblPDetailQuantity
	,PEL.intEntityLocationId AS intPEntityLocationId
	,PCD.dblScheduleQty AS dblPScheduleQty
	,PCD.dblBalance AS dblPBalance
	,PCNT.strCountry AS strPOrigin
	,PItem.intItemId AS intPItemId
	,PItem.strItemNo AS strPItemNo
	,PItem.strDescription AS strPItemDescription
	,PCD.intItemUOMId AS intPItemUOMId
	,PCB.strContractBasis AS strPINCOTerm
	,SCH.intContractHeaderId AS intSContractHeaderId
	,SCH.strContractNumber AS strSContractNumber
	,SCH.intEntityId AS intSEntityId
	,SE.strName AS strSName
	,SCD.intContractDetailId AS intSContractDetailId
	,SCD.intContractSeq AS intSContractSeq
	,SCD.dtmStartDate AS dtmSStartDate
	,SCD.dtmEndDate AS dtmSEndDate
	,SCD.dblQuantity AS dblSDetailQuantity
	,SCD.dblScheduleQty AS dblSScheduleQty
	,SCD.dblBalance AS dblSBalance
	,SEL.intEntityLocationId AS intSEntityLocationId
	,SItem.intItemId AS intSItemId
	,SItem.strItemNo AS strSItemNo
	,SItem.strDescription AS strSItemDescription
	,SCD.intItemUOMId AS intSItemUOMId
	,SCB.strContractBasis AS strSINCOTerm
	,SCNT.strCountry AS strSOrigin
	,AD.intPUnitMeasureId
	,AD.intSUnitMeasureId
	,UMP.strUnitMeasure AS strPUnitMeasure
	,UMS.strUnitMeasure AS strSUnitMeasure
	,AH.intUserSecurityId
	,SEC.strUserName AS strAllocatedBy
FROM tblLGAllocationHeader AH
JOIN tblLGAllocationDetail AD ON AH.intAllocationHeaderId = AD.intAllocationHeaderId
JOIN tblCTContractDetail PCD ON PCD.intContractDetailId = AD.intPContractDetailId
JOIN tblCTContractHeader PCH ON PCH.intContractHeaderId = PCD.intContractHeaderId
JOIN tblEMEntity PE ON PE.intEntityId = PCH.intEntityId
JOIN tblEMEntityLocation PEL ON PEL.intEntityId = PE.intEntityId
JOIN tblCTContractDetail SCD ON SCD.intContractDetailId = AD.intSContractDetailId
JOIN tblCTContractHeader SCH ON SCH.intContractHeaderId = SCD.intContractHeaderId
JOIN tblICItem PItem ON PItem.intItemId = PCD.intItemId
JOIN tblICItem SItem ON SItem.intItemId = SCD.intItemId
JOIN tblEMEntity SE ON SE.intEntityId = SCH.intEntityId
JOIN tblEMEntityLocation SEL ON SEL.intEntityId = SE.intEntityId
LEFT JOIN tblICUnitMeasure UMP ON UMP.intUnitMeasureId = AD.intPUnitMeasureId
LEFT JOIN tblICUnitMeasure UMS ON UMS.intUnitMeasureId = AD.intSUnitMeasureId
LEFT JOIN tblCTContractBasis PCB ON PCB.intContractBasisId = PCH.intContractBasisId
LEFT JOIN tblCTContractBasis SCB ON SCB.intContractBasisId = SCH.intContractBasisId
LEFT JOIN tblICCommodityAttribute PCA ON PCA.intCommodityAttributeId = PItem.intOriginId
LEFT JOIN tblSMCountry PCNT ON PCNT.intCountryID = PCA.intCountryID
LEFT JOIN tblICCommodityAttribute SCA ON SCA.intCommodityAttributeId = SItem.intOriginId
LEFT JOIN tblSMCountry SCNT ON SCNT.intCountryID = SCA.intCountryID
LEFT JOIN tblSMUserSecurity SEC ON SEC.intEntityId = AH.intUserSecurityId