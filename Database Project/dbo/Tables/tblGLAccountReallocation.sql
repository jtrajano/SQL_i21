CREATE TABLE [dbo].[tblGLAccountReallocation] (
    [intAccountReallocationID] INT           IDENTITY (1, 1) NOT NULL,
    [strName]                  NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strDescription]           NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyID]         INT           CONSTRAINT [DF_tblGLAccountReallocation_intConcurrencyID] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblGLAccountReallocation] PRIMARY KEY CLUSTERED ([intAccountReallocationID] ASC)
);

