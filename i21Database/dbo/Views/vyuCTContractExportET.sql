CREATE VIEW [dbo].[vyuCTContractExportET]
	
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
				TM.strTermCode			AS bkterm,
			
				null					AS bkdelt,
				'N'						COLLATE Latin1_General_CI_AS AS chrTaxable,
				strContractNumber		AS bknum,
				REPLACE(CONVERT(NVARCHAR(50),dtmStartDate,101),'/','')		COLLATE Latin1_General_CI_AS AS bkstart,
				REPLACE(CONVERT(NVARCHAR(50),dtmEndDate,101),'/','')		COLLATE Latin1_General_CI_AS AS bkend

		FROM	tblCTContractDetail		CD
		JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId		=	CD.intContractHeaderId		LEFT	
		JOIN	tblSMCompanyLocation	CL	ON	CL.intCompanyLocationId		=	CD.intCompanyLocationId		LEFT
		JOIN	tblSMTerm				TM	ON	TM.intTermID				=	CH.intTermId				LEFT
		JOIN	tblICItem				IM	ON	IM.intItemId				=	CD.intItemId				LEFT
		JOIN	tblEMEntity				EY	ON	EY.intEntityId				=	CH.intCreatedById		
	)t
