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
	IF @strPricingMethod COLLATE Latin1_General_CI_AS = 'Fixed Dollar Amount'
		SET @dblSalePrice = @dblStandardCost + @dblAmount
	ELSE IF @strPricingMethod COLLATE Latin1_General_CI_AS = 'Markup Standard Cost'
		SET @dblSalePrice = (@dblStandardCost * (@dblAmount / 100.00)) + @dblStandardCost
	ELSE IF @strPricingMethod COLLATE Latin1_General_CI_AS = 'Percent of Margin'
		SET @dblSalePrice = CASE WHEN @dblAmount < 100 THEN (@dblStandardCost / (1 - (@dblAmount / 100.00))) ELSE NULL END
	ELSE IF @strPricingMethod COLLATE Latin1_General_CI_AS = 'Markup Last Cost'
		SET @dblSalePrice = (@dblLastCost * (@dblAmount / 100.00)) + @dblLastCost
	ELSE IF @strPricingMethod COLLATE Latin1_General_CI_AS = 'Markup Avg Cost'
		SET @dblSalePrice = (@dblAvgCost * (@dblAmount / 100.00)) + @dblAvgCost
	ELSE
		SET @dblSalePrice = @dblProposedSalePrice
	
	IF NOT (@strPricingMethod COLLATE Latin1_General_CI_AS IS NULL OR @strPricingMethod COLLATE Latin1_General_CI_AS = 'None')
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