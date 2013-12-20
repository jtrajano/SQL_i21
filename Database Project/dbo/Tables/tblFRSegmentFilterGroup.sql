CREATE TABLE [dbo].[tblFRSegmentFilterGroup] (
    [intSegmentFilterGroupID] INT             IDENTITY (1, 1) NOT NULL,
    [strFilterString]         NVARCHAR (4000) COLLATE Latin1_General_CI_AS NULL,
    [strSegmentFilterGroup]   NVARCHAR (75)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strSegmentString]        NVARCHAR (4000) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyID]        INT             DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblFRSegmentFilterGroup] PRIMARY KEY CLUSTERED ([intSegmentFilterGroupID] ASC, [strSegmentFilterGroup] ASC)
);

