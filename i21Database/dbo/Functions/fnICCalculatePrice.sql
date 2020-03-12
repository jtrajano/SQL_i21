CREATE FUNCTION dbo.fnICCalculatePrice(
	  @strPricingMethod NVARCHAR(50)
	, @dblStandardCost NUMERIC(16, 9)
	, @dblLastCost NUMERIC(16, 9)
	, @dblAvgCost NUMERIC(16, 9)
	, @dblAmount NUMERIC(16, 9)
	, @dblProposedSalePrice NUMERIC(16, 9)
)
RETURNS NUMERIC(16, 9)
AS
BEGIN
	DECLARE @dblSalePrice NUMERIC(16, 9) = 0.00
	IF @strPricingMethod = 'Fixed Dollar Amount'
		SET @dblSalePrice = @dblStandardCost + @dblAmount
	ELSE IF @strPricingMethod = 'Markup Standard Cost'
		SET @dblSalePrice = (@dblStandardCost * (@dblAmount / 100.00)) + @dblStandardCost
	ELSE IF @strPricingMethod = 'Percent of Margin'
		SET @dblSalePrice = CASE WHEN @dblAmount < 100 THEN (@dblStandardCost / (1 - (@dblAmount / 100.00))) ELSE NULL END
	ELSE IF @strPricingMethod = 'Markup Last Cost'
		SET @dblSalePrice = (@dblLastCost * (@dblAmount / 100.00)) + @dblLastCost
	ELSE IF @strPricingMethod = 'Markup Avg Cost'
		SET @dblSalePrice = (@dblAvgCost * (@dblAmount / 100.00)) + @dblAvgCost
	ELSE
		SET @dblSalePrice = 0.00
	
	IF @strPricingMethod IS NULL OR @strPricingMethod = 'None'
	BEGIN
		IF @dblAmount <> 0 AND @dblStandardCost <> 0
			SET @dblSalePrice = @dblProposedSalePrice
	END
	ELSE
	BEGIN
		SET @dblSalePrice = @dblProposedSalePrice
	END

	RETURN @dblSalePrice
END