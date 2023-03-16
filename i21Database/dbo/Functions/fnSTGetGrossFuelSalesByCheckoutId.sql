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
	DECLARE @dblEditableOutsideFuelDiscount DECIMAL(18,6) = 0
	--DECLARE @dblEditableInsideFuelDiscount DECIMAL(18,6) = 0
	DECLARE @dblGrossFuelSales DECIMAL(18,6) = 0

	SELECT	@intStoreId = intStoreId,
			@dblEditableAggregateMeterReadingsForDollars = ISNULL(dblEditableAggregateMeterReadingsForDollars, 0),
			@dblEditableOutsideFuelDiscount = ISNULL(dblEditableOutsideFuelDiscount, 0)--,
			--@dblEditableInsideFuelDiscount = ISNULL(dblEditableInsideFuelDiscount, 0)
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
				SET @dblGrossFuelSales = @dblEditableAggregateMeterReadingsForDollars + @dblEditableOutsideFuelDiscount
			END
		ELSE
			BEGIN
				SET @dblGrossFuelSales = @dblEditableAggregateMeterReadingsForDollars
			END
		END
	ELSE
		BEGIN
			SET @dblDepartmentTotalForFuel = dbo.fnSTGetDepartmentTotalsForFuel(@intCheckoutId)

			IF @ysnConsAddOutsideFuelDiscounts = 1
				BEGIN
					SET @dblGrossFuelSales = @dblDepartmentTotalForFuel + @dblEditableOutsideFuelDiscount --+ @dblEditableInsideFuelDiscount
				END
			ELSE
				BEGIN
					SET @dblGrossFuelSales = @dblDepartmentTotalForFuel
				END
		END
	RETURN @dblGrossFuelSales
END