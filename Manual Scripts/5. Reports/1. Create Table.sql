
GO
/****** Object:  Table [dbo].[tblRMConnection]    Script Date: 12/26/2013 17:20:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRMConnection](
	[intConnectionId] [int] IDENTITY(1,1) NOT NULL,
	[strName] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[intConnectionType] [int] NOT NULL,
	[strUserName] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strPassword] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strServerName] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[intAuthenticationType] [int] NOT NULL,
	[strRemoteUri] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strDatabase] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strPort] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[ysnRemote] [bit] NULL,
 CONSTRAINT [PK_dbo.Connections] PRIMARY KEY CLUSTERED 
(
	[intConnectionId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblRMReport]    Script Date: 12/26/2013 17:20:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblRMReport](
	[intReportId] [int] IDENTITY(1,1) NOT NULL,
	[blbLayout] [varbinary](max) NULL,
	[strName] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strGroup] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strBuilderServiceAddress] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strWebViewerAddress] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[ysnAllowChangeFieldname] [bit] NOT NULL,
	[ysnAllowRemoveFieldname] [bit] NOT NULL,
	[ysnAllowAddFieldname] [bit] NOT NULL,
	[ysnUseAllAndOperator] [bit] NOT NULL,
	[ysnShowQuery] [bit] NOT NULL,
	[strDescription] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[intCompanyInformationId] [int] NULL,
	[intGroupSort] [int] NULL,
	[intNameSort] [int] NULL,
 CONSTRAINT [PK_dbo.Reports] PRIMARY KEY CLUSTERED 
(
	[intReportId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblRMArchive]    Script Date: 12/26/2013 17:20:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblRMArchive](
	[intArchiveID] [int] IDENTITY(1,1) NOT NULL,
	[blbDocument] [varbinary](max) NULL,
	[strName] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[dtmDate] [datetime] NULL,
	[strDescription] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strUserID] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_tblRMArchive] PRIMARY KEY CLUSTERED 
(
	[intArchiveID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblRMFilter]    Script Date: 12/26/2013 17:20:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRMFilter](
	[intFilterId] [int] IDENTITY(1,1) NOT NULL,
	[strBeginGroup] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strEndGroup] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strJoin] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[intReportId] [int] NOT NULL,
	[strFieldName] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strFrom] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strTo] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strCondition] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strDataType] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[intSortId] [int] NOT NULL,
	[intUserId] [int] NOT NULL,
 CONSTRAINT [PK_dbo.Filters] PRIMARY KEY CLUSTERED 
(
	[intFilterId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblRMUser]    Script Date: 12/26/2013 17:20:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRMUser](
	[intUserId] [int] IDENTITY(1,1) NOT NULL,
	[strUsername] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strPassword] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_dbo.Users] PRIMARY KEY CLUSTERED 
(
	[intUserId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblRMSubreportSetting]    Script Date: 12/26/2013 17:20:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRMSubreportSetting](
	[intSubreportSettingId] [int] IDENTITY(1,1) NOT NULL,
	[intReportId] [int] NOT NULL,
	[intSubreportId] [int] NOT NULL,
	[strControlName] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[intType] [int] NOT NULL,
	[strParentField] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strParentDataType] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strChildField] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strChildDataType] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_dbo.SubreportSettings] PRIMARY KEY CLUSTERED 
(
	[intSubreportSettingId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblRMSort]    Script Date: 12/26/2013 17:20:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRMSort](
	[intSortId] [int] IDENTITY(1,1) NOT NULL,
	[strSortField] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[intReportId] [int] NULL,
	[intSortDirection] [int] NULL,
	[ysnRequired] [bit] NULL,
	[intUserId] [int] NULL,
 CONSTRAINT [PK_dbo.Sorts] PRIMARY KEY CLUSTERED 
(
	[intSortId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblRMOption]    Script Date: 12/26/2013 17:20:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRMOption](
	[intOptionId] [int] IDENTITY(1,1) NOT NULL,
	[strName] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[intType] [int] NOT NULL,
	[strSettings] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[ysnShow] [bit] NOT NULL,
	[intReportId] [int] NOT NULL,
	[ysnEnable] [bit] NOT NULL,
	[intSortId] [int] NOT NULL,
 CONSTRAINT [PK_dbo.Options] PRIMARY KEY CLUSTERED 
(
	[intOptionId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblRMConfiguration]    Script Date: 12/26/2013 17:20:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRMConfiguration](
	[intConfigurationId] [int] IDENTITY(1,1) NOT NULL,
	[ysnPrintDirect] [bit] NOT NULL,
	[strPrinterName] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[intRecordsPerPage] [int] NOT NULL,
	[ysnShowPrintDialog] [bit] NOT NULL,
	[intNumberOfCopies] [int] NOT NULL,
	[intReportId] [int] NOT NULL,
 CONSTRAINT [PK_dbo.Configurations] PRIMARY KEY CLUSTERED 
(
	[intConfigurationId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblRMDatasource]    Script Date: 12/26/2013 17:20:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRMDatasource](
	[intDatasourceId] [int] IDENTITY(1,1) NOT NULL,
	[strName] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[intReportId] [int] NOT NULL,
	[intConnectionId] [int] NOT NULL,
	[strQuery] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[intDataSourceType] [int] NOT NULL,
 CONSTRAINT [PK_dbo.Datasources] PRIMARY KEY CLUSTERED 
(
	[intDatasourceId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblRMCriteriaFieldSelection]    Script Date: 12/26/2013 17:20:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRMCriteriaFieldSelection](
	[intCriteriaFieldSelectionId] [int] IDENTITY(1,1) NOT NULL,
	[strName] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[intConnectionId] [int] NULL,
	[strFieldName] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strCaption] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strValueField] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strDisplayField] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[ysnDistinct] [bit] NOT NULL,
	[strSource] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[intFieldSourceType] [int] NOT NULL,
 CONSTRAINT [PK_dbo.CriteriaFieldSelections] PRIMARY KEY CLUSTERED 
(
	[intCriteriaFieldSelectionId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblRMCriteriaField]    Script Date: 12/26/2013 17:20:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRMCriteriaField](
	[intCriteriaFieldId] [int] IDENTITY(1,1) NOT NULL,
	[intReportId] [int] NOT NULL,
	[intCriteriaFieldSelectionId] [int] NULL,
	[strFieldName] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strDataType] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strConditions] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[ysnIsRequired] [bit] NOT NULL,
	[ysnShow] [bit] NOT NULL,
	[ysnAllowSort] [bit] NOT NULL,
	[ysnEditCondition] [bit] NOT NULL,
 CONSTRAINT [PK_dbo.CriteriaFields] PRIMARY KEY CLUSTERED 
(
	[intCriteriaFieldId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblRMFieldSelectionFilter]    Script Date: 12/26/2013 17:20:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRMFieldSelectionFilter](
	[intFieldSelectionFilterId] [int] IDENTITY(1,1) NOT NULL,
	[intCriteriaFieldId] [int] NOT NULL,
	[intFilterType] [int] NOT NULL,
	[strFilter] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strJoin] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_dbo.FieldSelectionFilters] PRIMARY KEY CLUSTERED 
(
	[intFieldSelectionFilterId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  ForeignKey [FK_dbo.Configurations_dbo.Reports_intReportId]    Script Date: 12/26/2013 17:20:46 ******/
