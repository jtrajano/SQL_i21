
GO
/****** Object:  Table [dbo].[tblRMCompanyInformations]    Script Date: 10/14/2013 18:40:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRMCompanyInformations](
	[intCompanyInformationId] [int] IDENTITY(1,1) NOT NULL,
	[strCompanyInformationName] [nvarchar](max) NULL,
	[strName] [nvarchar](max) NULL,
	[strAttention] [nvarchar](max) NULL,
	[strAddress] [nvarchar](max) NULL,
	[intZip] [int] NOT NULL,
	[strCity] [nvarchar](max) NULL,
	[strState] [nvarchar](max) NULL,
	[strCountry] [nvarchar](max) NULL,
	[strPhone] [nvarchar](max) NULL,
	[strFax] [nvarchar](max) NULL,
	[strUserName] [nvarchar](max) NULL,
 CONSTRAINT [PK_dbo.CompanyInformations] PRIMARY KEY CLUSTERED 
(
	[intCompanyInformationId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblRMArchives]    Script Date: 10/14/2013 18:40:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblRMArchives](
	[intArchiveID] [int] IDENTITY(1,1) NOT NULL,
	[blbDocument] [varbinary](max) NULL,
	[strName] [nvarchar](100) NULL,
	[dtmDate] [datetime] NULL,
	[strDescription] [nvarchar](100) NULL,
	[strUserID] [nvarchar](50) NULL,
 CONSTRAINT [PK_tblRMArchive] PRIMARY KEY CLUSTERED 
(
	[intArchiveID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblRMUsers]    Script Date: 10/14/2013 18:40:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRMUsers](
	[intUserId] [int] IDENTITY(1,1) NOT NULL,
	[strUsername] [nvarchar](max) NULL,
	[strPassword] [nvarchar](max) NULL,
 CONSTRAINT [PK_dbo.Users] PRIMARY KEY CLUSTERED 
(
	[intUserId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblRMConnections]    Script Date: 10/14/2013 18:40:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRMConnections](
	[intConnectionId] [int] IDENTITY(1,1) NOT NULL,
	[strName] [nvarchar](max) NULL,
	[intConnectionType] [int] NOT NULL,
	[strUserName] [nvarchar](max) NULL,
	[strPassword] [nvarchar](max) NULL,
	[strServerName] [nvarchar](max) NULL,
	[intAuthenticationType] [int] NOT NULL,
	[strRemoteUri] [nvarchar](max) NULL,
	[strDatabase] [nvarchar](max) NULL,
 CONSTRAINT [PK_dbo.Connections] PRIMARY KEY CLUSTERED 
(
	[intConnectionId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblRMReports]    Script Date: 10/14/2013 18:40:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblRMReports](
	[intReportId] [int] IDENTITY(1,1) NOT NULL,
	[blbLayout] [varbinary](max) NULL,
	[strName] [nvarchar](max) NULL,
	[strGroup] [nvarchar](max) NULL,
	[strBuilderServiceAddress] [nvarchar](max) NULL,
	[strWebViewerAddress] [nvarchar](max) NULL,
	[ysnAllowChangeFieldname] [bit] NOT NULL,
	[ysnAllowRemoveFieldname] [bit] NOT NULL,
	[ysnAllowAddFieldname] [bit] NOT NULL,
	[ysnUseAllAndOperator] [bit] NOT NULL,
	[ysnShowQuery] [bit] NOT NULL,
	[strDescription] [nvarchar](max) NULL,
	[intCompanyInformationId] [int] NULL,
 CONSTRAINT [PK_dbo.Reports] PRIMARY KEY CLUSTERED 
(
	[intReportId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblRMCriteriaFieldSelections]    Script Date: 10/14/2013 18:40:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRMCriteriaFieldSelections](
	[intCriteriaFieldSelectionId] [int] IDENTITY(1,1) NOT NULL,
	[strName] [nvarchar](max) NULL,
	[intConnectionId] [int] NULL,
	[strFieldName] [nvarchar](max) NULL,
	[strCaption] [nvarchar](max) NULL,
	[strValueField] [nvarchar](max) NULL,
	[strDisplayField] [nvarchar](max) NULL,
	[ysnDistinct] [bit] NOT NULL,
	[strSource] [nvarchar](max) NULL,
	[intFieldSourceType] [int] NOT NULL,
 CONSTRAINT [PK_dbo.CriteriaFieldSelections] PRIMARY KEY CLUSTERED 
(
	[intCriteriaFieldSelectionId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblRMSubreportSettings]    Script Date: 10/14/2013 18:40:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRMSubreportSettings](
	[intSubreportSettingId] [int] IDENTITY(1,1) NOT NULL,
	[intReportId] [int] NOT NULL,
	[intSubreportId] [int] NOT NULL,
	[strControlName] [nvarchar](max) NULL,
	[intType] [int] NOT NULL,
	[strParentField] [nvarchar](max) NULL,
	[strParentDataType] [nvarchar](max) NULL,
	[strChildField] [nvarchar](max) NULL,
	[strChildDataType] [nvarchar](max) NULL,
 CONSTRAINT [PK_dbo.SubreportSettings] PRIMARY KEY CLUSTERED 
(
	[intSubreportSettingId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblRMSorts]    Script Date: 10/14/2013 18:40:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRMSorts](
	[intSortId] [int] IDENTITY(1,1) NOT NULL,
	[strSortField] [nvarchar](max) NULL,
	[intReportId] [int] NOT NULL,
	[intSortDirection] [int] NOT NULL,
	[ysnRequired] [bit] NOT NULL,
	[intUserId] [int] NOT NULL,
 CONSTRAINT [PK_dbo.Sorts] PRIMARY KEY CLUSTERED 
(
	[intSortId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblRMDesignParameters]    Script Date: 10/14/2013 18:40:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRMDesignParameters](
	[DesignParameterId] [int] IDENTITY(1,1) NOT NULL,
	[ReportId] [int] NOT NULL,
	[Name] [nvarchar](max) NULL,
	[Description] [nvarchar](max) NULL,
	[Controls] [nvarchar](max) NULL,
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
/****** Object:  Table [dbo].[tblRMDatasources]    Script Date: 10/14/2013 18:40:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRMDatasources](
	[intDatasourceId] [int] IDENTITY(1,1) NOT NULL,
	[strName] [nvarchar](max) NULL,
	[intReportId] [int] NOT NULL,
	[intConnectionId] [int] NOT NULL,
	[strQuery] [nvarchar](max) NULL,
	[intDataSourceType] [int] NOT NULL,
 CONSTRAINT [PK_dbo.Datasources] PRIMARY KEY CLUSTERED 
(
	[intDatasourceId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblRMCriteriaFields]    Script Date: 10/14/2013 18:40:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRMCriteriaFields](
	[intCriteriaFieldId] [int] IDENTITY(1,1) NOT NULL,
	[intReportId] [int] NOT NULL,
	[intCriteriaFieldSelectionId] [int] NULL,
	[strFieldName] [nvarchar](max) NULL,
	[strDataType] [nvarchar](max) NULL,
	[strDescription] [nvarchar](max) NULL,
	[strConditions] [nvarchar](max) NULL,
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
/****** Object:  Table [dbo].[tblRMConfigurations]    Script Date: 10/14/2013 18:40:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRMConfigurations](
	[intConfigurationId] [int] IDENTITY(1,1) NOT NULL,
	[ysnPrintDirect] [bit] NOT NULL,
	[strPrinterName] [nvarchar](max) NULL,
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
/****** Object:  Table [dbo].[tblRMOptions]    Script Date: 10/14/2013 18:40:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRMOptions](
	[intOptionId] [int] IDENTITY(1,1) NOT NULL,
	[strName] [nvarchar](max) NULL,
	[strDescription] [nvarchar](max) NULL,
	[intType] [int] NOT NULL,
	[strSettings] [nvarchar](max) NULL,
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
/****** Object:  Table [dbo].[tblRMFilters]    Script Date: 10/14/2013 18:40:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRMFilters](
	[intFilterId] [int] IDENTITY(1,1) NOT NULL,
	[strBeginGroup] [nvarchar](max) NULL,
	[strEndGroup] [nvarchar](max) NULL,
	[strJoin] [nvarchar](max) NULL,
	[intReportId] [int] NOT NULL,
	[strFieldName] [nvarchar](max) NULL,
	[strDescription] [nvarchar](max) NULL,
	[strFrom] [nvarchar](max) NULL,
	[strTo] [nvarchar](max) NULL,
	[strCondition] [nvarchar](max) NULL,
	[strDataType] [nvarchar](max) NULL,
	[intSortId] [int] NOT NULL,
	[intUserId] [int] NOT NULL,
 CONSTRAINT [PK_dbo.Filters] PRIMARY KEY CLUSTERED 
(
	[intFilterId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblRMFieldSelectionFilters]    Script Date: 10/14/2013 18:40:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRMFieldSelectionFilters](
	[intFieldSelectionFilterId] [int] IDENTITY(1,1) NOT NULL,
	[intCriteriaFieldId] [int] NOT NULL,
	[intFilterType] [int] NOT NULL,
	[strFilter] [nvarchar](max) NULL,
	[strJoin] [nvarchar](max) NULL,
 CONSTRAINT [PK_dbo.FieldSelectionFilters] PRIMARY KEY CLUSTERED 
(
	[intFieldSelectionFilterId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  ForeignKey [FK_dbo.Configurations_dbo.Reports_intReportId]    Script Date: 10/14/2013 18:40:21 ******/
