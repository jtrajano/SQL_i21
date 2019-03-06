﻿CREATE VIEW [dbo].[vyuETExportContractExport]
	
AS 

	SELECT	*,
			bkdelu * bkpric				AS bkusp
	FROM
	(
		SELECT	CL.strLocationNumber	AS bkloc,
				EY.strEntityNo			AS bkcust,
				IM.strItemNo			AS bkitem,
				CD.intContractSeq		AS bkseq,
				CD.dblQuantity			AS bkunit,
				CD.dblCashPrice			AS bkpric,
				null					AS bkppd,
				CASE	WHEN	CH.ysnLoad = 1
						THEN	ISNULL(CD.intNoOfLoad,0)	-	ISNULL(CD.dblBalance,0)
						ELSE	ISNULL(CD.dblQuantity,0)	-	ISNULL(CD.dblBalance,0)												
				END						AS bkdelu,
				LEFT(ISNULL(TM.strTermCode,''),2) AS bkterm,
			
				null					AS bkdelt,
				'N'						AS chrTaxable,
				strContractNumber		AS bknum,
				REPLACE(CONVERT(NVARCHAR(50),dtmStartDate,101),'/','')		AS bkstart,
				REPLACE(CONVERT(NVARCHAR(50),dtmEndDate,101),'/','')		AS bkend

		FROM	tblCTContractDetail		CD
		JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId		=	CD.intContractHeaderId		LEFT	
		JOIN	tblSMCompanyLocation	CL	ON	CL.intCompanyLocationId		=	CD.intCompanyLocationId		LEFT
		JOIN	tblSMTerm				TM	ON	TM.intTermID				=	CH.intTermId				LEFT
		JOIN	tblICItem				IM	ON	IM.intItemId				=	CD.intItemId				LEFT
		JOIN	tblEMEntity				EY	ON	EY.intEntityId				=	CH.intEntityId
		
		WHERE	ISNULL(CD.dblCashPrice,0)	>	0		AND
				ISNULL(EY.strEntityNo,'')	<>	''		AND
				IM.strStatus = 'Active'					AND
				CD.dtmEndDate >= DATEADD(d, 0, DATEDIFF(d, 0, GETDATE())) AND
				(
					IM.intItemId IN (SELECT intItemId FROM tblETExportFilterItem) OR 
					IM.intCategoryId IN (SELECT intCategoryId FROM tblETExportFilterCategory)
				)

	)t