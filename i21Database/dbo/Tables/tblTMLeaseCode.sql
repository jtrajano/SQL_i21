CREATE TABLE [dbo].[tblTMLeaseCode] (
    [intConcurrencyId] INT             DEFAULT 1 NOT NULL,
    [intLeaseCodeId]   INT             IDENTITY (1, 1) NOT NULL,
    [strLeaseCode]     NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [strDescription]   NVARCHAR (150)  COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [dblAmount]        NUMERIC (18, 6) DEFAULT 0 NOT NULL,
    CONSTRAINT [PK_tblTMLeaseCode] PRIMARY KEY CLUSTERED ([intLeaseCodeId] ASC),
    CONSTRAINT [UQ_tblTMLeaseCode_strLeaseCode] UNIQUE NONCLUSTERED ([strLeaseCode] ASC)
);

