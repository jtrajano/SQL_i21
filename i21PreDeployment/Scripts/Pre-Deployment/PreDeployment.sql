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

-- Validate Origin records
-- --coctlmst
:r .\UpdateValidation\1_CheckCoctlmst.sql

-- Delete Objects
:r .\DeleteScripts.sql

-- TM
:r .\1_TM\1_1320_to_1340.sql
:r .\1_TM\2_DropUniqueConstraints.sql
:r .\1_TM\3_1410_to_1420.sql

-- CM
:r .\2_CM\1_CM.sql

-- DB
:r .\3_DB\1_1340_to_1410.sql

-- SM
:r .\4_SM\1_DataCleanup.sql

-- CM
:r .\5_CM\1_DropTriggers.sql