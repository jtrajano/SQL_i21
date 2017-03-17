CREATE TABLE [dbo].[tblARInvoice] (
    [intInvoiceId]					INT				IDENTITY (1, 1)					NOT NULL,
    [strInvoiceNumber]				NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL,
    [strTransactionType]			NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NOT NULL,
	[strType]						NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL DEFAULT 'Standard' ,
    [intEntityCustomerId]			INT												NOT NULL,
    [intCompanyLocationId]			INT												NULL,
    [intAccountId]					INT												NOT NULL,
    [intCurrencyId]					INT												NOT NULL,
    [intTermId]						INT												NOT NULL,
	[intSourceId]					INT												NULL DEFAULT 0,
	[intPeriodsToAccrue]			INT												NULL DEFAULT 1,
    [dtmDate]						DATETIME										NOT NULL,
    [dtmDueDate]					DATETIME										NOT NULL,
    [dtmShipDate]					DATETIME										NULL,
    [dtmPostDate]					DATETIME										NULL,
	[dtmCalculated]					DATETIME										NULL,               
    [dblInvoiceSubtotal]			NUMERIC(18, 6)									NULL DEFAULT 0,
	[dblBaseInvoiceSubtotal]		NUMERIC(18, 6)									NULL DEFAULT 0,
    [dblShipping]					NUMERIC(18, 6)									NULL DEFAULT 0,
	[dblBaseShipping]				NUMERIC(18, 6)									NULL DEFAULT 0,
    [dblTax]						NUMERIC(18, 6)									NULL DEFAULT 0,
	[dblBaseTax]					NUMERIC(18, 6)									NULL DEFAULT 0,
    [dblInvoiceTotal]				NUMERIC(18, 6)									NULL DEFAULT 0,
	[dblBaseInvoiceTotal]			NUMERIC(18, 6)									NULL DEFAULT 0,
    [dblDiscount]					NUMERIC(18, 6)									NULL DEFAULT 0,
	[dblBaseDiscount]				NUMERIC(18, 6)									NULL DEFAULT 0,
	[dblDiscountAvailable]			NUMERIC(18, 6)									NULL DEFAULT 0,	
	[dblBaseDiscountAvailable]		NUMERIC(18, 6)									NULL DEFAULT 0,	
	[dblInterest]					NUMERIC(18, 6)									NULL DEFAULT 0,
	[dblBaseInterest]				NUMERIC(18, 6)									NULL DEFAULT 0,
    [dblAmountDue]					NUMERIC(18, 6)									NULL DEFAULT 0,
	[dblBaseAmountDue]				NUMERIC(18, 6)									NULL DEFAULT 0,
    [dblPayment]					NUMERIC(18, 6)									NULL DEFAULT 0,
	[dblBasePayment]				NUMERIC(18, 6)									NULL DEFAULT 0,
    [intEntitySalespersonId]		INT												NULL,    
    [intFreightTermId]				INT												NULL,
    [intShipViaId]					INT												NULL,
    [intPaymentMethodId]			INT												NULL, 	        
    [strInvoiceOriginId]			NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL,
    [strPONumber]					NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL,
	[strBOLNumber]					NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL,     
	[strDeliverPickup]				NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL,
    [strComments]					NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS	NULL,	
	[strFooterComments]				NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS	NULL,
    [intShipToLocationId]			INT												NULL,
	[strShipToLocationName]			NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL,
    [strShipToAddress]				NVARCHAR (MAX)	COLLATE Latin1_General_CI_AS	NULL,
    [strShipToCity]					NVARCHAR (MAX)	COLLATE Latin1_General_CI_AS	NULL,
    [strShipToState]				NVARCHAR (MAX)	COLLATE Latin1_General_CI_AS	NULL,
    [strShipToZipCode]				NVARCHAR (MAX)	COLLATE Latin1_General_CI_AS	NULL,
    [strShipToCountry]				NVARCHAR (MAX)	COLLATE Latin1_General_CI_AS	NULL,
	[intBillToLocationId]			INT												NULL,
	[strBillToLocationName]			NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL,
    [strBillToAddress]				NVARCHAR (MAX)	COLLATE Latin1_General_CI_AS	NULL,
    [strBillToCity]					NVARCHAR (MAX)	COLLATE Latin1_General_CI_AS	NULL,
    [strBillToState]				NVARCHAR (MAX)	COLLATE Latin1_General_CI_AS	NULL,
    [strBillToZipCode]				NVARCHAR (MAX)	COLLATE Latin1_General_CI_AS	NULL,
    [strBillToCountry]				NVARCHAR (MAX)	COLLATE Latin1_General_CI_AS	NULL,	
    [ysnPosted]						BIT             								NOT NULL	CONSTRAINT [DF_tblARInvoice_ysnPosted] DEFAULT ((0)),
    [ysnPaid]						BIT												NOT NULL	CONSTRAINT [DF_tblARInvoice_ysnPaid] DEFAULT ((0)),
	[ysnProcessed]					BIT												NOT NULL	CONSTRAINT [DF_tblARInvoice_ysnProcessed] DEFAULT ((0)),
	[ysnRecurring]					BIT												NOT NULL	CONSTRAINT [DF_tblARInvoice_ysnTemplate] DEFAULT ((0)),
	[ysnForgiven]					BIT												NOT NULL	CONSTRAINT [DF_tblARInvoice_ysnForgiven] DEFAULT ((0)),
	[ysnCalculated]					BIT												NOT NULL	CONSTRAINT [DF_tblARInvoice_ysnCalculated] DEFAULT ((0)),
	[ysnSplitted]					BIT												NOT NULL	CONSTRAINT [DF_tblARInvoice_ysnSplitted] DEFAULT ((0)),		
	[ysnImpactInventory]			BIT												NOT NULL	CONSTRAINT [DF_tblARInvoice_ysnImpactInventory] DEFAULT ((1)),		
	[ysnImportedFromOrigin]			BIT												NOT NULL	CONSTRAINT [DF_tblARInvoice_ysnImportedFromOrigin] DEFAULT ((0)),		
	[ysnImportedAsPosted]			BIT												NOT NULL	CONSTRAINT [DF_tblARInvoice_ysnImportedAsPosted] DEFAULT ((0)),		
	[intPaymentId]					INT												NULL,
	[intSplitId]					INT												NULL,
	[intDistributionHeaderId]		INT												NULL,
	[intLoadDistributionHeaderId]	INT												NULL,
	[strActualCostId]				NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL,
	[strImportFormat]				NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL,
	[intShipmentId]					INT												NULL,        	
	[intTransactionId]				INT												NULL,
	[intMeterReadingId]        		INT												NULL,
	[intContractHeaderId]      		INT												NULL,
	[intOriginalInvoiceId]			INT												NULL,        	
	[intLoadId]						INT												NULL,        	
	[intEntityId]					INT												NOT NULL	DEFAULT ((0)), 
	[intEntityContactId]			INT												NULL,
	[dblTotalWeight]				NUMERIC(18, 6)									NULL DEFAULT 0,	
	[intDocumentMaintenanceId]      INT												NULL,
	[dblTotalTermDiscount]			NUMERIC(18, 6)									NULL DEFAULT 0,	
	[intTruckDriverId]				INT												NULL,        	
	[intTruckDriverReferenceId]		INT												NULL,        	
	[intConcurrencyId]				INT												NOT NULL	CONSTRAINT [DF_tblARInvoice_intConcurrencyId] DEFAULT ((0)),
    CONSTRAINT [PK_tblARInvoice_intInvoiceId] PRIMARY KEY CLUSTERED ([intInvoiceId] ASC),
    CONSTRAINT [FK_tblARInvoice_tblARCustomer_intEntityCustomerId] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityId]),
	CONSTRAINT [FK_tblARInvoice_tblEMEntity_intEntityId] FOREIGN KEY (intEntityId) REFERENCES tblEMEntity(intEntityId),
	CONSTRAINT [FK_tblARInvoice_tblGLAccount_intAccountId] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARInvoice_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [dbo].[tblSMCompanyLocation] ([intCompanyLocationId]),
	CONSTRAINT [FK_tblARInvoice_tblEMEntityLocation_intShipToLocationId] FOREIGN KEY ([intShipToLocationId]) REFERENCES [dbo].[tblEMEntityLocation] ([intEntityLocationId]),
	CONSTRAINT [FK_tblARInvoice_tblEMEntityLocation_intBillToLocationId] FOREIGN KEY ([intBillToLocationId]) REFERENCES [dbo].[tblEMEntityLocation] ([intEntityLocationId]),
	CONSTRAINT [FK_tblARInvoice_tblSMFreightTerm] FOREIGN KEY ([intFreightTermId]) REFERENCES [tblSMFreightTerms]([intFreightTermId]),
	CONSTRAINT [FK_tblARInvoice_tblSMTerm_intTermId] FOREIGN KEY ([intTermId]) REFERENCES [tblSMTerm]([intTermID]),
	CONSTRAINT [FK_tblARInvoice_tblSMPaymentMethod_intPaymentMethodId] FOREIGN KEY ([intPaymentMethodId]) REFERENCES [tblSMPaymentMethod]([intPaymentMethodID]),
	CONSTRAINT [FK_tblARInvoice_tblSMCurrency_intCurrencyId] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]),
	CONSTRAINT [FK_tblARInvoice_tblARPayment_intPaymentId] FOREIGN KEY ([intPaymentId]) REFERENCES [tblARPayment]([intPaymentId]),
	CONSTRAINT [FK_tblARInvoice_tblEMEntitySplit_intSplitId] FOREIGN KEY ([intSplitId]) REFERENCES [tblEMEntitySplit]([intSplitId]),
	CONSTRAINT [FK_tblARInvoice_tblTRLoadDistributionHeader_intLoadDistributionHeaderId] FOREIGN KEY ([intLoadDistributionHeaderId]) REFERENCES [tblTRLoadDistributionHeader]([intLoadDistributionHeaderId]),
	CONSTRAINT [FK_tblARInvoice_tblLGShipment_intShipmentId] FOREIGN KEY ([intShipmentId]) REFERENCES [tblLGShipment]([intShipmentId]),
	CONSTRAINT [FK_tblARInvoice_tblCFTransaction_intTransactionId] FOREIGN KEY ([intTransactionId]) REFERENCES [tblCFTransaction]([intTransactionId]),
	CONSTRAINT [FK_tblARInvoice_tblMBMeterReading_intMeterReadingId] FOREIGN KEY ([intMeterReadingId]) REFERENCES [tblMBMeterReading]([intMeterReadingId]),
	CONSTRAINT [FK_tblARInvoice_tblCTContractHeader_intContractHeaderId] FOREIGN KEY ([intContractHeaderId]) REFERENCES [tblCTContractHeader]([intContractHeaderId]),
	CONSTRAINT [FK_tblARInvoice_tblLGLoad_intLoadId] FOREIGN KEY ([intLoadId]) REFERENCES [tblLGLoad]([intLoadId]),
	CONSTRAINT [FK_tblARInvoice_tblSCTruckDriverReference_intTruckDriverReferenceId] FOREIGN KEY ([intTruckDriverReferenceId]) REFERENCES [tblSCTruckDriverReference]([intTruckDriverReferenceId]),
	CONSTRAINT [FK_tblARInvoice_tblARSalesperson_intTruckDriverId] FOREIGN KEY ([intTruckDriverId]) REFERENCES [tblARSalesperson]([intEntityId])
);




















