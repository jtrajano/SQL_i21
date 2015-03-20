CREATE TABLE [dbo].[tblTMCustomer] (
    [intConcurrencyId]     INT DEFAULT 1 NOT NULL,
    [intCustomerID]        INT IDENTITY (1, 1) NOT NULL,
    [intCurrentSiteNumber] INT DEFAULT 0 NOT NULL,
    [intCustomerNumber]    INT DEFAULT 0 NOT NULL,
    [strOriginCustomerKey] NVARCHAR(15) COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL, 
    CONSTRAINT [PK_tblTMCustomer] PRIMARY KEY CLUSTERED ([intCustomerID] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCustomer',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCustomer',
    @level2type = N'COLUMN',
    @level2name = N'intCustomerID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Latest Site Number for the customer',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCustomer',
    @level2type = N'COLUMN',
    @level2name = N'intCurrentSiteNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer record ID from the customer maintenance table ',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCustomer',
    @level2type = N'COLUMN',
    @level2name = N'intCustomerNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Number from the customer maintenance table ',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCustomer',
    @level2type = N'COLUMN',
    @level2name = N'strOriginCustomerKey'