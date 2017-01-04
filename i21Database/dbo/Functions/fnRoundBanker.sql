CREATE FUNCTION [dbo].[fnRoundBanker]
(
	 @Amount	NUMERIC(18, 6)
	,@Precision	TINYINT
) 
RETURNS NUMERIC(18, 6)
AS
BEGIN
	SET @Amount = ISNULL(@Amount, 0.000000)
	SET @Precision = ISNULL(@Precision, 0.000000)
	DECLARE	@RoundedAmt	NUMERIC(18, 6)
			,@WholeAmt	INTEGER
			,@Decimal	TINYINT
			,@Ten		NUMERIC(18, 6)
	SET	@Ten		= 10.0
	SET	@WholeAmt	= ROUND(@Amount,0, 1 )
	SET	@RoundedAmt	= @Amount - @WholeAmt
	SET	@Decimal	= 6
	
	While @Decimal > @Precision
	BEGIN
		SET @Decimal = @Decimal - 1 
		--IF	5 = (ROUND(@RoundedAmt * POWER(@Ten, @Decimal + 1), 0,1) - (ROUND(@RoundedAmt * POWER(@Ten, @Decimal), 0, 1) * 10)) AND 0 = CAST((ROUND(@RoundedAmt * POWER(@Ten, @Decimal) ,0,1) - (ROUND(@RoundedAmt * POWER(@Ten, @Decimal - 1) ,0,1) * 10)) AS INTEGER) % 2			
		--	SET @RoundedAmt = ROUND(@RoundedAmt,@Decimal, 1 )
		--ELSE 
			SET @RoundedAmt = ROUND(@RoundedAmt,@Decimal, 0 )
	END
	
	RETURN (@RoundedAmt + @WholeAmt)

END