CREATE VIEW [dbo].[vyuBBBuybackExport]
AS  
	SELECT 
		A.strInvoiceNumber
		,E.strVendorSoldTo
		,E.strVendorShipTo
		,A.dtmDate
		,A.dtmShipDate
		,A.strBOLNumber
		,strBuybackInvoiceNumber = F.strInvoiceNumber
		,strItemNumber = ISNULL(H.strVendorProduct,G.strItemNo)
		,strUnitMeasure = ISNULL(K.strVendorUOM,J.strUnitMeasure)
		,A.intInvoiceId
		,B.dblQtyShipped
		,D.intBuybackId
		,L.strCategoryCode
		,B.intInvoiceDetailId
		,B.intConcurrencyId
	FROM tblARInvoice A
	INNER JOIN tblARInvoiceDetail B
		ON A.intInvoiceId = B.intInvoiceId
	INNER JOIN tblBBBuybackDetail C
		ON B.intInvoiceDetailId = C.intInvoiceDetailId
	INNER JOIN tblBBBuyback D
		ON C.intBuybackId = D.intBuybackId 
	INNER JOIN tblBBCustomerLocationXref E
		ON A.intShipToLocationId = E.intEntityLocationId
	INNER JOIN tblARInvoice F
		ON D.intInvoiceId = F.intInvoiceId
	INNER JOIN tblICItem G
		ON B.intItemId = G.intItemId
	INNER JOIN tblICCategory L
		ON G.intCategoryId = L.intCategoryId
	LEFT JOIN tblICItemVendorXref H
		ON B.intItemId = H.intItemId
	INNER JOIN tblICItemUOM I
		ON B.intItemUOMId = I.intItemUOMId
	INNER JOIN tblICUnitMeasure J
		ON I.intUnitMeasureId =  J.intUnitMeasureId
	LEFT JOIN tblVRUOMXref K
		ON J.intUnitMeasureId = K.intUnitMeasureId
GO

