CREATE TABLE [dbo].[tblSMGridLayout]
(
	[intGridLayoutId]			INT IDENTITY (1, 1) NOT NULL, 
    [strGridLayoutName]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
	[strGridLayoutFields]		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
	[strGridLayoutFilters]		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
	[strGridLayoutSorters]		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [strScreen]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    [strGrid]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    [intUserId]					INT NULL, 
    [ysnActive]					BIT NULL, 
	[ysnIsQuickFilter]			BIT NULL,
	[intTabIndex]				INT NULL,
	[ysnIsSorted]				BIT NULL,
	[ysnSystemLayout]			BIT NULL,
	[ysnSystemLayoutDefault]	BIT NULL,
	[ysnReadOnly]				BIT NULL,
	[ysnShowTotals]				BIT NULL,
	[strSearchId]				NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
	[ysnGroupedColumns]			BIT NULL,
	[ysnCollapse]				BIT NULL,
    [intConcurrencyId]			INT NOT NULL, 
    CONSTRAINT [PK_tblSMGridLayout] PRIMARY KEY CLUSTERED ([intGridLayoutId] ASC) 
)
