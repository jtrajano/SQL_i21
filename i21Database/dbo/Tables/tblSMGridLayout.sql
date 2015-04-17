CREATE TABLE [dbo].[tblSMGridLayout]
(
	[intGridLayoutId] INT IDENTITY (1, 1) NOT NULL, 
    [strGridLayoutName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strGridLayoutFields] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [strScreen] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strGrid] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intUserId] INT NULL, 
    [ysnActive] BIT NULL, 
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblSMGridLayout] PRIMARY KEY CLUSTERED ([intGridLayoutId] ASC) 
)