ALTER TABLE [dbo].[tblRMConfiguration]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Configurations_dbo.Reports_intReportId] FOREIGN KEY([intReportId])
REFERENCES [dbo].[tblRMReport] ([intReportId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblRMConfiguration] CHECK CONSTRAINT [FK_dbo.Configurations_dbo.Reports_intReportId]
GO
/****** Object:  ForeignKey [FK_dbo.CriteriaFields_dbo.CriteriaFieldSelections_intCriteriaFieldSelectionId]    Script Date: 12/26/2013 17:20:46 ******/
ALTER TABLE [dbo].[tblRMCriteriaField]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CriteriaFields_dbo.CriteriaFieldSelections_intCriteriaFieldSelectionId] FOREIGN KEY([intCriteriaFieldSelectionId])
REFERENCES [dbo].[tblRMCriteriaFieldSelection] ([intCriteriaFieldSelectionId])
GO
ALTER TABLE [dbo].[tblRMCriteriaField] CHECK CONSTRAINT [FK_dbo.CriteriaFields_dbo.CriteriaFieldSelections_intCriteriaFieldSelectionId]
GO
/****** Object:  ForeignKey [FK_dbo.CriteriaFields_dbo.Reports_intReportId]    Script Date: 12/26/2013 17:20:46 ******/
ALTER TABLE [dbo].[tblRMCriteriaField]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CriteriaFields_dbo.Reports_intReportId] FOREIGN KEY([intReportId])
REFERENCES [dbo].[tblRMReport] ([intReportId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblRMCriteriaField] CHECK CONSTRAINT [FK_dbo.CriteriaFields_dbo.Reports_intReportId]
GO
/****** Object:  ForeignKey [FK_dbo.CriteriaFieldSelections_dbo.Connections_intConnectionId]    Script Date: 12/26/2013 17:20:46 ******/
ALTER TABLE [dbo].[tblRMCriteriaFieldSelection]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CriteriaFieldSelections_dbo.Connections_intConnectionId] FOREIGN KEY([intConnectionId])
REFERENCES [dbo].[tblRMConnection] ([intConnectionId])
GO
ALTER TABLE [dbo].[tblRMCriteriaFieldSelection] CHECK CONSTRAINT [FK_dbo.CriteriaFieldSelections_dbo.Connections_intConnectionId]
GO
/****** Object:  ForeignKey [FK_dbo.Datasources_dbo.Connections_intConnectionId]    Script Date: 12/26/2013 17:20:46 ******/
ALTER TABLE [dbo].[tblRMDatasource]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Datasources_dbo.Connections_intConnectionId] FOREIGN KEY([intConnectionId])
REFERENCES [dbo].[tblRMConnection] ([intConnectionId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblRMDatasource] CHECK CONSTRAINT [FK_dbo.Datasources_dbo.Connections_intConnectionId]
GO
/****** Object:  ForeignKey [FK_dbo.Datasources_dbo.Reports_intReportId]    Script Date: 12/26/2013 17:20:46 ******/
ALTER TABLE [dbo].[tblRMDatasource]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Datasources_dbo.Reports_intReportId] FOREIGN KEY([intReportId])
REFERENCES [dbo].[tblRMReport] ([intReportId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblRMDatasource] CHECK CONSTRAINT [FK_dbo.Datasources_dbo.Reports_intReportId]
GO
/****** Object:  ForeignKey [FK_dbo.FieldSelectionFilters_dbo.CriteriaFields_intCriteriaFieldId]    Script Date: 12/26/2013 17:20:46 ******/
ALTER TABLE [dbo].[tblRMFieldSelectionFilter]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FieldSelectionFilters_dbo.CriteriaFields_intCriteriaFieldId] FOREIGN KEY([intCriteriaFieldId])
REFERENCES [dbo].[tblRMCriteriaField] ([intCriteriaFieldId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblRMFieldSelectionFilter] CHECK CONSTRAINT [FK_dbo.FieldSelectionFilters_dbo.CriteriaFields_intCriteriaFieldId]
GO
/****** Object:  ForeignKey [FK_dbo.Options_dbo.Reports_intReportId]    Script Date: 12/26/2013 17:20:46 ******/
ALTER TABLE [dbo].[tblRMOption]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Options_dbo.Reports_intReportId] FOREIGN KEY([intReportId])
REFERENCES [dbo].[tblRMReport] ([intReportId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblRMOption] CHECK CONSTRAINT [FK_dbo.Options_dbo.Reports_intReportId]
GO
/****** Object:  ForeignKey [FK_dbo.Sorts_dbo.Reports_intReportId]    Script Date: 12/26/2013 17:20:46 ******/
ALTER TABLE [dbo].[tblRMSort]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Sorts_dbo.Reports_intReportId] FOREIGN KEY([intReportId])
REFERENCES [dbo].[tblRMReport] ([intReportId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblRMSort] CHECK CONSTRAINT [FK_dbo.Sorts_dbo.Reports_intReportId]
GO
/****** Object:  ForeignKey [FK_dbo.SubreportSettings_dbo.Reports_intReportId]    Script Date: 12/26/2013 17:20:46 ******/
ALTER TABLE [dbo].[tblRMSubreportSetting]  WITH CHECK ADD  CONSTRAINT [FK_dbo.SubreportSettings_dbo.Reports_intReportId] FOREIGN KEY([intReportId])
REFERENCES [dbo].[tblRMReport] ([intReportId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblRMSubreportSetting] CHECK CONSTRAINT [FK_dbo.SubreportSettings_dbo.Reports_intReportId]
GO
