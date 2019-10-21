CREATE VIEW [dbo].[vyuBBExcludedBuyback]
AS  
	SELECT 
		M.dtmExcludedDate
		,strVendorName = E.strName
		,strVendorNumber = E.strEntityNo
		,strCustomerLocation = F.strLocationName
		,strCustomerId = D.strVendorSoldTo
		,A.strInvoiceNumber
		,A.dtmShipDate
		,G.strItemNo
		,strItemDescription = G.strDescription
		,H.strCategoryCode
		,J.strUnitMeasure
		,dblQuantity = B.dblQtyShipped
		,B.intConcurrencyId
		,B.intInvoiceDetailId
		,M.intBuybackExcludedId
	FROM tblARInvoice A
	INNER JOIN tblARInvoiceDetail B
		ON A.intInvoiceId = B.intInvoiceId
	INNER JOIN tblVRVendorSetup C
		ON A.intEntityCustomerId =  C.intEntityId
	INNER JOIN tblBBCustomerLocationXref D
		ON A.intShipToLocationId = D.intEntityLocationId
	INNER JOIN tblEMEntity E
		ON C.intEntityId = E.intEntityId
	INNER JOIN tblEMEntityLocation F
		ON D.intEntityLocationId = F.intEntityLocationId
	INNER JOIN tblICItem G
		ON  B.intItemId = G.intItemId
	INNER JOIN tblICCategory H
		ON G.intCategoryId = H.intCategoryId
	INNER JOIN tblICItemUOM I
		ON B.intItemUOMId = I.intItemUOMId
	INNER JOIN tblICUnitMeasure J
		ON I.intUnitMeasureId = J.intUnitMeasureId
	INNER JOIN tblBBBuybackExcluded M 
		ON B.intInvoiceDetailId = M.intInvoiceDetailId

GO

