CREATE PROCEDURE [dbo].[uspARPrePostPaymentIntegration]
AS
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF


DECLARE @ZeroDecimal DECIMAL(18,6)
SET @ZeroDecimal = 0.000000
DECLARE @OneDecimal DECIMAL(18,6)
SET @OneDecimal = 1.000000
DECLARE @OneHundredDecimal DECIMAL(18,6)
SET @OneHundredDecimal = 100.000000
DECLARE @ZeroBit BIT
SET @ZeroBit = CAST(0 AS BIT)
DECLARE @OneBit BIT
SET @OneBit = CAST(1 AS BIT)

IF EXISTS(SELECT TOP 1 NULL FROM #ARPostPaymentHeader WHERE [ysnPost] = @OneBit)
BEGIN
	DECLARE @DiscouuntedInvoices TABLE (
			intInvoiceId int PRIMARY KEY,
			UNIQUE (intInvoiceId)
		);

	INSERT INTO @DiscouuntedInvoices(intInvoiceId)
	SELECT DISTINCT
		PD.[intInvoiceId] 
	FROM
		tblARPaymentDetail PD 
	INNER JOIN
		#ARPostPaymentDetail P
			ON PD.[intPaymentId] = P.[intTransactionId]
	WHERE
		PD.[dblPayment] <> 0
		AND (ISNULL(PD.[dblDiscount],0) <> 0 OR ISNULL(PD.[dblInterest],0) <> 0)
	GROUP BY
		PD.[intInvoiceId]
	HAVING
		COUNT(PD.[intInvoiceId]) > 1
			
	WHILE(EXISTS(SELECT TOP 1 NULL FROM @DiscouuntedInvoices))
	BEGIN
		DECLARE @DiscountedInvID INT
				,@InvoiceDiscount NUMERIC(18,6) = 0
				,@InvoiceInterest NUMERIC(18,6) = 0
				,@DicountedInvoiceAmountDue NUMERIC(18,6) = 0
				,@DicountedInvoicePayment NUMERIC(18,6) = 0	
					
		SELECT TOP 1 @DiscountedInvID = intInvoiceId FROM @DiscouuntedInvoices
			
		DECLARE @PaymentsWithDiscount TABLE(
					intPaymentId INT,
					intPaymentDetailId INT,
					intInvoiceId INT,
					dblInvoiceTotal NUMERIC(18,6),
					dblAmountDue NUMERIC(18,6),
					dblPayment NUMERIC(18,6),
					dblDiscount  NUMERIC(18,6),
					dblInterest NUMERIC(18,6)
				);
					
		INSERT INTO @PaymentsWithDiscount(intPaymentId, intPaymentDetailId, intInvoiceId, dblInvoiceTotal, dblAmountDue, dblPayment, dblDiscount, dblInterest)
		SELECT
				A.[intPaymentId]
			,B.intPaymentDetailId
			,C.[intInvoiceId]
			,C.[dblInvoiceTotal]
			,C.[dblAmountDue]
			,B.[dblPayment]
			,B.[dblDiscount]
			,B.[dblInterest] 
		FROM
			tblARPayment A
		INNER JOIN
			tblARPaymentDetail B
				ON A.[intPaymentId] = B.[intPaymentId]
		INNER JOIN
			tblARInvoice C
				ON B.[intInvoiceId] = C.[intInvoiceId]
		INNER JOIN
			#ARPostPaymentDetail P
				ON A.[intPaymentId] = P.[intTransactionId]
		WHERE
			C.[intInvoiceId] = @DiscountedInvID
		ORDER BY
			P.[intTransactionId]
				
		WHILE EXISTS(SELECT TOP 1 NULL FROM @PaymentsWithDiscount)
		BEGIN
			DECLARE @DiscountepPaymetID INT
					,@DiscountepPaymetDetailID INT
			SELECT TOP 1 
				@DiscountepPaymetID = intPaymentId
				,@DiscountepPaymetDetailID = intPaymentDetailId
				,@DicountedInvoiceAmountDue = dblAmountDue
				,@InvoiceDiscount = @InvoiceDiscount + dblDiscount
				,@InvoiceInterest = @InvoiceInterest + dblInterest
				,@DicountedInvoicePayment = @DicountedInvoicePayment + dblPayment 
			FROM
				@PaymentsWithDiscount
			ORDER BY intPaymentId
				
			IF @DicountedInvoiceAmountDue <> ((@DicountedInvoicePayment - @InvoiceInterest) + @InvoiceDiscount)
			BEGIN
				UPDATE tblARPaymentDetail
				SET
						dblDiscount = 0.00
					,dblInterest = 0.00
				WHERE
					intPaymentDetailId = @DiscountepPaymetDetailID
						
				SET @InvoiceDiscount = 0										
				SET @InvoiceInterest = 0										
			END									
			SET @DicountedInvoiceAmountDue = @DicountedInvoiceAmountDue - ((@DicountedInvoicePayment - @InvoiceInterest) + @InvoiceDiscount)
			DELETE FROM @PaymentsWithDiscount WHERE intPaymentId = @DiscountepPaymetID	
		END 						
		DELETE FROM @DiscouuntedInvoices WHERE intInvoiceId = @DiscountedInvID							
	END
END

RETURN 1
