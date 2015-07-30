﻿CREATE TABLE [dbo].[tblARCustomerFreightXRef] (
    [intFreightXRefId]  INT             IDENTITY (1, 1) NOT NULL,
    [intEntityCustomerId]       INT             NOT NULL,
    [intSupplyPointId] INT			NULL,
    [intCategoryId]      INT				NULL,
    [ysnFreightOnly]    BIT             NOT NULL DEFAULT ((0)),
    [strFreightType]    NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [dblFreightAmount]  NUMERIC (18, 6) NULL,
    [dblFreightRate]    NUMERIC (18, 6) NULL,
    [dblMinimumUnits]   NUMERIC (18, 6) NULL,
    [ysnFreightInPrice] BIT             NOT NULL DEFAULT ((0)),
    [dblFreightMiles]   NUMERIC (18, 6) NULL,
    [intShipViaId]       INT				NULL,
	[intEntityLocationId]		INT			NULL,
    [intConcurrencyId]  INT             NOT NULL,
    CONSTRAINT [PK_tblARCustomerFreightXRef] PRIMARY KEY CLUSTERED ([intFreightXRefId] ASC),
	CONSTRAINT [FK_tblARCustomerFreightXRef_tblICCategory] FOREIGN KEY ([intCategoryId]) REFERENCES [tblICCategory]([intCategoryId]),
	CONSTRAINT [FK_tblARCustomerFreightXRef_tblSMShipVia] FOREIGN KEY ([intShipViaId]) REFERENCES [tblSMShipVia]([intEntityShipViaId]),
	CONSTRAINT [FK_tblARCustomerFreightXRef_tblTRSupplyPoint] FOREIGN KEY ([intSupplyPointId]) REFERENCES [tblTRSupplyPoint]([intSupplyPointId]),
	CONSTRAINT [FK_tblARCustomerFreightXRef_tblARCustomer] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityCustomerId]),
	CONSTRAINT [FK_tblARCustomerFreightXRef_tblEntityLocation] FOREIGN KEY ([intEntityLocationId]) REFERENCES [dbo].[tblEntityLocation] ([intEntityLocationId]),
	CONSTRAINT [UK_tblARCustomerFreightXRef_reference_columns] UNIQUE NONCLUSTERED ([intSupplyPointId] ASC, [intCategoryId] ASC,[intEntityLocationId] ASC)	--THE NAME IS USED IN THE FRONT END, IF THERE ARE CHANGES PLEASE INFORM MON.GONZALES
);

