CREATE TABLE [dbo].[tblAPVendorPortalMenu]
(
	[intVendorPortalMenuId]			INT IDENTITY (1, 1) NOT NULL,	 
    [strVendorPortalMenuName]		NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [intVendorPortalParentMenuId]	INT           NOT NULL,
    [strType]                       NVARCHAR (10) COLLATE Latin1_General_CI_AS NULL,
    [strCommand]					NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    CONSTRAINT [PK_tblAPVendorPortalMenu] PRIMARY KEY CLUSTERED ([intVendorPortalMenuId] ASC)
)
