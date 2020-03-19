CREATE VIEW dbo.vyuIPGetInvoiceDetail
AS
SELECT I.strItemNo
	,IVD.intContractHeaderId
	,IVD.intContractDetailId
	,IVD.dblQtyOrdered
	,IVD.dblQtyShipped
	,UM.strUnitMeasure
	,IVD.dblPrice
	,IVD.dblTotal
	,IVD.dblShipmentNetWt
	,IVD.dblItemWeight
	,WUM.strUnitMeasure AS strWeightUnitMeasure
	,IV.intInvoiceId
FROM dbo.tblARInvoice IV
JOIN dbo.tblARInvoiceDetail IVD ON IV.intInvoiceId = IVD.intInvoiceId
JOIN dbo.tblCTBook B ON B.intBookId = IV.intBookId
LEFT JOIN dbo.tblCTSubBook SB ON SB.intSubBookId = IV.intSubBookId
JOIN dbo.tblICItem I ON I.intItemId = IVD.intItemId
JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = IVD.intItemUOMId
JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
Left JOIN dbo.tblICItemUOM WIU ON WIU.intItemUOMId = IVD.intItemWeightUOMId
Left JOIN dbo.tblICUnitMeasure WUM ON WUM.intUnitMeasureId = WIU.intUnitMeasureId
