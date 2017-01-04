﻿CREATE TABLE [dbo].[tblGRDiscountId]
(
	[intDiscountId] INT NOT NULL IDENTITY, 
    [intCurrencyId] INT NOT NULL, 
    [strDiscountId] NVARCHAR(3) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strDiscountDescription] NVARCHAR(30) COLLATE Latin1_General_CI_AS NOT NULL, 
    [ysnDiscountIdActive] BIT NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [PK_tblGRDiscountId_intDiscountId] PRIMARY KEY ([intDiscountId]), 
    CONSTRAINT [FK_tblGRDiscountId_tblSMCurrency_intCurrencyId] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]), 
    CONSTRAINT [UK_tblGRDiscountId_strDiscountId_intCurrencyId] UNIQUE ([strDiscountId], [intCurrencyId]) 
)