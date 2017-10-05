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
UPDATE CF 
SET intFiscalYearId = F.intFiscalYearId
FROM tblGLCurrentFiscalYear  CF JOIN
tblGLFiscalYear F ON F.dtmDateFrom = CF.dtmBeginDate

GO