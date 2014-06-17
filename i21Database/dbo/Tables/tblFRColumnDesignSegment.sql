CREATE TABLE [dbo].[tblFRColumnDesignSegment] (
    [intColumnSegmentId]	INT            IDENTITY (1, 1) NOT NULL,
    [intColumnDetailId]		INT            NOT NULL,
    [strJoin]				NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [intSegmentType]		INT            NOT NULL,
    [strSegment]			NVARCHAR (500) COLLATE Latin1_General_CI_AS NULL,
    [strSegmentCode]		NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
    [intColumnId]			INT            NOT NULL,
    [intRefNo]				INT            NOT NULL,    
    [intConcurrencyId]		INT            DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblFRColumnDesignSegment] PRIMARY KEY CLUSTERED ([intColumnSegmentId] ASC),
    CONSTRAINT [FK_tblFRColumnDesign_tblFRColumnDesignSegment] FOREIGN KEY([intColumnDetailId]) REFERENCES [dbo].[tblFRColumnDesign] ([intColumnDetailId]) ON DELETE CASCADE
);

