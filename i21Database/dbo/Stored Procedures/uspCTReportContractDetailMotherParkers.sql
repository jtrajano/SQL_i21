CREATE PROCEDURE [dbo].[uspCTReportContractDetailMotherParkers] 
	@intContractHeaderId INT  
	,@strDetailAmendedColumns NVARCHAR(MAX) = NULL  
   
AS  
  
BEGIN TRY 

	DECLARE @ErrMsg NVARCHAR(MAX)

	SELECT
		intContractHeaderId = CD.intContractHeaderId,  
		intContractSeq = CD.intContractSeq,  
		strPeriod = CONVERT(NVARCHAR(50),dtmStartDate,106) + ' - ' + CONVERT(NVARCHAR(50),dtmEndDate,106),
		strQunatity =	CASE
							WHEN CP.strDefaultContractReport = 'ContractBeGreen'
							THEN CONVERT(NVARCHAR,CAST(CD.dblQuantity  AS Money),1)
							ELSE LTRIM(dbo.fnRemoveTrailingZeroes(CD.dblQuantity))
						END
						+ ' ' + UM.strUnitMeasure,  
		strPrice =	CASE
						WHEN CD.intPricingTypeId IN (1,6)
						THEN dbo.fnCTChangeNumericScale(dbo.fnRemoveTrailingZeroes(CAST(CD.dblCashPrice AS NUMERIC(18, 6))),4) + ' ' + CY.strCurrency + ' per ' + PU.strUnitMeasure + ' net'   
						WHEN  CD.intPricingTypeId = 2
						THEN dbo.fnCTChangeNumericScale(dbo.fnRemoveTrailingZeroes(CD.dblBasis),4) + ' ' + CY.strCurrency + ' per ' + PU.strUnitMeasure + ', ' + MO.strFutureMonth +
							CASE
							WHEN ISNULL(CH.ysnMultiplePriceFixation,0) = 0
							THEN ' ('+ LTRIM(CAST(CD.dblNoOfLots AS INT)) +' Lots)'
							ELSE ''
							END    
					END, 
		strItemNo = IM.strItemNo,  
		strDescription   = ISNULL(IC.strContractItemName,IM.strDescription),
		strItemSpecification	= CD.strItemSpecification
  
	FROM
		tblCTContractDetail CD WITH (NOLOCK)
		JOIN tblCTContractHeader CH WITH (NOLOCK) ON CH.intContractHeaderId = CD.intContractHeaderId
		LEFT JOIN tblICItemUOM  QM WITH (NOLOCK) ON QM.intItemUOMId   = CD.intItemUOMId
		LEFT JOIN tblICUnitMeasure UM WITH (NOLOCK) ON UM.intUnitMeasureId  = QM.intUnitMeasureId
		LEFT JOIN tblSMCurrency  CY WITH (NOLOCK) ON CY.intCurrencyID  = CD.intCurrencyId
		LEFT JOIN tblICItemUOM  PM WITH (NOLOCK) ON PM.intItemUOMId   = CD.intPriceItemUOMId
		LEFT JOIN tblICUnitMeasure PU WITH (NOLOCK) ON PU.intUnitMeasureId  = PM.intUnitMeasureId
		LEFT JOIN tblRKFuturesMonth MO WITH (NOLOCK) ON MO.intFutureMonthId  = CD.intFutureMonthId
		LEFT JOIN tblICItemContract IC WITH (NOLOCK) ON IC.intItemContractId = CD.intItemContractId
		LEFT JOIN tblICItem   IM WITH (NOLOCK) ON IM.intItemId   = CD.intItemId
		CROSS JOIN tblCTCompanyPreference   CP
	WHERE
		CD.intContractHeaderId = @intContractHeaderId  
		AND  CD.intContractStatusId <> 3  
  
END TRY  
  
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()    
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH  