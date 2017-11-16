CREATE VIEW [dbo].[vyuARInvoicePaymentDetail]
AS 
SELECT PAYMENTS.*
	 , I.dblInvoiceTotal
FROM (
	SELECT PD.intInvoiceId
		 , dblTotalPayment		= SUM(ISNULL(dblPayment, 0))
		 , dblTotalDiscount		= SUM(ISNULL(dblDiscount, 0))
		 , strRecordNumber		= P.strRecordNumber
		 , strPaymentMethod		= P.strPaymentMethod
		 , strPaymentInfo		= P.strPaymentInfo
		 , dtmDatePaid			= P.dtmDatePaid
	FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)
	INNER JOIN (
		SELECT intPaymentId
			 , strRecordNumber
			 , strPaymentMethod = PM.strPaymentMethod
			 , strPaymentInfo
			 , dtmDatePaid			 
		FROM dbo.tblARPayment P WITH (NOLOCK)
		INNER JOIN (
			SELECT intPaymentMethodID
				 , strPaymentMethod
			FROM dbo.tblSMPaymentMethod WITH (NOLOCK)
		) PM ON P.intPaymentMethodId = PM.intPaymentMethodID
		WHERE ysnPosted = 1
	) P ON PD.intPaymentId = P.intPaymentId
	GROUP BY PD.intInvoiceId, strRecordNumber, strPaymentMethod, strPaymentInfo, dtmDatePaid

	UNION ALL 

	SELECT PD.intInvoiceId
		 , dblTotalPayment		= SUM(ISNULL(dblPayment, 0))
		 , dblTotalDiscount		= SUM(ISNULL(dblDiscount, 0))
		 , strRecordNumber		= P.strPaymentRecordNum
		 , strPaymentMethod		= NULL
		 , strPaymentInfo		= P.strPaymentInfo
		 , dtmDatePaid			= P.dtmDatePaid
	FROM dbo.tblAPPaymentDetail PD WITH (NOLOCK)
	INNER JOIN (
		SELECT intPaymentId
			 , strPaymentRecordNum
			 , strPaymentInfo
			 , dtmDatePaid
		FROM dbo.tblAPPayment WITH (NOLOCK)
		WHERE ysnPosted = 1
	) P ON PD.intPaymentId = P.intPaymentId
	GROUP BY PD.intInvoiceId, strPaymentRecordNum, dtmDatePaid, strPaymentInfo

	UNION ALL

	SELECT PC.intInvoiceId
		 , dblTotalPayment		= SUM(dblAppliedInvoiceAmount)
		 , dblTotalDiscount		= 0
		 , strRecordNumber		= I.strInvoiceNumber
		 , strPaymentMethod		= NULL
		 , strPaymentInfo		= NULL
		 , dtmDatePaid			= NULL
	FROM dbo.tblARPrepaidAndCredit PC WITH (NOLOCK) 
	INNER JOIN (
		SELECT intInvoiceId
			 , strInvoiceNumber
		FROM dbo.tblARInvoice WITH (NOLOCK)
	) I ON I.intInvoiceId = PC.intPrepaymentId
	WHERE ysnApplied = 1
	GROUP BY PC.intInvoiceId, strInvoiceNumber
) PAYMENTS
INNER JOIN (
	SELECT intInvoiceId
		 , dblInvoiceTotal
	FROM dbo.tblARInvoice
) I ON I.intInvoiceId = PAYMENTS.intInvoiceId