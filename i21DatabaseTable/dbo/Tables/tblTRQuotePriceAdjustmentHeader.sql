CREATE TABLE [dbo].[tblTRQuotePriceAdjustmentHeader]
(
	[intQuotePriceAdjustmentHeaderId] INT NOT NULL IDENTITY,
	[intCustomerGroupId] INT NULL,
	[intEntityCustomerId] INT NULL,
	[intSupplyPointId] INT NULL,
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblTRQuotePriceAdjustmentHeader] PRIMARY KEY ([intQuotePriceAdjustmentHeaderId]),
	CONSTRAINT [AK_tblTRQuotePriceAdjustmentHeader] UNIQUE ([intQuotePriceAdjustmentHeaderId]),
	CONSTRAINT [FK_tblTRQuotePriceAdjustmentHeader_tblARCustomerGroup_intCustomerGroupId] FOREIGN KEY ([intCustomerGroupId]) REFERENCES [dbo].[tblARCustomerGroup] ([intCustomerGroupId]),
	CONSTRAINT [FK_tblTRQuotePriceAdjustmentHeader_tblARCustomer_intEntityCustomerId] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] (intEntityId),
	CONSTRAINT [FK_tblTRQuotePriceAdjustmentHeader_tblTRSupplyPoint_intSupplyPointId] FOREIGN KEY ([intSupplyPointId]) REFERENCES [dbo].[tblTRSupplyPoint] ([intSupplyPointId])
	
)
