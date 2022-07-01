CREATE FUNCTION dbo.fnICCalculateSalePriceLevel(
	  @strPricingMethod NVARCHAR(50)
	, @dblOriginalRetailPrice NUMERIC(16, 9)
	, @ysnIsFunctionalCurrency BIT
	, @dblSalesPrice NUMERIC(16, 9)
	, @dblMsrpPrice NUMERIC(16, 9)
	, @dblAmount NUMERIC(16, 9)
	, @dblQuantity NUMERIC(16, 9)
	, @dblStandardCost NUMERIC(16, 9)
	, @dblLastCost NUMERIC(16, 9)
	, @dblAvgCost NUMERIC(16, 9))
RETURNS NUMERIC(16, 9)
AS
BEGIN

DECLARE @dblRetailPrice NUMERIC(16, 9) = 0.0

IF @ysnIsFunctionalCurrency = 1
BEGIN
	IF @strPricingMethod COLLATE Latin1_General_CI_AS = 'Discount Retail Price'
	BEGIN
		SET @dblSalesPrice = @dblSalesPrice - (@dblSalesPrice * (@dblAmount / 100.00))
		SET @dblRetailPrice = @dblSalesPrice * @dblQuantity
	END
	ELSE IF @strPricingMethod COLLATE Latin1_General_CI_AS = 'MSRP Discount'
	BEGIN
		SET @dblMsrpPrice = @dblMsrpPrice - (@dblMsrpPrice * (@dblAmount / 100.00))
		SET @dblRetailPrice = ISNULL(NULLIF(@dblMsrpPrice * @dblQuantity, 0), @dblOriginalRetailPrice)
	END
	ELSE IF @strPricingMethod COLLATE Latin1_General_CI_AS = 'Percent of Margin (MSRP)'
	BEGIN
		DECLARE @dblPercent NUMERIC(16, 9)
		SET @dblPercent = @dblAmount / 100.00
		SET @dblSalesPrice = ((@dblMsrpPrice - @dblStandardCost) * @dblPercent) + @dblStandardCost
		SET @dblRetailPrice = @dblSalesPrice * @dblQuantity
	END
	ELSE IF @strPricingMethod COLLATE Latin1_General_CI_AS = 'Fixed Dollar Amount'
	BEGIN
		SET @dblSalesPrice = @dblStandardCost + @dblAmount
		SET @dblRetailPrice = @dblSalesPrice * @dblQuantity
	END
	ELSE IF @strPricingMethod COLLATE Latin1_General_CI_AS = 'Markup Standard Cost'
	BEGIN
		DECLARE @dblMarkup NUMERIC(16, 9)
		SET @dblMarkup = @dblStandardCost * (@dblAmount / 100.00)
		SET @dblSalesPrice = @dblStandardCost + @dblMarkup
		SET @dblRetailPrice = @dblSalesPrice * @dblQuantity
	END
	ELSE IF @strPricingMethod COLLATE Latin1_General_CI_AS = 'Percent of Margin'
	BEGIN
		SET @dblSalesPrice = @dblStandardCost / (1 - (@dblAmount / 100.00))
		SET @dblRetailPrice = @dblSalesPrice * @dblQuantity
	END
	ELSE IF @strPricingMethod COLLATE Latin1_General_CI_AS = 'Markup Last Cost'
	BEGIN
		SET @dblMarkup = (@dblLastCost * (@dblAmount / 100.00))
		SET @dblSalesPrice = (@dblLastCost + @dblMarkup)
		SET @dblRetailPrice = @dblSalesPrice * @dblQuantity
	END
	ELSE IF @strPricingMethod COLLATE Latin1_General_CI_AS = 'Markup Avg Cost'
	BEGIN
		SET @dblMarkup = (@dblAvgCost * (@dblAmount / 100.00))
		SET @dblSalesPrice = (@dblAvgCost + @dblMarkup)
		SET @dblRetailPrice = @dblAvgCost * @dblQuantity
	END
	ELSE
		SET @dblRetailPrice = @dblOriginalRetailPrice
END
ELSE
BEGIN
	SET @dblRetailPrice = @dblOriginalRetailPrice
END

RETURN @dblRetailPrice

END