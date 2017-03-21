CREATE VIEW [dbo].[vyuCTContStsInvoiceSummary]

AS 

	SELECT	CAST(ROW_NUMBER() OVER (ORDER BY UP.intContractDetailId ASC) AS INT) intUniqueId,
			UP.intContractDetailId,
			UP.strName,
			UP.strValue
	FROM	(
				SELECT	CD.intContractDetailId,
						CAST(dbo.fnRemoveTrailingZeroes(VI.dblTotal) + ' ' + VI.strCurrency AS NVARCHAR(MAX))collate Latin1_General_CI_AS AS [Invoiced(P)],
						CAST(dbo.fnRemoveTrailingZeroes(CI.dblTotal) + ' ' + CI.strCurrency AS NVARCHAR(MAX))collate Latin1_General_CI_AS AS [Invoiced(S)],
						CAST(dbo.fnRemoveTrailingZeroes(CI.dblNetWeight) AS NVARCHAR(MAX))collate Latin1_General_CI_AS AS [Invoiced Wt(S)],
						CAST(dbo.fnRemoveTrailingZeroes(dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,QU.intUnitMeasureId,LP.intWeightUOMId,CD.dblQuantity) - CI.dblNetWeight)  AS NVARCHAR(MAX))collate Latin1_General_CI_AS AS [To be Invoiced(S)]
				FROM	tblCTContractDetail CD LEFT
				JOIN	(
							SELECT		intContractDetailId,CAST(ISNULL(SUM(dblTotal),0)AS NUMERIC(18, 6)) AS dblTotal,MAX(strCurrency)  strCurrency
							FROM		vyuCTContStsVendorInvoice 
							Group By	intContractDetailId
						)	VI	  ON	VI.intContractDetailId		=	CD.intContractDetailId
				JOIN	(
							SELECT		intContractDetailId,CAST(ISNULL(SUM(dblTotal),0)AS NUMERIC(18, 6)) AS dblTotal,MAX(strCurrency)  strCurrency,CAST(ISNULL(SUM(dblNetWeight),0)AS NUMERIC(18, 6)) dblNetWeight
							FROM		vyuCTContStsCustomerInvoice 
							Group By	intContractDetailId
						)	CI	  ON	CI.intContractDetailId		=	CD.intContractDetailId	
				JOIN	tblICItemUOM	QU	ON	QU.intItemUOMId	=	CD.intItemUOMId			CROSS	
				APPLY	tblLGCompanyPreference	LP
			) s
			UNPIVOT	(strValue FOR strName IN 
						(
							[Invoiced(P)],
							[Invoiced(S)],
							[Invoiced Wt(S)],
							[To be Invoiced(S)] 
						)
			) UP
