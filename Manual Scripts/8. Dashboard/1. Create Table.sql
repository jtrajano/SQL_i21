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
	[strClass] [nvarchar](max)  COLLATE Latin1_General_CI_AS NOT NULL DEFAULT(''),
	[strPanelName] [nvarchar](max)  COLLATE Latin1_General_CI_AS NOT NULL DEFAULT(''),
	[strStyle] [nvarchar](max)  COLLATE Latin1_General_CI_AS NULL ,
	[strAccessType] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strCaption] [nvarchar](max) COLLATE Latin1_General_CI_AS NOT NULL,
	[strChart] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strChartPosition] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strChartColor] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strConnectionName] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strDateCondition] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strDateCondition2] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strDateFieldName] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strDateFieldName2] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strDataSource] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strDataSource2] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strDateVariable] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strDateVariable2] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strDefaultTab] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strPanelNameDuplicate] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strPanelType] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strQBCriteriaOptions] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strFilterCondition] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strFilterVariable] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strFilterFieldName] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strFilterVariable2] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strFilterFieldName2] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strGroupFields] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strFilters] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strConfigurator] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[ysnChartLegend] [bit] NOT NULL DEFAULT(0),
	[ysnShowInGroups] [bit] NOT NULL DEFAULT(0),
	[imgLayoutGrid] [varbinary](max) NULL,
	[imgLayoutPivotGrid] [varbinary](max) NULL,
	[strPanelVersion] [nvarchar](max) COLLATE Latin1_General_CI_AS NOT NULL DEFAULT((14.1)),
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
	[ysnShow] [bit] NOT NULL DEFAULT(0),
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
	[strColumn] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strCaption] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[intWidth] [smallint] NOT NULL DEFAULT(30),
	[strAlignment] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strArea] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strFooter] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strFormat] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[intSort] [smallint] NOT NULL,
	[strFormatTrue] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strFormatFalse] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strDrillDownColumn] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[ysnVisible] [bit] NOT NULL DEFAULT(0),
	[strType] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strAxis] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strUserName] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[intUserID] [int] NOT NULL,
	[intDonut] [smallint] NOT NULL,
	[intMinInterval] [smallint] NOT NULL DEFAULT(0),
	[intMaxInterval] [smallint] NOT NULL DEFAULT(0),
	[intStepInterval] [smallint] NOT NULL DEFAULT(0),
	[strIntervalFormat] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[ysnHiddenColumn] [bit] NOT NULL DEFAULT(0),
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
	[strColumn] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strCondition] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strValue1] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strValue2] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[intBackColor] [int] NOT NULL,
	[strFontStyle] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[intFontColor] [int] NOT NULL,
	[strApplyTo] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[intPanelID] [int] NOT NULL,
	[intUserID] [int] NOT NULL,
	[intSort] [smallint] NOT NULL,
	[strType] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
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
	[strTabName] [nvarchar](max) COLLATE Latin1_General_CI_AS NOT NULL DEFAULT(''),
	[strRenameTabName] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
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
