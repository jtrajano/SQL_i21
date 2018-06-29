CREATE TABLE [dbo].[tblSMMenu] (
    [intMenuID]        INT            IDENTITY (1, 1) NOT NULL,
    [strName]          NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strTemplate]      NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT            DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_Menu] PRIMARY KEY CLUSTERED ([intMenuID] ASC)
);

