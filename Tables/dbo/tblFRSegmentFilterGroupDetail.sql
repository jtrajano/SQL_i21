CREATE TABLE [dbo].[tblFRSegmentFilterGroupDetail] (
    [intSegmentFilterGroupDetailId] INT            IDENTITY (1, 1) NOT NULL,
    [intSegmentFilterGroupId]       INT            NOT NULL,
    [strJoin]                       NVARCHAR (10)  COLLATE Latin1_General_CI_AS NULL,
    [strSegmentCode]                NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strSegmentName]                NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [ysnDisplayToHeader]            BIT            DEFAULT ((0)) NULL,
    [intConcurrencyId]              INT            DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblFRSegmentFilterGroupDetail] PRIMARY KEY CLUSTERED ([intSegmentFilterGroupDetailId] ASC, [intSegmentFilterGroupId] ASC),
    CONSTRAINT [FK_tblFRSegmentFilterGroupDetail_tblFRSegmentFilterGroup] FOREIGN KEY ([intSegmentFilterGroupId]) REFERENCES [dbo].[tblFRSegmentFilterGroup] ([intSegmentFilterGroupId]) ON DELETE CASCADE
);

