CREATE TABLE [dbo].[tblFRSegmentFilterGroup] (
    [intSegmentFilterGroupID] INT            IDENTITY (1, 1) NOT NULL,
    [strFilterString]         NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strSegmentFilterGroup]   NVARCHAR (75)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strSegmentString]        NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]        INT            DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblFRSegmentFilterGroup] PRIMARY KEY CLUSTERED ([intSegmentFilterGroupID] ASC)
);

