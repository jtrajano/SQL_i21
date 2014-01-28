CREATE TABLE [dbo].[tblGLCOAAdjustmentDetail] (
    [intCOAAdjustmentDetailID] INT           IDENTITY (1, 1) NOT NULL,
    [intCOAAdjustmentID]       INT           NULL,
    [strAction]                NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strType]                  NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strNew]                   NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strPrimaryField]          NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strOriginal]              NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [intAccountID]             INT           NULL,
    [intAccountGroupID]        INT           NULL,
	[intConcurrencyId]         INT           NOT NULL DEFAULT 1,
    CONSTRAINT [PK_tblGLCOAAdjustmentDetail] PRIMARY KEY CLUSTERED ([intCOAAdjustmentDetailID] ASC),
    CONSTRAINT [FK_tblGLCOAAdjustmentDetail_tblGLAccountGroup] FOREIGN KEY ([intAccountGroupID]) REFERENCES [dbo].[tblGLAccountGroup] ([intAccountGroupID]),
    CONSTRAINT [FK_tblGLCOAAdjustmentDetail_tblGLCOAAdjustment] FOREIGN KEY ([intCOAAdjustmentID]) REFERENCES [dbo].[tblGLCOAAdjustment] ([intCOAAdjustmentID]) ON DELETE CASCADE
);

