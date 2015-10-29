CREATE TABLE [dbo].[tblARInvoice] (
    [intInvoiceId]				INT				IDENTITY (1, 1)					NOT NULL,
    [strInvoiceNumber]			NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL,
    [strTransactionType]		NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NOT NULL,
	[strType]					NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL DEFAULT 'Standard' ,
    [intEntityCustomerId]		INT												NOT NULL,
    [intCompanyLocationId]		INT												NULL,
    [intAccountId]				INT												NOT NULL,
    [intCurrencyId]				INT												NOT NULL,
    [intTermId]					INT												NOT NULL,
    [dtmDate]					DATETIME										NOT NULL,
    [dtmDueDate]				DATETIME										NOT NULL,
    [dtmShipDate]				DATETIME										NULL,
    [dtmPostDate]				DATETIME										NULL,               
    [dblInvoiceSubtotal]		NUMERIC(18, 6)									NULL,
    [dblShipping]				NUMERIC(18, 6)									NULL,
    [dblTax]					NUMERIC(18, 6)									NULL,
    [dblInvoiceTotal]			NUMERIC(18, 6)									NULL,
    [dblDiscount]				NUMERIC(18, 6)									NULL,
    [dblAmountDue]				NUMERIC(18, 6)									NULL,
    [dblPayment]				NUMERIC(18, 6)									NULL,
    [intEntitySalespersonId]	INT												NULL,    
    [intFreightTermId]			INT												NULL,
    [intShipViaId]				INT												NULL,
    [intPaymentMethodId]		INT												NULL, 	        
    [strInvoiceOriginId]		NVARCHAR(8)		COLLATE Latin1_General_CI_AS	NULL,
    [strPONumber]				NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL,
	[strBOLNumber]				NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL,     
	[strDeliverPickup]			NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL,
    [strComments]				NVARCHAR(500)	COLLATE Latin1_General_CI_AS	NULL,	
    [intShipToLocationId]		INT												NULL,
	[strShipToLocationName]		NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL,
    [strShipToAddress]			NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL,
    [strShipToCity]				NVARCHAR(30)	COLLATE Latin1_General_CI_AS	NULL,
    [strShipToState]			NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL,
    [strShipToZipCode]			NVARCHAR(12)	COLLATE Latin1_General_CI_AS	NULL,
    [strShipToCountry]			NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL,
	[intBillToLocationId]		INT												NULL,
	[strBillToLocationName]		NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL,
    [strBillToAddress]			NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL,
    [strBillToCity]				NVARCHAR(30)	COLLATE Latin1_General_CI_AS	NULL,
    [strBillToState]			NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL,
    [strBillToZipCode]			NVARCHAR(12)	COLLATE Latin1_General_CI_AS	NULL,
    [strBillToCountry]			NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL,	
    [ysnPosted]					BIT             								NOT NULL	CONSTRAINT [DF_tblARInvoice_ysnPosted] DEFAULT ((0)),
    [ysnPaid]					BIT												NOT NULL	CONSTRAINT [DF_tblARInvoice_ysnPaid] DEFAULT ((0)),
	[ysnTemplate]				BIT												NOT NULL	CONSTRAINT [DF_tblARInvoice_ysnTemplate] DEFAULT ((0)),
	[ysnForgiven]				BIT												NOT NULL	CONSTRAINT [DF_tblARInvoice_ysnForgiven] DEFAULT ((0)),
	[ysnCalculated]				BIT												NOT NULL	CONSTRAINT [DF_tblARInvoice_ysnCalculated] DEFAULT ((0)),
	[ysnSplitted]				BIT												NOT NULL	CONSTRAINT [DF_tblARInvoice_ysnSplitted] DEFAULT ((0)),		
	[intPaymentId]				INT												NULL,
	[intSplitId]				INT												NULL,
	[intDistributionHeaderId]	INT												NULL,
	[strActualCostId]			NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL,
	[intShipmentId]				INT												NULL,        	
	[intTransactionId]			INT												NULL,        	
	[intEntityId]				INT												NOT NULL	DEFAULT ((0)), 
	[intConcurrencyId]			INT												NOT NULL	CONSTRAINT [DF_tblARInvoice_intConcurrencyId] DEFAULT ((0)),
    CONSTRAINT [PK_tblARInvoice_intInvoiceId] PRIMARY KEY CLUSTERED ([intInvoiceId] ASC),
    CONSTRAINT [FK_tblARInvoice_tblARCustomer_intEntityCustomerId] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityCustomerId]),
	CONSTRAINT [FK_tblARInvoice_tblEntity_intEntityId] FOREIGN KEY (intEntityId) REFERENCES tblEntity(intEntityId),
	CONSTRAINT [FK_tblARInvoice_tblGLAccount_intAccountId] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARInvoice_tblEntityLocation_intShipToLocationId] FOREIGN KEY ([intShipToLocationId]) REFERENCES [dbo].[tblEntityLocation] ([intEntityLocationId]),
	CONSTRAINT [FK_tblARInvoice_tblEntityLocation_intBillToLocationId] FOREIGN KEY ([intBillToLocationId]) REFERENCES [dbo].[tblEntityLocation] ([intEntityLocationId]),
	CONSTRAINT [FK_tblARInvoice_tblSMFreightTerm] FOREIGN KEY ([intFreightTermId]) REFERENCES [tblSMFreightTerms]([intFreightTermId]),
	CONSTRAINT [FK_tblARInvoice_tblSMTerm_intTermId] FOREIGN KEY ([intTermId]) REFERENCES [tblSMTerm]([intTermID]),
	CONSTRAINT [FK_tblARInvoice_tblARPayment_intPaymentId] FOREIGN KEY ([intPaymentId]) REFERENCES [tblARPayment]([intPaymentId]),
	CONSTRAINT [FK_tblARInvoice_tblEntitySplit_intSplitId] FOREIGN KEY ([intSplitId]) REFERENCES [tblEntitySplit]([intSplitId]),
	CONSTRAINT [FK_tblARInvoice_tblTRDistributionHeader_intDistributionHeaderId] FOREIGN KEY ([intDistributionHeaderId]) REFERENCES [tblTRDistributionHeader]([intDistributionHeaderId]),
	CONSTRAINT [FK_tblARInvoice_tblLGShipment_intShipmentId] FOREIGN KEY ([intShipmentId]) REFERENCES [tblLGShipment]([intShipmentId]),
	CONSTRAINT [FK_tblARInvoice_tblCFTransaction_intTransactionId] FOREIGN KEY ([intTransactionId]) REFERENCES [tblCFTransaction]([intTransactionId]),
);




















