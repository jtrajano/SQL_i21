CREATE TABLE [dbo].[tblGLModuleList] (
    [cntId]            INT           IDENTITY (1, 1) NOT NULL,
    [strModule]        NVARCHAR (20) COLLATE Latin1_General_CI_AS NOT NULL,
    [ysnOpen]          BIT           NOT NULL,
    [intConcurrencyId] INT           DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLModuleList] PRIMARY KEY CLUSTERED ([cntId] ASC, [strModule] ASC)
);

