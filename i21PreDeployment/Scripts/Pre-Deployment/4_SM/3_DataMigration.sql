GO
	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMUserSecurityMenuFavorite')
	BEGIN
		IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMUserSecurityMenuFavorite' AND [COLUMN_NAME] = 'intUserSecurityId') 
			EXEC('ALTER TABLE tblSMUserSecurityMenuFavorite ADD intUserSecurityId INT NOT NULL DEFAULT 0')
	END
GO
	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMUserSecurityMenuFavorite')
	BEGIN
		IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMUserSecurityMenuFavorite' AND [COLUMN_NAME] = 'intUserRoleMenuId') 
			IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMUserSecurityMenuFavorite' AND [COLUMN_NAME] = 'intMenuId') 
				EXEC('ALTER TABLE tblSMUserSecurityMenuFavorite ADD intUserRoleMenuId INT NOT NULL DEFAULT 0')
	END
GO

	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMUserSecurityMenuFavorite')
	BEGIN
		EXEC
		(
			'PRINT N''Check if intUserSecurityMenuID is existing''
			
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = ''tblSMUserSecurityMenuFavorite'' AND [COLUMN_NAME] = ''intUserSecurityMenuId'')
				BEGIN
					IF EXISTS(SELECT TOP 1 1 FROM sys.objects where name = ''FK_tblSMUserSecurityMenuFavorite_tblSMUserSecurityMenu'')
					BEGIN
						PRINT N''Drop FK_tblSMUserSecurityMenuFavorite_tblSMUserSecurityMenu''
						ALTER TABLE tblSMUserSecurityMenuFavorite DROP CONSTRAINT FK_tblSMUserSecurityMenuFavorite_tblSMUserSecurityMenu;
					END

					PRINT N''UPDATE intUserSecurityMenuId with intUserRoleMenuId data AND INSERT the intUserSecurityId''

					EXEC (''UPDATE MenuFavorite SET MenuFavorite.intUserRoleMenuId = RoleMenu.intUserRoleMenuId, MenuFavorite.intUserSecurityId = UserSecurity.intUserSecurityID
					FROM tblSMUserRoleMenu RoleMenu
					JOIN tblSMUserSecurity UserSecurity 
						ON RoleMenu.intUserRoleId = UserSecurity.intUserRoleID
					JOIN tblSMUserSecurityMenu SecurityMenu 
						ON UserSecurity.intUserSecurityID = SecurityMenu.intUserSecurityId AND SecurityMenu.intMenuId = RoleMenu.intMenuId
					JOIN tblSMUserSecurityMenuFavorite MenuFavorite 
						ON SecurityMenu.intUserSecurityMenuId = MenuFavorite.intUserSecurityMenuId'')
				END'
		)
	END

