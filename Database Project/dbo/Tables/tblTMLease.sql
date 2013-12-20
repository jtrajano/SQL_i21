CREATE TABLE [dbo].[tblTMLease] (
    [intConcurrencyID]        INT           CONSTRAINT [DEF_tblTMLease_intConcurrencyID] DEFAULT ((0)) NULL,
    [intLeaseID]              INT           IDENTITY (1, 1) NOT NULL,
    [intLeaseCodeID]          INT           CONSTRAINT [DEF_tblTMLease_intLeaseCodeID] DEFAULT ((0)) NULL,
    [strLeaseNumber]          NVARCHAR (50) COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMLease_strLeaseNumber] DEFAULT ('') NOT NULL,
    [intBillToCustomerID]     INT           CONSTRAINT [DEF_tblTMLease_intBillToCustomerID] DEFAULT ((0)) NULL,
    [ysnLeaseToOwn]           BIT           CONSTRAINT [DEF_tblTMLease_ysnLeaseToOwn] DEFAULT ((0)) NULL,
    [strLeaseStatus]          NVARCHAR (50) COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMLease_strLeaseStatus] DEFAULT ('') NULL,
    [strBillingFrequency]     NVARCHAR (50) COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMLease_strBillingFrequency] DEFAULT ('') NULL,
    [intBillingMonth]         INT           CONSTRAINT [DEF_tblTMLease_intBillingMonth] DEFAULT ((0)) NULL,
    [strBillingType]          NVARCHAR (50) COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMLease_strBillingType] DEFAULT ('') NULL,
    [dtmStartDate]            DATETIME      CONSTRAINT [DEF_tblTMLease_dtmStartDate] DEFAULT ((0)) NULL,
    [dtmDontBillAfter]        DATETIME      CONSTRAINT [DEF_tblTMLease_dtmDontBillAfter] DEFAULT ((0)) NULL,
    [strRentalStatus]         NVARCHAR (20) COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMLease_strRentalStatus] DEFAULT ('') NULL,
    [dtmLastLeaseBillingDate] DATETIME      NULL,
    CONSTRAINT [PK_tblTMLease] PRIMARY KEY CLUSTERED ([intLeaseID] ASC),
    CONSTRAINT [FK_tblTMLease_tblTMLeaseCode] FOREIGN KEY ([intLeaseCodeID]) REFERENCES [dbo].[tblTMLeaseCode] ([intLeaseCodeID]) ON DELETE SET NULL,
    CONSTRAINT [UQ_tblTMLease_strLeaseNumber] UNIQUE NONCLUSTERED ([strLeaseNumber] ASC)
);

