CREATE TABLE [dbo].[tblSMUserSecurity] (
    [intUserSecurityID] INT            IDENTITY (1, 1) NOT NULL,
    [intUserRoleID]     INT            NULL,
    [strUserName]       NVARCHAR (50)  COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [strFullName]       NVARCHAR (50)  COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [strPassword]       NVARCHAR (50)  COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [strFirstName]      NVARCHAR (50)  COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [strMiddleName]     NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strLastName]       NVARCHAR (50)  COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [strPhone]          NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strDepartment]     NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strLocation]       NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strEmail]          NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strMenuPermission] NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strMenu]           NVARCHAR (MAX) COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [strForm]           NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strFavorite]       NVARCHAR (MAX) COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [ysnDisabled]       BIT            DEFAULT ((0)) NOT NULL,
    [ysnAdmin]          BIT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED ([intUserSecurityID] ASC),
    CONSTRAINT [FK_UserSecurity_UserRole] FOREIGN KEY ([intUserRoleID]) REFERENCES [dbo].[tblSMUserRole] ([intUserRoleID])
);

