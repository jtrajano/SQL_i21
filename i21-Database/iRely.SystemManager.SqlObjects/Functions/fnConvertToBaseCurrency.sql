CREATE FUNCTION [dbo].[fnConvertToBaseCurrency](
	@CurrencyId	INT
	,@Amount	NUMERIC(38, 20)
)
RETURNS NUMERIC(38,20)
AS 
BEGIN 
	DECLARE @MainCurrencyId	INT
		,@SubCurrency	BIT
		,@Cent			INT

	SELECT
		 @MainCurrencyId	= [intMainCurrencyId]
		,@SubCurrency		= [ysnSubCurrency]
		,@Cent				= [intCent]
	FROM
		tblSMCurrency
	WHERE
		[intCurrencyID] = @CurrencyId
		

	IF ISNULL(@SubCurrency,0) = 0
		RETURN @Amount
		
	IF @CurrencyId = @MainCurrencyId
		RETURN @Amount
		
	IF @CurrencyId <> @MainCurrencyId AND ISNULL(@Cent,0) <> 0
		RETURN @Amount/@Cent
		
	RETURN @Amount
END