CREATE TABLE [dbo].[tblTMLeaseCode] (
    [intConcurrencyID] INT             CONSTRAINT [DEF_tblTMLeaseCode_intConcurrencyID] DEFAULT ((0)) NULL,
    [intLeaseCodeID]   INT             IDENTITY (1, 1) NOT NULL,
    [strLeaseCode]     NVARCHAR (50)   COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMLeaseCode_strLeaseCode] DEFAULT ('') NOT NULL,
    [strDescription]   NVARCHAR (150)  COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMLeaseCode_strDescription] DEFAULT ('') NULL,
    [dblAmount]        NUMERIC (18, 6) CONSTRAINT [DEF_tblTMLeaseCode_dblAmount] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblTMLeaseCode] PRIMARY KEY CLUSTERED ([intLeaseCodeID] ASC),
    CONSTRAINT [UQ_tblTMLeaseCode_strLeaseCode] UNIQUE NONCLUSTERED ([strLeaseCode] ASC)
);

