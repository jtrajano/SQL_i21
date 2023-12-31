﻿CREATE TABLE [dbo].[tblTMDeliveryMethod] (
    [intConcurrencyId]    INT           DEFAULT 1 NOT NULL,
    [intDeliveryMethodID] INT           IDENTITY (1, 1) NOT NULL,
    [strDeliveryMethod]   NVARCHAR (50) COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_tblTMDeliveryMethod] PRIMARY KEY CLUSTERED ([intDeliveryMethodID] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryMethod',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryMethod',
    @level2type = N'COLUMN',
    @level2name = N'intDeliveryMethodID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Delivery Method Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryMethod',
    @level2type = N'COLUMN',
    @level2name = N'strDeliveryMethod'