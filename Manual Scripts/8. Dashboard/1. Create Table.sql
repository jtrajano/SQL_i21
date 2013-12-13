GO
/****** Object:  Table [dbo].[tblDBPanel]    Script Date: 12/12/2013 11:06:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblDBPanel](
	[intPanelID] [int] IDENTITY(1,1) NOT NULL,
	[intRowsReturned] [int] NOT NULL,
	[intRowsVisible] [smallint] NOT NULL,
	[intChartZoom] [smallint] NOT NULL,
	[intChartHeight] [smallint] NOT NULL,
	[intUserID] [int] NOT NULL,
	[intDefaultColumn] [smallint] NULL,
	[intDefaultRow] [smallint] NULL,
	[intDefaultWidth] [smallint] NULL,
	[intSourcePanelID] [int] NOT NULL,
	[intConnectionID] [int] NOT NULL,
	[intDrillDownPanel] [int] NOT NULL,
	[strClass] [nvarchar](max) NOT NULL,
	[strPanelName] [nvarchar](max) NOT NULL,
	[strStyle] [nvarchar](max) NULL,
	[strAccessType] [nvarchar](max) NULL,
	[strCaption] [nvarchar](max) NOT NULL,
	[strChart] [nvarchar](max) NULL,
	[strChartPosition] [nvarchar](max) NULL,
	[strChartColor] [nvarchar](max) NULL,
	[strConnectionName] [nvarchar](max) NULL,
	[strDateCondition] [nvarchar](max) NULL,
	[strDateCondition2] [nvarchar](max) NULL,
	[strDateFieldName] [nvarchar](max) NULL,
	[strDateFieldName2] [nvarchar](max) NULL,
	[strDataSource] [nvarchar](max) NULL,
	[strDataSource2] [nvarchar](max) NULL,
	[strDateVariable] [nvarchar](max) NULL,
	[strDateVariable2] [nvarchar](max) NULL,
	[strDefaultTab] [nvarchar](max) NULL,
	[strDescription] [nvarchar](max) NULL,
	[strPanelNameDuplicate] [nvarchar](max) NULL,
	[strPanelType] [nvarchar](max) NULL,
	[strQBCriteriaOptions] [nvarchar](max) NULL,
	[strFilterCondition] [nvarchar](max) NULL,
	[strFilterVariable] [nvarchar](max) NULL,
	[strFilterFieldName] [nvarchar](max) NULL,
	[strFilterVariable2] [nvarchar](max) NULL,
	[strFilterFieldName2] [nvarchar](max) NULL,
	[strGroupFields] [nvarchar](max) NULL,
	[strFilters] [nvarchar](max) NULL,
	[strConfigurator] [nvarchar](max) NULL,
	[ysnChartLegend] [bit] NOT NULL,
	[ysnShowInGroups] [bit] NOT NULL,
	[imgLayoutGrid] [varbinary](max) NULL,
	[imgLayoutPivotGrid] [varbinary](max) NULL,
	[strPanelVersion] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_dbo.tblDBPanel] PRIMARY KEY CLUSTERED 
(
	[intPanelID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblDBPanelAccess]    Script Date: 12/12/2013 11:06:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblDBPanelAccess](
	[intPanelUserID] [int] IDENTITY(1,1) NOT NULL,
	[intUserID] [int] NOT NULL,
	[intPanelID] [int] NOT NULL,
	[ysnShow] [bit] NOT NULL,
 CONSTRAINT [PK_dbo.tblDBPanelAccess] PRIMARY KEY CLUSTERED 
(
	[intPanelUserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblDBPanelColumn]    Script Date: 12/12/2013 11:06:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblDBPanelColumn](
	[intPanelColumnID] [int] IDENTITY(1,1) NOT NULL,
	[intPanelID] [int] NOT NULL,
	[strColumn] [nvarchar](max) NULL,
	[strCaption] [nvarchar](max) NULL,
	[intWidth] [smallint] NOT NULL,
	[strAlignment] [nvarchar](max) NULL,
	[strArea] [nvarchar](max) NULL,
	[strFooter] [nvarchar](max) NULL,
	[strFormat] [nvarchar](max) NULL,
	[intSort] [smallint] NOT NULL,
	[strFormatTrue] [nvarchar](max) NULL,
	[strFormatFalse] [nvarchar](max) NULL,
	[strDrillDownColumn] [nvarchar](max) NULL,
	[ysnVisible] [bit] NOT NULL,
	[strType] [nvarchar](max) NULL,
	[strAxis] [nvarchar](max) NULL,
	[strUserName] [nvarchar](max) NULL,
	[intUserID] [int] NOT NULL,
	[intDonut] [smallint] NOT NULL,
	[intMinInterval] [smallint] NOT NULL,
	[intMaxInterval] [smallint] NOT NULL,
	[intStepInterval] [smallint] NOT NULL,
	[strIntervalFormat] [nvarchar](max) NULL,
	[ysnHiddenColumn] [bit] NOT NULL,
 CONSTRAINT [PK_dbo.tblDBPanelColumn] PRIMARY KEY CLUSTERED 
(
	[intPanelColumnID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblDBPanelFormat]    Script Date: 12/12/2013 11:06:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblDBPanelFormat](
	[intPanelFormatID] [int] IDENTITY(1,1) NOT NULL,
	[strColumn] [nvarchar](max) NULL,
	[strCondition] [nvarchar](max) NULL,
	[strValue1] [nvarchar](max) NULL,
	[strValue2] [nvarchar](max) NULL,
	[intBackColor] [int] NOT NULL,
	[strFontStyle] [nvarchar](max) NULL,
	[intFontColor] [int] NOT NULL,
	[strApplyTo] [nvarchar](max) NULL,
	[intPanelID] [int] NOT NULL,
	[intUserID] [int] NOT NULL,
	[intSort] [smallint] NOT NULL,
	[strType] [nvarchar](max) NULL,
	[ysnVisible] [bit] NOT NULL,
 CONSTRAINT [PK_dbo.tblDBPanelFormat] PRIMARY KEY CLUSTERED 
(
	[intPanelFormatID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblDBPanelTab]    Script Date: 12/12/2013 11:06:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblDBPanelTab](
	[intPanelTabID] [int] IDENTITY(1,1) NOT NULL,
	[intSort] [smallint] NOT NULL,
	[intUserID] [int] NOT NULL,
	[intColumn1Width] [int] NOT NULL,
	[intColumn2Width] [int] NOT NULL,
	[intColumn3Width] [int] NOT NULL,
	[intColumn4Width] [int] NOT NULL,
	[intColumn5Width] [int] NOT NULL,
	[intColumn6Width] [int] NOT NULL,
	[intColumnCount] [int] NOT NULL,
	[strTabName] [nvarchar](max) NOT NULL,
	[strRenameTabName] [nvarchar](max) NULL,
 CONSTRAINT [PK_dbo.tblDBPanelTab] PRIMARY KEY CLUSTERED 
(
	[intPanelTabID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblDBPanelUser]    Script Date: 12/12/2013 11:06:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblDBPanelUser](
	[intPanelUserID] [int] IDENTITY(1,1) NOT NULL,
	[intPanelID] [int] NOT NULL,
	[intSort] [smallint] NOT NULL,
	[intPanelTabID] [int] NOT NULL,
	[intColumn] [int] NOT NULL,
	[intUserID] [int] NOT NULL,
 CONSTRAINT [PK_dbo.tblDBPanelUser] PRIMARY KEY CLUSTERED 
(
	[intPanelUserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[tblDBPanel] ADD  CONSTRAINT [DF_tblDBPanel_strPanelVersion]  DEFAULT ((14.1)) FOR [strPanelVersion]
GO
ALTER TABLE [dbo].[tblDBPanelAccess]  WITH CHECK ADD  CONSTRAINT [FK_dbo.tblDBPanelAccess_dbo.tblDBPanel_intPanelID] FOREIGN KEY([intPanelID])
REFERENCES [dbo].[tblDBPanel] ([intPanelID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblDBPanelAccess] CHECK CONSTRAINT [FK_dbo.tblDBPanelAccess_dbo.tblDBPanel_intPanelID]
GO
ALTER TABLE [dbo].[tblDBPanelColumn]  WITH CHECK ADD  CONSTRAINT [FK_dbo.tblDBPanelColumn_dbo.tblDBPanel_intPanelID] FOREIGN KEY([intPanelID])
REFERENCES [dbo].[tblDBPanel] ([intPanelID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblDBPanelColumn] CHECK CONSTRAINT [FK_dbo.tblDBPanelColumn_dbo.tblDBPanel_intPanelID]
GO
ALTER TABLE [dbo].[tblDBPanelFormat]  WITH CHECK ADD  CONSTRAINT [FK_dbo.tblDBPanelFormat_dbo.tblDBPanel_intPanelID] FOREIGN KEY([intPanelID])
REFERENCES [dbo].[tblDBPanel] ([intPanelID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblDBPanelFormat] CHECK CONSTRAINT [FK_dbo.tblDBPanelFormat_dbo.tblDBPanel_intPanelID]
GO
ALTER TABLE [dbo].[tblDBPanelUser]  WITH CHECK ADD  CONSTRAINT [FK_dbo.tblDBPanelUser_dbo.tblDBPanel_intPanelID] FOREIGN KEY([intPanelID])
REFERENCES [dbo].[tblDBPanel] ([intPanelID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblDBPanelUser] CHECK CONSTRAINT [FK_dbo.tblDBPanelUser_dbo.tblDBPanel_intPanelID]
GO
ALTER TABLE [dbo].[tblDBPanelUser]  WITH CHECK ADD  CONSTRAINT [FK_dbo.tblDBPanelUser_dbo.tblDBPanelTab_intPanelTabID] FOREIGN KEY([intPanelTabID])
REFERENCES [dbo].[tblDBPanelTab] ([intPanelTabID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblDBPanelUser] CHECK CONSTRAINT [FK_dbo.tblDBPanelUser_dbo.tblDBPanelTab_intPanelTabID]
GO
