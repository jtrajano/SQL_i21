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
PRINT 'Updating fiscal year/period upper bounds'
GO
UPDATE tblGLFiscalYear set dtmDateTo = DATEADD(SECOND,59, DATEADD(MINUTE, 59, DATEADD(HOUR, 23, DATEADD(dd, 0, DATEDIFF(dd, 0, dtmDateTo)))))
UPDATE tblGLFiscalYearPeriod set dtmEndDate = DATEADD(SECOND,59, DATEADD(MINUTE, 59, DATEADD(HOUR, 23, DATEADD(dd, 0, DATEDIFF(dd, 0, dtmEndDate)))))
GO