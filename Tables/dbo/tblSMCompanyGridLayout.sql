CREATE TABLE [dbo].[tblSMCompanyGridLayout]
(
	[intCompanyGridLayoutId] INT IDENTITY (1, 1) NOT NULL, 
    [strGridLayoutName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
	[strGridLayoutFields] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
	[strGridLayoutFilters] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
	[strGridLayoutSorters] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [strScreen] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    [strGrid] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    [ysnActive] BIT NULL, 
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblSMCompanyGridLayout] PRIMARY KEY CLUSTERED ([intCompanyGridLayoutId] ASC) 
)
