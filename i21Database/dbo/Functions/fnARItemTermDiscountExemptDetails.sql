CREATE FUNCTION [dbo].[fnARItemTermDiscountExemptDetails]
(
	 @ItemId			INT
	,@LocationId		INT
	,@TermId			INT
	,@TransactionDate	DATETIME
	,@PaymentDate		DATETIME = NULL
)
RETURNS @returntable TABLE
(
	 dblTermDiscountRate	NUMERIC(18,6)
	,ysnTermDiscountExempt	BIT
)
AS
BEGIN

DECLARE @ZeroDecimal DECIMAL(18,6)
SET @ZeroDecimal = 0.000000

SET @PaymentDate = CAST(ISNULL(@PaymentDate,GETDATE()) AS DATE)

IF @PaymentDate > [dbo].[fnGetDiscountDateBasedOnTerm](@TransactionDate, @TermId, @PaymentDate)
BEGIN
	INSERT INTO @returntable(dblTermDiscountRate, ysnTermDiscountExempt)
	VALUES(@ZeroDecimal, CAST(0 AS BIT))
	RETURN;
END

IF EXISTS	(
			SELECT TOP 1 NULL
			FROM
				tblICItemSpecialPricing ICISP
			LEFT OUTER JOIN
				tblICItemLocation ICIL
					ON ICISP.intItemLocationId = ICIL.intItemLocationId
			WHERE
				ISNULL(ICISP.strPromotionType, '') <> ''
				AND ICISP.strPromotionType = 'Terms Discount Exempt'
				AND ICISP.intItemId = @ItemId 
				AND (ICIL.intLocationId = @LocationId OR ICIL.intLocationId IS NULL)
				AND CAST(@TransactionDate AS DATE) BETWEEN CAST(ICISP.dtmBeginDate AS DATE) AND CAST(ISNULL(ICISP.dtmEndDate,@TransactionDate) AS DATE)
			)
	BEGIN
	
		INSERT INTO @returntable(dblTermDiscountRate, ysnTermDiscountExempt)
		SELECT
			 [dblTermDiscountRate]		= ISNULL([dblDiscountEP], @ZeroDecimal)
			,[ysnTermDiscountExempt]	= CAST(1 AS BIT)
		FROM
			tblSMTerm
		WHERE
			intTermID = @TermId

		RETURN;
	END
ELSE
	BEGIN
		INSERT INTO @returntable(dblTermDiscountRate, ysnTermDiscountExempt)
		VALUES(@ZeroDecimal, CAST(0 AS BIT))
		RETURN;
	END
	
INSERT INTO @returntable(dblTermDiscountRate, ysnTermDiscountExempt)
VALUES(@ZeroDecimal, CAST(0 AS BIT))
RETURN;

END

