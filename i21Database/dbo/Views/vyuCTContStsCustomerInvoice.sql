CREATE VIEW [dbo].[vyuCTContStsCustomerInvoice]

AS 

	SELECT	CAST(ROW_NUMBER() OVER (ORDER BY intContractDetailId ASC) AS INT) intUniqueId,
			*
	FROM	(
		SELECT	CD.intContractDetailId,
				IE.strInvoiceNumber,
				CH.strContractNumber,
				SUM(ID.dblTotal)dblTotal,
				CY.strCurrency,
				IE.strType,
				SUM(ID.dblQtyShipped) dblQtyShipped,
				SM.strUnitMeasure,
				dbo.fnCTConvertQuantityToTargetItemUOM(ID.intItemId,SM.intUnitMeasureId,LP.intWeightUOMId,SUM(ID.dblQtyShipped)) dblNetWeight,
				LP.intWeightUOMId
		FROM	tblCTContractDetail		CD
		JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
		JOIN	tblARInvoiceDetail		ID	ON	ID.intContractDetailId	=	CD.intContractDetailId
		JOIN	tblARInvoice			IE	ON	IE.intInvoiceId			=	ID.intInvoiceId
		JOIN	tblSMCurrency			CY	ON	CY.intCurrencyID		=	IE.intCurrencyId
		JOIN	tblICItemUOM			SU	ON	SU.intItemUOMId			=	ID.intItemUOMId
		JOIN	tblICUnitMeasure		SM	ON	SM.intUnitMeasureId		=	SU.intUnitMeasureId		CROSS	
		APPLY	tblLGCompanyPreference	LP
		GROUP 
		BY		CD.intContractDetailId,IE.strInvoiceNumber,CH.strContractNumber,CY.strCurrency,IE.strType,SM.strUnitMeasure,SM.intUnitMeasureId,ID.intItemId,LP.intWeightUOMId

		UNION ALL

		SELECT	AD.intPContractDetailId,
				IE.strInvoiceNumber,
				CH.strContractNumber,
				SUM(ID.dblTotal)dblTotal,
				CY.strCurrency,
				IE.strType,
				SUM(ID.dblQtyShipped) dblQtyShipped,
				SM.strUnitMeasure,
				dbo.fnCTConvertQuantityToTargetItemUOM(ID.intItemId,SM.intUnitMeasureId,LP.intWeightUOMId,SUM(ID.dblQtyShipped)) dblNetWeight,
				LP.intWeightUOMId
		FROM	tblCTContractDetail		CD
		JOIN	tblLGAllocationDetail	AD	ON	AD.intPContractDetailId =	CD.intContractDetailId
		JOIN	tblCTContractDetail		SD	ON	SD.intContractDetailId	=	AD.intSContractDetailId
		JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId	=	SD.intContractHeaderId
		JOIN	tblARInvoiceDetail		ID	ON	ID.intContractDetailId	=	SD.intContractDetailId
		JOIN	tblARInvoice			IE	ON	IE.intInvoiceId			=	ID.intInvoiceId
		JOIN	tblSMCurrency			CY	ON	CY.intCurrencyID		=	IE.intCurrencyId
		JOIN	tblICItemUOM			SU	ON	SU.intItemUOMId			=	ID.intItemUOMId
		JOIN	tblICUnitMeasure		SM	ON	SM.intUnitMeasureId		=	SU.intUnitMeasureId		CROSS	
		APPLY	tblLGCompanyPreference	LP
		GROUP 
		BY		AD.intPContractDetailId,IE.strInvoiceNumber,CH.strContractNumber,CY.strCurrency,IE.strType,SM.strUnitMeasure,SM.intUnitMeasureId,ID.intItemId,LP.intWeightUOMId
	)t
