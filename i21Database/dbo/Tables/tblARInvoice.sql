CREATE TABLE [dbo].[tblARInvoice] (
    [intInvoiceId]         INT             IDENTITY (1, 1) NOT NULL,
    [strInvoiceNumber]     NVARCHAR (25)   COLLATE Latin1_General_CI_AS NULL,
    [intCustomerId]        INT             NOT NULL,
    [dtmDate]              DATETIME        NOT NULL,
    [dtmDueDate]           DATETIME        NOT NULL,
    [intCurrencyId]        INT             NOT NULL,
    [intCompanyLocationId] INT             NULL,
    [intSalespersonId]     INT             NOT NULL,
    [dtmShipDate]          DATETIME        NULL,
    [intShipViaId]         INT             NOT NULL,
    [strPONumber]          NVARCHAR (25)   NULL,
    [intTermId]            INT             NOT NULL,
    [dblInvoiceSubtotal]   NUMERIC (18, 6) NULL,
    [dblShipping]          NUMERIC (18, 6) NULL,
    [dblTax]               NUMERIC (18, 6) NULL,
    [dblInvoiceTotal]      NUMERIC (18, 6) NULL,
    [dblDiscount]          NUMERIC (18, 6) NULL,
    [dblAmountDue]         NUMERIC (18, 6) NULL,
    [dblPayment]           NUMERIC (18, 6) NULL,
    [strTransactionType]   NVARCHAR (25)   COLLATE Latin1_General_CI_AS NOT NULL,
    [intPaymentMethodId]   INT             NOT NULL,
    [strComments]          NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [intAccountId]         INT             NOT NULL,
    [ysnPosted]            BIT             CONSTRAINT [DF_tblARInvoice_ysnPosted] DEFAULT ((0)) NOT NULL,
    [ysnPaid]              BIT             CONSTRAINT [DF_tblARInvoice_ysnPaid] DEFAULT ((0)) NOT NULL,
    [strShipToAddress]     NVARCHAR (100)  NULL,
    [strShipToCity]        NVARCHAR (30)   NULL,
    [strShipToState]       NVARCHAR (50)   NULL,
    [strShipToZipCode]     NVARCHAR (12)   NULL,
    [strShipToCountry]     NVARCHAR (25)   NULL,
    [strBillToAddress]     NVARCHAR (100)  NULL,
    [strBillToCity]        NVARCHAR (30)   NULL,
    [strBillToState]       NVARCHAR (50)   NULL,
    [strBillToZipCode]     NVARCHAR (12)   NULL,
    [strBillToCountry]     NVARCHAR (25)   NULL,
    [intConcurrencyId]     INT             CONSTRAINT [DF_tblARInvoice_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblARInvoice] PRIMARY KEY CLUSTERED ([intInvoiceId] ASC),
    CONSTRAINT [FK_tblARInvoice_tblEntity] FOREIGN KEY ([intCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intCustomerId])
);


















GO
CREATE TRIGGER trgInvoiceNumber
ON dbo.tblARInvoice
AFTER INSERT
AS

DECLARE @inserted TABLE(intInvoiceId INT)
DECLARE @count INT = 0
DECLARE @intInvoiceId INT
DECLARE @InvoiceNumber NVARCHAR(50)

INSERT INTO @inserted
SELECT intInvoiceId FROM INSERTED ORDER BY intInvoiceId

WHILE((SELECT TOP 1 1 FROM @inserted) IS NOT NULL)
BEGIN
	
	--EXEC uspARFixStartingNumbers 17
	--IF(OBJECT_ID('tempdb..#tblTempAPByPassFixStartingNumber') IS NOT NULL) RETURN;
	EXEC uspSMGetStartingNumber 19, @InvoiceNumber OUT

	SELECT TOP 1 @intInvoiceId = intInvoiceId FROM @inserted
	
	IF(@InvoiceNumber IS NOT NULL)
	BEGIN
		UPDATE tblARInvoice
			SET tblARInvoice.strInvoiceNumber = @InvoiceNumber
		FROM tblARInvoice A
		WHERE A.intInvoiceId = @intInvoiceId
	END

	DELETE FROM @inserted
	WHERE intInvoiceId = @intInvoiceId

END
GO
CREATE NONCLUSTERED INDEX [PIndex2]
    ON [dbo].[tblARInvoice]([dblInvoiceSubtotal] ASC, [dblShipping] ASC, [dblTax] ASC, [dblInvoiceTotal] ASC, [dblDiscount] ASC, [dblAmountDue] ASC, [dblPayment] ASC, [strTransactionType] ASC, [intPaymentMethodId] ASC, [strComments] ASC, [intAccountId] ASC, [ysnPosted] ASC, [ysnPaid] ASC);


GO
CREATE NONCLUSTERED INDEX [PIndex]
    ON [dbo].[tblARInvoice]([strInvoiceNumber] ASC, [intCustomerId] ASC, [dtmDate] ASC, [dtmDueDate] ASC, [intCurrencyId] ASC, [intCompanyLocationId] ASC, [intSalespersonId] ASC, [dtmShipDate] ASC, [intShipViaId] ASC, [strPONumber] ASC, [intTermId] ASC);

