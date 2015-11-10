CREATE VIEW [dbo].[vyuCTContStsContractSummary]

AS

	SELECT	CAST(ROW_NUMBER() OVER (ORDER BY UP.intContractDetailId ASC) AS INT) intUniqueId,
			UP.intContractDetailId,
			UP.strName,
			UP.strValue
	FROM	(
				SELECT	CD.intContractDetailId,
						CAST(CD.dblQuantity AS NVARCHAR(100)) collate Latin1_General_CI_AS Quantity,
						CAST(LTRIM(CD.dblBasis) + ' ' + CY.strCurrency + ' Per ' + PM.strUnitMeasure AS NVARCHAR(100) ) collate Latin1_General_CI_AS [Differential],
						CAST(LTRIM(PF.intLotsFixed) + '/' + LTRIM(PF.intTotalLots - PF.intLotsFixed) AS NVARCHAR(100)) collate Latin1_General_CI_AS AS [Fixed/Unfixed],
						CAST(LTRIM(PF.intLotsHedged) + '/' + LTRIM(PF.intTotalLots - PF.intLotsHedged) AS NVARCHAR(100)) collate Latin1_General_CI_AS AS [Hedge/Not Hedge],
						CAST(LTRIM(PF.dblFinalPrice) + ' ' + CY.strCurrency + ' Per ' + FM.strUnitMeasure AS NVARCHAR(100)) collate Latin1_General_CI_AS [Final Price]
				FROM	tblCTContractDetail			CD LEFT
				JOIN	tblCTPriceFixation			PF	ON	PF.intContractDetailId			=		CD.intContractDetailId	LEFT
				JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID				=		CD.intCurrencyId		LEFT
				JOIN	tblICItemUOM				PU	ON	PU.intItemUOMId					=		CD.intPriceItemUOMId	LEFT
				JOIN	tblICUnitMeasure			PM	ON	PM.intUnitMeasureId				=		PU.intUnitMeasureId		LEFT
				JOIN	tblICCommodityUnitMeasure	FU	ON	FU.intCommodityUnitMeasureId	=		PF.intFinalPriceUOMId	LEFT
				JOIN	tblICUnitMeasure			FM	ON	FM.intUnitMeasureId				=		FU.intUnitMeasureId
			) s
	UNPIVOT	(strValue FOR strName IN 
				(
					[Quantity],
					[Differential],
					[Fixed/Unfixed],
					[Hedge/Not Hedge],
					[Final Price]
				)
			) UP
