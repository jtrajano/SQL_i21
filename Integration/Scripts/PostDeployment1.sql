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


-- DROP temp table created from PreDeployment script
IF OBJECT_ID('tempdb..##tblOriginMod') IS NOT NULL DROP TABLE ##tblOriginMod
GO

-- Add the SQL Server custom messages
EXEC dbo.uspSMErrorMessages

:r "..\Scripts\AP\TransferImportedTermsData.sql"
:r "..\Scripts\AP\TransferImportedVendorData.sql"