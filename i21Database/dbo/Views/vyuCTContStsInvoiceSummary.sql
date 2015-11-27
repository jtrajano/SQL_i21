CREATE VIEW [dbo].[vyuCTContStsInvoiceSummary]

AS 

	SELECT	CAST(ROW_NUMBER() OVER (ORDER BY UP.intContractDetailId ASC) AS INT) intUniqueId,
			UP.intContractDetailId,
			UP.strName,
			UP.strValue
	FROM	(
				SELECT	CD.intContractDetailId,
						LTRIM(dblTotal) + ' ' + strCurrency AS [Invoiced(P)] 
				FROM	tblCTContractDetail CD LEFT
				JOIN	(
							SELECT		intContractDetailId,CAST(ISNULL(SUM(dblTotal),0)AS NUMERIC(18,2)) AS dblTotal,MAX(strCurrency)  strCurrency
							FROM		vyuCTContStsVendorInvoice 
							Group By	intContractDetailId
						)	VI	  ON	VI.intContractDetailId		=	CD.intContractDetailId
			) s
					UNPIVOT	(strValue FOR strName IN 
								(
									[Invoiced(P)] 
								)
							) UP
