CREATE TABLE [dbo].[tblFRGroupOtherReports] (
    [intGroupOtherReportID] INT            IDENTITY (1, 1) NOT NULL,
    [strReportGroup]        NVARCHAR (255) COLLATE Latin1_General_CI_AS NOT NULL,
    [strFRReportGroup]      NVARCHAR (255) COLLATE Latin1_General_CI_AS NOT NULL,
    [strReportName]         NVARCHAR (200) COLLATE Latin1_General_CI_AS NOT NULL,
    [strFullpath]           NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL,
    [ysnShowCriteria]       BIT            DEFAULT ((0)) NOT NULL,
    [intConcurrencyID]      INT            DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblFRGroupOtherReports] PRIMARY KEY CLUSTERED ([intGroupOtherReportID] ASC, [strFRReportGroup] ASC)
);

