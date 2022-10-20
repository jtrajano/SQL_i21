﻿CREATE VIEW [dbo].[vyuARInvoicePaymentDetail]
AS 
SELECT intInvoiceId			= I.intInvoiceId
	 , dblInvoiceTotal		= I.dblInvoiceTotal
	 , dblAmountDue			= CASE WHEN I.ysnPaid = 0 THEN I.dblAmountDue - I.dblDiscountAvailable ELSE I.dblAmountDue END
	 , dblDiscount			= I.dblDiscountAvailable
	 , dtmDueDate			= I.dtmDueDate
	 , intPaymentId			= PAYMENTS.intPaymentId
	 , dblTotalPayment		= CASE WHEN I.strTransactionType = 'Cash' AND ISNULL(PAYMENTS.dblTotalPayment, 0.00) = 0
								THEN ISNULL((CASE WHEN I.ysnPaid = 0 THEN I.dblAmountDue - I.dblDiscountAvailable ELSE I.dblAmountDue END), 0) 
								ELSE ISNULL(PAYMENTS.dblTotalPayment, 0.00) END
	 , strRecordNumber		= PAYMENTS.strRecordNumber
	 , strPaymentMethod		= CASE WHEN I.strTransactionType = 'Cash' AND PAYMENTS.strPaymentMethod IS NULL
								THEN I.strTransactionType 
								ELSE PAYMENTS.strPaymentMethod END
	 , strPaymentInfo		= PAYMENTS.strPaymentInfo
	 , dtmDatePaid			= CASE WHEN I.strTransactionType = 'Cash'  AND PAYMENTS.dtmDatePaid IS NULL
								THEN I.dtmDate 
								ELSE PAYMENTS.dtmDatePaid END
	 , strPaymentSource		= PAYMENTS.strPaymentSource
	 , dtmDiscountDate      = DATEADD(DAYOFYEAR, T.intDiscountDay, I.dtmDate) 
FROM dbo.tblARInvoice I WITH (NOLOCK)
LEFT JOIN dbo.tblSMTerm T WITH (NOLOCK) ON I.intTermId = T.intTermID
LEFT JOIN (
	SELECT PD.intInvoiceId
		 , P.intPaymentId
		 , dblTotalPayment		= ISNULL(dblPayment, 0)
		 , strRecordNumber		= P.strRecordNumber
		 , strPaymentMethod		= P.strPaymentMethod
		 , strPaymentInfo		= P.strPaymentInfo
		 , dtmDatePaid			= P.dtmDatePaid
		 , strPaymentSource		= 'AR Payment' COLLATE Latin1_General_CI_AS
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

	UNION ALL 

	SELECT PD.intInvoiceId
	     , P.intPaymentId
		 , dblTotalPayment		= ISNULL(dblPayment, 0)
		 , strRecordNumber		= P.strPaymentRecordNum
		 , strPaymentMethod		= NULL
		 , strPaymentInfo		= P.strPaymentInfo
		 , dtmDatePaid			= P.dtmDatePaid
		 , strPaymentSource		= 'AP Payment' COLLATE Latin1_General_CI_AS
	FROM dbo.tblAPPaymentDetail PD WITH (NOLOCK)
	INNER JOIN (
		SELECT intPaymentId
			 , strPaymentRecordNum
			 , strPaymentInfo
			 , dtmDatePaid			 
		FROM dbo.tblAPPayment WITH (NOLOCK)
		WHERE ysnPosted = 1
	) P ON PD.intPaymentId = P.intPaymentId
) PAYMENTS ON I.intInvoiceId = PAYMENTS.intInvoiceId