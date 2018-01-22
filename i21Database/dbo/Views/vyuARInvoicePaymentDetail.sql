CREATE VIEW [dbo].[vyuARInvoicePaymentDetail]
AS 
SELECT PAYMENTS.*
	 , I.dblInvoiceTotal
	 , I.dblAmountDue
	 , I.dblDiscount
	 , I.dtmDueDate
FROM dbo.tblARInvoice I 
INNER JOIN (
	SELECT PD.intInvoiceId
		 , P.intPaymentId
		 , dblTotalPayment		= ISNULL(dblPayment, 0)
		 , strRecordNumber		= P.strRecordNumber
		 , strPaymentMethod		= P.strPaymentMethod
		 , strPaymentInfo		= P.strPaymentInfo
		 , dtmDatePaid			= P.dtmDatePaid
		 , strPaymentSource		= 'AR Payment'
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
		 , strPaymentSource		= 'AP Payment'
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