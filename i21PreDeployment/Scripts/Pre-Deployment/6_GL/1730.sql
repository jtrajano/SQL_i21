/*
 Pre-Deployment Script Template
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be executed before the build script.
 Use SQLCMD syntax to include a file in the pre-deployment script.
 Example:      :r .\myfile.sql
 Use SQLCMD syntax to reference a variable in the pre-deployment script.
 Example:      :setvar TableName MyTable
               SELECT * FROM [$(TableName)]
--------------------------------------------------------------------------------------
*/
GO
/*Corrects the intFiscalYearId to avoid foreign constraint issues*/
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCurrentFiscalYear]') AND type in (N'U')) 
BEGIN
	UPDATE CF 
	SET intFiscalYearId = F.intFiscalYearId
	FROM tblGLCurrentFiscalYear  CF JOIN tblGLFiscalYear F ON F.dtmDateFrom = CF.dtmBeginDate
END

GO