GO
CREATE TRIGGER trgInvoiceNumber
ON dbo.tblARInvoice
AFTER INSERT
AS

DECLARE @inserted TABLE(intInvoiceId INT, strTransactionType NVARCHAR(25))
DECLARE @count INT = 0
DECLARE @intInvoiceId INT
DECLARE @InvoiceNumber NVARCHAR(50)
DECLARE @strTransactionType NVARCHAR(25)
DECLARE @intMaxCount INT = 0
DECLARE @intStartingNumberId INT = 0

INSERT INTO @inserted
SELECT intInvoiceId, strTransactionType FROM INSERTED ORDER BY intInvoiceId

WHILE((SELECT TOP 1 1 FROM @inserted) IS NOT NULL)
BEGIN
	SET @intStartingNumberId = 19
	
	SELECT TOP 1 @intInvoiceId = intInvoiceId, @strTransactionType = strTransactionType FROM @inserted

	SET @intStartingNumberId = CASE WHEN @strTransactionType = 'Prepayment' THEN 64 
									WHEN @strTransactionType = 'Overpayment' THEN 65
									WHEN @strTransactionType = 'Provisional Invoice' THEN 81
									ELSE 19 END
		
	EXEC uspSMGetStartingNumber @intStartingNumberId, @InvoiceNumber OUT	
	
	IF(@InvoiceNumber IS NOT NULL)
	BEGIN
		IF EXISTS (SELECT NULL FROM tblARInvoice WHERE strInvoiceNumber = @InvoiceNumber)
			BEGIN
				SET @InvoiceNumber = NULL
				DECLARE @intStartIndex INT = 4
				IF @strTransactionType = 'Prepayment' OR @strTransactionType = 'Overpayment'
					SET @intStartIndex = 5
				
				SELECT @intMaxCount = MAX(CONVERT(INT, SUBSTRING(strInvoiceNumber, @intStartIndex, 10))) FROM tblARInvoice WHERE strTransactionType = @strTransactionType

				UPDATE tblSMStartingNumber SET intNumber = @intMaxCount + 1 WHERE intStartingNumberId = @intStartingNumberId
				EXEC uspSMGetStartingNumber @intStartingNumberId, @InvoiceNumber OUT				
			END

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
    ON [dbo].[tblARInvoice]([dblInvoiceSubtotal] ASC, [dblShipping] ASC, [dblTax] ASC, [dblInvoiceTotal] ASC, [dblDiscount] ASC, [dblAmountDue] ASC, [dblPayment] ASC, [strTransactionType] ASC, [intPaymentMethodId] ASC, [intAccountId] ASC, [ysnPosted] ASC, [ysnPaid] ASC);


GO
CREATE NONCLUSTERED INDEX [PIndex]
    ON [dbo].[tblARInvoice]([strInvoiceNumber] ASC, [intEntityCustomerId] ASC, [dtmDate] ASC, [dtmDueDate] ASC, [intCurrencyId] ASC, [intCompanyLocationId] ASC, [intEntitySalespersonId] ASC, [dtmShipDate] ASC, [intShipViaId] ASC, [strPONumber] ASC, [intTermId] ASC);

