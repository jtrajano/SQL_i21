CREATE VIEW dbo.vyuIPGetInvoiceDetail
AS
SELECT I.strItemNo
	,IVD.intContractHeaderId
	,IVD.intContractDetailId
	,IVD.dblQtyOrdered
	,OUM.strUnitMeasure AS strOrderUnitMeasure
	,IVD.dblQtyShipped
	,UM.strUnitMeasure
	,IVD.dblUnitPrice AS dblPrice
	,IVD.dblTotal
	,IVD.dblShipmentNetWt
	,IVD.dblItemWeight
	,WUM.strUnitMeasure AS strWeightUnitMeasure
	,IV.intInvoiceId
	,IsNULL(LD.intLoadId, (
			SELECT WC.intLoadId
			FROM tblLGWeightClaim WC
			JOIN tblLGWeightClaimDetail WCD ON WCD.intWeightClaimId = WC.intWeightClaimId
				AND WCD.intInvoiceId = IV.intInvoiceId
			)) AS intLoadId
	,LD.intLoadDetailId
FROM dbo.tblARInvoice IV
JOIN dbo.tblARInvoiceDetail IVD ON IV.intInvoiceId = IVD.intInvoiceId
LEFT JOIN dbo.tblICItemUOM OIU ON OIU.intItemUOMId = IVD.intOrderUOMId
LEFT JOIN dbo.tblICUnitMeasure OUM ON OUM.intUnitMeasureId = OIU.intUnitMeasureId
JOIN dbo.tblCTBook B ON B.intBookId = IV.intBookId
LEFT JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = IVD.intLoadDetailId
LEFT JOIN dbo.tblCTSubBook SB ON SB.intSubBookId = IV.intSubBookId
JOIN dbo.tblICItem I ON I.intItemId = IVD.intItemId
JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = IVD.intItemUOMId
JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN dbo.tblICItemUOM WIU ON WIU.intItemUOMId = IVD.intItemWeightUOMId
LEFT JOIN dbo.tblICUnitMeasure WUM ON WUM.intUnitMeasureId = WIU.intUnitMeasureId
