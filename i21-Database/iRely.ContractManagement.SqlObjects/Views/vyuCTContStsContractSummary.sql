CREATE VIEW [dbo].[vyuCTContStsContractSummary]

AS

	
	SELECT	CAST(ROW_NUMBER() OVER (ORDER BY UP.intContractDetailId ASC) AS INT) intUniqueId,
			UP.intContractDetailId,
			UP.strName,
			UP.strValue
	FROM	(
				SELECT	CD.intContractDetailId,
						ISNULL(CAST(dbo.fnRemoveTrailingZeroes(dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,QU.intUnitMeasureId,LP.intWeightUOMId,CD.dblQuantity)) AS NVARCHAR(100)) collate Latin1_General_CI_AS,'') Quantity,
						ISNULL(CAST(dbo.fnRemoveTrailingZeroes(CAST(CD.dblBasis AS NUMERIC(18, 6)))  + ' ' + CY.strCurrency + ' Per ' + PM.strUnitMeasure AS NVARCHAR(100) ) collate Latin1_General_CI_AS,'') [Differential],
						ISNULL(CAST(dbo.fnRemoveTrailingZeroes(PF.[dblLotsFixed]) + '/' + dbo.fnRemoveTrailingZeroes(PF.[dblTotalLots] - PF.[dblLotsFixed]) AS NVARCHAR(100)) collate Latin1_General_CI_AS,'') AS [Fixed/Unfixed],
						ISNULL(CAST(dbo.fnRemoveTrailingZeroes(PF.intLotsHedged) + '/' + dbo.fnRemoveTrailingZeroes(PF.[dblTotalLots] - PF.intLotsHedged) AS NVARCHAR(100)) collate Latin1_General_CI_AS,'') AS [Hedge/Not Hedge],
						ISNULL(CAST(dbo.fnRemoveTrailingZeroes(CAST(ISNULL(PF.dblFinalPrice,CD.dblCashPrice) AS NUMERIC(18, 6)))  + ' ' + CY.strCurrency + ' Per ' + ISNULL(FM.strUnitMeasure,PM.strUnitMeasure) AS NVARCHAR(100)) collate Latin1_General_CI_AS,'') [Final Price]
				FROM	tblCTContractDetail			CD 
				JOIN	tblCTContractHeader			CH	ON	CH.intContractHeaderId				=	CD.intContractHeaderId	LEFT
				JOIN	tblCTPriceFixation			PF	ON	ISNULL(PF.intContractDetailId,0)	=	CASE	WHEN CH.ysnMultiplePriceFixation = 1 
																											THEN  ISNULL(PF.intContractDetailId,0)	
																											ELSE CD.intContractDetailId	
																									END
														AND	PF.intContractHeaderId = CD.intContractHeaderId					LEFT
	
				JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID				=		CD.intCurrencyId		LEFT
				JOIN	tblICItemUOM				QU	ON	QU.intItemUOMId					=		CD.intItemUOMId			LEFT
				JOIN	tblICItemUOM				PU	ON	PU.intItemUOMId					=		CD.intPriceItemUOMId	LEFT
				JOIN	tblICUnitMeasure			PM	ON	PM.intUnitMeasureId				=		PU.intUnitMeasureId		LEFT
				JOIN	tblICCommodityUnitMeasure	FU	ON	FU.intCommodityUnitMeasureId	=		PF.intFinalPriceUOMId	LEFT
				JOIN	tblICUnitMeasure			FM	ON	FM.intUnitMeasureId				=		FU.intUnitMeasureId		CROSS	
				APPLY	tblLGCompanyPreference		LP 	
			) s
	UNPIVOT	(	strValue FOR strName IN 
				(
					[Quantity],
					[Differential],
					[Fixed/Unfixed],
					[Hedge/Not Hedge],
					[Final Price]
				)
			) UP