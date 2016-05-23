CREATE VIEW [dbo].[vyuCTContractExportET]
	
AS 

	SELECT	strLocationName		AS bkloc,
			strEntityName		AS bkcust,
			strItemNo			AS bkitem,
			intContractSeq		AS bkseq,
			dblDetailQuantity	AS bkunit,
			dblCashPrice		AS bkpric,
			null				AS bkppd,
			dblAppliedQty		AS bkdelu,
			strTerm				AS bkterm,
			dblAppliedQty * 
				dblCashPrice	AS bkusp,
			null				AS bkdelt,
			'N'					AS chrTaxable,
			strContractNumber	AS bknum,
			dtmStartDate		AS bkstart,
			dtmEndDate			AS bkend

	FROM	vyuCTContractDetailView
