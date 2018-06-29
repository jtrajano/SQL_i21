CREATE TABLE [dbo].[tblRMDefaultOption] (
    [intDefaultOptionId]     INT            IDENTITY (1, 1) NOT NULL,
    [strName]                NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strDescription]         NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intType]                INT            NULL,
    [strSettings]            NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [ysnShow]                BIT            NULL,
    [intReportId]            INT            NULL,
    [ysnEnable]              BIT            NULL,
    [intSortId]              INT            NULL,
    [intUserId]              INT            NULL,
    [intOptionConcurrencyId] INT            NULL,
    [intConcurrencyId]       INT            CONSTRAINT [DF_tblRMDefaultOption_intConcurrencyId] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_tblRMDefaultOption] PRIMARY KEY CLUSTERED ([intDefaultOptionId] ASC),
    CONSTRAINT [FK_tblRMDefaultOption_tblRMReport] FOREIGN KEY ([intReportId]) REFERENCES [dbo].[tblRMReport] ([intReportId])
);

