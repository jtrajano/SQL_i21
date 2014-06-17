CREATE TABLE [dbo].[tblFRGroupOtherReport] (
    [intGroupOtherReportId] INT            IDENTITY (1, 1) NOT NULL,
    [strReportGroup]        NVARCHAR (255) COLLATE Latin1_General_CI_AS NOT NULL,
    [strFRReportGroup]      NVARCHAR (255) COLLATE Latin1_General_CI_AS NOT NULL,
    [strReportName]         NVARCHAR (200) COLLATE Latin1_General_CI_AS NOT NULL,
    [strFullpath]           NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL,
    [ysnShowCriteria]       BIT            DEFAULT ((0)) NOT NULL,
    [intConcurrencyId]      INT            DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblFRGroupOtherReport] PRIMARY KEY CLUSTERED ([intGroupOtherReportId] ASC, [strFRReportGroup] ASC)
);