GO
	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMTaxClass')
	BEGIN
		IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMTaxClass' AND [COLUMN_NAME] = 'ysnTaxable') 
		BEGIN		
			PRINT N'INSERT data from tblSMTaxType to tblSMTaxClass'

			EXEC ('TRUNCATE TABLE tblSMTaxClass
				   SET IDENTITY_INSERT tblSMTaxClass ON
				   INSERT INTO tblSMTaxClass([intTaxClassId], [strTaxClass], [ysnTaxable])
				   SELECT [intTaxTypeId], [strTaxType], 0
				   FROM tblSMTaxType
				   SET IDENTITY_INSERT tblSMTaxClass OFF')
		END	
	END
GO
	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMCompanyPreference')
	BEGIN
		IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblCFCompanyPreference')
		BEGIN
			PRINT N'CREATING tblTEMPCompanyPreference'

			IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblTEMPCompanyPreference')
			BEGIN
				   CREATE TABLE [dbo].[tblTEMPCompanyPreference] (
				   [intCompanyPreferenceId]            INT            IDENTITY (1, 1) NOT NULL,
				   [strCFServiceReminderMessage]       NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
				   [ysnCFUseSpecialPrices]             BIT            NULL,
				   [strCFUsePrice]                     NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
				   [ysnCFUseContracts]                 BIT            NULL,
				   [ysnCFSummarizeInvoice]             BIT            NULL,
				   [strCFInvoiceSummarizationLocation] NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
				   [intConcurrencyId]                  INT            CONSTRAINT [DF_tblTEMPCompanyPreference_intConcurrencyId] DEFAULT ((1)) NULL,
				   CONSTRAINT [PK_tblTEMPCompanyPreference] PRIMARY KEY CLUSTERED ([intCompanyPreferenceId] ASC)
				   );
			END

			PRINT N'INSERTING tblTEMPCompanyPreference from tblSMCompanyPreference'

			EXEC ('INSERT INTO [dbo].[tblTEMPCompanyPreference]
			       ([strCFServiceReminderMessage],
				   [ysnCFUseSpecialPrices],
				   [strCFUsePrice],
				   [ysnCFUseContracts],
				   [ysnCFSummarizeInvoice],
				   [strCFInvoiceSummarizationLocation],
				   [intConcurrencyId])
				   SELECT [strCFServiceReminderMessage],
				   [ysnCFUseSpecialPrices],
				   [strCFUsePrice],
				   [ysnCFUseContracts],
				   [ysnCFSummarizeInvoice],
				   [strCFInvoiceSummarizationLocation],
				   [intConcurrencyId]
				   FROM [dbo].[tblSMCompanyPreference]')
		END
		--ELSE
		--BEGIN
		--	IF NOT EXISTS(SELECT TOP 1 1 FROM tblCFCompanyPreference)
		--	BEGIN
		--		PRINT N'INSERTING tblCFCompanyPreference default data'
		--		INSERT INTO tblCFCompanyPreference(strCFServiceReminderMessage, ysnCFUseSpecialPrices, strCFUsePrice, ysnCFUseContracts, ysnCFSummarizeInvoice, strCFInvoiceSummarizationLocation, intConcurrencyId)
		--		VALUES(NULL, NULL, NULL, NULL, NULL, NULL, 1)
		--	END
		--END
	END
GO
	-- DROP USER ROLE MENU RELATION IN PRE-DEPLOYMENT
	-- REPLACE intUserRoleMenuId with intMenuId in PRE-DEPLOYMENT
	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMUserSecurityMenuFavorite')
	BEGIN
		IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMUserSecurityMenuFavorite' AND [COLUMN_NAME] = 'intMenuId') 
		BEGIN
			EXEC('ALTER TABLE tblSMUserSecurityMenuFavorite ADD intMenuId INT NOT NULL DEFAULT 0')	
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMUserSecurityMenuFavorite')
			BEGIN
				EXEC
				(
					'PRINT N''Check if intUserRoleMenuId is existing''
			
					IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = ''tblSMUserSecurityMenuFavorite'' AND [COLUMN_NAME] = ''intUserRoleMenuId'')
						BEGIN
							IF EXISTS(SELECT TOP 1 1 FROM sys.objects where name = ''FK_tblSMUserSecurityMenuFavorite_tblSMUserRoleMenu'')
							BEGIN
								PRINT N''Drop FK_tblSMUserSecurityMenuFavorite_tblSMUserRoleMenu''
								ALTER TABLE tblSMUserSecurityMenuFavorite DROP CONSTRAINT FK_tblSMUserSecurityMenuFavorite_tblSMUserRoleMenu;
							END

							PRINT N''UPDATE intUserRoleMenuId with intMenuId data''

							EXEC (''UPDATE MenuFavorite SET MenuFavorite.intMenuId = MasterMenu.intMenuID
							FROM tblSMMasterMenu MasterMenu
							JOIN tblSMUserRoleMenu RoleMenu 
								ON RoleMenu.intMenuId = MasterMenu.intMenuID
							JOIN tblSMUserSecurityMenuFavorite MenuFavorite 
								ON RoleMenu.intUserRoleMenuId = MenuFavorite.intUserRoleMenuId'')
						END'
				)
			END
		END
	END
GO

	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMUserSecurity' AND [COLUMN_NAME] = 'intUserSecurityID') 
	BEGIN
		EXEC
		(
		'PRINT N''Check if tblSMRecurrintTransaction is existing''

		IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = ''tblSMRecurringTransaction'')
		BEGIN
			ALTER TABLE tblSMRecurringTransaction ALTER COLUMN intUserId INT NULL

			UPDATE tblSMRecurringTransaction SET intUserId = NULL 
			WHERE intUserId NOT IN (SELECT intUserSecurityID FROM tblSMUserSecurity) 
			AND intUserId NOT IN (SELECT intEntityId FROM tblSMUserSecurity)
		
			UPDATE tblSMRecurringTransaction SET intUserId = UserSecurity.intEntityId
			FROM tblSMRecurringTransaction Recurring
			INNER JOIN tblSMUserSecurity UserSecurity ON Recurring.intUserId = UserSecurity.intUserSecurityID
		END'
		)
	END

