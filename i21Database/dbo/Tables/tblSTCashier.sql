﻿CREATE TABLE [dbo].[tblSTCashier] (
    [intCashierId]     INT            IDENTITY (1, 1) NOT NULL,
    [strCashierNumber] NVARCHAR (MAX) NULL,
    [strCashierName]   NVARCHAR (MAX) NULL,
    [intConcurrencyId] INT            CONSTRAINT [DF_tblSTCashier_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblSTCashier] PRIMARY KEY CLUSTERED ([intCashierId] ASC)
);

