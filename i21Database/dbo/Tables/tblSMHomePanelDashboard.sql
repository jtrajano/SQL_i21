CREATE TABLE [dbo].[tblSMHomePanelDashboard]
(
	[intHomePanelDashboardId]	INT Identity (1,1)							NOT NULL,
	[strPanelName]				NVARCHAR(250) Collate Latin1_General_CI_AS	NOT NULL,
	[strType]					NVARCHAR(100) Collate Latin1_General_CI_AS	NULL,
	[ysnVisible]				bit											NOT NULL		DEFAULT 0,
	[ysnDefaultPanel]			bit											NULL			DEFAULT 0,
	[intPanelHeight]			int											NOT NULL		DEFAULT 0,
	[intColumnIndex]			int											NOT NULL,
	[intRowIndex]				int											NOT NULL,
	[strPanelStyle]				NVARCHAR(100) Collate Latin1_General_CI_AS	NULL			DEFAULT '',
	[strChartStyle]				NVARCHAR(100) Collate Latin1_General_CI_AS	NULL			DEFAULT '',
	[intPanelWidth]				int											NULL,
	[intGridLayoutId]			int											NULL,
	[strWidgetName]				NVARCHAR(100) Collate Latin1_General_CI_AS	NULL			DEFAULT '',
	[intEntityId]				int											NOT NULL, 
	[ysnCollapse]				bit											NULL,
	[strGridLayoutUrl]			NVARCHAR(MAX) Collate Latin1_General_CI_AS	NULL,
	[strScreenName]				NVARCHAR(250) Collate Latin1_General_CI_AS	NULL,
	[strDefaultFilters]			NVARCHAR(MAX) Collate Latin1_General_CI_AS  NULL,
	[strSearchSettingsId]		NVARCHAR(250) Collate Latin1_General_CI_AS  NULL,
	[intConcurrencyId]			int											NOT NULL, 

	CONSTRAINT [PK_tblSMHomePanelDashboard] PRIMARY KEY CLUSTERED ([intHomePanelDashboardId] ASC),
	CONSTRAINT [FK_tblSMHomePanelDashboard_tblSMGridLayout_intGridLayoutId] FOREIGN KEY (intGridLayoutId) REFERENCES tblSMGridLayout([intGridLayoutId]) ON DELETE NO ACTION ON UPDATE NO ACTION
)
