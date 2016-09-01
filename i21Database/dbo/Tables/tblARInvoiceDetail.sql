CREATE TABLE [dbo].[tblARInvoiceDetail] (
    [intInvoiceDetailId]					INT             IDENTITY (1, 1)					NOT NULL,
    [intInvoiceId]							INT												NOT NULL,
	[strDocumentNumber]						NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL,
    [intItemId]								INT												NULL,
	[intPrepayTypeId]						INT												NULL DEFAULT 0,
	[dblPrepayRate]							NUMERIC(18, 6)									NULL DEFAULT 0,
    [strItemDescription]					NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NULL,
	[dblQtyOrdered]							NUMERIC(18, 6)									NULL DEFAULT 0,
	[intOrderUOMId]							INT												NULL,    
    [dblQtyShipped]							NUMERIC(18, 6)									NULL DEFAULT 0,
	[intItemUOMId]							INT												NULL,
	[dblItemWeight]							NUMERIC(18, 6)									NULL DEFAULT 0,
	[intItemWeightUOMId]					INT												NULL,    
	[dblDiscount]							NUMERIC(18, 6)									NULL DEFAULT 0,
	[dblItemTermDiscount]					NUMERIC(18, 6)									NULL DEFAULT 0,	
    [dblPrice]								NUMERIC(18, 6)									NULL DEFAULT 0,
	[strPricing]							NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NULL,
	[dblTotalTax]							NUMERIC(18, 6)									NULL DEFAULT 0,
    [dblTotal]								NUMERIC(18, 6)									NULL DEFAULT 0,
	[ysnSubCurrency]						BIT												NULL DEFAULT 0,	
	[ysnRestricted]							BIT												NULL DEFAULT 0,
	[ysnBlended]							BIT												NULL DEFAULT 0,	
	[intAccountId]							INT												NULL,
	[intCOGSAccountId]						INT												NULL,
	[intSalesAccountId]						INT												NULL,
	[intInventoryAccountId]					INT												NULL,
	[intServiceChargeAccountId]				INT												NULL,
	[strMaintenanceType]					NVARCHAR(25)    COLLATE Latin1_General_CI_AS	NULL,
    [strFrequency]							NVARCHAR(25)    COLLATE Latin1_General_CI_AS	NULL,
    [dtmMaintenanceDate]					DATETIME										NULL, 
    [dblMaintenanceAmount]					NUMERIC(18, 6)									NULL, 
    [dblLicenseAmount]						NUMERIC(18, 6)									NULL,      	
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
	[intContractHeaderId]					INT												NULL,
	[intContractDetailId]					INT												NULL, 
	[dblContractBalance]					NUMERIC(18, 6)									NOT NULL DEFAULT 0, 
	[dblContractAvailable]					NUMERIC(18, 6)									NOT NULL DEFAULT 0, 
	[intShipmentId]							INT												NULL,
	[intShipmentPurchaseSalesContractId]	INT												NULL,	
	[dblShipmentGrossWt]					NUMERIC(18, 6)									NULL DEFAULT 0,
	[dblShipmentTareWt]						NUMERIC(18, 6)									NULL DEFAULT 0,
	[dblShipmentNetWt]						NUMERIC(18, 6)									NULL DEFAULT 0,
	[intTicketId]							INT												NULL, 
	[intTicketHoursWorkedId]				INT												NULL,
	[intCustomerStorageId]					INT												NULL,
	[intSiteDetailId]						INT												NULL,
	[intLoadDetailId]						INT												NULL,
	[intOriginalInvoiceDetailId]			INT												NULL,
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
	[dblOriginalItemWeight]					NUMERIC(18, 6)									NULL DEFAULT 0,
    [intConcurrencyId]						INT												NOT NULL	CONSTRAINT [DF_tblARInvoiceDetail_intConcurrencyId] DEFAULT ((0)),    
	[intRecipeId]							INT												NULL,
	[intSubLocationId]						INT												NULL,
	[intCostTypeId]							INT												NULL,
	[intMarginById]							INT												NULL,
	[intCommentTypeId]						INT												NULL,
	[dblMargin]								NUMERIC(18, 6)									NULL DEFAULT 0,
	[dblRecipeQuantity]						NUMERIC(18, 6)									NULL DEFAULT 0,
	[intStorageScheduleTypeId]						INT												NULL,
    CONSTRAINT [PK_tblARInvoiceDetail_intInvoiceDetailId] PRIMARY KEY CLUSTERED ([intInvoiceDetailId] ASC),
    CONSTRAINT [FK_tblARInvoiceDetail_tblARInvoice] FOREIGN KEY ([intInvoiceId]) REFERENCES [dbo].[tblARInvoice] ([intInvoiceId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblARInvoiceDetail_tblGLAccount_intAccountId] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblGLAccount_intCOGSAccountId] FOREIGN KEY ([intCOGSAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblGLAccount_intSalesAccountId] FOREIGN KEY ([intSalesAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblGLAccount_intInventoryAccountId] FOREIGN KEY ([intInventoryAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
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
	CONSTRAINT [FK_tblARInvoiceDetail_tblGRStorageType_intStorageScheduleTypeId] FOREIGN KEY ([intStorageScheduleTypeId]) REFERENCES [tblGRStorageType]([intStorageScheduleTypeId])
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