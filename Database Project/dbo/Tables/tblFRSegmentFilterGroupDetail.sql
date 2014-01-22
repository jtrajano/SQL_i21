CREATE TABLE [dbo].[tblFRSegmentFilterGroupDetail] (
    [intSegmentFilterGroupDetailID] INT            IDENTITY (1, 1) NOT NULL,
	[intSegmentFilterGroupID]		INT            NOT NULL,
    [strJoin]                       NVARCHAR (10)  COLLATE Latin1_General_CI_AS NULL,
    [strSegmentCode]                NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strSegmentName]                NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [ysnDisplayToHeader]            BIT            DEFAULT ((0)) NULL,
    [intConcurrencyID]              INT            DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblFRSegmentFilterGroupDetail] PRIMARY KEY CLUSTERED ([intSegmentFilterGroupDetailID] ASC, [intSegmentFilterGroupID] ASC)
);