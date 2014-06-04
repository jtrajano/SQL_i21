CREATE TABLE [dbo].[tblARCustomerPortalMenu] (
    [intCustomerPortalMenuId]       INT           IDENTITY (1, 1) NOT NULL,
    [strCustomerPortalMenuName]     NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [intCustomerPortalParentMenuId] INT           NOT NULL,
    [strType]                       NVARCHAR (10) COLLATE Latin1_General_CI_AS NULL,
    [strCommand] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    CONSTRAINT [PK_tblARCustomerPortalMenu] PRIMARY KEY CLUSTERED ([intCustomerPortalMenuId] ASC)
);

