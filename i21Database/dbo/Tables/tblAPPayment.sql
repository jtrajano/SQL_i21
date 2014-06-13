CREATE TABLE [dbo].[tblAPPayment] (
    [intPaymentId]        INT             IDENTITY (1, 1) NOT NULL,
    [intAccountId]        INT             NOT NULL,
    [intBankAccountId]    INT             NOT NULL,
    [intPaymentMethodId]    INT             NOT NULL,
    [intCurrencyId]       INT             NOT NULL,
    [strVendorId]         NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strPaymentInfo]      NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strNotes]            NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [dtmDatePaid]         DATETIME        NOT NULL,
    [dblCredit]           DECIMAL (18, 2) NOT NULL,
    [dblAmountPaid]       DECIMAL (18, 2) NOT NULL,
    [dblUnappliedAmount]  DECIMAL (18, 2) NOT NULL,
    [ysnPosted]           BIT             NOT NULL,
    [strPaymentRecordNum] NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [dblWithheldAmount]   DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [intUserId]           INT             NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT 0, 
    [intEntityId] INT NOT NULL DEFAULT 0, 
    CONSTRAINT [PK_dbo.tblAPPayments] PRIMARY KEY CLUSTERED ([intPaymentId] ASC)
);


GO
CREATE TRIGGER trgPaymentRecordNumber
ON tblAPPayment
AFTER INSERT
AS
	DECLARE @PaymentId NVARCHAR(50)
	EXEC uspAPFixStartingNumbers 8
	EXEC uspSMGetStartingNumber 8, @PaymentId OUT
	
	IF(@PaymentId IS NOT NULL)
	BEGIN
		UPDATE tblAPPayment
			SET tblAPPayment.strPaymentRecordNum = @PaymentId
		FROM tblAPPayment A
			INNER JOIN INSERTED B ON A.intPaymentId = B.intPaymentId
	END
