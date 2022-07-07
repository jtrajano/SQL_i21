CREATE FUNCTION [dbo].[fnSTGetGrossFuelSalesByCheckoutId] 
(
	@intCheckoutId AS INT
)
RETURNS DECIMAL(18,6)
AS BEGIN

    DECLARE @intStoreId INT
	DECLARE @ysnConsMeterReadingsForDollars BIT
	DECLARE @ysnConsAddOutsideFuelDiscounts BIT
	DECLARE @dblEditableAggregateMeterReadingsForDollars DECIMAL(18,6) = 0 
	DECLARE @dblDepartmentTotalForFuel DECIMAL(18,6) = 0 
	DECLARE @dblLoyaltyPpgDiscount DECIMAL(18,6) = 0
	DECLARE @dblGrossFuelSales DECIMAL(18,6) = 0

	SELECT	@intStoreId = intStoreId,
			@dblEditableAggregateMeterReadingsForDollars = ISNULL(dblEditableAggregateMeterReadingsForDollars, 0),
			@dblLoyaltyPpgDiscount = ISNULL(dblLoyaltyPpgDiscount, 0)
	FROM	tblSTCheckoutHeader 
	WHERE	intCheckoutId = @intCheckoutId

	SELECT	@ysnConsMeterReadingsForDollars = ysnConsMeterReadingsForDollars,
			@ysnConsAddOutsideFuelDiscounts = ysnConsAddOutsideFuelDiscounts
	FROM	tblSTStore 
	WHERE	intStoreId = @intStoreId

	IF @ysnConsMeterReadingsForDollars = 1
		BEGIN
		IF @ysnConsAddOutsideFuelDiscounts = 1
			BEGIN
				SET @dblGrossFuelSales = @dblEditableAggregateMeterReadingsForDollars + @dblLoyaltyPpgDiscount
			END
		ELSE
			BEGIN
				SET @dblGrossFuelSales = @dblEditableAggregateMeterReadingsForDollars
			END
		END
	ELSE
		BEGIN
			SELECT			@dblDepartmentTotalForFuel =ISNULL(SUM(dblTotalSalesAmountComputed), 0)
			FROM			tblSTCheckoutDepartmetTotals a
			INNER JOIN		tblICItem b
			ON				a.intItemId = b.intItemId
			WHERE			a.intCheckoutId = @intCheckoutId AND
							b.ysnFuelItem = 1

			IF @ysnConsAddOutsideFuelDiscounts = 1
				BEGIN
					SET @dblGrossFuelSales = @dblDepartmentTotalForFuel + @dblLoyaltyPpgDiscount
				END
			ELSE
				BEGIN
					SET @dblGrossFuelSales = @dblDepartmentTotalForFuel
				END
		END
	RETURN @dblGrossFuelSales
END