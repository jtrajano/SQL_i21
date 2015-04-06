CREATE TABLE [dbo].[tblEntityPortalMenu]
(
	[intEntityPortalMenuId]       INT           IDENTITY (1, 1) NOT NULL,
    [strPortalMenuName]     NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [intPortalParentMenuId] INT           NOT NULL,
    [strType]                       NVARCHAR (10) COLLATE Latin1_General_CI_AS NULL,
	[strEntityType]                       NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strCommand] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    CONSTRAINT [PK_tblEntityPortalMenu] PRIMARY KEY CLUSTERED ([intEntityPortalMenuId] ASC)
);
