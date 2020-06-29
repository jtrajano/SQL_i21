CREATE TABLE [dbo].[tblARInvoice] (
    [intInvoiceId]						INT				IDENTITY (1, 1)					NOT NULL,
    [strInvoiceNumber]					NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL,
    [strTransactionType]				NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NOT NULL,
	[strType]							NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL DEFAULT 'Standard' ,
    [intEntityCustomerId]				INT												NOT NULL,
    [intCompanyLocationId]				INT												NULL,
    [intAccountId]						INT												NOT NULL,
    [intCurrencyId]						INT												NOT NULL,
    [intTermId]							INT												NOT NULL,	
	[intSourceId]						INT												NULL DEFAULT 0,
	[intPeriodsToAccrue]				INT												NULL DEFAULT 1,
    [dtmDate]							DATETIME										NOT NULL,
    [dtmDueDate]						DATETIME										NOT NULL,
    [dtmShipDate]						DATETIME										NULL,
    [dtmPostDate]						DATETIME										NULL,
	[dtmCalculated]						DATETIME										NULL,               
	[dtmExportedDate]					DATETIME										NULL,
    [dblInvoiceSubtotal]				NUMERIC(18, 6)									NULL DEFAULT 0,
	[dblBaseInvoiceSubtotal]			NUMERIC(18, 6)									NULL DEFAULT 0,
    [dblShipping]						NUMERIC(18, 6)									NULL DEFAULT 0,
	[dblBaseShipping]					NUMERIC(18, 6)									NULL DEFAULT 0,
    [dblTax]							NUMERIC(18, 6)									NULL DEFAULT 0,
	[dblBaseTax]						NUMERIC(18, 6)									NULL DEFAULT 0,
    [dblInvoiceTotal]					NUMERIC(18, 6)									NULL DEFAULT 0,
	[dblBaseInvoiceTotal]				NUMERIC(18, 6)									NULL DEFAULT 0,
    [dblDiscount]						NUMERIC(18, 6)									NULL DEFAULT 0,
	[dblBaseDiscount]					NUMERIC(18, 6)									NULL DEFAULT 0,	
	[dblDiscountAvailable]				NUMERIC(18, 6)									NULL DEFAULT 0,	
	[dblBaseDiscountAvailable]			NUMERIC(18, 6)									NULL DEFAULT 0,	
	[dblTotalTermDiscount]				NUMERIC(18, 6)									NULL DEFAULT 0,	
	[dblBaseTotalTermDiscount]			NUMERIC(18, 6)									NULL DEFAULT 0,	
	[dblTotalTermDiscountExemption]		NUMERIC(18, 6)									NULL DEFAULT 0,	
	[dblBaseTotalTermDiscountExemption]	NUMERIC(18, 6)									NULL DEFAULT 0,		
	[dblInterest]						NUMERIC(18, 6)									NULL DEFAULT 0,
	[dblBaseInterest]					NUMERIC(18, 6)									NULL DEFAULT 0,
    [dblAmountDue]						NUMERIC(18, 6)									NULL DEFAULT 0,
	[dblBaseAmountDue]					NUMERIC(18, 6)									NULL DEFAULT 0,
    [dblPayment]						NUMERIC(18, 6)									NULL DEFAULT 0,
	[dblBasePayment]					NUMERIC(18, 6)									NULL DEFAULT 0,
	[dblProvisionalAmount]				NUMERIC(18, 6)									NULL DEFAULT 0,
	[dblBaseProvisionalAmount]			NUMERIC(18, 6)									NULL DEFAULT 0,
	[dblCurrencyExchangeRate]			NUMERIC(18, 6)									CONSTRAINT [DF_tblARInvoice_dblCurrencyExchangeRate] DEFAULT ((1)) NULL,
    [intEntitySalespersonId]			INT												NULL,    
    [intFreightTermId]					INT												NULL,
    [intShipViaId]						INT												NULL,
    [intPaymentMethodId]				INT												NULL, 	        
    [strInvoiceOriginId]				NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL,
	[strMobileBillingShiftNo]			NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL,
    [strPONumber]						NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL,
	[strBOLNumber]						NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL,
	[strPaymentInfo]					NVARCHAR(50)    COLLATE Latin1_General_CI_AS 	NULL,
    [strComments]						NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS	NULL,	
	[strFooterComments]					NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS	NULL,
    [intShipToLocationId]				INT												NULL,
	[strShipToLocationName]				NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL,
    [strShipToAddress]					NVARCHAR (MAX)	COLLATE Latin1_General_CI_AS	NULL,
    [strShipToCity]						NVARCHAR (MAX)	COLLATE Latin1_General_CI_AS	NULL,
    [strShipToState]					NVARCHAR (MAX)	COLLATE Latin1_General_CI_AS	NULL,
    [strShipToZipCode]					NVARCHAR (MAX)	COLLATE Latin1_General_CI_AS	NULL,
    [strShipToCountry]					NVARCHAR (MAX)	COLLATE Latin1_General_CI_AS	NULL,
	[intBillToLocationId]				INT												NULL,
	[strBillToLocationName]				NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL,
    [strBillToAddress]					NVARCHAR (MAX)	COLLATE Latin1_General_CI_AS	NULL,
    [strBillToCity]						NVARCHAR (MAX)	COLLATE Latin1_General_CI_AS	NULL,
    [strBillToState]					NVARCHAR (MAX)	COLLATE Latin1_General_CI_AS	NULL,
    [strBillToZipCode]					NVARCHAR (MAX)	COLLATE Latin1_General_CI_AS	NULL,
    [strBillToCountry]					NVARCHAR (MAX)	COLLATE Latin1_General_CI_AS	NULL,	
    [ysnPosted]							BIT             								NOT NULL	CONSTRAINT [DF_tblARInvoice_ysnPosted] DEFAULT ((0)),
    [ysnPaid]							BIT												NOT NULL	CONSTRAINT [DF_tblARInvoice_ysnPaid] DEFAULT ((0)),
    [ysnPaidCPP]						BIT												NOT NULL	CONSTRAINT [DF_tblARInvoice_ysnPaidCPP] DEFAULT ((0)),
	[ysnProcessed]						BIT												NOT NULL	CONSTRAINT [DF_tblARInvoice_ysnProcessed] DEFAULT ((0)),
	[ysnReturned]						BIT												NOT NULL	CONSTRAINT [DF_tblARInvoice_ysnReturned] DEFAULT ((0)),
	[ysnRecurring]						BIT												NOT NULL	CONSTRAINT [DF_tblARInvoice_ysnTemplate] DEFAULT ((0)),
	[ysnForgiven]						BIT												NOT NULL	CONSTRAINT [DF_tblARInvoice_ysnForgiven] DEFAULT ((0)),
	[ysnCalculated]						BIT												NOT NULL	CONSTRAINT [DF_tblARInvoice_ysnCalculated] DEFAULT ((0)),
	[ysnSplitted]						BIT												NOT NULL	CONSTRAINT [DF_tblARInvoice_ysnSplitted] DEFAULT ((0)),		
	[dblSplitPercent]					NUMERIC(18, 6)									NOT NULL	CONSTRAINT [DF_tblARInvoice_dblSplitPercent] DEFAULT ((1)),
	[ysnImpactInventory]				BIT												NOT NULL	CONSTRAINT [DF_tblARInvoice_ysnImpactInventory] DEFAULT ((1)),		
	[ysnImportedFromOrigin]				BIT												NOT NULL	CONSTRAINT [DF_tblARInvoice_ysnImportedFromOrigin] DEFAULT ((0)),		
	[ysnImportedAsPosted]				BIT												NOT NULL	CONSTRAINT [DF_tblARInvoice_ysnImportedAsPosted] DEFAULT ((0)),		
	[ysnExcludeFromPayment]				BIT                                             NOT NULL    CONSTRAINT [DF_tblARInvoice_ysnExcludeFromPayment] DEFAULT ((0)),        
    [ysnFromProvisional]				BIT                                             NULL        CONSTRAINT [DF_tblARInvoice_ysnFromProvisional] DEFAULT ((0)),        
    [ysnProvisionalWithGL]				BIT                                             NULL        CONSTRAINT [DF_tblARInvoice_ysnProvisionalWithGL] DEFAULT ((0)),        
	[ysnExported]						BIT												NULL,
	[ysnCancelled]						BIT												NOT NULL	CONSTRAINT [DF_tblARInvoice_ysnCancelled] DEFAULT ((0)),
	[ysnRejected]						BIT												NOT NULL	CONSTRAINT [DF_tblARInvoice_ysnRejected] DEFAULT ((0)),
	[ysnProcessedToNSF]					BIT												NOT NULL	CONSTRAINT [DF_tblARInvoice_ysnProcessedToNSF] DEFAULT ((0)),
	[ysnServiceChargeCredit]			BIT												NOT NULL	CONSTRAINT [DF_tblARInvoice_ysnServiceChargeCredit] DEFAULT ((0)),
	[intPaymentId]						INT												NULL,
	[intSplitId]						INT												NULL,
	[intDistributionHeaderId]			INT												NULL,
	[intLoadDistributionHeaderId]		INT												NULL,
	[strActualCostId]					NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL,
	[strImportFormat]					NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL,
	[strContractApplyTo]				NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL,
	[intShipmentId]						INT												NULL,        	
	[intTransactionId]					INT												NULL,
	[intMeterReadingId]        			INT												NULL,
	[intContractHeaderId]      			INT												NULL,
	[intOriginalInvoiceId]				INT												NULL,        	
	[intLoadId]							INT												NULL,        	
	[intEntityId]						INT												NOT NULL	DEFAULT ((0)), 
	[intEntityContactId]				INT												NULL,
	[intEntityApplicatorId]				INT												NULL,
	[dblTotalWeight]					NUMERIC(18, 6)									NULL		DEFAULT 0,	
	[intDocumentMaintenanceId]			INT												NULL,	
	[intTruckDriverId]					INT												NULL,        	
	[intTruckDriverReferenceId]			INT												NULL,
	[strBatchId]						NVARCHAR (20)	COLLATE Latin1_General_CI_AS	NULL,	
	[dtmBatchDate]						DATETIME										NULL,
	[dtmDateFullyPaid]					DATETIME										NULL,
	[intPostedById]						INT												NULL,
	[intLineOfBusinessId]				INT												NULL,
	[intICTId]							INT												NULL,
	[intBookId]							INT												NULL,
	[intSubBookId]						INT												NULL,
	[intSalesOrderId]					INT												NULL,
	[dtmForgiveDate]					DATETIME										NULL,
	[dtmDateCreated]					DATETIME										NULL,
	[ysnRefundProcessed]				BIT             								NOT NULL	CONSTRAINT [DF_tblARInvoice_ysnRefundProcessed] DEFAULT ((0)),
	[ysnValidCreditCode]				BIT												NOT NULL	CONSTRAINT [DF_tblARInvoice_ysnValidCreditCode] DEFAULT ((0)),
	[ysnFromItemContract]				BIT												NOT NULL	CONSTRAINT [DF_tblARInvoice_ysnFromItemContract] DEFAULT ((0)),
	[intCompanyId]						INT												NULL,
	[intConcurrencyId]					INT												NOT NULL	CONSTRAINT [DF_tblARInvoice_intConcurrencyId] DEFAULT ((0)),
	[blbSignature]						VARBINARY(MAX)								    NULL,
    CONSTRAINT [PK_tblARInvoice_intInvoiceId] PRIMARY KEY CLUSTERED ([intInvoiceId] ASC),
	CONSTRAINT [UK_tblARInvoice_strInvoiceNumber] UNIQUE ([strInvoiceNumber]),
    CONSTRAINT [FK_tblARInvoice_tblARCustomer_intEntityCustomerId] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityId]),
	CONSTRAINT [FK_tblARInvoice_tblEMEntity_intEntityId] FOREIGN KEY (intEntityId) REFERENCES tblEMEntity(intEntityId),
	CONSTRAINT [FK_tblARInvoice_tblEMEntity_intEntityContactId] FOREIGN KEY (intEntityContactId) REFERENCES tblEMEntity(intEntityId),
	CONSTRAINT [FK_tblARInvoice_tblEMEntity_intEntityApplicatorId] FOREIGN KEY ([intEntityApplicatorId]) REFERENCES [dbo].tblEMEntity ([intEntityId]),
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
	CONSTRAINT [FK_tblARInvoice_tblTRLoadDistributionHeader_intLoadDistributionHeaderId] FOREIGN KEY ([intLoadDistributionHeaderId]) REFERENCES [tblTRLoadDistributionHeader]([intLoadDistributionHeaderId]),-- ON DELETE CASCADE,
	CONSTRAINT [FK_tblARInvoice_tblLGShipment_intShipmentId] FOREIGN KEY ([intShipmentId]) REFERENCES [tblLGShipment]([intShipmentId]),
	CONSTRAINT [FK_tblARInvoice_tblCFTransaction_intTransactionId] FOREIGN KEY ([intTransactionId]) REFERENCES [tblCFTransaction]([intTransactionId]),
	CONSTRAINT [FK_tblARInvoice_tblMBMeterReading_intMeterReadingId] FOREIGN KEY ([intMeterReadingId]) REFERENCES [tblMBMeterReading]([intMeterReadingId]),
	CONSTRAINT [FK_tblARInvoice_tblCTContractHeader_intContractHeaderId] FOREIGN KEY ([intContractHeaderId]) REFERENCES [tblCTContractHeader]([intContractHeaderId]),
	CONSTRAINT [FK_tblARInvoice_tblLGLoad_intLoadId] FOREIGN KEY ([intLoadId]) REFERENCES [tblLGLoad]([intLoadId]),
	CONSTRAINT [FK_tblARInvoice_tblSCTruckDriverReference_intTruckDriverReferenceId] FOREIGN KEY ([intTruckDriverReferenceId]) REFERENCES [tblSCTruckDriverReference]([intTruckDriverReferenceId]),
	CONSTRAINT [FK_tblARInvoice_tblARSalesperson_intTruckDriverId] FOREIGN KEY ([intTruckDriverId]) REFERENCES [tblARSalesperson]([intEntityId]),
	CONSTRAINT [FK_tblARInvoice_tblSMLineOfBusiness_intLineOfBusinessId] FOREIGN KEY ([intLineOfBusinessId]) REFERENCES [tblSMLineOfBusiness]([intLineOfBusinessId]),
	CONSTRAINT [FK_tblARInvoice_tblARICT_intICTId] FOREIGN KEY ([intICTId]) REFERENCES [tblARICT]([intICTId]),
	CONSTRAINT [FK_tblARInvoice_tblCTBook_intBookId] FOREIGN KEY ([intBookId]) REFERENCES [tblCTBook]([intBookId]),
	CONSTRAINT [FK_tblARInvoice_tblCTSubBook_intSubBookId] FOREIGN KEY ([intSubBookId]) REFERENCES [tblCTSubBook]([intSubBookId]),
	CONSTRAINT [FK_tblARInvoice_tblSOSalesOrder_intSalesOrderId] FOREIGN KEY ([intSalesOrderId]) REFERENCES [tblSOSalesOrder]([intSalesOrderId])
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
SELECT intInvoiceId, strTransactionType, strType, intCompanyLocationId FROM INSERTED WHERE ISNULL(RTRIM(LTRIM(strInvoiceNumber)), '') = '' ORDER BY intInvoiceId

