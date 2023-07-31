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

GO
	PRINT N'Begin setting defaults for SOW Types.';
GO
	--SOW Types
	IF NOT EXISTS (SELECT TOP 1 '' FROM tblHDStatementOfWorkType WHERE strType = 'Development')
	BEGIN
			INSERT INTO tblHDStatementOfWorkType (
				strType,
				strDescription,
				intConcurrencyId
			) 
			VALUES (
				'Development',
				NULL,
				1
			)
	END

	IF NOT EXISTS (SELECT TOP 1 '' FROM tblHDStatementOfWorkType WHERE strType = 'Implementation')
	BEGIN
			INSERT INTO tblHDStatementOfWorkType (
				strType,
				strDescription,
				intConcurrencyId
			) 
			VALUES (
				'Implementation',
				NULL,
				1
			)
	END

	--SOW Subtypes

	IF NOT EXISTS (SELECT TOP 1 '' FROM tblHDStatementOfWorkTypeSubtype WHERE strSubtype = 'Maintenance/Bug') 
	BEGIN
			INSERT INTO tblHDStatementOfWorkTypeSubtype (
				intTypeId,
				strSubtype,
				strDescription,
				intConcurrencyId
			) 
			SELECT TOP 1	intTypeId			= intTypeId
						   ,strSubtype			= 'Maintenance/Bug'
						   ,strDescription		= NULL
						   ,intConcurrencyId	= 1
		    FROM tblHDStatementOfWorkType
			WHERE strType = 'Development'

	END

	IF NOT EXISTS (SELECT TOP 1 '' FROM tblHDStatementOfWorkTypeSubtype WHERE strSubtype = 'Customization/Enhancement') 
	BEGIN
			INSERT INTO tblHDStatementOfWorkTypeSubtype (
				intTypeId,
				strSubtype,
				strDescription,
				intConcurrencyId
			) 
			SELECT TOP 1	intTypeId			= intTypeId
						   ,strSubtype			= 'Customization/Enhancement'
						   ,strDescription		= NULL
						   ,intConcurrencyId	= 1
		    FROM tblHDStatementOfWorkType
			WHERE strType = 'Development'

	END

	IF NOT EXISTS (SELECT TOP 1 '' FROM tblHDStatementOfWorkTypeSubtype WHERE strSubtype = 'Configuration') 
	BEGIN
			INSERT INTO tblHDStatementOfWorkTypeSubtype (
				intTypeId,
				strSubtype,
				strDescription,
				intConcurrencyId
			) 
			SELECT  intTypeId			= intTypeId
				   ,strSubtype			= 'Configuration'
				   ,strDescription		= NULL
				   ,intConcurrencyId	= 1
		    FROM tblHDStatementOfWorkType
			WHERE strType = 'Development'

	END
	
	IF NOT EXISTS (SELECT TOP 1 '' FROM tblHDStatementOfWorkTypeSubtype WHERE strSubtype = 'Customer Driven Development') 
	BEGIN
			INSERT INTO tblHDStatementOfWorkTypeSubtype (
				intTypeId,
				strSubtype,
				strDescription,
				intConcurrencyId
			) 
			SELECT  intTypeId			= intTypeId
				   ,strSubtype			= 'Customer Driven Development'
				   ,strDescription		= NULL
				   ,intConcurrencyId	= 1
		    FROM tblHDStatementOfWorkType
			WHERE strType = 'Development'

	END

	IF NOT EXISTS (SELECT TOP 1 '' FROM tblHDStatementOfWorkTypeSubtype WHERE strSubtype = 'Full Install') 
	BEGIN
			INSERT INTO tblHDStatementOfWorkTypeSubtype (
				intTypeId,
				strSubtype,
				strDescription,
				intConcurrencyId
			) 
			SELECT  intTypeId			= intTypeId
				   ,strSubtype			= 'Full Install'
				   ,strDescription		= NULL
				   ,intConcurrencyId	= 1
		    FROM tblHDStatementOfWorkType
			WHERE strType = 'Implementation'

	END

	IF NOT EXISTS (SELECT TOP 1 '' FROM tblHDStatementOfWorkTypeSubtype WHERE strSubtype = 'Upgrade') 
	BEGIN
			INSERT INTO tblHDStatementOfWorkTypeSubtype (
				intTypeId,
				strSubtype,
				strDescription,
				intConcurrencyId
			) 
			SELECT  intTypeId			= intTypeId
				   ,strSubtype			= 'Upgrade'
				   ,strDescription		= NULL
				   ,intConcurrencyId	= 1
		    FROM tblHDStatementOfWorkType
			WHERE strType = 'Implementation'

	END

	IF NOT EXISTS (SELECT TOP 1 '' FROM tblHDStatementOfWorkTypeSubtype WHERE strSubtype = 'Additional Services') 
	BEGIN
			INSERT INTO tblHDStatementOfWorkTypeSubtype (
				intTypeId,
				strSubtype,
				strDescription,
				intConcurrencyId
			) 
			SELECT  intTypeId			= intTypeId
				   ,strSubtype			= 'Additional Services'
				   ,strDescription		= NULL
				   ,intConcurrencyId	= 1
		    FROM tblHDStatementOfWorkType
			WHERE strType = 'Implementation'

	END



GO
	PRINT N'End setting defaults for SOW Types.';
GO