GO

	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityCredential' AND [COLUMN_NAME] = 'intEntityRoleId') 
	BEGIN
		PRINT N'Check if tblEMEntityCredential is existing and intEntityRoleId'

		IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityToContact')
		BEGIN
			IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityToContact' AND [COLUMN_NAME] = 'intEntityRoleId') 
			BEGIN
				EXEC('ALTER TABLE tblEMEntityToContact ADD intEntityRoleId INT NULL')
				EXEC
				('
					UPDATE tblEMEntityToContact SET intEntityRoleId = EntityCredential.intEntityRoleId
					FROM [dbo].[tblEMEntityToContact] EntityToContact
					INNER JOIN [dbo].[tblEMEntityCredential] EntityCredential ON EntityToContact.intEntityContactId = EntityCredential.intEntityId
					WHERE EntityCredential.intEntityRoleId IS NOT NULL
				')
			END
		END
	END

GO

	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomerLicenseModule')
	BEGIN
		IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomerLicenseModule' AND ([COLUMN_NAME] = 'ysnEnabled' OR [COLUMN_NAME] = 'intModuleId')) 
		BEGIN
			PRINT N'ADDING tblARCustomerLicenseModule.ysnEnabled AND tblARCustomerLicenseModule.intModuleId'
			EXEC('ALTER TABLE tblARCustomerLicenseModule ADD ysnEnabled BIT DEFAULT 0
				  ALTER TABLE tblARCustomerLicenseModule ADD intModuleId INT NULL')
		END
	END

GO

	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomerLicenseModule' AND ([COLUMN_NAME] = 'ysnEnabled' OR [COLUMN_NAME] = 'intModuleId')) 
	BEGIN
		PRINT N'TRY UPDATING tblARCustomerLicenseModule.ysnEnabled AND tblARCustomerLicenseModule.intModuleId VALUES'
		EXEC('IF EXISTS(SELECT TOP 1 1 FROM tblARCustomerLicenseModule WHERE intModuleId IS NULL)
			 BEGIN
				 UPDATE T SET T.ysnEnabled = 1, T.intModuleId = module.intModuleId
				 FROM tblARCustomerLicenseModule T
		 		INNER JOIN tblSMModule module ON T.strModuleName = module.strModule AND module.strApplicationName = ''i21''
			 END')
	END

GO

	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomerLicenseModule' AND ([COLUMN_NAME] = 'ysnEnabled' OR [COLUMN_NAME] = 'intModuleId')) 
	BEGIN
		PRINT N'ADDING NEW i21 MODULES IN tblARCustomerLicenseModule'
		EXEC('DECLARE @currentRow INT
			  DECLARE @totalRows INT
	  
			  SET @currentRow = 1
			  SELECT @totalRows = Count(*) FROM tblARCustomerLicenseInformation
	  
			  WHILE (@currentRow <= @totalRows)
			  BEGIN
	  
			  Declare @customerId INT
			  SELECT @customerId = intCustomerLicenseInformationId FROM (  
	  			SELECT ROW_NUMBER() OVER(ORDER BY intCustomerLicenseInformationId ASC) AS ''ROWID'', *
	  			FROM tblARCustomerLicenseInformation
			  ) a
			  WHERE ROWID = @currentRow
	  
			  INSERT INTO tblARCustomerLicenseModule (intCustomerLicenseInformationId, strModuleName, intModuleId)
			  SELECT @customerId, Module.strModule, Module.intModuleId
			  FROM tblARCustomerLicenseModule License 
			  RIGHT JOIN tblSMModule Module ON License.intModuleId =  Module.intModuleId AND License.intCustomerLicenseInformationId = @customerId
			  WHERE Module.strApplicationName = ''i21'' AND Module.intModuleId NOT IN (93, 94, 95, 96) AND License.intModuleId IS NULL
	  
			  SET @currentRow = @currentRow + 1
			  END')
	END

GO

	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomerLicenseModule' AND ([COLUMN_NAME] = 'ysnEnabled' OR [COLUMN_NAME] = 'intModuleId')) 
	BEGIN
		PRINT N'RENAME GRAIN TO TICKET MANAGEMENT'
		EXEC('UPDATE tblARCustomerLicenseModule SET strModuleName = ''Ticket Management'', ysnEnabled = 0 WHERE strModuleName = ''Grain''')
	END

GO
	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMCommentMaintenanceComment')
	BEGIN
		IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMDocumentMaintenanceMessage')
		BEGIN
			EXEC('ALTER TABLE tblSMCommentMaintenanceComment ADD strHeaderFooter NVARCHAR(25)  COLLATE Latin1_General_CI_AS NULL')

			EXEC('UPDATE Comment SET strHeaderFooter = CASE WHEN Maintenance.strSource LIKE ''%Footer%'' THEN ''Footer'' ELSE ''Header'' END
				FROM tblSMCommentMaintenance Maintenance
				INNER JOIN tblSMCommentMaintenanceComment Comment ON Maintenance.intCommentMaintenanceId = Comment.intCommentMaintenanceId')

			EXEC('sp_rename ''tblSMCommentMaintenanceComment.intCommentMaintenanceId'',''intDocumentMaintenanceId'', ''COLUMN''')

			EXEC('sp_rename ''tblSMCommentMaintenanceComment'',''tblSMDocumentMaintenanceMessage''')
		END
	END

	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMCommentMaintenance')
	BEGIN
		IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMDocumentMaintenance')
		BEGIN
			EXEC('UPDATE tblARCommentMaintenance SET strCommentCode = REPLACE(strCommentCode, ''COM'', ''DOM'')')
			EXEC('sp_rename ''tblSMCommentMaintenance.intCommentMaintenanceId'',''intDocumentMaintenanceId'', ''COLUMN''')
			EXEC('sp_rename ''tblSMCommentMaintenance'',''tblSMDocumentMaintenance''')
		END
	END

	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCommentMaintenance')
	BEGIN
		IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMDocumentMaintenanceMessage')
		BEGIN
			PRINT N'CREATING tblSMDocumentMaintenanceMessage'
			EXEC('CREATE TABLE [dbo].[tblSMDocumentMaintenanceMessage]
					(
					[intDocumentMaintenanceCommentId] INT NOT NULL PRIMARY KEY IDENTITY, 
					[intDocumentMaintenanceId] INT NOT NULL, 
					[strHeaderFooter] NVARCHAR(25)  COLLATE Latin1_General_CI_AS NULL,
					[intCharacterLimit] INT NOT NULL, 
					[strMessage] NVARCHAR(MAX) NOT NULL
					)')

			PRINT N'MIGRATING RECORDS FROM tblSMDocumentMaintenance TO tblSMDocumentMaintenanceMessage'
			EXEC('INSERT INTO tblSMDocumentMaintenanceMessage(intDocumentMaintenanceId, strHeaderFooter, intCharacterLimit, strMessage)
	     			SELECT intCommentId, CASE WHEN strTransactionType LIKE ''%Footer%'' THEN ''Footer'' ELSE ''Header'' END, LEN(strCommentDesc) AS intCharacterLimit, strCommentDesc FROM tblARCommentMaintenance')
		END

	END

GO