WHILE((SELECT TOP 1 1 FROM @inserted) IS NOT NULL)
BEGIN
	SET @intStartingNumberId = 19
	
	SELECT TOP 1 @intInvoiceId = intInvoiceId, @strTransactionType = strTransactionType, @strType = strType, @intCompanyLocationId = intCompanyLocationId FROM @inserted

	UPDATE tblARInvoice SET dtmDateCreated = GETDATE() WHERE intInvoiceId = @intInvoiceId

	SELECT TOP 1 @intStartingNumberId = intStartingNumberId 
	FROM tblSMStartingNumber 
	WHERE strTransactionType = CASE WHEN @strTransactionType = 'Prepayment' THEN 'Customer Prepayment' 
									WHEN @strTransactionType = 'Customer Prepayment' THEN 'Customer Prepayment' 
									WHEN @strTransactionType = 'Overpayment' THEN 'Customer Overpayment'
									WHEN @strTransactionType = 'Invoice' AND @strType = 'Service Charge' THEN 'Service Charge'
									WHEN @strTransactionType = 'Invoice' AND @strType = 'Provisional' THEN 'Provisional'									 
									ELSE 'Invoice' END
		
	EXEC uspSMGetStartingNumber @intStartingNumberId, @InvoiceNumber OUT, @intCompanyLocationId
	
	IF(@InvoiceNumber IS NOT NULL)
	BEGIN
		IF EXISTS (SELECT NULL FROM tblARInvoice WHERE strInvoiceNumber = @InvoiceNumber)
			BEGIN
				SET @InvoiceNumber = NULL
				
				-- UPDATE tblSMStartingNumber SET intNumber = intNumber + 1 WHERE intStartingNumberId = @intStartingNumberId
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

