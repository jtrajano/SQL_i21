CREATE TABLE [dbo].[tblTMLease] (
    [intConcurrencyId]        INT           DEFAULT 1 NOT NULL,
    [intLeaseId]              INT           IDENTITY (1, 1) NOT NULL,
    [intLeaseCodeId]          INT           DEFAULT 0 NULL,
    [strLeaseNumber]          NVARCHAR (50) COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [intBillToCustomerId]     INT           DEFAULT 0 NULL,
    [ysnLeaseToOwn]           BIT           DEFAULT 0 NOT NULL,
    [strLeaseStatus]          NVARCHAR (50) COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strBillingFrequency]     NVARCHAR (50) COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [intBillingMonth]         INT           DEFAULT 0 NULL,
    [strBillingType]          NVARCHAR (50) COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [dtmStartDate]            DATETIME      DEFAULT 0 NULL,
    [dtmDontBillAfter]        DATETIME      DEFAULT 0 NULL,
    [strRentalStatus]         NVARCHAR (20) COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [dtmLastLeaseBillingDate] DATETIME      NULL,
    CONSTRAINT [PK_tblTMLease] PRIMARY KEY CLUSTERED ([intLeaseId] ASC),
    CONSTRAINT [FK_tblTMLease_tblTMLeaseCode] FOREIGN KEY ([intLeaseCodeId]) REFERENCES [dbo].[tblTMLeaseCode] ([intLeaseCodeId]),
    CONSTRAINT [UQ_tblTMLease_strLeaseNumber] UNIQUE NONCLUSTERED ([strLeaseNumber] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Indicates if Lease to Own',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMLease',
    @level2type = N'COLUMN',
    @level2name = N'ysnLeaseToOwn'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMLease',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMLease',
    @level2type = N'COLUMN',
    @level2name = N'intLeaseId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Lease Code ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMLease',
    @level2type = N'COLUMN',
    @level2name = N'intLeaseCodeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Lease Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMLease',
    @level2type = N'COLUMN',
    @level2name = N'strLeaseNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Bill to Customer ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMLease',
    @level2type = N'COLUMN',
    @level2name = N'intBillToCustomerId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Lease Status',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMLease',
    @level2type = N'COLUMN',
    @level2name = N'strLeaseStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Billing Frequency',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMLease',
    @level2type = N'COLUMN',
    @level2name = N'strBillingFrequency'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Billing Month',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMLease',
    @level2type = N'COLUMN',
    @level2name = N'intBillingMonth'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'BIlling Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMLease',
    @level2type = N'COLUMN',
    @level2name = N'strBillingType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Start Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMLease',
    @level2type = N'COLUMN',
    @level2name = N'dtmStartDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Dont Bill After Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMLease',
    @level2type = N'COLUMN',
    @level2name = N'dtmDontBillAfter'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Rental Status',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMLease',
    @level2type = N'COLUMN',
    @level2name = N'strRentalStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Lease Billing Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMLease',
    @level2type = N'COLUMN',
    @level2name = N'dtmLastLeaseBillingDate'