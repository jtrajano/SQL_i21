CREATE FUNCTION [dbo].[fnCTGetTopOneSequence]
(
	@intContractHeaderId	INT,
	@intContractDetailId	INT
)
RETURNS @returntable	TABLE
(
	intCurrencyId			INT,
	intBookId				INT,
	intSubBookId			INT,
	intCompanyLocationId	INT,
	intContractSeq			INT,					
	dtmStartDate			DATETIME,				
	dtmEndDate				DATETIME,						
	strPurchasingGroup		NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	dblQuantity				NUMERIC(18,6),		
	dblFutures				NUMERIC(18,6),					
	dblBasis				NUMERIC(18,6),						
	dblCashPrice			NUMERIC(18,6),
	dblScheduleQty			NUMERIC(18,6),					
	dblNoOfLots				NUMERIC(18,6),				
	strItemNo				NVARCHAR(100) COLLATE Latin1_General_CI_AS,						
	strPricingType			NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFutMarketName		NVARCHAR(100) COLLATE Latin1_General_CI_AS,				
	strItemUOM				NVARCHAR(100) COLLATE Latin1_General_CI_AS,					
	strLocationName			NVARCHAR(100) COLLATE Latin1_General_CI_AS,				
	strPriceUOM				NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strCurrency				NVARCHAR(100) COLLATE Latin1_General_CI_AS,					
	strFutureMonth			NVARCHAR(100) COLLATE Latin1_General_CI_AS,				
	strStorageLocation		NVARCHAR(100) COLLATE Latin1_General_CI_AS,				
	strSubLocation			NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strItemDescription		NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	intContractDetailId		INT,
	strProductType			NVARCHAR(100) COLLATE Latin1_General_CI_AS
)
AS
BEGIN

	IF ISNULL(@intContractDetailId,0) > 0
		INSERT INTO @returntable
		SELECT	intCurrencyId,					intBookId,					intSubBookId,					intCompanyLocationId, 
				intContractSeq,					dtmStartDate,				dtmEndDate,						strPurchasingGroup,
				dblQuantity,					dblFutures,					dblBasis,						dblCashPrice,
				dblScheduleQty,					dblNoOfLots,				strItemNo,						strPricingType,
				strFutMarketName,				strItemUOM,					strLocationName,				strPriceUOM,
				strCurrency,					strFutureMonth,				strStorageLocation,				strSubLocation,
				strItemDescription,				intContractDetailId,		strProductType
				
		FROM	vyuCTContractSequence WHERE intContractDetailId = @intContractDetailId
	ELSE
		INSERT INTO @returntable
		SELECT TOP 1 intCurrencyId,				intBookId,					intSubBookId,					intCompanyLocationId, 
				intContractSeq,					dtmStartDate,				dtmEndDate,						strPurchasingGroup,
				dblQuantity,					dblFutures,					dblBasis,						dblCashPrice,
				dblScheduleQty,					dblNoOfLots,				strItemNo,						strPricingType,
				strFutMarketName,				strItemUOM,					strLocationName,				strPriceUOM,
				strCurrency,					strFutureMonth,				strStorageLocation,				strSubLocation,
				strItemDescription,				intContractDetailId,		strProductType
				
		FROM	vyuCTContractSequence WHERE intContractHeaderId = @intContractHeaderId
	RETURN;
END