ALTER TABLE [dbo].[tblRMConfigurations]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Configurations_dbo.Reports_intReportId] FOREIGN KEY([intReportId])
REFERENCES [dbo].[tblRMReports] ([intReportId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblRMConfigurations] CHECK CONSTRAINT [FK_dbo.Configurations_dbo.Reports_intReportId]
GO
/****** Object:  ForeignKey [FK_dbo.CriteriaFields_dbo.CriteriaFieldSelections_intCriteriaFieldSelectionId]    Script Date: 10/14/2013 18:40:21 ******/
ALTER TABLE [dbo].[tblRMCriteriaFields]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CriteriaFields_dbo.CriteriaFieldSelections_intCriteriaFieldSelectionId] FOREIGN KEY([intCriteriaFieldSelectionId])
REFERENCES [dbo].[tblRMCriteriaFieldSelections] ([intCriteriaFieldSelectionId])
GO
ALTER TABLE [dbo].[tblRMCriteriaFields] CHECK CONSTRAINT [FK_dbo.CriteriaFields_dbo.CriteriaFieldSelections_intCriteriaFieldSelectionId]
GO
/****** Object:  ForeignKey [FK_dbo.CriteriaFields_dbo.Reports_intReportId]    Script Date: 10/14/2013 18:40:21 ******/
ALTER TABLE [dbo].[tblRMCriteriaFields]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CriteriaFields_dbo.Reports_intReportId] FOREIGN KEY([intReportId])
REFERENCES [dbo].[tblRMReports] ([intReportId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblRMCriteriaFields] CHECK CONSTRAINT [FK_dbo.CriteriaFields_dbo.Reports_intReportId]
GO
/****** Object:  ForeignKey [FK_dbo.CriteriaFieldSelections_dbo.Connections_intConnectionId]    Script Date: 10/14/2013 18:40:21 ******/
ALTER TABLE [dbo].[tblRMCriteriaFieldSelections]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CriteriaFieldSelections_dbo.Connections_intConnectionId] FOREIGN KEY([intConnectionId])
REFERENCES [dbo].[tblRMConnections] ([intConnectionId])
GO
ALTER TABLE [dbo].[tblRMCriteriaFieldSelections] CHECK CONSTRAINT [FK_dbo.CriteriaFieldSelections_dbo.Connections_intConnectionId]
GO
/****** Object:  ForeignKey [FK_dbo.Datasources_dbo.Connections_intConnectionId]    Script Date: 10/14/2013 18:40:21 ******/
ALTER TABLE [dbo].[tblRMDatasources]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Datasources_dbo.Connections_intConnectionId] FOREIGN KEY([intConnectionId])
REFERENCES [dbo].[tblRMConnections] ([intConnectionId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblRMDatasources] CHECK CONSTRAINT [FK_dbo.Datasources_dbo.Connections_intConnectionId]
GO
/****** Object:  ForeignKey [FK_dbo.Datasources_dbo.Reports_intReportId]    Script Date: 10/14/2013 18:40:21 ******/
ALTER TABLE [dbo].[tblRMDatasources]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Datasources_dbo.Reports_intReportId] FOREIGN KEY([intReportId])
REFERENCES [dbo].[tblRMReports] ([intReportId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblRMDatasources] CHECK CONSTRAINT [FK_dbo.Datasources_dbo.Reports_intReportId]
GO
/****** Object:  ForeignKey [FK_dbo.DesignParameters_dbo.Reports_Report_intReportId]    Script Date: 10/14/2013 18:40:21 ******/
ALTER TABLE [dbo].[tblRMDesignParameters]  WITH CHECK ADD  CONSTRAINT [FK_dbo.DesignParameters_dbo.Reports_Report_intReportId] FOREIGN KEY([Report_intReportId])
REFERENCES [dbo].[tblRMReports] ([intReportId])
GO
ALTER TABLE [dbo].[tblRMDesignParameters] CHECK CONSTRAINT [FK_dbo.DesignParameters_dbo.Reports_Report_intReportId]
GO
/****** Object:  ForeignKey [FK_dbo.FieldSelectionFilters_dbo.CriteriaFields_intCriteriaFieldId]    Script Date: 10/14/2013 18:40:21 ******/
ALTER TABLE [dbo].[tblRMFieldSelectionFilters]  WITH CHECK ADD  CONSTRAINT [FK_dbo.FieldSelectionFilters_dbo.CriteriaFields_intCriteriaFieldId] FOREIGN KEY([intCriteriaFieldId])
REFERENCES [dbo].[tblRMCriteriaFields] ([intCriteriaFieldId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblRMFieldSelectionFilters] CHECK CONSTRAINT [FK_dbo.FieldSelectionFilters_dbo.CriteriaFields_intCriteriaFieldId]
GO
/****** Object:  ForeignKey [FK_dbo.Filters_dbo.Reports_intReportId]    Script Date: 10/14/2013 18:40:21 ******/
ALTER TABLE [dbo].[tblRMFilters]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Filters_dbo.Reports_intReportId] FOREIGN KEY([intReportId])
REFERENCES [dbo].[tblRMReports] ([intReportId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblRMFilters] CHECK CONSTRAINT [FK_dbo.Filters_dbo.Reports_intReportId]
GO
/****** Object:  ForeignKey [FK_dbo.Options_dbo.Reports_intReportId]    Script Date: 10/14/2013 18:40:21 ******/
ALTER TABLE [dbo].[tblRMOptions]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Options_dbo.Reports_intReportId] FOREIGN KEY([intReportId])
REFERENCES [dbo].[tblRMReports] ([intReportId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblRMOptions] CHECK CONSTRAINT [FK_dbo.Options_dbo.Reports_intReportId]
GO
/****** Object:  ForeignKey [FK_dbo.Reports_dbo.CompanyInformations_intCompanyInformationId]    Script Date: 10/14/2013 18:40:21 ******/
ALTER TABLE [dbo].[tblRMReports]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Reports_dbo.CompanyInformations_intCompanyInformationId] FOREIGN KEY([intCompanyInformationId])
REFERENCES [dbo].[tblRMCompanyInformations] ([intCompanyInformationId])
GO
ALTER TABLE [dbo].[tblRMReports] CHECK CONSTRAINT [FK_dbo.Reports_dbo.CompanyInformations_intCompanyInformationId]
GO
/****** Object:  ForeignKey [FK_dbo.Sorts_dbo.Reports_intReportId]    Script Date: 10/14/2013 18:40:21 ******/
ALTER TABLE [dbo].[tblRMSorts]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Sorts_dbo.Reports_intReportId] FOREIGN KEY([intReportId])
REFERENCES [dbo].[tblRMReports] ([intReportId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblRMSorts] CHECK CONSTRAINT [FK_dbo.Sorts_dbo.Reports_intReportId]
GO
/****** Object:  ForeignKey [FK_dbo.SubreportSettings_dbo.Reports_intReportId]    Script Date: 10/14/2013 18:40:21 ******/
ALTER TABLE [dbo].[tblRMSubreportSettings]  WITH CHECK ADD  CONSTRAINT [FK_dbo.SubreportSettings_dbo.Reports_intReportId] FOREIGN KEY([intReportId])
REFERENCES [dbo].[tblRMReports] ([intReportId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblRMSubreportSettings] CHECK CONSTRAINT [FK_dbo.SubreportSettings_dbo.Reports_intReportId]
GO
