CREATE VIEW [dbo].[vyuBBOpenBuyback]
AS  
	SELECT DISTINCT
		strVendorNumber = E.strEntityNo
		,strVendorName = E.strName
		,strCustomerLocation = F.strLocationName
		,strCustomerId = D.strVendorSoldTo
		,A.strInvoiceNumber
		,A.dtmShipDate
		,G.strItemNo
		,strItemDescription = G.strDescription
		,H.strCategoryCode
		,J.strUnitMeasure
		,dblQuantity = B.dblQtyShipped
		,dblStockQuantity = CAST(dbo.fnICConvertUOMtoStockUnit(B.intItemId,B.intItemUOMId,B.dblQtyShipped) AS NUMERIC(18,6))
		,strStockUOM = L.strUnitMeasure
		,B.intConcurrencyId
		,B.intInvoiceDetailId
		,C.intEntityId
	FROM tblARInvoice A
	INNER JOIN tblARInvoiceDetail B
		ON A.intInvoiceId = B.intInvoiceId
	INNER JOIN tblVRVendorSetup C
		ON A.intEntityCustomerId =  C.intEntityId
	INNER JOIN tblBBCustomerLocationXref D
		ON A.intShipToLocationId = D.intEntityLocationId
			AND C.intVendorSetupId = D.intVendorSetupId
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
	LEFT JOIN tblICItemUOM K
		ON B.intItemId = K.intItemId
			AND K.ysnStockUnit = 1
	LEFT JOIN tblICUnitMeasure L
		ON K.intUnitMeasureId = L.intUnitMeasureId
	INNER JOIN tblBBProgram M
		ON C.intVendorSetupId = M.intVendorSetupId
	INNER JOIN tblBBProgramCharge N
		ON M.intProgramId = N.intProgramId
	OUTER APPLY dbo.fnBBGetChargeRates(N.intProgramChargeId,D.intEntityLocationId,B.intItemId,J.intUnitMeasureId,A.dtmDate) P
	WHERE B.dblPrice = 0
		AND NOT EXISTS(SELECT TOP 1 1 FROM tblBBBuybackDetail WHERE intInvoiceDetailId = B.intInvoiceDetailId)
		AND NOT EXISTS(SELECT TOP 1 1 FROM tblBBBuybackExcluded WHERE intInvoiceDetailId = B.intInvoiceDetailId)
		AND ISNULL(P.dblRate,0) <> 0
		AND B.strBuybackSubmitted <> 'E'
		AND A.ysnPosted = 1
		

GO