CREATE TABLE [dbo].[tblFRColumnDesignSegment] (
    [intColumnSegmentID] INT            IDENTITY (1, 1) NOT NULL,
    [strJoin]            NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [intSegmentType]     INT            NOT NULL,
    [strSegment]         NVARCHAR (500) COLLATE Latin1_General_CI_AS NULL,
    [strSegmentCode]     NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
    [intColumnID]        INT            NOT NULL,
    [intRefNo]           INT            NOT NULL,
    [intConcurrencyID]   INT            DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblFRColumnDesignSegment_1] PRIMARY KEY CLUSTERED ([intColumnSegmentID] ASC)
);

