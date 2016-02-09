CREATE PROCEDURE uspCTReportContractDetailGrain

	@intContractHeaderId	INT
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX)

	SELECT	strItemNo,dblDetailQuantity,
			ISNULL(dblCashPrice,ISNULL(dblBasis,ISNULL(dblFutures,0)))	dblPrice,
			dtmStartDate,
			dtmEndDate,
			strPricingType,
			strShipVia,
			strLocationName,
			intContractHeaderId,
			strRemark,
			strItemUOM strDetailUnitMeasure
	FROM	vyuCTContractDetailView DV
	WHERE	intContractHeaderId	=	@intContractHeaderId
	
END TRY

BEGIN CATCH

	SET @ErrMsg = 'uspCTReportContractDetailGrain - ' + ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO
