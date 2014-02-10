﻿/*
Deployment script for Powell

This code was generated by a tool.
Changes to this file may cause incorrect behavior and will be lost if
the code is regenerated.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName "Powell"
:setvar DefaultFilePrefix "Powell"
:setvar DefaultDataPath "C:\Program Files\Microsoft SQL Server\MSSQL10_50.SQL2008R2DEV\MSSQL\DATA\"
:setvar DefaultLogPath "C:\Program Files\Microsoft SQL Server\MSSQL10_50.SQL2008R2DEV\MSSQL\DATA\"

GO
:on error exit
GO
/*
Detect SQLCMD mode and disable script execution if SQLCMD mode is not supported.
To re-enable the script after enabling SQLCMD mode, execute the following:
SET NOEXEC OFF; 
*/
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'SQLCMD mode must be enabled to successfully execute this script.';
        SET NOEXEC ON;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET ANSI_NULLS ON,
                ANSI_PADDING ON,
                ANSI_WARNINGS ON,
                ARITHABORT ON,
                CONCAT_NULL_YIELDS_NULL ON,
                QUOTED_IDENTIFIER ON,
                ANSI_NULL_DEFAULT ON,
                CURSOR_DEFAULT LOCAL,
                RECOVERY FULL 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET PAGE_VERIFY NONE 
            WITH ROLLBACK IMMEDIATE;
    END


GO
USE [$(DatabaseName)];


GO
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

-- Validate if there are more than ONE record on coctlmst. if there are, raise error
IF (SELECT count(*) from coctlmst) >1
BEGIN
	GOTO MULTIPLE_Rec;	
END

IF (SELECT count(*) from coctlmst) = 0
BEGIN
	GOTO NO_Rec;	
END

CREATE TABLE ##tblOriginMod
(
	 intModId INT IDENTITY(1,1)
	, strPrefix NVARCHAR(5)
	, strName NVARCHAR(30)
	, ysnUsed BIT
)


IF EXISTS (SELECT TOP 1 1 from INFORMATION_SCHEMA.COLUMNS where COLUMN_NAME = 'coctl_ap')
BEGIN
	EXEC ('INSERT INTO ##tblOriginMod (strPrefix, strName, ysnUsed) SELECT TOP 1 N''AP'', N''ACCOUNTS PAYABLE'', CASE ISNULL(coctl_ap, ''N'') WHEN ''Y'' THEN 1 else 0 END FROM coctlmst')
	--SELECT TOP 1 @AP = ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AP'
END







RETURN;
MULTIPLE_Rec:
	RAISERROR(N'There are multiple records on coctlmst. Deployment terminated.', 16,1)
	RETURN;
	
NO_Rec:
	RAISERROR(N'There are no records on coctlmst. Deployment terminated.', 16,1)

GO

-- ACCOUNTS PAYABLE
IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'apcbkmst')
	DROP VIEW apcbkmst

IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AP') = 1
	EXEC ('
		CREATE VIEW [dbo].apcbkmst
		AS 

		SELECT * FROM apcbkmst_origin
	')

GO

GO
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

GO
PRINT N'Update complete.';


GO
