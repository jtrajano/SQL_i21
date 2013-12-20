/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

print 'BEGIN POST DEPLOYMENT'

:r .\1_ReportDisableConstraints.sql
:r .\2_ReportDeleteOldData.sql
:r .\3_ReportEnableConstraints.sql
:r .\4_ReportData.sql


print 'END POST DEPLOYMENT'