CREATE FUNCTION [dbo].[fnSTTotalAmountOfDepositablePaymentMethods] 
(
	@intCheckoutId AS INT
)
RETURNS DECIMAL(18,2)
AS BEGIN

    DECLARE @dblTotalAmountOfDepositablePaymentMethods DECIMAL(18,2) = 0

    SELECT          @dblTotalAmountOfDepositablePaymentMethods = ISNULL(SUM(a.dblAmount),0)
    FROM            tblSTCheckoutPaymentOptions a
    INNER JOIN      tblSTPaymentOption b
    ON              a.intPaymentOptionId = b.intPaymentOptionId
    WHERE           b.ysnDepositable = 1 AND
                    a.intCheckoutId = @intCheckoutId

    RETURN @dblTotalAmountOfDepositablePaymentMethods
END