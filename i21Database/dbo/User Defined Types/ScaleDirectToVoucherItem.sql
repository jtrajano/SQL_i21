
CREATE TYPE [dbo].ScaleDirectToVoucherItem AS TABLE
(
		[intAccountId]					INT             NULL
		,[intItemId]					INT             NULL
		,[strMiscDescription]			NVARCHAR(500)	NULL
		,[intUnitOfMeasureId]           INT             NULL
		,[dblQuantity]					DECIMAL(38, 20)	NULL 
		,[dblUnitQty]					DECIMAL(38, 20)	NULL 
		,[dblDiscount]					DECIMAL(18, 6)	NOT NULL DEFAULT 0
		,[intCostUOMId]                 INT             NULL
		,[dblCost]						DECIMAL(38, 20)	NULL 
		,[dblCostUnitQty]               DECIMAL(38, 20)	NULL 
		,[intTaxGroupId]				INT             NULL
		,[intInvoiceId]					INT             NULL
		,[intScaleTicketId]				INT				NULL
		,[intContractDetailId]          INT             NULL
		,[intLoadDetailId]              INT             NULL
		,[intFreightItemId]             INT             NULL
		,[dblFreightRate]               DECIMAL(38, 20)	NULL
		,[intTicketFeesItemId]          INT             NULL
		,[dblTicketFees]				DECIMAL(38, 20)	NULL
		,[intEntityId]					INT             NULL
		,[intScaleSetupId]				INT             NULL
		,[ysnFarmerPaysFreight]			BIT				NULL
		,[ysnCusVenPaysFees]			BIT				NULL
		,[dblGrossUnits]				DECIMAL(38, 20)	NULL
		,[dblNetUnits]					DECIMAL(38, 20)	NULL
		,[strVendorOrderNumber]			NVARCHAR(50)	NULL
		,[intStorageScheduleTypeId]		INT				NULL
		,intUnitItemUOMId				INT				NULL
		,intTicketDistributionAllocationId INT NULL
)

