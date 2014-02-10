-- CONSOLIDATED DELETE SCRIPTS


PRINT N' BEGIN CONSOLIDATED DELETE PATH: 13.4 to 14.1'


	GO
	PRINT N'Dropping FK_dbo.Reports_dbo.CompanyInformations_intCompanyInformationId...';
	GO
	ALTER TABLE [dbo].[tblRMReports] DROP CONSTRAINT [FK_dbo.Reports_dbo.CompanyInformations_intCompanyInformationId];
	GO
	PRINT N'Dropping FK_dbo.CriteriaFieldSelections_dbo.Connections_intConnectionId...';
	GO
	ALTER TABLE [dbo].[tblRMCriteriaFieldSelections] DROP CONSTRAINT [FK_dbo.CriteriaFieldSelections_dbo.Connections_intConnectionId];
	GO
	PRINT N'Dropping FK_dbo.Datasources_dbo.Connections_intConnectionId...';
	GO
	ALTER TABLE [dbo].[tblRMDatasources] DROP CONSTRAINT [FK_dbo.Datasources_dbo.Connections_intConnectionId];
	GO
	PRINT N'Dropping FK_dbo.FieldSelectionFilters_dbo.CriteriaFields_intCriteriaFieldId...';
	GO
	ALTER TABLE [dbo].[tblRMFieldSelectionFilters] DROP CONSTRAINT [FK_dbo.FieldSelectionFilters_dbo.CriteriaFields_intCriteriaFieldId];
	GO
	PRINT N'Dropping FK_dbo.CriteriaFields_dbo.CriteriaFieldSelections_intCriteriaFieldSelectionId...';
	GO
	ALTER TABLE [dbo].[tblRMCriteriaFields] DROP CONSTRAINT [FK_dbo.CriteriaFields_dbo.CriteriaFieldSelections_intCriteriaFieldSelectionId];
	GO
	PRINT N'Dropping FK_dbo.Options_dbo.Reports_intReportId...';
	GO
	ALTER TABLE [dbo].[tblRMOptions] DROP CONSTRAINT [FK_dbo.Options_dbo.Reports_intReportId];
	GO
	PRINT N'Dropping FK_dbo.Sorts_dbo.Reports_intReportId...';
	GO
	ALTER TABLE [dbo].[tblRMSorts] DROP CONSTRAINT [FK_dbo.Sorts_dbo.Reports_intReportId];
	GO
	PRINT N'Dropping FK_dbo.SubreportSettings_dbo.Reports_intReportId...';
	GO
	ALTER TABLE [dbo].[tblRMSubreportSettings] DROP CONSTRAINT [FK_dbo.SubreportSettings_dbo.Reports_intReportId];
	GO
	PRINT N'Dropping FK_dbo.Configurations_dbo.Reports_intReportId...';
	GO
	ALTER TABLE [dbo].[tblRMConfigurations] DROP CONSTRAINT [FK_dbo.Configurations_dbo.Reports_intReportId];
	GO
	PRINT N'Dropping FK_dbo.CriteriaFields_dbo.Reports_intReportId...';
	GO
	ALTER TABLE [dbo].[tblRMCriteriaFields] DROP CONSTRAINT [FK_dbo.CriteriaFields_dbo.Reports_intReportId];
	GO
	PRINT N'Dropping FK_dbo.Datasources_dbo.Reports_intReportId...';
	GO
	ALTER TABLE [dbo].[tblRMDatasources] DROP CONSTRAINT [FK_dbo.Datasources_dbo.Reports_intReportId];
	GO
	PRINT N'Dropping FK_dbo.Filters_dbo.Reports_intReportId...';
	GO
	ALTER TABLE [dbo].[tblRMFilters] DROP CONSTRAINT [FK_dbo.Filters_dbo.Reports_intReportId];
	GO
	PRINT N'Dropping [dbo].[tblRMArchives]...';
	GO
	DROP TABLE [dbo].[tblRMArchives];
	GO
	PRINT N'Dropping [dbo].[tblRMCompanyInformations]...';
	GO
	DROP TABLE [dbo].[tblRMCompanyInformations];
	GO
	PRINT N'Dropping [dbo].[tblRMConfigurations]...';
	GO
	DROP TABLE [dbo].[tblRMConfigurations];
	GO
	PRINT N'Dropping [dbo].[tblRMFieldSelectionFilters]...';
	GO
	DROP TABLE [dbo].[tblRMFieldSelectionFilters];
	GO
	PRINT N'Dropping [dbo].[tblRMFilters]...';
	GO
	DROP TABLE [dbo].[tblRMFilters];
	GO
	PRINT N'Dropping [dbo].[tblRMOptions]...';
	GO
	DROP TABLE [dbo].[tblRMOptions];
	GO
	PRINT N'Dropping [dbo].[tblRMSorts]...';
	GO
	DROP TABLE [dbo].[tblRMSorts];
	GO
	PRINT N'Dropping [dbo].[tblRMSubreportSettings]...';
	GO
	DROP TABLE [dbo].[tblRMSubreportSettings];
	GO
	PRINT N'Dropping [dbo].[tblRMUsers]...';
	GO
	DROP TABLE [dbo].[tblRMUsers];
	GO
	PRINT N'Dropping [dbo].[vwapivcmst]...';
	GO
	DROP VIEW [dbo].[vwapivcmst];
	GO
	PRINT N'Dropping [dbo].[vwcoctlmst]...';
	GO
	DROP VIEW [dbo].[vwcoctlmst];
	GO
	PRINT N'Dropping [dbo].[vwticmst]...';
	GO
	DROP VIEW [dbo].[vwticmst];
	GO
	PRINT N'Dropping [dbo].[vyu_GLAccountView]...';
	GO
	DROP VIEW [dbo].[vyu_GLAccountView];
	GO
	PRINT N'Dropping [dbo].[vyu_GLDetailView]...';
	GO
	DROP VIEW [dbo].[vyu_GLDetailView];
	GO
	PRINT N'Dropping [dbo].[usp_BuildGLAccount]...';
	GO
	DROP PROCEDURE [dbo].[usp_BuildGLAccount];
	GO
	PRINT N'Dropping [dbo].[usp_BuildGLAccountTemporary]...';
	GO
	DROP PROCEDURE [dbo].[usp_BuildGLAccountTemporary];
	GO
	PRINT N'Dropping [dbo].[usp_RMInsertDynamicParameterFields]...';
	GO
	DROP PROCEDURE [dbo].[usp_RMInsertDynamicParameterFields];
	GO
	PRINT N'Dropping [dbo].[usp_SyncAccounts]...';
	GO
	DROP PROCEDURE [dbo].[usp_SyncAccounts];
	GO
	PRINT N'Dropping [dbo].[tblRMConnections]...';
	GO
	DROP TABLE [dbo].[tblRMConnections];
	GO
	PRINT N'Dropping [dbo].[tblRMCriteriaFields]...';
	GO
	DROP TABLE [dbo].[tblRMCriteriaFields];
	GO
	PRINT N'Dropping [dbo].[tblRMCriteriaFieldSelections]...';
	GO
	DROP TABLE [dbo].[tblRMCriteriaFieldSelections];
	GO
	PRINT N'Dropping [dbo].[tblRMDatasources]...';
	GO
	DROP TABLE [dbo].[tblRMDatasources];
	GO
	PRINT N'Dropping [dbo].[tblRMReports]...';
	GO
	DROP TABLE [dbo].[tblRMReports];
	GO
	PRINT N'Dropping [dbo].[usp_BuildGLTempCOASegment]...';
	GO
	DROP PROCEDURE [dbo].[usp_BuildGLTempCOASegment];
	GO



PRINT N' END CONSOLIDATED DELETE PATH: 13.4 to 14.1'