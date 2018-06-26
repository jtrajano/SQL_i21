CREATE VIEW [dbo].[vyuBBBuybackExport]
AS  
	SELECT DISTINCT
		A.strInvoiceNumber
		,E.strVendorSoldTo
		,E.strVendorShipTo
		,A.dtmDate
		,A.dtmShipDate
		,A.strBOLNumber
		,strItemNumber = ISNULL(H.strVendorProduct,G.strItemNo)
		,strUnitMeasure = ISNULL(K.strVendorUOM,J.strUnitMeasure)
		,A.intInvoiceId
		,B.dblQtyShipped
		,D.intBuybackId
		,L.strCategoryCode
		,B.intInvoiceDetailId
		,B.intConcurrencyId
		,P.strProgramDescription
		,P.strVendorProgramId
		,E.strVendorCustomerLocation
		,ysnPosted = CAST(ISNULL(D.ysnPosted,0) AS BIT)
	FROM tblARInvoice A
	INNER JOIN tblARInvoiceDetail B
		ON A.intInvoiceId = B.intInvoiceId
	INNER JOIN tblBBBuybackDetail C
		ON B.intInvoiceDetailId = C.intInvoiceDetailId
	INNER JOIN tblBBRate N
		ON C.intProgramRateId = N.intRateId
	INNER JOIN tblBBProgramCharge O
		ON N.intProgramChargeId = O.intProgramChargeId
	INNER JOIN tblBBProgram P
		ON O.intProgramId = P.intProgramId
	INNER JOIN tblBBBuyback D
		ON C.intBuybackId = D.intBuybackId 
	INNER JOIN tblVRVendorSetup M
		ON A.intEntityCustomerId = M.intEntityId
	INNER JOIN tblBBCustomerLocationXref E
		ON A.intShipToLocationId = E.intEntityLocationId
			AND M.intVendorSetupId = E.intVendorSetupId
	INNER JOIN tblICItem G
		ON B.intItemId = G.intItemId
	INNER JOIN tblICCategory L
		ON G.intCategoryId = L.intCategoryId
	LEFT JOIN tblICItemVendorXref H
		ON B.intItemId = H.intItemId
			AND M.intVendorSetupId = H.intVendorSetupId
	INNER JOIN tblICItemUOM I
		ON B.intItemUOMId = I.intItemUOMId
	INNER JOIN tblICUnitMeasure J
		ON I.intUnitMeasureId =  J.intUnitMeasureId
	LEFT JOIN tblVRUOMXref K
		ON J.intUnitMeasureId = K.intUnitMeasureId
			AND M.intVendorSetupId = K.intVendorSetupId
GO

