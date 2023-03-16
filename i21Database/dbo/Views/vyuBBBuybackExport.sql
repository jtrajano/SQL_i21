﻿CREATE VIEW [dbo].[vyuBBBuybackExport]
AS  
	SELECT DISTINCT
		A.strInvoiceNumber
		,E.strVendorSoldTo
		,E.strVendorShipTo
		,A.dtmDate
		,A.dtmShipDate
		,A.strBOLNumber
		,G.strItemNo strActualItemNo
		,strItemNumber = ISNULL(H.strVendorProduct,G.strItemNo)
		,strUnitMeasure = COALESCE(NULLIF(H.strVendorProductUOM, ''), CASE WHEN M.strDataFileTemplate = 'Chevron' THEN RIGHT(G.strItemNo, 3) ELSE K.strVendorUOM END, J.strUnitMeasure) COLLATE Latin1_General_CI_AS 
		,A.intInvoiceId
		,B.dblQtyOrdered
		,B.dblQtyShipped
		,D.intBuybackId
		, CAST(ROW_NUMBER() OVER(ORDER BY D.intBuybackId ASC) AS INT) AS intRowNumber
		,L.strCategoryCode
		,B.intInvoiceDetailId
		,B.intConcurrencyId
		,P.strProgramDescription
		,P.strVendorProgramId
		,E.strVendorCustomerLocation
		,M.intVendorSetupId
		,M.strCompany1Id
		,SO.dtmDate dtmSalesOrderDate
		,SO.strBOLNumber strSalesOrderBOLNumber
		,COALESCE(NULLIF(M.strMarketerAccountNo, ''), M.strCompany2Id) strMarketerAccountNo
		,M.strMarketerEmail
		,M.strDataFileTemplate
		,M.strExportFilePath
		,strVendorUOM = vendorUOM.strUnitMeasure
		,strVendorName = vendorEntity.strName
		,strVendorProgram = P.strVendorProgramId
		,intProgramId = P.intProgramId
		,A.strPONumber
		,CAST(B.dblQtyOrdered AS INT) intQtyOrdered
		,CAST(B.dblQtyShipped AS INT) intQtyShipped
		,CASE WHEN A.ysnReturned = 1 THEN 'Return'
			  WHEN A.intSalesOrderId > 0 THEN 'Sales'
			  ELSE ''
		 END AS strTransactionType
		, D.ysnChevronUploaded
		, D.strReimbursementNo
		, strCharge = CASE WHEN O.strCharge = 'Inventory' THEN NULL ELSE O.strCharge END
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
	INNER JOIN tblEMEntity vendorEntity 
		ON vendorEntity.intEntityId = M.intEntityId
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
	OUTER APPLY (
        SELECT TOP 1 xK.*
        FROM tblVRUOMXref xK
		WHERE J.intUnitMeasureId = xK.intUnitMeasureId
			AND M.intVendorSetupId = xK.intVendorSetupId
    ) K
	LEFT JOIN tblSOSalesOrder SO ON SO.intSalesOrderId = A.intSalesOrderId
	LEFT JOIN tblICItemUOM vendorItemUOM ON vendorItemUOM.intItemUOMId = H.intItemUnitMeasureId
	LEFT JOIN tblICUnitMeasure vendorUOM ON vendorUOM.intUnitMeasureId = vendorItemUOM.intUnitMeasureId
	WHERE D.ysnPosted = 1