﻿	CREATE VIEW [dbo].[vyuVRRebate]
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
			,O.strSubmitted
			,O.intProgramId
			,O.ysnExported
			,M.strLocationName
		FROM tblVRRebate O
		INNER JOIN tblARInvoiceDetail B
			ON B.intInvoiceDetailId = O.intInvoiceDetailId
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
			ON O.intProgramId = I.intProgramId
		INNER JOIN tblVRVendorSetup J
			ON I.intVendorSetupId = J.intVendorSetupId
		INNER JOIN tblAPVendor K 
			ON J.intEntityId = K.intEntityId
		INNER JOIN tblVRCustomerXref L
			ON J.intVendorSetupId = L.intVendorSetupId
				AND A.intEntityCustomerId = L.intEntityId
		INNER JOIN tblSMCompanyLocation M
			ON A.intCompanyLocationId = M.intCompanyLocationId
	GO

