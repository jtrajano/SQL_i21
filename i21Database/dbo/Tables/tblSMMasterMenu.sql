CREATE TABLE [dbo].[tblSMMasterMenu] (
    [intMenuID]        INT            IDENTITY (1, 1) NOT NULL,
    [strMenuName]      NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
    [strModuleName]    NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL,
    [intParentMenuID]  INT            NULL,
    [strDescription]   NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strType]          NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strCommand]       NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strIcon]          NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [ysnVisible]       BIT            DEFAULT ((0)) NOT NULL,
    [ysnExpanded]      BIT            DEFAULT ((0)) NOT NULL,
    [ysnIsLegacy]      BIT            DEFAULT ((0)) NOT NULL,
    [ysnLeaf]          BIT            DEFAULT ((1)) NOT NULL,
    [intSort]          INT            NULL,
    [intConcurrencyId] INT            DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_tblSMMasterMenu] PRIMARY KEY CLUSTERED ([intMenuID] ASC)
);

