CREATE TABLE [dbo].[tblFRGroupsDetail] (
    [intGroupDetailID]      INT            IDENTITY (1, 1) NOT NULL,
    [strSegmentFilter]      NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strGroupName]          NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [ysnShowReportSettings] BIT            NULL,
    [strReportName]         NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
    [strReportDescription]  NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]      INT            DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblFRGroupsDetail] PRIMARY KEY CLUSTERED ([intGroupDetailID] ASC)
);

