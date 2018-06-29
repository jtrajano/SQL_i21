CREATE FUNCTION [dbo].[fnCTGetContractPrice]
(
	@intContractDetailId INT
)
RETURNS NUMERIC(18,6)
AS
BEGIN
	DECLARE @ysnMaxPrice			BIT,
			@dblCashPrice			NUMERIC(18,6),
			@dblContractPrice		NUMERIC(18,6),
			@intItemId				INT,
			@intCompanyLocationId	INT,
			@strPricingLevelName	NVARCHAR(100),
			@intCompanyLocationPricingLevelId	INT
			
	SELECT	@ysnMaxPrice	=	ISNULL(CH.ysnMaxPrice,0),
			@dblCashPrice	=	CD.dblCashPrice, 
			@intItemId		=	CD.intItemId,
			@intCompanyLocationPricingLevelId	=	CH.intCompanyLocationPricingLevelId,
			@intCompanyLocationId	=	CD.intCompanyLocationId
	FROM	tblCTContractDetail CD
	JOIN	tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	WHERE	CD.intContractDetailId	=	@intContractDetailId

	IF @ysnMaxPrice = 0
	BEGIN
		SET @dblContractPrice = @dblCashPrice;
	END
	ELSE
	BEGIN
		IF @intCompanyLocationPricingLevelId IS NULL
		BEGIN
			SELECT	@dblContractPrice =  MIN(IP.dblSalePrice) 
			FROM	tblICItemPricing	IP
			JOIN	tblICItemLocation	IL	ON	IL.intItemLocationId = IP.intItemLocationId
			WHERE	IP.intItemId = @intItemId AND IP.dblSalePrice > 0 AND IL.intLocationId = @intCompanyLocationId

			IF @dblContractPrice > @dblCashPrice 
			BEGIN
				SET @dblContractPrice = @dblCashPrice 
			END
			ELSE 
			BEGIN
				SET @dblContractPrice =  ISNULL(@dblContractPrice,@dblCashPrice)
			END
		END
		ELSE
		BEGIN
			SELECT	@strPricingLevelName	=	strPricingLevelName FROM tblSMCompanyLocationPricingLevel WHERE intCompanyLocationPricingLevelId = @intCompanyLocationPricingLevelId
			
			SELECT	@dblContractPrice = MIN(IP.dblUnitPrice) 
			FROM	tblICItemPricingLevel	IP
			JOIN	tblICItemLocation		IL	ON	IL.intItemLocationId = IP.intItemLocationId
			WHERE	IP.intItemId = @intItemId AND IP.dblUnitPrice > 0 AND IL.intLocationId = @intCompanyLocationId AND IP.strPriceLevel = @strPricingLevelName
			
			IF @dblContractPrice > @dblCashPrice 
			BEGIN
				SET @dblContractPrice = @dblCashPrice 
			END
			ELSE 
			BEGIN
				SET @dblContractPrice =  ISNULL(@dblContractPrice,@dblCashPrice)
			END
		END
	END
	RETURN @dblContractPrice
END