CREATE TABLE [dbo].[tblSMHomePanelDashboard]
(
	[intHomePanelDashboardId]	INT Identity (1,1)							NOT NULL,
	[strPanelName]				NVARCHAR(250) Collate Latin1_General_CI_AS	NOT NULL,
	[strType]					NVARCHAR(100) Collate Latin1_General_CI_AS	NULL,
	[ysnIsVisible]				bit											NOT NULL		DEFAULT 0,
	[ysnDefaultPanel]			bit											NULL			DEFAULT 0,
	[intPanelHeight]			int											NOT NULL		DEFAULT 0,
	[intColumnIndex]			int											NOT NULL,
	[intRowINdex]				int											NOT NULL,
	[strPanelStyle]				NVARCHAR(100) Collate Latin1_General_CI_AS	NULL			DEFAULT '',
	[strChartStyle]				NVARCHAR(100) Collate Latin1_General_CI_AS	NULL			DEFAULT '',
	[intColumn1Width]			int											NULL,
	[intGridLayoutId]			int											NULL,
	[strWidgetName]				NVARCHAR(100) Collate Latin1_General_CI_AS	NULL			DEFAULT '',

	CONSTRAINT [PK_tblSMHomePanelDashboard] PRIMARY KEY CLUSTERED ([intHomePanelDashboardId] ASC),
	CONSTRAINT [FK_tblSMHomePanelDashboard_tblSMGridLayout_intEntityId] FOREIGN KEY (intGridLayoutId) REFERENCES tblSMGridLayout([intGridLayoutId])
)
