CREATE TABLE [dbo].[tblRMOption] (
    [intOptionId]            INT            IDENTITY (1, 1) NOT NULL,
    [strName]                NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strDescription]         NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intType]                INT            NOT NULL,
    [strSettings]            NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [ysnShow]                BIT            NULL,
    [intReportId]            INT            NOT NULL,
    [ysnEnable]              BIT            NOT NULL,
    [intSortId]              INT            NOT NULL,
    [ysnDefault]             BIT            NULL,
    [intUserId]              INT            NULL,
    [intOptionConcurrencyId] INT            NULL,
    [intConcurrencyId]       INT            CONSTRAINT [DF__tblRMOpti__intCo__703483B9] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_dbo.Options] PRIMARY KEY CLUSTERED ([intOptionId] ASC),
    CONSTRAINT [FK_tblRMOption_tblRMReport] FOREIGN KEY ([intReportId]) REFERENCES [dbo].[tblRMReport] ([intReportId]) ON DELETE CASCADE
);





