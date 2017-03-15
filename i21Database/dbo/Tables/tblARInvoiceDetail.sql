CREATE TABLE [dbo].[tblARInvoiceDetail] (
    [intInvoiceDetailId]					INT             IDENTITY (1, 1)					NOT NULL,
    [intInvoiceId]							INT												NOT NULL,
	[strDocumentNumber]						NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL,
    [intItemId]								INT												NULL,
	[intPrepayTypeId]						INT				CONSTRAINT [DF_tblARInvoiceDetail_intPrepayTypeId] DEFAULT ((0)) NULL,
	[dblPrepayRate]							NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblPrepayRate] DEFAULT ((0)) NULL,
    [strItemDescription]					NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NULL,
	[dblQtyOrdered]							NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblQtyOrdered] DEFAULT ((0)) NULL,
	[intOrderUOMId]							INT												NULL,    
    [dblQtyShipped]							NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblQtyShipped] DEFAULT ((0)) NULL,
	[intItemUOMId]							INT												NULL,
	[dblItemWeight]							NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblItemWeight] DEFAULT ((0)) NULL,
	[intItemWeightUOMId]					INT												NULL,    
	[dblDiscount]							NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblDiscount] DEFAULT ((0)) NULL,
	[dblItemTermDiscount]					NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblItemTermDiscount] DEFAULT ((0)) NULL,
	[strItemTermDiscountBy]					NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL,
    [dblPrice]								NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblPrice] DEFAULT ((0)) NULL,
	[dblBasePrice]							NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblBasePrice] DEFAULT ((0)) NULL,
	[strPricing]							NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NULL,
	[dblTotalTax]							NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblTotalTax] DEFAULT ((0)) NULL,
	[dblBaseTotalTax]						NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblBaseTotalTax] DEFAULT ((0)) NULL,
    [dblTotal]								NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblTotal] DEFAULT ((0)) NULL,
	[dblBaseTotal]							NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblBaseTotal] DEFAULT ((0)) NULL,
	[intCurrencyExchangeRateTypeId]			INT												NULL,
	[intCurrencyExchangeRateId]				INT												NULL,
	[dblCurrencyExchangeRate]				NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblCurrencyExchangeRate] DEFAULT ((1)) NULL,
	[intSubCurrencyId]						INT												NULL,
	[dblSubCurrencyRate]					NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblSubCurrencyRate] DEFAULT ((1)) NULL,
	[ysnRestricted]							BIT				CONSTRAINT [DF_tblARInvoiceDetail_ysnRestricted] DEFAULT ((0)) NULL,
	[ysnBlended]							BIT				CONSTRAINT [DF_tblARInvoiceDetail_ysnBlended] DEFAULT ((0)) NULL,
	[intAccountId]							INT												NULL,
	[intCOGSAccountId]						INT												NULL,
	[intSalesAccountId]						INT												NULL,
	[intInventoryAccountId]					INT												NULL,
	[intServiceChargeAccountId]				INT												NULL,
	[intLicenseAccountId]					INT												NULL,
	[intMaintenanceAccountId]				INT												NULL,
	[strMaintenanceType]					NVARCHAR(25)    COLLATE Latin1_General_CI_AS	NULL,
    [strFrequency]							NVARCHAR(25)    COLLATE Latin1_General_CI_AS	NULL,
    [dtmMaintenanceDate]					DATETIME										NULL, 
    [dblMaintenanceAmount]					NUMERIC(18, 6)									NULL, 
	[dblBaseMaintenanceAmount]				NUMERIC(18, 6)									NULL, 
    [dblLicenseAmount]						NUMERIC(18, 6)									NULL,      	
	[dblBaseLicenseAmount]					NUMERIC(18, 6)									NULL,      	
	[intTaxGroupId]							INT												NULL,
	[intStorageLocationId]					INT												NULL,
	[intCompanyLocationSubLocationId]		INT												NULL,
	[intSCInvoiceId]						INT												NULL,
	[intSCBudgetId]							INT												NULL,
	[strSCInvoiceNumber]					NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL,
	[strSCBudgetDescription]				NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL,
	[intInventoryShipmentItemId]			INT												NULL,
	[intInventoryShipmentChargeId]			INT												NULL,
	[intRecipeItemId]						INT												NULL,
	[strShipmentNumber]						NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL,
	[intSalesOrderDetailId]					INT												NULL,
	[strSalesOrderNumber]					NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL,
	[strVFDDocumentNumber]					NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL,
	[intContractHeaderId]					INT												NULL,
	[intContractDetailId]					INT												NULL, 
	[dblContractBalance]					NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblContractBalance] DEFAULT ((0)) NULL,
	[dblContractAvailable]					NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblContractAvailable] DEFAULT ((0)) NULL,
	[intShipmentId]							INT												NULL,
	[intShipmentPurchaseSalesContractId]	INT												NULL,	
	[dblShipmentGrossWt]					NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblShipmentGrossWt] DEFAULT ((0)) NULL,
	[dblShipmentTareWt]						NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblShipmentTareWt] DEFAULT ((0)) NULL,
	[dblShipmentNetWt]						NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblShipmentNetWt] DEFAULT ((0)) NULL,
	[intTicketId]							INT												NULL, 
	[intTicketHoursWorkedId]				INT												NULL,
	[intCustomerStorageId]					INT												NULL,
	[intSiteDetailId]						INT												NULL,
	[intLoadDetailId]						INT												NULL,
	[intOriginalInvoiceDetailId]			INT												NULL,
	[intConversionAccountId]				INT												NULL,
	[intEntitySalespersonId]				INT												NULL,
	[intSiteId]								INT												NULL,
	[strBillingBy]							NVARCHAR(100)   COLLATE Latin1_General_CI_AS	NULL,
	[dblPercentFull]						NUMERIC(18, 6)									NULL,
	[dblNewMeterReading]					NUMERIC(18, 6)									NULL,
	[dblPreviousMeterReading]				NUMERIC(18, 6)									NULL,
	[dblConversionFactor]					NUMERIC(18, 8)									NULL,
	[intPerformerId]						INT												NULL,
	[ysnLeaseBilling]						BIT												NULL,	
	[ysnVirtualMeterReading]				BIT												NULL,	
	[dblOriginalItemWeight]					NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblOriginalItemWeight] DEFAULT ((0)) NULL,
    [intConcurrencyId]						INT				CONSTRAINT [DF_tblARInvoiceDetail_intConcurrencyId] DEFAULT ((0)) NOT NULL,
	[intRecipeId]							INT												NULL,
	[intSubLocationId]						INT												NULL,
	[intCostTypeId]							INT												NULL,
	[intMarginById]							INT												NULL,
	[intCommentTypeId]						INT												NULL,
	[dblMargin]								NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblMargin] DEFAULT ((0)) NULL,
	[dblRecipeQuantity]						NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblRecipeQuantity] DEFAULT ((0)) NULL,
	[intStorageScheduleTypeId]				INT												NULL,
	[intDestinationGradeId]					INT												NULL,
	[intDestinationWeightId]				INT												NULL,
    CONSTRAINT [PK_tblARInvoiceDetail_intInvoiceDetailId] PRIMARY KEY CLUSTERED ([intInvoiceDetailId] ASC),
    CONSTRAINT [FK_tblARInvoiceDetail_tblARInvoice] FOREIGN KEY ([intInvoiceId]) REFERENCES [dbo].[tblARInvoice] ([intInvoiceId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblARInvoiceDetail_tblGLAccount_intAccountId] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblGLAccount_intCOGSAccountId] FOREIGN KEY ([intCOGSAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblGLAccount_intSalesAccountId] FOREIGN KEY ([intSalesAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblGLAccount_intInventoryAccountId] FOREIGN KEY ([intInventoryAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblGLAccount_intConversionAccountId] FOREIGN KEY ([intConversionAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
    CONSTRAINT [FK_tblARInvoiceDetail_tblGLAccount_intLicenseAccountId] FOREIGN KEY ([intLicenseAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
    CONSTRAINT [FK_tblARInvoiceDetail_tblGLAccount_intMaintenanceAccountId] FOREIGN KEY ([intMaintenanceAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblICInventoryShipmentItem_intInventoryShipmentItemId] FOREIGN KEY ([intInventoryShipmentItemId]) REFERENCES [dbo].[tblICInventoryShipmentItem] ([intInventoryShipmentItemId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblICInventoryShipmentCharge_intInventoryShipmentChargeId] FOREIGN KEY ([intInventoryShipmentChargeId]) REFERENCES [dbo].[tblICInventoryShipmentCharge] ([intInventoryShipmentChargeId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblSOSalesOrderDetail_intSalesOrderDetailId] FOREIGN KEY ([intSalesOrderDetailId]) REFERENCES [dbo].[tblSOSalesOrderDetail] ([intSalesOrderDetailId]),	
	CONSTRAINT [FK_tblARInvoiceDetail_tblCTContractHeader_intContractHeaderId] FOREIGN KEY ([intContractHeaderId]) REFERENCES [dbo].[tblCTContractHeader] ([intContractHeaderId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [dbo].[tblCTContractDetail] ([intContractDetailId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblLGShipment_intShipmentId] FOREIGN KEY ([intShipmentId]) REFERENCES [dbo].[tblLGShipment] ([intShipmentId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblLGShipmentPurchaseSalesContract_intShipmentPurchaseSalesContractId] FOREIGN KEY ([intShipmentPurchaseSalesContractId]) REFERENCES [dbo].[tblLGShipmentPurchaseSalesContract] ([intShipmentPurchaseSalesContractId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblSCTicket_intTicketId] FOREIGN KEY ([intTicketId]) REFERENCES [dbo].[tblSCTicket] ([intTicketId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblHDTicketHoursWorked_intTicketHoursWorkedId] FOREIGN KEY ([intTicketHoursWorkedId]) REFERENCES [dbo].[tblHDTicketHoursWorked] ([intTicketHoursWorkedId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblTMSite_intSiteId] FOREIGN KEY ([intSiteId]) REFERENCES [dbo].[tblTMSite] ([intSiteID]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblSMTaxGroup_intTaxGroupId] FOREIGN KEY ([intTaxGroupId]) REFERENCES [dbo].[tblSMTaxGroup] ([intTaxGroupId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblARSalesperson_intEntitySalespersonId] FOREIGN KEY ([intEntitySalespersonId]) REFERENCES [dbo].[tblARSalesperson] ([intEntitySalespersonId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblICStorageLocation_intStorageLocationId] FOREIGN KEY ([intStorageLocationId]) REFERENCES [tblICStorageLocation]([intStorageLocationId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblSMCompanyLocationSubLocation_intCompanyLocationSubLocationId] FOREIGN KEY ([intCompanyLocationSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblGRCustomerStorage_intCustomerStorageId] FOREIGN KEY ([intCustomerStorageId]) REFERENCES [tblGRCustomerStorage]([intCustomerStorageId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblCCSiteDetail_intSiteDetailId] FOREIGN KEY ([intSiteDetailId]) REFERENCES [tblCCSiteDetail]([intSiteDetailId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblLGLoadDetail_intLoadDetailId] FOREIGN KEY ([intLoadDetailId]) REFERENCES [tblLGLoadDetail]([intLoadDetailId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblMFRecipeItem_intRecipeItemId] FOREIGN KEY ([intRecipeItemId]) REFERENCES [tblMFRecipeItem]([intRecipeItemId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblGRStorageType_intStorageScheduleTypeId] FOREIGN KEY ([intStorageScheduleTypeId]) REFERENCES [tblGRStorageType]([intStorageScheduleTypeId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblSMCurrencyExchangeRateType_intCurrencyExchangeRateTypeId] FOREIGN KEY ([intCurrencyExchangeRateTypeId]) REFERENCES [tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId]),
	--CONSTRAINT [FK_tblARInvoiceDetail_tblSMCurrencyExchangeRate_intCurrencyExchangeRateId] FOREIGN KEY ([intCurrencyExchangeRateId]) REFERENCES [tblSMCurrencyExchangeRate]([intCurrencyExchangeRateId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblSMCurrency_intSubCurrencyId] FOREIGN KEY ([intSubCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblCTWeightGrade_intDestinationGradeId] FOREIGN KEY ([intDestinationGradeId]) REFERENCES [tblCTWeightGrade]([intWeightGradeId]),
    CONSTRAINT [FK_tblARInvoiceDetail_tblCTWeightGrade_intDestinationWeightId] FOREIGN KEY ([intDestinationWeightId]) REFERENCES [tblCTWeightGrade]([intWeightGradeId])

);

GO
CREATE NONCLUSTERED INDEX [PIndex]
    ON [dbo].[tblARInvoiceDetail]([intInvoiceId] ASC, [intItemId] ASC, [strItemDescription] ASC, [dblQtyOrdered] ASC, [dblQtyShipped] ASC, [dblPrice] ASC, [dblTotal] ASC);

GO
CREATE TRIGGER [dbo].[trgUpdateOrderStatus]
    ON [dbo].[tblARInvoiceDetail]
    FOR DELETE
    AS
    BEGIN
        DECLARE @deleted TABLE(intInvoiceDetailId INT, intSalesOrderDetailId INT)

		INSERT INTO @deleted
		SELECT intInvoiceDetailId, intSalesOrderDetailId FROM DELETED ORDER BY intInvoiceDetailId

		WHILE EXISTS(SELECT NULL FROM @deleted)
			BEGIN
				DECLARE @invoiceDetailId INT,
						@orderDetailId INT,
						@orderId INT

				SELECT TOP 1 @invoiceDetailId = intInvoiceDetailId
				           , @orderDetailId = intSalesOrderDetailId FROM @deleted

				IF ISNULL(@orderDetailId, 0) > 0
					BEGIN
						SELECT TOP 1 @orderId = intSalesOrderId FROM tblSOSalesOrderDetail WHERE intSalesOrderDetailId = @orderDetailId
						EXEC uspSOUpdateOrderShipmentStatus @orderId, 0 , 1
					END				

				DELETE FROM @deleted WHERE intInvoiceDetailId = @invoiceDetailId
			END
    END