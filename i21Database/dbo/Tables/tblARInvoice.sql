CREATE TABLE [dbo].[tblARInvoice] (
    [intInvoiceId]         INT             IDENTITY (1, 1) NOT NULL,
    [strInvoiceNumber]     NVARCHAR (25)   COLLATE Latin1_General_CI_AS NULL,
    [strInvoiceOriginId]   NVARCHAR (8)     COLLATE Latin1_General_CI_AS NULL,
    [intEntityCustomerId]        INT             NOT NULL,
    [dtmDate]              DATETIME        NOT NULL,
    [dtmDueDate]           DATETIME        NOT NULL,
    [intCurrencyId]        INT             NOT NULL,
    [intCompanyLocationId] INT             NULL,
    [intEntitySalespersonId]     INT       NULL,
    [dtmShipDate]          DATETIME        NULL,
    [intShipViaId]         INT             NULL,
    [strPONumber]          NVARCHAR (25)    COLLATE Latin1_General_CI_AS NULL,
    [intTermId]            INT             NOT NULL,
    [dblInvoiceSubtotal]   NUMERIC (18, 6) NULL,
    [dblShipping]          NUMERIC (18, 6) NULL,
    [dblTax]               NUMERIC (18, 6) NULL,
    [dblInvoiceTotal]      NUMERIC (18, 6) NULL,
    [dblDiscount]          NUMERIC (18, 6) NULL,
    [dblAmountDue]         NUMERIC (18, 6) NULL,
    [dblPayment]           NUMERIC (18, 6) NULL,
    [strTransactionType]   NVARCHAR (25)   COLLATE Latin1_General_CI_AS NOT NULL,
	[strType]			   NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL ,
    [intPaymentMethodId]   INT             NOT NULL,
    [strComments]          NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [intAccountId]         INT             NOT NULL,
	[dtmPostDate]          DATETIME        NULL,
    [ysnPosted]            BIT             CONSTRAINT [DF_tblARInvoice_ysnPosted] DEFAULT ((0)) NOT NULL,
    [ysnPaid]              BIT             CONSTRAINT [DF_tblARInvoice_ysnPaid] DEFAULT ((0)) NOT NULL,
	[ysnTemplate]          BIT             CONSTRAINT [DF_tblARInvoice_ysnTemplate] DEFAULT ((0)) NOT NULL,
	[ysnForgiven]		   BIT			   CONSTRAINT [DF_tblARInvoice_ysnForgiven] DEFAULT ((0)) NOT NULL,
	[ysnCalculated]		   BIT			   CONSTRAINT [DF_tblARInvoice_ysnCalculated] DEFAULT ((0)) NOT NULL,
	[intFreightTermId]	   INT				NULL, 
	[strDeliverPickup]     NVARCHAR (100)   COLLATE Latin1_General_CI_AS NULL,
	[intShipToLocationId]  INT             NULL,
	[strShipToLocationName]     NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strShipToAddress]     NVARCHAR (100)   COLLATE Latin1_General_CI_AS NULL,
    [strShipToCity]        NVARCHAR (30)    COLLATE Latin1_General_CI_AS NULL,
    [strShipToState]       NVARCHAR (50)    COLLATE Latin1_General_CI_AS NULL,
    [strShipToZipCode]     NVARCHAR (12)    COLLATE Latin1_General_CI_AS NULL,
    [strShipToCountry]     NVARCHAR (25)    COLLATE Latin1_General_CI_AS NULL,
	[intBillToLocationId]  INT             NULL,
	[strBillToLocationName]     NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strBillToAddress]     NVARCHAR (100)   COLLATE Latin1_General_CI_AS NULL,
    [strBillToCity]        NVARCHAR (30)    COLLATE Latin1_General_CI_AS NULL,
    [strBillToState]       NVARCHAR (50)    COLLATE Latin1_General_CI_AS NULL,
    [strBillToZipCode]     NVARCHAR (12)    COLLATE Latin1_General_CI_AS NULL,
    [strBillToCountry]     NVARCHAR (25)    COLLATE Latin1_General_CI_AS NULL,	
    [intConcurrencyId]     INT             CONSTRAINT [DF_tblARInvoice_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    [intEntityId]		   INT             NOT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblARInvoice_intInvoiceId] PRIMARY KEY CLUSTERED ([intInvoiceId] ASC),
    CONSTRAINT [FK_tblARInvoice_tblARCustomer_intEntityCustomerId] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityCustomerId]),
	CONSTRAINT [FK_tblARInvoice_tblEntity_intEntityId] FOREIGN KEY (intEntityId) REFERENCES tblEntity(intEntityId),
	CONSTRAINT [FK_tblARInvoice_tblGLAccount_intAccountId] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARInvoice_tblEntityLocation_intShipToLocationId] FOREIGN KEY ([intShipToLocationId]) REFERENCES [dbo].[tblEntityLocation] ([intEntityLocationId]),
	CONSTRAINT [FK_tblARInvoice_tblEntityLocation_intBillToLocationId] FOREIGN KEY ([intBillToLocationId]) REFERENCES [dbo].[tblEntityLocation] ([intEntityLocationId]),
	CONSTRAINT [FK_tblARInvoice_tblSMFreightTerm] FOREIGN KEY ([intFreightTermId]) REFERENCES [tblSMFreightTerms]([intFreightTermId]),
	CONSTRAINT [FK_tblARInvoice_tblSMTerm_intTermId] FOREIGN KEY ([intTermId]) REFERENCES [tblSMTerm]([intTermID]),
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
    ON [dbo].[tblARInvoice]([strInvoiceNumber] ASC, [intEntityCustomerId] ASC, [dtmDate] ASC, [dtmDueDate] ASC, [intCurrencyId] ASC, [intCompanyLocationId] ASC, [intEntitySalespersonId] ASC, [dtmShipDate] ASC, [intShipViaId] ASC, [strPONumber] ASC, [intTermId] ASC);

