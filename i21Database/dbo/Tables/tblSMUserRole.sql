﻿CREATE TABLE [dbo].[tblSMUserRole] (
    [intUserRoleID]     INT            IDENTITY (1, 1) NOT NULL,
    [strName]           NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL ,
    [strDescription]    NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [strMenu]           NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strMenuPermission] NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strForm]           NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
	[strRoleType]       NVARCHAR (20) COLLATE Latin1_General_CI_AS NULL,
    [ysnAdmin]          BIT            DEFAULT ((0)) NOT NULL,
    [intConcurrencyId]  INT            DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_Role] PRIMARY KEY CLUSTERED ([intUserRoleID] ASC)--, 
    --CONSTRAINT [UQ_tblSMUserRole_strName] UNIQUE ([strName]) 
);


GO
