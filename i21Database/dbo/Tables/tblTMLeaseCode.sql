CREATE TABLE [dbo].[tblTMLeaseCode] (
    [intConcurrencyId] INT             DEFAULT 1 NOT NULL,
    [intLeaseCodeId]   INT             IDENTITY (1, 1) NOT NULL,
    [strLeaseCode]     NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [strDescription]   NVARCHAR (150)  COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [dblAmount]        NUMERIC (18, 6) DEFAULT 0 NOT NULL,
    CONSTRAINT [PK_tblTMLeaseCode] PRIMARY KEY CLUSTERED ([intLeaseCodeId] ASC),
    CONSTRAINT [UQ_tblTMLeaseCode_strLeaseCode] UNIQUE NONCLUSTERED ([strLeaseCode] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMLeaseCode',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMLeaseCode',
    @level2type = N'COLUMN',
    @level2name = N'intLeaseCodeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Lease Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMLeaseCode',
    @level2type = N'COLUMN',
    @level2name = N'strLeaseCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMLeaseCode',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Amount',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMLeaseCode',
    @level2type = N'COLUMN',
    @level2name = N'dblAmount'