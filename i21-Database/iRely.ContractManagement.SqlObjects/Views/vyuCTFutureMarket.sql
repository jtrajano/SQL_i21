CREATE VIEW [dbo].[vyuCTFutureMarket]

AS

	SELECT			 CM.intCommodityMarketId   
					,MA.intFutureMarketId
					,CO.intCommodityId    
					,CO.strCommodityCode  
					,MA.strFutMarketName 
					,MA.strFutSymbol     
					,MA.dblContractSize  
					,UM.intUnitMeasureId 
					,UM.strUnitMeasure   
					,CY.intCurrencyID    
					,CY.strCurrency
					,CM.strCommodityAttributeId
					,MY.strCurrency				AS	strMainCurrency
					,MY.intMainCurrencyId

	FROM			tblICCommodity				CO 
			JOIN	tblRKCommodityMarketMapping CM	ON	CO.intCommodityId		=	CM.intCommodityId
			JOIN	tblRKFutureMarket			MA	ON	MA.intFutureMarketId	=	CM.intFutureMarketId
			JOIN	tblICUnitMeasure			UM	ON	MA.intUnitMeasureId		=	UM.intUnitMeasureId
			JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID		=	MA.intCurrencyId
	LEFT	JOIN	tblSMCurrency				MY	ON	MY.intCurrencyID		=	CY.intMainCurrencyId