GO
CREATE NONCLUSTERED INDEX [PIndex_tblARInvoice_intEntityCustomerId_ysnPosted]
ON [dbo].[tblARInvoice] ([intEntityCustomerId],[ysnPosted])
INCLUDE ([strTransactionType],[dtmPostDate],[dblInvoiceSubtotal])

GO
CREATE NONCLUSTERED INDEX [PIndex_tblARInvoice_intEntityCustomerId_ysnForgiven]
ON [dbo].[tblARInvoice] ([intEntityCustomerId],[ysnPosted])
INCLUDE ([intInvoiceId],[strTransactionType],[strType],[dtmPostDate],[dblInvoiceTotal],[ysnForgiven])

GO
CREATE INDEX [IX_tblARInvoice_strType] ON [dbo].[tblARInvoice] ([strType] ASC)

GO
CREATE TRIGGER trg_tblARInvoiceDelete
ON dbo.tblARInvoice
INSTEAD OF DELETE 
AS
BEGIN
	DECLARE @strInvoiceNumber 	NVARCHAR(50) = NULL
		  , @strError 			NVARCHAR(500) = NULL
		  , @intInvoiceId 		INT = NULL
		  , @ysnPosted			BIT = 0	      

	SELECT @intInvoiceId 		= intInvoiceId
	     , @strInvoiceNumber 	= strInvoiceNumber
		 , @ysnPosted			= ysnPosted 
	FROM DELETED 	
	
	IF EXISTS (SELECT TOP 1 NULL FROM tblGLDetail WHERE ysnIsUnposted = 0 AND intTransactionId = @intInvoiceId AND strTransactionId = @strInvoiceNumber)
		SET @strError = 'You cannot delete invoice ' + @strInvoiceNumber + '. It has existing posted GL entries.';

	IF @ysnPosted = 1
		SET @strError = 'You cannot delete posted invoice (' + @strInvoiceNumber + ')';			

	IF ISNULL(@strError, '') <> ''
		RAISERROR(@strError, 16, 1);
	ELSE
		DELETE A
		FROM tblARInvoice A
		INNER JOIN DELETED B ON A.intInvoiceId = B.intInvoiceId
END