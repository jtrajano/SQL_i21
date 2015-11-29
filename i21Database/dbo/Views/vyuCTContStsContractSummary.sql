CREATE VIEW [dbo].[vyuCTContStsContractSummary]

AS

	
	SELECT	CAST(ROW_NUMBER() OVER (ORDER BY UP.intContractDetailId ASC) AS INT) intUniqueId,
			UP.intContractDetailId,
			UP.strName,
			UP.strValue
	FROM	(
				SELECT	CD.intContractDetailId,
						ISNULL(CAST(CAST(CD.dblQuantity AS NUMERIC(18,2)) AS NVARCHAR(100)) collate Latin1_General_CI_AS,'') Quantity,
						ISNULL(CAST(LTRIM(CAST(CD.dblBasis AS NUMERIC(18,2)))  + ' ' + CY.strCurrency + ' Per ' + PM.strUnitMeasure AS NVARCHAR(100) ) collate Latin1_General_CI_AS,'') [Differential],
						ISNULL(CAST(LTRIM(PF.intLotsFixed) + '/' + LTRIM(PF.intTotalLots - PF.intLotsFixed) AS NVARCHAR(100)) collate Latin1_General_CI_AS,'') AS [Fixed/Unfixed],
						ISNULL(CAST(LTRIM(PF.intLotsHedged) + '/' + LTRIM(PF.intTotalLots - PF.intLotsHedged) AS NVARCHAR(100)) collate Latin1_General_CI_AS,'') AS [Hedge/Not Hedge],
						ISNULL(CAST(LTRIM(CAST(ISNULL(PF.dblFinalPrice,CD.dblCashPrice) AS NUMERIC(18,2)))  + ' ' + CY.strCurrency + ' Per ' + ISNULL(FM.strUnitMeasure,PM.strUnitMeasure) AS NVARCHAR(100)) collate Latin1_General_CI_AS,'') [Final Price]
				FROM	tblCTContractDetail			CD LEFT
				JOIN	tblCTPriceFixation			PF	ON	PF.intContractDetailId			=		CD.intContractDetailId	LEFT
				JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID				=		CD.intCurrencyId		LEFT
				JOIN	tblICItemUOM				PU	ON	PU.intItemUOMId					=		CD.intPriceItemUOMId	LEFT
				JOIN	tblICUnitMeasure			PM	ON	PM.intUnitMeasureId				=		PU.intUnitMeasureId		LEFT
				JOIN	tblICCommodityUnitMeasure	FU	ON	FU.intCommodityUnitMeasureId	=		PF.intFinalPriceUOMId	LEFT
				JOIN	tblICUnitMeasure			FM	ON	FM.intUnitMeasureId				=		FU.intUnitMeasureId		
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