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
		,intProgramId = I.intProgramId
		,J.intVendorSetupId
		,A.intInvoiceId
		,F.strUnitMeasure
		,I.strProgramDescription
		,L.strVendorCustomer
		,O.intConcurrencyId
		,B.intInvoiceDetailId
		,strVendorName = S.strName
	FROM tblARInvoiceDetail B
	INNER JOIN tblARInvoice A
		ON A.intInvoiceId = B.intInvoiceId
	INNER JOIN tblVRRebate O
		ON B.intInvoiceDetailId = O.intInvoiceDetailId
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
		ON O.intProgramId = I.intProgramId
	INNER JOIN tblVRVendorSetup J
		ON I.intVendorSetupId = J.intVendorSetupId
	INNER JOIN tblAPVendor K 
		ON J.intEntityId = K.intEntityId
	INNER JOIN tblEMEntity S
		ON K.intEntityId = S.intEntityId
	INNER JOIN tblVRCustomerXref L
		ON J.intVendorSetupId = L.intVendorSetupId
			AND A.intEntityCustomerId = L.intEntityId
	LEFT JOIN tblICItemVendorXref P
		ON B.intItemId = P.intItemId
			AND J.intVendorSetupId = P.intVendorSetupId
	LEFT JOIN tblICCategoryVendor Q
		ON C.intCategoryId = Q.intCategoryId
			AND J.intVendorSetupId = Q.intVendorSetupId
	LEFT JOIN tblVRUOMXref R
		ON F.intUnitMeasureId = R.intUnitMeasureId
			AND J.intVendorSetupId = R.intVendorSetupId
	

GO

