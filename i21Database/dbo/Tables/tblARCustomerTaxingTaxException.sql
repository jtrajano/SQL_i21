CREATE TABLE [dbo].[tblARCustomerTaxingTaxException]
(
	[intCustomerTaxingTaxExceptionId]	INT             IDENTITY (1, 1) NOT NULL,
    [intEntityCustomerId]				INT             NOT NULL,
    [intItemId]							INT             NULL,
	[intCategoryId]						INT             NULL,
	[intTaxCodeId]						INT             NULL,
	[intTaxClassId]						INT             NULL,
    [strState]							NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
	[strException]						NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
	[dtmStartDate]						DATETIME		NULL,
	[dtmEndDate]						DATETIME		NULL,	
	[intEntityCustomerLocationId]		INT				NULL,	
    [dblPartialTax]						NUMERIC(18,6) NULL,
	[intCardId]							INT				NULL,
	[intVehicleId]						INT				NULL,
    [intConcurrencyId]					INT			CONSTRAINT [DF_tblARCustomerTaxingTaxException_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblARCustomerTaxingTaxException] PRIMARY KEY CLUSTERED ([intCustomerTaxingTaxExceptionId] ASC),
	CONSTRAINT [FK_tblARCustomerTaxingTaxException_tblARCustomer] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityId]),
	CONSTRAINT [FK_tblARCustomerTaxingTaxException_tblCFCard] FOREIGN KEY ([intCardId]) REFERENCES [dbo].[tblCFCard] ([intCardId]),
	CONSTRAINT [FK_tblARCustomerTaxingTaxException_tblCFVehicle] FOREIGN KEY ([intVehicleId]) REFERENCES [dbo].[tblCFVehicle] ([intVehicleId]),
	CONSTRAINT FK_tblARCustomerTaxingTaxException_tblEMEntityLocation FOREIGN KEY ([intEntityCustomerLocationId]) REFERENCES [tblEMEntityLocation]([intEntityLocationId])
)
