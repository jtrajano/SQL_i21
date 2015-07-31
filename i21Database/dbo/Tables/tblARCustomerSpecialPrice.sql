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
    [ysnConsignable]    BIT             NOT NULL DEFAULT ((0)),
    [intRackVendorId]   INT				NULL,
    [intRackItemId] INT				NULL,
	[intSupplyPointId] INT			NULL,
    [intConcurrencyId]  INT             NOT NULL,
    CONSTRAINT [PK_tblARCustomerSpecialPrice] PRIMARY KEY CLUSTERED ([intSpecialPriceId] ASC),
	CONSTRAINT [FK_tblARCustomerSpecialPrice_tblTRSupplyPoint] FOREIGN KEY ([intSupplyPointId]) REFERENCES [tblTRSupplyPoint]([intSupplyPointId])
);

