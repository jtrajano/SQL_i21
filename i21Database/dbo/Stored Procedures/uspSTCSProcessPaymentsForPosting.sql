CREATE PROCEDURE [dbo].[uspSTCSProcessPaymentsForPosting] (
    @intCheckoutId INT
)
AS
SET NOCOUNT ON;

DECLARE @intPaymentOptionId				VARCHAR(MAX)
DECLARE @strDescription					VARCHAR(MAX)
DECLARE @ysnConsMOPForInvoice			BIT
DECLARE @dblAmount						DECIMAL (18,6) = 0
DECLARE @dblConsAmountForInvoice		DECIMAL (18,6) = 0
DECLARE @dblConsAmountForCreditMemo		DECIMAL (18,6) = 0
DECLARE @dblTotalSalesRemaining			DECIMAL (18,6) = 0
DECLARE @dblDealerCommission			DECIMAL (18,6) = 0
DECLARE @dblTotalPaymentRemaining		DECIMAL (18,6) = 0
DECLARE @dblPreviousRemainingPayment	DECIMAL (18,6) = 0
DECLARE @dblFuelSales					DECIMAL (18,6) = 0
DECLARE @ysnPaymentCompleteInSingleMOP	BIT = 0
DECLARE @ysnCommissionDeducted			BIT = 0

DECLARE @intPaymentOptionsPrimId int  
  
DECLARE MY_CURSOR CURSOR   
    LOCAL STATIC READ_ONLY FORWARD_ONLY  
FOR  
  
SELECT intPaymentOptionsPrimId  
FROM  
dbo.tblSTCheckoutPaymentOptions CPO  
WHERE CPO.intCheckoutId = @intCheckoutId
ORDER BY CPO.dblAmount DESC

SELECT 
@dblTotalSalesRemaining = dblTotalSales - dblDealerCommission
,@dblFuelSales = dblTotalSales
,@dblDealerCommission = dblDealerCommission
,@dblTotalPaymentRemaining = dblTotalPaidOuts
FROM tblSTCheckoutHeader
WHERE intCheckoutId = @intCheckoutId

OPEN MY_CURSOR
FETCH NEXT FROM MY_CURSOR INTO @intPaymentOptionsPrimId
WHILE @@FETCH_STATUS = 0
BEGIN 
	SELECT 
	@intPaymentOptionId = CPO.intPaymentOptionId
	, @strDescription = CPO.strDescription
	, @dblAmount = CPO.dblAmount  
	, @ysnConsMOPForInvoice = CPO.ysnConsMOPForInvoice  
	, @dblConsAmountForInvoice = CPO.dblConsAmountForInvoice  
	, @dblConsAmountForCreditMemo = CPO.dblConsAmountForCreditMemo 
	FROM tblSTCheckoutPaymentOptions CPO
	INNER JOIN tblSTCheckoutHeader CH
		ON CH.intCheckoutId = CPO.intCheckoutId
	WHERE CPO.intPaymentOptionsPrimId = @intPaymentOptionsPrimId

	IF (@dblTotalSalesRemaining < @dblAmount) AND @ysnPaymentCompleteInSingleMOP = 0
	BEGIN
		IF @ysnCommissionDeducted = 0
		BEGIN
			SET @dblTotalSalesRemaining = @dblTotalSalesRemaining - (@dblAmount + @dblDealerCommission);	
			SET @ysnCommissionDeducted = 1;
		END
		ELSE
		BEGIN
			SET @dblTotalSalesRemaining = @dblTotalSalesRemaining - @dblAmount;
		END		
		SET @dblTotalPaymentRemaining = @dblTotalPaymentRemaining - @dblAmount;

		UPDATE tblSTCheckoutPaymentOptions SET ysnConsMOPForInvoice = 1, dblConsAmountForInvoice = @dblFuelSales - @dblDealerCommission, dblConsAmountForCreditMemo = (@dblTotalSalesRemaining + @dblDealerCommission) * -1 WHERE intPaymentOptionsPrimId = @intPaymentOptionsPrimId
		SET @ysnPaymentCompleteInSingleMOP = 1;
	END
	ELSE
	BEGIN		
		SET @dblTotalSalesRemaining = @dblTotalSalesRemaining - @dblAmount;	
		SET @dblTotalPaymentRemaining = @dblTotalPaymentRemaining - @dblAmount;

		IF @dblTotalSalesRemaining > 0
		BEGIN
			UPDATE tblSTCheckoutPaymentOptions SET ysnConsMOPForInvoice = 1, dblConsAmountForInvoice = @dblAmount, dblConsAmountForCreditMemo = 0 WHERE intPaymentOptionsPrimId = @intPaymentOptionsPrimId
		END
		ELSE IF @dblTotalSalesRemaining < 0
		BEGIN				
			UPDATE tblSTCheckoutPaymentOptions SET ysnConsMOPForInvoice = 0, dblConsAmountForInvoice = (CASE WHEN @dblPreviousRemainingPayment < 0 THEN 0 ELSE @dblPreviousRemainingPayment END), dblConsAmountForCreditMemo = (CASE WHEN @dblPreviousRemainingPayment < 0 THEN @dblAmount ELSE @dblTotalSalesRemaining * -1 END)  WHERE intPaymentOptionsPrimId = @intPaymentOptionsPrimId 
		END
		SET @ysnPaymentCompleteInSingleMOP = 1;
	END

	SET @dblPreviousRemainingPayment = @dblTotalSalesRemaining;

	FETCH NEXT FROM MY_CURSOR INTO @intPaymentOptionsPrimId
END  
CLOSE MY_CURSOR  
DEALLOCATE MY_CURSOR 

--ROLLBACK