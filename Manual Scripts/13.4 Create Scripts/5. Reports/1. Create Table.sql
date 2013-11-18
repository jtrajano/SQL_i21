
GO
/****** Object:  Table [dbo].[tblRMCompanyInformations]    Script Date: 11/04/2013 14:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRMCompanyInformations](
	[intCompanyInformationId] [int] IDENTITY(1,1) NOT NULL,
	[strCompanyInformationName] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strName] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strAttention] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strAddress] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[intZip] [int] NOT NULL,
	[strCity] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strState] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strCountry] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strPhone] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strFax] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strUserName] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_dbo.CompanyInformations] PRIMARY KEY CLUSTERED 
(
	[intCompanyInformationId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblRMArchives]    Script Date: 11/04/2013 14:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblRMArchives](
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
/****** Object:  Table [dbo].[tblRMUsers]    Script Date: 11/04/2013 14:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRMUsers](
	[intUserId] [int] IDENTITY(1,1) NOT NULL,
	[strUsername] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strPassword] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_dbo.Users] PRIMARY KEY CLUSTERED 
(
	[intUserId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblRMConnections]    Script Date: 11/04/2013 14:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRMConnections](
	[intConnectionId] [int] IDENTITY(1,1) NOT NULL,
	[strName] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[intConnectionType] [int] NOT NULL,
	[strUserName] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strPassword] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strServerName] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[intAuthenticationType] [int] NOT NULL,
	[strRemoteUri] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strDatabase] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strConnectionType] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_dbo.Connections] PRIMARY KEY CLUSTERED 
(
	[intConnectionId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblRMReports]    Script Date: 11/04/2013 14:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblRMReports](
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
 CONSTRAINT [PK_dbo.Reports] PRIMARY KEY CLUSTERED 
(
	[intReportId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblRMCriteriaFieldSelections]    Script Date: 11/04/2013 14:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRMCriteriaFieldSelections](
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
/****** Object:  Table [dbo].[tblRMSubreportSettings]    Script Date: 11/04/2013 14:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRMSubreportSettings](
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
/****** Object:  Table [dbo].[tblRMSorts]    Script Date: 11/04/2013 14:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRMSorts](
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
/****** Object:  Table [dbo].[tblRMDesignParameters]    Script Date: 11/04/2013 14:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRMDesignParameters](
	[DesignParameterId] [int] IDENTITY(1,1) NOT NULL,
	[ReportId] [int] NOT NULL,
	[Name] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[Description] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[Controls] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[ysnShow] [bit] NOT NULL,
	[SortId] [int] NOT NULL,
	[UserId] [int] NOT NULL,
	[Report_intReportId] [int] NULL,
 CONSTRAINT [PK_dbo.DesignParameters] PRIMARY KEY CLUSTERED 
(
	[DesignParameterId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblRMDatasources]    Script Date: 11/04/2013 14:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRMDatasources](
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
/****** Object:  Table [dbo].[tblRMCriteriaFields]    Script Date: 11/04/2013 14:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRMCriteriaFields](
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
/****** Object:  Table [dbo].[tblRMConfigurations]    Script Date: 11/04/2013 14:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRMConfigurations](
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
/****** Object:  Table [dbo].[tblRMOptions]    Script Date: 11/04/2013 14:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRMOptions](
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
/****** Object:  Table [dbo].[tblRMFilters]    Script Date: 11/04/2013 14:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRMFilters](
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
/****** Object:  Table [dbo].[tblRMFieldSelectionFilters]    Script Date: 11/04/2013 14:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRMFieldSelectionFilters](
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
/****** Object:  ForeignKey [FK_dbo.Configurations_dbo.Reports_intReportId]    Script Date: 11/04/2013 14:05:16 ******/
ALTER TABLE [dbo].[tblRMConfigurations]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Configurations_dbo.Reports_intReportId] FOREIGN KEY([intReportId])
REFERENCES [dbo].[tblRMReports] ([intReportId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblRMConfigurations] CHECK CONSTRAINT [FK_dbo.Configurations_dbo.Reports_intReportId]
GO
/****** Object:  ForeignKey [FK_dbo.CriteriaFields_dbo.CriteriaFieldSelections_intCriteriaFieldSelectionId]    Script Date: 11/04/2013 14:05:16 ******/
ALTER TABLE [dbo].[tblRMCriteriaFields]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CriteriaFields_dbo.CriteriaFieldSelections_intCriteriaFieldSelectionId] FOREIGN KEY([intCriteriaFieldSelectionId])
REFERENCES [dbo].[tblRMCriteriaFieldSelections] ([intCriteriaFieldSelectionId])
GO
ALTER TABLE [dbo].[tblRMCriteriaFields] CHECK CONSTRAINT [FK_dbo.CriteriaFields_dbo.CriteriaFieldSelections_intCriteriaFieldSelectionId]
GO
/****** Object:  ForeignKey [FK_dbo.CriteriaFields_dbo.Reports_intReportId]    Script Date: 11/04/2013 14:05:16 ******/
ALTER TABLE [dbo].[tblRMCriteriaFields]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CriteriaFields_dbo.Reports_intReportId] FOREIGN KEY([intReportId])
REFERENCES [dbo].[tblRMReports] ([intReportId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblRMCriteriaFields] CHECK CONSTRAINT [FK_dbo.CriteriaFields_dbo.Reports_intReportId]
GO
/****** Object:  ForeignKey [FK_dbo.CriteriaFieldSelections_dbo.Connections_intConnectionId]    Script Date: 11/04/2013 14:05:16 ******/
ALTER TABLE [dbo].[tblRMCriteriaFieldSelections]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CriteriaFieldSelections_dbo.Connections_intConnectionId] FOREIGN KEY([intConnectionId])
REFERENCES [dbo].[tblRMConnections] ([intConnectionId])
GO
ALTER TABLE [dbo].[tblRMCriteriaFieldSelections] CHECK CONSTRAINT [FK_dbo.CriteriaFieldSelections_dbo.Connections_intConnectionId]
GO
/****** Object:  ForeignKey [FK_dbo.Datasources_dbo.Connections_intConnectionId]    Script Date: 11/04/2013 14:05:16 ******/
ALTER TABLE [dbo].[tblRMDatasources]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Datasources_dbo.Connections_intConnectionId] FOREIGN KEY([intConnectionId])
REFERENCES [dbo].[tblRMConnections] ([intConnectionId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblRMDatasources] CHECK CONSTRAINT [FK_dbo.Datasources_dbo.Connections_intConnectionId]
GO
/****** Object:  ForeignKey [FK_dbo.Datasources_dbo.Reports_intReportId]    Script Date: 11/04/2013 14:05:16 ******/
ALTER TABLE [dbo].[tblRMDatasources]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Datasources_dbo.Reports_intReportId] FOREIGN KEY([intReportId])
REFERENCES [dbo].[tblRMReports] ([intReportId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblRMDatasources] CHECK CONSTRAINT [FK_dbo.Datasources_dbo.Reports_intReportId]
GO
/****** Object:  ForeignKey [FK_dbo.DesignParameters_dbo.Reports_Report_intReportId]    Script Date: 11/04/2013 14:05:16 ******/
ALTER TABLE [dbo].[tblRMDesignParameters]  WITH CHECK ADD  CONSTRAINT [FK_dbo.DesignParameters_dbo.Reports_Report_intReportId] FOREIGN KEY([Report_intReportId])
REFERENCES [dbo].[tblRMReports] ([intReportId])
GO
ALTER TABLE [dbo].[tblRMDesignParameters] CHECK CONSTRAINT [FK_dbo.DesignParameters_dbo.Reports_Report_intReportId]
GO
/****** Object:  ForeignKey [FK_dbo.FieldSelectionFilters_dbo.CriteriaFields_intCriteriaFieldId]    Script Date: 11/04/2013 14:05:16 ******/
ALTER TABLE [dbo].[tblRMFieldSelectionFilters]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FieldSelectionFilters_dbo.CriteriaFields_intCriteriaFieldId] FOREIGN KEY([intCriteriaFieldId])
REFERENCES [dbo].[tblRMCriteriaFields] ([intCriteriaFieldId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblRMFieldSelectionFilters] CHECK CONSTRAINT [FK_dbo.FieldSelectionFilters_dbo.CriteriaFields_intCriteriaFieldId]
GO
/****** Object:  ForeignKey [FK_dbo.Filters_dbo.Reports_intReportId]    Script Date: 11/04/2013 14:05:16 ******/
ALTER TABLE [dbo].[tblRMFilters]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Filters_dbo.Reports_intReportId] FOREIGN KEY([intReportId])
REFERENCES [dbo].[tblRMReports] ([intReportId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblRMFilters] CHECK CONSTRAINT [FK_dbo.Filters_dbo.Reports_intReportId]
GO
/****** Object:  ForeignKey [FK_dbo.Options_dbo.Reports_intReportId]    Script Date: 11/04/2013 14:05:16 ******/
ALTER TABLE [dbo].[tblRMOptions]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Options_dbo.Reports_intReportId] FOREIGN KEY([intReportId])
REFERENCES [dbo].[tblRMReports] ([intReportId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblRMOptions] CHECK CONSTRAINT [FK_dbo.Options_dbo.Reports_intReportId]
GO
/****** Object:  ForeignKey [FK_dbo.Reports_dbo.CompanyInformations_intCompanyInformationId]    Script Date: 11/04/2013 14:05:16 ******/
ALTER TABLE [dbo].[tblRMReports]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Reports_dbo.CompanyInformations_intCompanyInformationId] FOREIGN KEY([intCompanyInformationId])
REFERENCES [dbo].[tblRMCompanyInformations] ([intCompanyInformationId])
GO
ALTER TABLE [dbo].[tblRMReports] CHECK CONSTRAINT [FK_dbo.Reports_dbo.CompanyInformations_intCompanyInformationId]
GO
/****** Object:  ForeignKey [FK_dbo.Sorts_dbo.Reports_intReportId]    Script Date: 11/04/2013 14:05:16 ******/
ALTER TABLE [dbo].[tblRMSorts]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Sorts_dbo.Reports_intReportId] FOREIGN KEY([intReportId])
REFERENCES [dbo].[tblRMReports] ([intReportId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblRMSorts] CHECK CONSTRAINT [FK_dbo.Sorts_dbo.Reports_intReportId]
GO
/****** Object:  ForeignKey [FK_dbo.SubreportSettings_dbo.Reports_intReportId]    Script Date: 11/04/2013 14:05:16 ******/
ALTER TABLE [dbo].[tblRMSubreportSettings]  WITH CHECK ADD  CONSTRAINT [FK_dbo.SubreportSettings_dbo.Reports_intReportId] FOREIGN KEY([intReportId])
REFERENCES [dbo].[tblRMReports] ([intReportId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblRMSubreportSettings] CHECK CONSTRAINT [FK_dbo.SubreportSettings_dbo.Reports_intReportId]
GO
