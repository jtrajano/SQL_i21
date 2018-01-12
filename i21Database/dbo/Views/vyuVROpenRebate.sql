CREATE VIEW [dbo].[vyuVROpenRebate]
AS  
	SELECT 
		*
		,dblRebateAmount = CASE WHEN A.strRebateBy = 'Unit' THEN
								CAST((A.dblRebateQuantity * A.dblRebateRate) AS NUMERIC(18,6))
							ELSE
								CAST((A.dblRebateQuantity * A.dblRebateRate * A.dblCost / 100) AS NUMERIC(18,6))
							END
	FROM(
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
		,dblQtyShipped = CASE WHEN A.strTransactionType = 'Credit Memo' THEN (B.dblQtyShipped * -1) ELSE B.dblQtyShipped END
		,F.strUnitMeasure
		,E.dblUnitQty
		,dblCost = B.dblPrice
		,dblRebateRate = ISNULL(M.dblRebateRate,ISNULL(N.dblRebateRate,0.0))
		,dblRebateQuantity =	CASE WHEN A.strTransactionType = 'Credit Memo' THEN 
									CAST((dbo.fnCalculateQtyBetweenUOM(B.intItemUOMId, ISNULL(M.intItemUOMId,ISNULL(N.intItemUOMId,0.0)), B.dblQtyShipped)) AS NUMERIC(18,6)) * -1
								ELSE
									CAST((dbo.fnCalculateQtyBetweenUOM(B.intItemUOMId, ISNULL(M.intItemUOMId,ISNULL(N.intItemUOMId,0.0)), B.dblQtyShipped)) AS NUMERIC(18,6))
								END
		,B.intInvoiceDetailId
		,B.intConcurrencyId 
		,I.intProgramId
		,strRebateBy = ISNULL(M.strRebateBy,N.strRebateBy)
		,P.strLocationName
		,J.intVendorSetupId 
		,A.intInvoiceId
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
			AND A.dtmDate >= N.dtmBeginDate
			AND A.dtmDate <= ISNULL(N.dtmEndDate,'12/31/9999')
	INNER JOIN tblAPVendor K 
		ON J.intEntityId = K.intEntityId
	INNER JOIN tblSMCompanyLocation P
		ON A.intCompanyLocationId = P.intCompanyLocationId
	WHERE (ISNULL(N.dblRebateRate,0) <> 0 OR ISNULL(M.dblRebateRate,0) <>0)
		AND NOT EXISTS(SELECT TOP 1 1 FROM tblVRRebate WHERE intInvoiceDetailId = B.intInvoiceDetailId)
		AND A.ysnPosted = 1
		AND A.strTransactionType IN ('Invoice', 'Credit Memo')) A

GO