CREATE TABLE [dbo].[tblGLAccountReallocation] (
    [intAccountReallocationId] INT           IDENTITY (1, 1) NOT NULL,
    [strName]                  NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strDescription]           NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]         INT           DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLAccountReallocation] PRIMARY KEY CLUSTERED ([intAccountReallocationId] ASC)
);

