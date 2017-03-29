CREATE TABLE [dbo].[tblARPayment] (
    [intPaymentId]			INT             IDENTITY (1, 1) NOT NULL,
    [intEntityCustomerId]   INT             NOT NULL,
    [intCurrencyId]			INT             NOT NULL,
    [dtmDatePaid]			DATETIME        NULL,
    [intAccountId]			INT             NULL,
	[intBankAccountId]		INT             NULL,
    [intPaymentMethodId]	INT             NOT NULL,
    [intLocationId]			INT             NULL,
    [dblAmountPaid]			NUMERIC (18, 6) NULL,
	[dblBaseAmountPaid]		NUMERIC (18, 6) NULL,
    [dblUnappliedAmount]	NUMERIC (18, 6) NULL,
	[dblBaseUnappliedAmount]	NUMERIC (18, 6) NULL,
    [dblOverpayment]		NUMERIC (18, 6) NULL,
	[dblBaseOverpayment]	NUMERIC (18, 6) NULL,
    [dblBalance]			NUMERIC (18, 6) NULL,
    [strRecordNumber]		NVARCHAR (25)   COLLATE Latin1_General_CI_AS NULL,
    [strPaymentInfo]		NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strNotes]				NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
	[ysnApplytoBudget]		BIT				NULL,
	[ysnApplyOnAccount]		BIT				CONSTRAINT [DF_tblARPayment_ysnApplyOnAccount] DEFAULT ((0)) NULL,
    [ysnPosted]				BIT             CONSTRAINT [DF_tblARPayment_ysnPosted] DEFAULT ((0)) NOT NULL,
	[ysnInvoicePrepayment]	BIT             CONSTRAINT [DF_tblARPayment_ysnInvoicePrepayment] DEFAULT ((0)) NOT NULL,
	[ysnImportedFromOrigin]	BIT				CONSTRAINT [DF_tblARPayment_ysnImportedFromOrigin] DEFAULT ((0)) NOT NULL,
	[intEntityId]			INT				NULL DEFAULT ((0)),
	[intWriteOffAccountId]	INT				NULL,
	[strPaymentMethod]		NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
	[dblTotalAR]			NUMERIC (18, 6) NULL,
    [intConcurrencyId]		INT             CONSTRAINT [DF_tblARPayment_intConcurrencyId] DEFAULT ((0)) NOT NULL,    
    CONSTRAINT [PK_tblARPayment_intPaymentId] PRIMARY KEY CLUSTERED ([intPaymentId] ASC),
    CONSTRAINT [FK_tblARPayment_tblARCustomer_intEntityCustomerId] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityId]),
	CONSTRAINT [FK_tblARPayment_tblGLAccount_intAccountId] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARPayment_tblCMBankAccount_intBankAccountId] FOREIGN KEY ([intBankAccountId]) REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountId])
);






GO
CREATE TRIGGER trgReceivePaymentRecordNumber
ON tblARPayment
AFTER INSERT
AS

DECLARE @inserted TABLE(intPaymentId INT, intCompanyLocationId INT)
DECLARE @count INT = 0
DECLARE @intPaymentId INT
DECLARE @intCompanyLocationId INT
DECLARE @PaymentId NVARCHAR(50)
DECLARE @intMaxCount INT = 0

INSERT INTO @inserted
SELECT intPaymentId, intLocationId FROM INSERTED ORDER BY intPaymentId

WHILE((SELECT TOP 1 1 FROM @inserted) IS NOT NULL)
BEGIN	
	SELECT TOP 1 @intPaymentId = intPaymentId, @intCompanyLocationId = intCompanyLocationId FROM @inserted

	EXEC uspSMGetStartingNumber 17, @PaymentId OUT, @intCompanyLocationId
	
	IF(@PaymentId IS NOT NULL)
	BEGIN
		IF EXISTS (SELECT NULL FROM tblARPayment WHERE strRecordNumber = @PaymentId)
			BEGIN
				SET @PaymentId = NULL
				SELECT @intMaxCount = MAX(CONVERT(INT, SUBSTRING(strRecordNumber, 5, 10))) FROM tblARPayment
				UPDATE tblSMStartingNumber SET intNumber = @intMaxCount + 1 WHERE intStartingNumberId = 17
				EXEC uspSMGetStartingNumber 17, @PaymentId OUT, @intCompanyLocationId		
			END
		
		UPDATE tblARPayment
			SET tblARPayment.strRecordNumber = @PaymentId
		FROM tblARPayment A
		WHERE A.intPaymentId = @intPaymentId
	END

	DELETE FROM @inserted
	WHERE intPaymentId = @intPaymentId

END