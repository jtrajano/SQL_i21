CREATE VIEW [dbo].[vyuVRRebate]
AS  
	SELECT 
		strVendorNumber = K.strVendorId
		,I.strProgram
		,G.strCustomerNumber
		,L.strVendorCustomer
		,A.strInvoiceNumber
		,A.strBOLNumber
		,A.dtmDate
		,strItemNumber = C.strItemNo
		,strItemDescription = C.strDescription
		,D.strCategoryCode
		,dblQuantity = B.dblQtyShipped
		,F.strUnitMeasure
		,E.dblUnitQty
		,dblCost = B.dblPrice
		,dblRebateRate = O.dblRebateRate
		,dblRebateAmount = O.dblRebateAmount
		,B.intInvoiceDetailId
		,O.intConcurrencyId 
		,O.intRebateId
		,O.ysnSubmitted
		,O.ysnExcluded
		,O.intProgramId
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
	

GO

