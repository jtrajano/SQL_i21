CREATE VIEW [dbo].[vyuBBOpenBuyback]
AS  
	SELECT 
		strVendorNumber = G.strEntityNo
		,strVendorName = G.strName
		,strCustomerNumber = H.strEntityNo
		,strCustomerName = H.strName
		,strCustomerLocation = O.strLocationName
		,A.strInvoiceNumber
		,A.dtmShipDate
		,I.strItemNo
		,strItemDescription = I.strDescription
		,J.strCategoryCode
		,L.strUnitMeasure
		,dblQuantity = B.dblQtyShipped
		,dblStockQuantity = CAST(dbo.fnICConvertUOMtoStockUnit(K.intItemUOMId,M.intItemUOMId,B.dblQtyShipped) AS NUMERIC(18,6))
		,strStockUOM = N.strUnitMeasure
		,B.intConcurrencyId
		,B.intInvoiceDetailId
	FROM tblARInvoice A
	INNER JOIN tblARInvoiceDetail B
		ON A.intInvoiceId = B.intInvoiceId
	INNER JOIN tblVRCustomerXref C
		ON A.intEntityCustomerId = C.intEntityId
	INNER JOIN tblBBCustomerLocationXref D
		ON A.intBillToLocationId = D.intEntityLocationId
	INNER JOIN tblBBCustomerLocationXref E --Ship To
		ON A.intShipToLocationId = E.intEntityLocationId
	INNER JOIN tblVRVendorSetup F
		ON C.intVendorSetupId = F.intVendorSetupId	
	INNER JOIN tblEMEntity G
		ON F.intEntityId = G.intEntityId
	INNER JOIN tblEMEntity H
		ON A.intEntityCustomerId = H.intEntityId
	INNER JOIN tblICItem I
		ON B.intItemId = I.intItemId
	INNER JOIN tblICCategory J
		ON I.intCategoryId = J.intCategoryId
	INNER JOIN tblICItemUOM K
		ON B.intItemUOMId = K.intItemUOMId
			AND B.intItemId = K.intItemId
	INNER JOIN tblICUnitMeasure L
		ON K.intUnitMeasureId = L.intUnitMeasureId
	LEFT JOIN tblICItemUOM M
		ON B.intItemId = M.intItemId
			AND M.ysnStockUnit = 1
	LEFT JOIN tblICUnitMeasure N
		ON M.intUnitMeasureId = N.intUnitMeasureId
	INNER JOIN tblEMEntityLocation O
		ON E.intEntityLocationId = O.intEntityLocationId
	WHERE B.dblPrice = 0
		AND NOT EXISTS(SELECT TOP 1 1 FROM tblBBBuybackDetail WHERE intInvoiceDetailId = B.intInvoiceDetailId)
		AND B.strBuybackSubmitted <> 'E'
		AND A.ysnPosted = 1

GO

