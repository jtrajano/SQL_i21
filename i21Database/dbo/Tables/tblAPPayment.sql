CREATE TABLE [dbo].[tblAPPayment] (
    [intPaymentId]        INT             IDENTITY (1, 1) NOT NULL,
    [intAccountId]        INT             NOT NULL,
    [intBankAccountId]    INT             NOT NULL,
    [intPaymentMethodId]    INT             NOT NULL,
    [intCurrencyId]       INT             NOT NULL,
    [strPaymentInfo]      NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strNotes]            NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [dtmDatePaid]         DATETIME        NOT NULL,
    [dblAmountPaid]       DECIMAL (18, 2) NOT NULL,
    [dblUnapplied]  DECIMAL (18, 2) NOT NULL,
    [ysnPosted]           BIT             NOT NULL,
    [strPaymentRecordNum] NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [dblWithheld]   DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [intUserId]           INT             NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT 0, 
    [intEntityId] INT NOT NULL,
    [intVendorId] INT NOT NULL,
    [ysnOrigin] BIT NOT NULL DEFAULT 0,
    CONSTRAINT [PK_dbo.tblAPPayments] PRIMARY KEY CLUSTERED ([intPaymentId] ASC), 
    CONSTRAINT [FK_tblAPPayment_tblAPVendor] FOREIGN KEY ([intVendorId]) REFERENCES [tblAPVendor]([intVendorId]),
	CONSTRAINT [FK_dbo.tblAPPayment_dbo.tblEntity_intEntityId] FOREIGN KEY (intEntityId) REFERENCES tblEntity(intEntityId),
	CONSTRAINT [FK_dbo.tblAPPayment_dbo.tblGLAccount_intAccountId] FOREIGN KEY (intAccountId) REFERENCES tblGLAccount(intAccountId)
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
