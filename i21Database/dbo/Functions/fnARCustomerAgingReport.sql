CREATE FUNCTION [dbo].[fnARCustomerAgingReport]
( 
	  @dtmDateTo			DATETIME = NULL
	, @ysnIncludeCurrent	BIT = 0
)
RETURNS @returntable TABLE (
	  dblTotalAR			NUMERIC(18, 6) NULL
	, dbl0Days				NUMERIC(18, 6) NULL
)
AS
BEGIN	
	SET @dtmDateTo		= CAST(ISNULL(@dtmDateTo, GETDATE()) AS DATE)
	
	INSERT INTO @returntable (
		   dblTotalAR
	     , dbl0Days
	)
	SELECT dblTotalAR	= ISNULL(INVOICES.dblInvoices, 0) + ISNULL(CASHREFUND.dblRefundTotal, 0)
		 , dbl0Days		= ISNULL(INVOICES.dblCurrentInvoices, 0) + ISNULL(CASHREFUND.dblCurrentRefund, 0)
	FROM (
		SELECT dblInvoices			= ISNULL(SUM(I.dblInvoiceTotal * CASE WHEN I.strTransactionType IN ('Overpayment', 'Customer Prepayment', 'Credit Memo') THEN -1 ELSE 1 END), 0) - SUM(ISNULL(PAYMENT.dblPayment, 0)) - SUM(ISNULL(APPAYMENT.dblPayment, 0))
			 , dblCurrentInvoices	= ISNULL(SUM((CASE WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo) <= 0 THEN I.dblInvoiceTotal ELSE 0 END) * CASE WHEN I.strTransactionType IN ('Overpayment', 'Customer Prepayment', 'Credit Memo') THEN -1 ELSE 1 END), 0) - SUM(ISNULL(PAYMENT.dblPayment, 0)) - SUM(ISNULL(APPAYMENT.dblPayment, 0))
		FROM dbo.tblARInvoice I WITH (NOLOCK)
		LEFT JOIN (
			SELECT dblPayment	= ISNULL(SUM(dblPayment + dblDiscount) , 0)
				 , intInvoiceId
			FROM tblARPaymentDetail PD
			INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId
			WHERE P.ysnPosted = 1
			  AND P.ysnProcessedToNSF = 0
			  AND P.ysnInvoicePrepayment = 0
			  AND P.dtmDatePaid <= @dtmDateTo
			GROUP BY intInvoiceId
		) PAYMENT ON I.intInvoiceId = PAYMENT.intInvoiceId
		LEFT JOIN (
			SELECT dblPayment = ISNULL(SUM(PD.dblPayment + PD.dblDiscount), 0)
				 , PD.intInvoiceId
			FROM tblAPPayment P
			INNER JOIN tblAPPaymentDetail PD ON P.intPaymentId = PD.intPaymentId
			INNER JOIN tblARInvoice I ON PD.intInvoiceId = I.intInvoiceId
			WHERE P.ysnPosted = 1
			  AND P.dtmDatePaid <= @dtmDateTo
			GROUP BY PD.intInvoiceId
		) APPAYMENT ON I.intInvoiceId = APPAYMENT.intInvoiceId		
		WHERE ysnPosted = 1
		  AND ysnCancelled = 0	
		  AND strTransactionType <> 'Cash Refund'
		  AND ((I.strType = 'Service Charge' AND (0 = 0 AND GETDATE() < CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmForgiveDate))))) OR (I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
		  AND I.dtmPostDate <= @dtmDateTo
		  AND I.intAccountId IN (
			SELECT A.intAccountId
			FROM dbo.tblGLAccount A WITH (NOLOCK)
			INNER JOIN (SELECT intAccountSegmentId
								, intAccountId
						FROM dbo.tblGLAccountSegmentMapping WITH (NOLOCK)
			) ASM ON A.intAccountId = ASM.intAccountId
			INNER JOIN (SELECT intAccountSegmentId
								, intAccountCategoryId
								, intAccountStructureId
						FROM dbo.tblGLAccountSegment WITH (NOLOCK)
			) GLAS ON ASM.intAccountSegmentId = GLAS.intAccountSegmentId
			INNER JOIN (SELECT intAccountStructureId                 
						FROM dbo.tblGLAccountStructure WITH (NOLOCK)
						WHERE strType = 'Primary'
			) AST ON GLAS.intAccountStructureId = AST.intAccountStructureId
			INNER JOIN (SELECT intAccountCategoryId
								, strAccountCategory 
						FROM dbo.tblGLAccountCategory WITH (NOLOCK)
						WHERE (strAccountCategory IN ('AR Account', 'Customer Prepayments') OR (I.strTransactionType = 'Cash Refund' AND strAccountCategory = 'AP Account'))
			) AC ON GLAS.intAccountCategoryId = AC.intAccountCategoryId
		)
	) INVOICES
	inner join 
	(
		SELECT dblRefundTotal	= SUM(I.dblInvoiceTotal) 
			 , dblCurrentRefund	= SUM(CASE WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, @dtmDateTo) <= 0 THEN I.dblInvoiceTotal ELSE 0 END)
		FROM tblARInvoiceDetail ID
		INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
		WHERE I.strTransactionType = 'Cash Refund'
		  AND I.ysnPosted = 1
		  AND I.dtmPostDate <= @dtmDateTo
		  AND ISNULL(ID.strDocumentNumber, '') <> ''
	) CASHREFUND
	on 1=1
	
	RETURN
			
END