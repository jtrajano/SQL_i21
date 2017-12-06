﻿CREATE VIEW [dbo].[vyuVROpenRebate]
AS  
	SELECT 
		intRowId = CAST(ROW_NUMBER() OVER(ORDER BY A.intInvoiceId) AS INT)
		,strVendorNumber = K.strVendorId
		,I.strProgram
		,G.strCustomerNumber
		,L.strVendorCustomer
		,A.strInvoiceNumber
		,A.strBOLNumber
		,A.dtmDate
		,strItemNumber = C.strItemNo
		,strItemDescription = C.strDescription
		,D.strCategoryCode
		,B.dblQtyShipped
		,F.strUnitMeasure
		,E.dblUnitQty
		,dblCost = B.dblPrice
		,dblRebateRate = ISNULL(M.dblRebateRate,ISNULL(N.dblRebateRate,0.0))
		,dblRebateAmount = CASE WHEN ISNULL(M.strRebateBy,N.strRebateBy) = 'Percentage' THEN
								 CAST((B.dblQtyShipped * dblPrice * ISNULL(M.dblRebateRate,ISNULL(N.dblRebateRate,0.0)) / 100) AS NUMERIC(18,6))
							WHEN ISNULL(M.strRebateBy,N.strRebateBy) = 'Unit' THEN
								CAST((B.dblQtyShipped * ISNULL(M.dblRebateRate,ISNULL(N.dblRebateRate,0.0))) AS NUMERIC(18,6))
							ELSE
								ISNULL(M.dblRebateRate,ISNULL(N.dblRebateRate,0.0))
							END
		,B.intInvoiceDetailId
		,B.intConcurrencyId 
		,I.intProgramId
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
	INNER JOIN tblVRCustomerXref L
		ON A.intEntityCustomerId = L.intEntityId
	INNER JOIN tblVRVendorSetup J
		ON L.intVendorSetupId = J.intVendorSetupId
	INNER JOIN tblVRProgram I
		ON J.intVendorSetupId = I.intVendorSetupId
	INNER JOIN tblICItemVendorXref O
		ON B.intItemId = O.intItemId
			AND J.intVendorSetupId = O.intVendorSetupId
	LEFT JOIN tblVRProgramItem M
		ON I.intProgramId = M.intProgramId
			AND B.intItemId = M.intItemId
			AND A.dtmDate >= M.dtmBeginDate
			AND A.dtmDate <= ISNULL(M.dtmEndDate,'12/31/9999')
	LEFT JOIN tblVRProgramItem N
		ON I.intProgramId = N.intProgramId
			AND D.intCategoryId = N.intCategoryId
			AND A.dtmDate >= M.dtmBeginDate
			AND A.dtmDate <= ISNULL(M.dtmEndDate,'12/31/9999')
	INNER JOIN tblAPVendor K 
		ON J.intEntityId = K.intEntityId
	WHERE (N.dblRebateRate IS NOT NULL OR M.dblRebateRate IS NOT NULL)
		AND NOT EXISTS(SELECT TOP 1 1 FROM tblVRRebate WHERE intInvoiceDetailId = B.intInvoiceDetailId)
		AND A.ysnPosted = 1

GO

