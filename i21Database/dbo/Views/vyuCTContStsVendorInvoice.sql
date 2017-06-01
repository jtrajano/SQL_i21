CREATE VIEW [dbo].[vyuCTContStsVendorInvoice]

AS 
	
	SELECT	CAST(ROW_NUMBER() OVER (ORDER BY intContractDetailId ASC) AS INT) intUniqueId,
			*
	FROM	(
				SELECT	CD.intContractDetailId,
						BL.strBillId,
						CH.strContractNumber,
						SUM(BD.dblTotal)dblTotal,
						CY.strCurrency,
						BL.intBillId
				FROM	tblCTContractDetail CD
				JOIN	tblCTContractHeader CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
				JOIN	tblAPBillDetail		BD	ON	BD.intContractDetailId	=	CD.intContractDetailId
				JOIN	tblAPBill			BL	ON	BL.intBillId			=	BD.intBillId
				JOIN	tblSMCurrency		CY	ON	CY.intCurrencyID		=	BL.intCurrencyId
				GROUP 
				BY		CD.intContractDetailId,BL.strBillId,CH.strContractNumber,CY.strCurrency,BL.intBillId

				UNION ALL

				SELECT	AD.intSContractDetailId,
						BL.strBillId,
						CH.strContractNumber,
						SUM(BD.dblTotal)dblTotal,
						CY.strCurrency,
						BL.intBillId
				FROM	tblCTContractDetail		CD
				JOIN	tblLGAllocationDetail	AD	ON	AD.intSContractDetailId =	CD.intContractDetailId
				JOIN	tblCTContractDetail		PD	ON	PD.intContractDetailId	=	AD.intPContractDetailId
				JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId	=	PD.intContractHeaderId
				JOIN	tblAPBillDetail			BD	ON	BD.intContractDetailId	=	PD.intContractDetailId
				JOIN	tblAPBill				BL	ON	BL.intBillId			=	BD.intBillId
				JOIN	tblSMCurrency			CY	ON	CY.intCurrencyID		=	BL.intCurrencyId
				GROUP 
				BY		AD.intSContractDetailId,BL.strBillId,CH.strContractNumber,CY.strCurrency,BL.intBillId
			)t
