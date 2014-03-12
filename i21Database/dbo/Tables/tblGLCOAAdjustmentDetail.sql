CREATE TABLE [dbo].[tblGLCOAAdjustmentDetail] (
    [intCOAAdjustmentDetailId] INT           IDENTITY (1, 1) NOT NULL,
    [intCOAAdjustmentId]       INT           NULL,
    [strAction]                NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strType]                  NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strNew]                   NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strPrimaryField]          NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strOriginal]              NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [intAccountId]             INT           NULL,
    [intAccountGroupId]        INT           NULL,
    [intConcurrencyId]         INT           DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLCOAAdjustmentDetail] PRIMARY KEY CLUSTERED ([intCOAAdjustmentDetailId] ASC),
    CONSTRAINT [FK_tblGLCOAAdjustmentDetail_tblGLAccountGroup] FOREIGN KEY ([intAccountGroupId]) REFERENCES [dbo].[tblGLAccountGroup] ([intAccountGroupId]),
    CONSTRAINT [FK_tblGLCOAAdjustmentDetail_tblGLCOAAdjustment] FOREIGN KEY ([intCOAAdjustmentId]) REFERENCES [dbo].[tblGLCOAAdjustment] ([intCOAAdjustmentId]) ON DELETE CASCADE
);