GO
CREATE TRIGGER trgInvoiceNumber
ON dbo.tblARInvoice
AFTER INSERT
AS

DECLARE @inserted TABLE(intInvoiceId INT, strTransactionType NVARCHAR(25), strType NVARCHAR(100), intCompanyLocationId INT)
DECLARE @count INT = 0
DECLARE @intInvoiceId INT
DECLARE @intCompanyLocationId INT
DECLARE @InvoiceNumber NVARCHAR(50)
DECLARE @strTransactionType NVARCHAR(25)
DECLARE @strType NVARCHAR(100)
DECLARE @intMaxCount INT = 0
DECLARE @intStartingNumberId INT = 0

INSERT INTO @inserted
SELECT intInvoiceId, strTransactionType, strType, intCompanyLocationId FROM INSERTED WHERE strInvoiceNumber IS NULL ORDER BY intInvoiceId

WHILE((SELECT TOP 1 1 FROM @inserted) IS NOT NULL)
BEGIN
	SET @intStartingNumberId = 19
	
	SELECT TOP 1 @intInvoiceId = intInvoiceId, @strTransactionType = strTransactionType, @strType = strType, @intCompanyLocationId = intCompanyLocationId FROM @inserted

	SELECT TOP 1 @intStartingNumberId = intStartingNumberId 
	FROM tblSMStartingNumber 
	WHERE strTransactionType = CASE WHEN @strTransactionType = 'Prepayment' THEN 'Customer Prepayment' 
									WHEN @strTransactionType = 'Customer Prepayment' THEN 'Customer Prepayment' 
									WHEN @strTransactionType = 'Overpayment' THEN 'Customer Overpayment'
									WHEN @strTransactionType = 'Invoice' AND @strType = 'Service Charge' THEN 'Service Charge'
									ELSE 'Invoice' END
		
	EXEC uspSMGetStartingNumber @intStartingNumberId, @InvoiceNumber OUT, @intCompanyLocationId
	
	IF(@InvoiceNumber IS NOT NULL)
	BEGIN
		IF EXISTS (SELECT NULL FROM tblARInvoice WHERE strInvoiceNumber = @InvoiceNumber)
			BEGIN
				SET @InvoiceNumber = NULL
				DECLARE @intStartIndex INT = 4
				IF (@strTransactionType = 'Prepayment' OR @strTransactionType = 'Customer Prepayment') OR @strTransactionType = 'Overpayment'
					SET @intStartIndex = 5
				
				SELECT @intMaxCount = MAX(CONVERT(INT, SUBSTRING(strInvoiceNumber, @intStartIndex, 10))) FROM tblARInvoice WHERE strTransactionType = @strTransactionType

				UPDATE tblSMStartingNumber SET intNumber = @intMaxCount + 1 WHERE intStartingNumberId = @intStartingNumberId
				EXEC uspSMGetStartingNumber @intStartingNumberId, @InvoiceNumber OUT, @intCompanyLocationId			
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

