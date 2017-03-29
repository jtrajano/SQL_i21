﻿CREATE TABLE [dbo].[tblARCustomerSpecialPrice] (
    [intSpecialPriceId] INT             IDENTITY (1, 1) NOT NULL,
    [intEntityCustomerId]       INT             NOT NULL,
    [intEntityVendorId]       INT				NULL,
    [intItemId]			INT				NULL,
    [strClass]          NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strPriceBasis]     NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strCustomerGroup]  NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strCostToUse]      NVARCHAR(50)	COLLATE Latin1_General_CI_AS NULL,
    [dblDeviation]      NUMERIC (18, 6) NULL,
    [strLineNote]       NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [dtmBeginDate]      DATETIME        NOT NULL,
    [dtmEndDate]        DATETIME        NULL,
    --[ysnConsignable]    BIT             NOT NULL DEFAULT ((0)),
    [intRackVendorId]   INT				NULL,
    [intRackItemId] INT				NULL,
	[intEntityLocationId] INT			NULL,
	[intRackLocationId] INT			NULL,
	[intCustomerLocationId]			INT		NULL,
	[strInvoiceType]    NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
	[intCategoryId]		INT				NULL,
	[intCurrencyId] INT NULL,
    [intConcurrencyId]  INT             NOT NULL,
    CONSTRAINT [PK_tblARCustomerSpecialPrice] PRIMARY KEY CLUSTERED ([intSpecialPriceId] ASC),
	CONSTRAINT [FK_tblARCustomerSpecialPrice_tblEMEntityLocation] FOREIGN KEY ([intEntityLocationId]) REFERENCES [tblEMEntityLocation]([intEntityLocationId]),
	CONSTRAINT [FK_tblARCustomerSpecialPrice_tblEMEntityLocation_Rack] FOREIGN KEY ([intRackLocationId]) REFERENCES [tblEMEntityLocation]([intEntityLocationId]),
	CONSTRAINT [FK_tblARCustomerSpecialPrice_tblEMEntityLocation_Customer] FOREIGN KEY ([intCustomerLocationId]) REFERENCES [tblEMEntityLocation]([intEntityLocationId]),	
	CONSTRAINT [FK_tblARCustomerSpecialPrice_tblARCustomer] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblARCustomerSpecialPrice_tblSMCurrency_intCurrencyId] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID])
);


