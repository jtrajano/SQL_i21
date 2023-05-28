CREATE PROCEDURE [dbo].[uspLGGetInboundShipmentContainerSalesReport]
	@xmlParam INT = NULL
AS
BEGIN
	SELECT DISTINCT 
		strCustomer = CASE WHEN ISNULL(SHeader.strContractNumber, '0') = '0' THEN 'Unsold' ELSE EM.strName END
		,SHeader.strContractNumber AS strSContractNumber
		,dblQuantity = CASE WHEN ISNULL(SHeader.strContractNumber, '0') = '0' THEN NULL ELSE LDCL.dblQuantity END
		,strUnitMeasure = CASE WHEN ISNULL(SHeader.strContractNumber, '0') = '0' THEN NULL ELSE UOM.strUnitMeasure END
		,strFreightTerm = FT.strFreightTerm
		,dtmLastFreeDate = CASE WHEN ISNULL(SHeader.strContractNumber, '0') = '0' THEN 'N/A' ELSE LW.dtmLastFreeDate END
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
	JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
	JOIN tblLGLoadContainer LC ON LDCL.intLoadContainerId = LC.intLoadContainerId
	LEFT JOIN tblICUnitMeasure LCWU ON LCWU.intUnitMeasureId = LC.intWeightUnitMeasureId
	LEFT JOIN tblICUnitMeasure LCIU ON LCIU.intUnitMeasureId = LC.intUnitMeasureId
	LEFT JOIN tblICItem Item ON Item.intItemId = LD.intItemId
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LD.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT JOIN tblCTContractDetail PDetail ON PDetail.intContractDetailId = LD.intPContractDetailId
	LEFT JOIN tblCTContractHeader PHeader ON PHeader.intContractHeaderId = PDetail.intContractHeaderId
	LEFT JOIN tblCTContractDetail SDetail ON SDetail.intContractDetailId = LD.intSContractDetailId
	LEFT JOIN tblCTContractHeader SHeader ON SHeader.intContractHeaderId = SDetail.intContractHeaderId
	LEFT JOIN tblCTPricingType PTP ON PTP.intPricingTypeId = PDetail.intPricingTypeId
	LEFT JOIN tblCTPricingType PTS ON PTS.intPricingTypeId = SDetail.intPricingTypeId
	LEFT JOIN tblEMEntity EM ON EM.intEntityId = SHeader.intEntityId
	LEFT JOIN tblSMFreightTerms FT ON FT.intFreightTermId = SHeader.intFreightTermId
	LEFT JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = LC.intLoadContainerId
	LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId
	WHERE LC.intLoadContainerId = @xmlParam
END