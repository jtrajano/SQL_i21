CREATE VIEW [dbo].[vyuBBOpenBuybackWithRate]
AS  
	SELECT 
		strVendorNumber = E.strEntityNo
		,strVendorName = E.strName
		,strCustomerLocation = F.strLocationName
		,strCustomerId = D.strVendorSoldTo
		,A.strInvoiceNumber
		,A.dtmShipDate
		,A.dtmDate
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
		,B.intItemId
		,dblRatePerUnit = CASE WHEN ISNULL(O.dblRatePerUnit,0.0) <> 0 THEN O.dblRatePerUnit
							   WHEN ISNULL(P.dblRatePerUnit,0.0) <> 0 THEN P.dblRatePerUnit
							   WHEN ISNULL(Q.dblRatePerUnit,0.0) <> 0 THEN Q.dblRatePerUnit
							   ELSE 0.0
						  END
		,intChargedItemId = N.intItemId
		,strChargedItem = R.strItemNo
		,strChargedItemDescription = R.strDescription
		,M.intProgramId
		,M.strProgramId
		,dblReimbursementAmount = CAST(((CASE WHEN ISNULL(O.dblRatePerUnit,0.0) <> 0 THEN O.dblRatePerUnit
											   WHEN ISNULL(P.dblRatePerUnit,0.0) <> 0 THEN P.dblRatePerUnit
											   WHEN ISNULL(Q.dblRatePerUnit,0.0) <> 0 THEN Q.dblRatePerUnit
											   ELSE 0.0
										 END)
										* B.dblQtyShipped) AS NUMERIC(18,6))
		,intProgramRateId = CASE WHEN ISNULL(O.intRateId,0) <> 0 THEN O.intRateId
							   WHEN ISNULL(P.intRateId,0) <> 0 THEN P.intRateId
							   WHEN ISNULL(Q.intRateId,0) <> 0 THEN Q.intRateId
							END
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
	LEFT JOIN tblICItemUOM K
		ON B.intItemId = K.intItemId
			AND K.ysnStockUnit = 1
	LEFT JOIN tblICUnitMeasure L
		ON K.intUnitMeasureId = L.intUnitMeasureId
	INNER JOIN tblBBProgram M
		ON C.intVendorSetupId = M.intVendorSetupId
	INNER JOIN tblBBProgramCharge N
		ON M.intProgramId = N.intProgramId
	LEFT JOIN tblICItem R
		ON N.intItemId = R.intItemId
	LEFT JOIN tblBBRate O
		ON N.intProgramChargeId = O.intProgramChargeId
			AND D.intEntityLocationId = O.intCustomerLocationId
			AND B.intItemId = O.intItemId
			AND J.intUnitMeasureId = O.intUnitMeasureId
	LEFT JOIN tblBBRate P
		ON N.intProgramChargeId = P.intProgramChargeId
			AND B.intItemId = P.intItemId
			AND J.intUnitMeasureId = P.intUnitMeasureId
	LEFT JOIN tblBBRate Q
		ON N.intProgramChargeId =Q.intProgramChargeId
			AND J.intUnitMeasureId = Q.intUnitMeasureId
	WHERE B.dblPrice = 0
		AND NOT EXISTS(SELECT TOP 1 1 FROM tblBBBuybackDetail WHERE intInvoiceDetailId = B.intInvoiceDetailId)
		AND NOT EXISTS(SELECT TOP 1 1 FROM tblBBBuybackExcluded WHERE intInvoiceDetailId = B.intInvoiceDetailId)
		AND B.strBuybackSubmitted <> 'E'
		AND A.ysnPosted = 1

GO

