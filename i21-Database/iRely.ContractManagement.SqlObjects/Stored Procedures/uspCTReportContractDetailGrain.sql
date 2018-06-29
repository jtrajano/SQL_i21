CREATE PROCEDURE uspCTReportContractDetailGrain

	@intContractHeaderId	INT
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX)

	SELECT	strItemNo,dblDetailQuantity,
			CASE	WHEN intPricingTypeId IN (1,6)	THEN	ISNULL(dblCashPrice,0)
					WHEN intPricingTypeId = 2		THEN	ISNULL(dblBasis,0)
					WHEN intPricingTypeId = 3		THEN	ISNULL(dblFutures,0)
					ELSE 0
			END	dblPrice,
			dtmStartDate,
			dtmEndDate,
			strPricingType,
			strShipVia,
			strLocationName,
			intContractHeaderId,
			strRemark,
			strItemUOM strDetailUnitMeasure,
			strPriceUOM + ' ' + strCurrency AS strPriceUOMWithCurrency
	FROM	vyuCTContractDetailView DV
	WHERE	intContractHeaderId	=	@intContractHeaderId
	
END TRY

BEGIN CATCH

	SET @ErrMsg = 'uspCTReportContractDetailGrain - ' + ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO
