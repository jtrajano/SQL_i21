CREATE TABLE [dbo].[tblGLAccountUnit] (
    [intAccountUnitId] INT             IDENTITY (1, 1) NOT NULL,
    [strUOMCode]       NVARCHAR (50)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strUOMDesc]       NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [dblLbsPerUnit]    DECIMAL (16, 4) NULL,
    [intConcurrencyId] INT             DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLAccountUnit] PRIMARY KEY CLUSTERED ([intAccountUnitId] ASC)
);

