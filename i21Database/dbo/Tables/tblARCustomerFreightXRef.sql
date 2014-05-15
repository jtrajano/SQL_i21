﻿CREATE TABLE [dbo].[tblARCustomerFreightXRef] (
    [intFreightXRefId]  INT             IDENTITY (1, 1) NOT NULL,
    [intEntityId]       INT             NOT NULL,
    [intTerminalVendorId] INT			NULL,
    [strClassCode]      NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [ysnFreightOnly]    BIT             NOT NULL DEFAULT ((0)),
    [strFreightType]    NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [dblFreightAmount]  NUMERIC (18, 6) NULL,
    [dblFreightRate]    NUMERIC (18, 6) NULL,
    [dblMinimumUnits]   NUMERIC (18, 6) NULL,
    [ysnFreightInPrice] BIT             NOT NULL DEFAULT ((0)),
    [dblFreightMiles]   NUMERIC (18, 6) NULL,
    [strCarrier]        NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]  INT             NOT NULL,
    CONSTRAINT [PK_tblARFreightXReference] PRIMARY KEY CLUSTERED ([intFreightXRefId] ASC)
);

