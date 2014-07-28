CREATE TABLE [dbo].[tblSMStartingNumber] (
    [intStartingNumberId]                INT            IDENTITY (1, 1) NOT NULL,
    [strTransactionType]   NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
    [strPrefix]            NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL,
    [intNumber]            INT            NOT NULL,
    [strModule]            NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL,
    [ysnEnable]            BIT            NOT NULL DEFAULT 0,
    [intConcurrencyId]     INT            DEFAULT 1 NOT NULL, 
    CONSTRAINT [PK_tblSMStartingNumber] PRIMARY KEY ([intStartingNumberId] ASC) ,
	CONSTRAINT [AK_tblSMStartingNumber_strTransactionType] UNIQUE NONCLUSTERED ([strTransactionType] ASC)

);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMStartingNumber',
    @level2type = N'COLUMN',
    @level2name = N'intStartingNumberId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Transaction Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMStartingNumber',
    @level2type = N'COLUMN',
    @level2name = N'strTransactionType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Prefix',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMStartingNumber',
    @level2type = N'COLUMN',
    @level2name = N'strPrefix'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMStartingNumber',
    @level2type = N'COLUMN',
    @level2name = N'intNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Module Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMStartingNumber',
    @level2type = N'COLUMN',
    @level2name = N'strModule'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Starting Number is enabled',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMStartingNumber',
    @level2type = N'COLUMN',
    @level2name = N'ysnEnable'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMStartingNumber',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'