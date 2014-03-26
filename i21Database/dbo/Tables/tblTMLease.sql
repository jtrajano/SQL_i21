CREATE TABLE [dbo].[tblTMLease] (
    [intConcurrencyId]        INT           DEFAULT 1 NOT NULL,
    [intLeaseId]              INT           IDENTITY (1, 1) NOT NULL,
    [intLeaseCodeID]          INT           DEFAULT 0 NULL,
    [strLeaseNumber]          NVARCHAR (50) COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [intBillToCustomerID]     INT           DEFAULT 0 NULL,
    [ysnLeaseToOwn]           BIT           DEFAULT 0 NULL,
    [strLeaseStatus]          NVARCHAR (50) COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strBillingFrequency]     NVARCHAR (50) COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [intBillingMonth]         INT           DEFAULT 0 NULL,
    [strBillingType]          NVARCHAR (50) COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [dtmStartDate]            DATETIME      DEFAULT 0 NULL,
    [dtmDontBillAfter]        DATETIME      DEFAULT 0 NULL,
    [strRentalStatus]         NVARCHAR (20) COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [dtmLastLeaseBillingDate] DATETIME      NULL,
    CONSTRAINT [PK_tblTMLease] PRIMARY KEY CLUSTERED ([intLeaseId] ASC),
    CONSTRAINT [FK_tblTMLease_tblTMLeaseCode] FOREIGN KEY ([intLeaseCodeID]) REFERENCES [dbo].[tblTMLeaseCode] ([intLeaseCodeID]) ON DELETE SET NULL,
    CONSTRAINT [UQ_tblTMLease_strLeaseNumber] UNIQUE NONCLUSTERED ([strLeaseNumber] ASC)
);

