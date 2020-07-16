CREATE VIEW [dbo].[vyuLGClearingItemGL]
AS
SELECT
	[strLoadNumber] = L.strLoadNumber
	,[intLoadId] = L.intLoadId
	,[dtmDate] = GLD.dtmDate
	,[intLoadDetailId] = LD.intLoadDetailId
	,[intUnitMeasureId] = ISNULL(L.intWeightUnitMeasureId, LDUM.intUnitMeasureId)
	,[strUnitMeasure] = ISNULL(UM.strUnitMeasure, LDUM.strUnitMeasure)
	,[intItemId] = LD.intItemId
	,[dblQty] = LD.dblQty
	,[dblAmount] = GLD.dblClearingAmount
	,[dblAmountForeign] = GLD.dblClearingAmountForeign
	,[dblTaxForeign] = CONVERT(NUMERIC(18, 6), 0)
	,[intLocationId] = CL.intCompanyLocationId
	,[strLocationName] = CL.strLocationName 
	,[intAccountId] = GLD.intAccountId
	,[strAccountId] = GLA.strAccountId
FROM 
	(SELECT 
		intTransactionId
		,intAccountId
		,dtmDate = dtmTransactionDate
		,dblClearingAmount = dblDebit - dblCredit
		,dblClearingAmountForeign = dblDebitForeign - dblCreditForeign
		,intLineNo = DENSE_RANK() OVER (PARTITION BY intTransactionId, intAccountId ORDER BY intJournalLineNo)
		FROM tblGLDetail
		WHERE strModuleName = 'Logistics'
		 AND intAccountId IN 
			(SELECT intAccountId FROM tblGLAccountSegmentMapping WHERE intAccountSegmentId IN 
				(SELECT intAccountSegmentId FROM tblGLAccountSegment WHERE intAccountCategoryId IN (
					SELECT intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = 'AP Clearing')))
					AND ysnIsUnposted = 0) GLD
	INNER JOIN tblGLAccount GLA ON GLA.intAccountId = GLD.intAccountId
	INNER JOIN tblLGLoad L ON L.intLoadId = GLD.intTransactionId
	OUTER APPLY (SELECT * FROM
					(SELECT 
						intLoadDetailId
						,intLoadCostId = NULL
						,intVendorId = intVendorEntityId
						,intItemId 
						,dblQty = dblNet
						,intWeightUOMId = ISNULL(LD1.intWeightItemUOMId, LD1.intItemUOMId)
						,intCompanyLocationId = intPCompanyLocationId
						,intLineNo = DENSE_RANK() OVER (PARTITION BY intLoadId ORDER BY intLoadDetailId)
					 FROM tblLGLoadDetail LD1
					 WHERE LD1.intLoadId = L.intLoadId) LD2
				 WHERE GLD.intLineNo  = LD2.intLineNo) LD
	LEFT JOIN tblICItem I ON I.intItemId = LD.intItemId
	LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = L.intWeightUnitMeasureId
	LEFT JOIN tblICItemUOM LDUOM ON LDUOM.intItemUOMId = LD.intWeightUOMId
	LEFT JOIN tblICUnitMeasure LDUM ON LDUM.intUnitMeasureId = LDUOM.intUnitMeasureId
	LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = LD.intCompanyLocationId
WHERE ISNULL(L.ysnCancelled, 0) <> 1

GO
