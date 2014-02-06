CREATE TABLE [dbo].[tblGLAccountSegment] (
    [intAccountSegmentID]   INT            IDENTITY (1, 1) NOT NULL,
    [strCode]               NVARCHAR (20)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strDescription]        NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
    [intAccountStructureID] INT            NOT NULL,
    [intAccountGroupID]     INT            NULL,
    [ysnActive]             BIT            CONSTRAINT [DF_tblGLAccountSegment_ysnActive] DEFAULT ((1)) NULL,
    [ysnSelected]           BIT            CONSTRAINT [DF_tblGLAccountSegment_ysnSelected] DEFAULT ((0)) NOT NULL,
    [ysnBuild]              BIT            CONSTRAINT [DF_tblGLAccountSegment_ysnBuild] DEFAULT ((0)) NOT NULL,
    [ysnIsNotExisting]      BIT            CONSTRAINT [DF_tblGLAccountSegment_ysnIsNotExisting] DEFAULT ((0)) NULL,
    [intConcurrencyId]      INT            DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_GLAccountSegment_AccountSegmentID] PRIMARY KEY CLUSTERED ([intAccountSegmentID] ASC),
    CONSTRAINT [FK_tblGLAccountSegment_tblGLAccountGroup] FOREIGN KEY ([intAccountGroupID]) REFERENCES [dbo].[tblGLAccountGroup] ([intAccountGroupID]),
    CONSTRAINT [FK_tblGLAccountSegment_tblGLAccountStructure] FOREIGN KEY ([intAccountStructureID]) REFERENCES [dbo].[tblGLAccountStructure] ([intAccountStructureID])
);

