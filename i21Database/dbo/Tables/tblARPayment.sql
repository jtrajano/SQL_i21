CREATE TABLE [dbo].[tblARPayment] (
    [intPaymentId]       INT             IDENTITY (1, 1) NOT NULL,
    [intEntityId]        INT             NOT NULL,
    [intCurrencyId]      INT             NOT NULL,
    [dtmDatePaid]        DATETIME        NULL,
    [intAccountId]       INT             NOT NULL,
    [intPaymentMethodId] INT             NOT NULL,
    [intLocationId]      INT             NULL,
    [dblAmountPaid]      NUMERIC (18, 6) NULL,
    [dblUnappliedAmount] NUMERIC (18, 6) NULL,
    [dblOverpayment]     NUMERIC (18, 6) NULL,
    [dblBalance]         NUMERIC (18, 6) NULL,
    [strRecordNumber]    NVARCHAR (10)   COLLATE Latin1_General_CI_AS NULL,
    [strPaymentInfo]     NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strNotes]           NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [ysnPosted]          BIT             CONSTRAINT [DF_tblARPayment_ysnPosted] DEFAULT ((0)) NOT NULL,
    [intConcurrencyId]   INT             CONSTRAINT [DF_tblARPayment_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblARPayment] PRIMARY KEY CLUSTERED ([intPaymentId] ASC),
    CONSTRAINT [FK_tblARPayment_tblEntity] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntity] ([intEntityId])
);






GO
CREATE TRIGGER trgReceivePaymentRecordNumber
ON tblARPayment
AFTER INSERT
AS

DECLARE @inserted TABLE(intPaymentId INT)
DECLARE @count INT = 0
DECLARE @intPaymentId INT
DECLARE @PaymentId NVARCHAR(50)

INSERT INTO @inserted
SELECT intPaymentId FROM INSERTED ORDER BY intPaymentId

WHILE((SELECT TOP 1 1 FROM @inserted) IS NOT NULL)
BEGIN
	
	--EXEC uspARFixStartingNumbers 17
	--IF(OBJECT_ID('tempdb..#tblTempAPByPassFixStartingNumber') IS NOT NULL) RETURN;
	EXEC uspSMGetStartingNumber 17, @PaymentId OUT

	SELECT TOP 1 @intPaymentId = intPaymentId FROM @inserted
	
	IF(@PaymentId IS NOT NULL)
	BEGIN
		UPDATE tblARPayment
			SET tblARPayment.strRecordNumber = @PaymentId
		FROM tblARPayment A
		WHERE A.intPaymentId = @intPaymentId
		--INNER JOIN INSERTED B ON A.intBillId = B.intBillId
		--WHERE A.strBillId IS NULL
	END

	DELETE FROM @inserted
	WHERE intPaymentId = @intPaymentId

END