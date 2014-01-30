CREATE TABLE [dbo].[tblSMUserRole] (
    [intUserRoleID]     INT            IDENTITY (1, 1) NOT NULL,
    [strName]           NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strDescription]    NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strMenu]           NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NOT NULL,
    [strMenuPermission] NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strForm]           NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [ysnAdmin]          BIT            DEFAULT ((0)) NOT NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [PK_Role] PRIMARY KEY CLUSTERED ([intUserRoleID] ASC)
);

