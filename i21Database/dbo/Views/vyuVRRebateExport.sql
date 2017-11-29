CREATE VIEW [dbo].[vyuVRRebateExport]
AS  
	SELECT 
		A.strInvoiceNumber
		,O.intRebateId
		,J.strCompany1Id
		,J.strCompany2Id
		,A.dtmShipDate
		,A.strBOLNumber
		,P.strVendorProduct
		,O.dblQuantity
		,B.dblPrice
		,B.intItemUOMId
		,D.strCategoryCode
		,strVendorCategory = Q.strVendorDepartment
		,C.strItemNo
		,strVendorItemNo = P.strVendorProduct
		,strVendorUOM = R.strVendorUOM
		,B.intProgramId
		,J.intVendorSetupId
		,A.intInvoiceId
		,F.strUnitMeasure
		,I.strProgramDescription
		,L.strVendorCustomer
		,O.intConcurrencyId
	FROM tblARInvoiceDetail B
	INNER JOIN tblARInvoice A
		ON A.intInvoiceId = B.intInvoiceId
	INNER JOIN tblICItem C
		ON B.intItemId = C.intItemId
	INNER JOIN tblICCategory D
		ON C.intCategoryId = D.intCategoryId
	INNER JOIN tblICItemUOM E
		ON B.intItemUOMId = E.intItemUOMId
	INNER JOIN tblICUnitMeasure F
		ON E.intUnitMeasureId = F.intUnitMeasureId
	INNER JOIN tblARCustomer G
		ON A.intEntityCustomerId = G.intEntityId
	INNER JOIN tblEMEntity H
		ON G.intEntityId = H.intEntityId
	INNER JOIN tblVRProgram I
		ON B.intProgramId = I.intProgramId
	INNER JOIN tblVRVendorSetup J
		ON I.intVendorSetupId = J.intVendorSetupId
	INNER JOIN tblAPVendor K 
		ON J.intEntityId = K.intEntityId
	INNER JOIN tblVRCustomerXref L
		ON J.intVendorSetupId = L.intVendorSetupId
			AND A.intEntityCustomerId = L.intEntityId
	LEFT JOIN tblVRProgramItem M
		ON B.intItemId = M.intItemId
		AND B.intProgramId = M.intProgramId
	LEFT JOIN tblVRProgramItem N
		ON D.intCategoryId = N.intCategoryId
		AND B.intProgramId = N.intProgramId
	INNER JOIN tblVRRebate O
		ON B.intInvoiceDetailId = O.intInvoiceDetailId
	LEFT JOIN tblICItemVendorXref P
		ON B.intItemId = P.intItemId
	LEFT JOIN tblICCategoryVendor Q
		ON C.intCategoryId = Q.intCategoryId
	LEFT JOIN tblVRUOMXref R
		ON F.intUnitMeasureId = R.intUnitMeasureId
	

GO

