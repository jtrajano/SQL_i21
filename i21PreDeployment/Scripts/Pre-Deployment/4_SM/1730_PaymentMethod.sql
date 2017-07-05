GO	
	PRINT N'MIGRATING PAYMENT METHOD'

	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMPaymentMethod') 
	BEGIN
		
		EXEC
		('
			IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''tmpSMPaymentMethod'')
			BEGIN
				DROP TABLE tmpSMPaymentMethod
			END

			IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = ''tblSMPaymentMethod'' AND [COLUMN_NAME] = ''strPrefix'') 
			BEGIN
				ALTER TABLE tblSMPaymentMethod 
				ADD [strPrefix] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL
			END

			IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = ''tblSMPaymentMethod'' AND [COLUMN_NAME] = ''intNumber'') 
			BEGIN
				ALTER TABLE tblSMPaymentMethod 
				ADD [intNumber] INT NOT NULL DEFAULT 1
			END
		')

		IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMPaymentMethod' AND [COLUMN_NAME] = 'intOriginalId') 
		BEGIN

			EXEC
			('

			IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS where CONSTRAINT_NAME = ''FK_dbo.tblAPPayment_tblSMPaymentMethod_intPaymentMethodId'')
			BEGIN
				ALTER TABLE tblAPPayment DROP CONSTRAINT [FK_dbo.tblAPPayment_tblSMPaymentMethod_intPaymentMethodId]
			END

			IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS where CONSTRAINT_NAME = ''FK_tblCCSite_tblSMPaymentMethod_intPaymentMethodId'')
			BEGIN
				ALTER TABLE tblCCSite DROP CONSTRAINT FK_tblCCSite_tblSMPaymentMethod_intPaymentMethodId
			END

			SELECT * INTO tmpSMPaymentMethod FROM tblSMPaymentMethod

			TRUNCATE TABLE tblSMPaymentMethod

			SET IDENTITY_INSERT tblSMPaymentMethod ON

			INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
			SELECT 1, ''Write Off'', NULL, 0, NULL, 1, 0
			UNION ALL 
			SELECT 2, ''ACH'', NULL, 0, NULL, 1, 0
			UNION ALL 
			SELECT 3, ''Debit memos and Payments'', NULL, 0, NULL, 1, 0
			UNION ALL 
			SELECT 4, ''Credit'', NULL, 0, NULL, 1, 0
			UNION ALL 
			SELECT 5, ''Refund'', NULL, 0, NULL, 1, 0
			UNION ALL 
			SELECT 6, ''eCheck'', NULL, 0, NULL, 1, 0
			UNION ALL 
			SELECT 7, ''Check'', NULL, 0, NULL, 1, 0
			UNION ALL 
			SELECT 8, ''Prepay'', NULL, 0, NULL, 1, 0
			UNION ALL 
			SELECT 9, ''CF Invoice'', NULL, 0, NULL, 1, 0
			UNION ALL 
			SELECT 10, ''Cash'', NULL, 0, NULL, 1, 0
			UNION ALL 
			SELECT 11, ''Credit Card'', NULL, 0, NULL, 1, 0

			SET IDENTITY_INSERT tblSMPaymentMethod OFF

			INSERT INTO tblSMPaymentMethod([strPaymentMethod], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
			SELECT strPaymentMethod, strPaymentMethodCode, intAccountId, strPrintOption, ysnActive, intSort
			FROM tmpSMPaymentMethod
			WHERE strPaymentMethod NOT IN (SELECT strPaymentMethod FROM tblSMPaymentMethod)

			UPDATE APPayment SET intPaymentMethodId = Orig.intPaymentMethodID
			FROM tblAPPayment APPayment
			INNER JOIN tmpSMPaymentMethod Temp ON APPayment.intPaymentMethodId = Temp.intPaymentMethodID
			INNER JOIN tblSMPaymentMethod Orig ON Temp.strPaymentMethod = Orig.strPaymentMethod

			UPDATE Sites SET intPaymentMethodId = Orig.intPaymentMethodID
			FROM tblCCSite Sites
			INNER JOIN tmpSMPaymentMethod Temp ON Sites.intPaymentMethodId = Temp.intPaymentMethodID
			INNER JOIN tblSMPaymentMethod Orig ON Temp.strPaymentMethod = Orig.strPaymentMethod

			UPDATE ARPayment SET intPaymentMethodId = Orig.intPaymentMethodID
			FROM tblARPayment ARPayment
			INNER JOIN tmpSMPaymentMethod Temp ON ARPayment.intPaymentMethodId = Temp.intPaymentMethodID
			INNER JOIN tblSMPaymentMethod Orig ON Temp.strPaymentMethod = Orig.strPaymentMethod

			UPDATE ARInvoice SET intPaymentMethodId = Orig.intPaymentMethodID
			FROM tblARInvoice ARInvoice
			INNER JOIN tmpSMPaymentMethod Temp ON ARInvoice.intPaymentMethodId = Temp.intPaymentMethodID
			INNER JOIN tblSMPaymentMethod Orig ON Temp.strPaymentMethod = Orig.strPaymentMethod

			ALTER TABLE tblSMPaymentMethod ADD intOriginalId INT NULL

			UPDATE Orig SET intOriginalId = Temp.intPaymentMethodID
			FROM tblSMPaymentMethod Orig
			INNER JOIN tmpSMPaymentMethod Temp ON Orig.strPaymentMethod = Temp.strPaymentMethod

			')

		END		
		ELSE
		BEGIN
			EXEC
			('
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = ''Prepay'' AND intPaymentMethodID = 8)
				BEGIN
				
					IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS where CONSTRAINT_NAME = ''FK_dbo.tblAPPayment_tblSMPaymentMethod_intPaymentMethodId'')
					BEGIN
						ALTER TABLE tblAPPayment DROP CONSTRAINT [FK_dbo.tblAPPayment_tblSMPaymentMethod_intPaymentMethodId]
					END
					
					IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS where CONSTRAINT_NAME = ''FK_tblCCSite_tblSMPaymentMethod_intPaymentMethodId'')
					BEGIN
						ALTER TABLE tblCCSite DROP CONSTRAINT FK_tblCCSite_tblSMPaymentMethod_intPaymentMethodId
					END

					IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS where CONSTRAINT_NAME = ''FK_tblARInvoice_tblSMPaymentMethod_intPaymentMethodId'')
					BEGIN
						ALTER TABLE tblARInvoice DROP CONSTRAINT FK_tblARInvoice_tblSMPaymentMethod_intPaymentMethodId
					END
					
					IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = ''tblSMPaymentMethod'' AND [COLUMN_NAME] = ''strPrefix'') 
					BEGIN
						ALTER TABLE tblSMPaymentMethod 
						ALTER COLUMN [strPrefix] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL
					END
									
					SELECT * INTO tmpSMPaymentMethod FROM tblSMPaymentMethod WHERE intPaymentMethodID > 7

					DELETE FROM tblSMPaymentMethod WHERE intPaymentMethodID > 7

					SET IDENTITY_INSERT tblSMPaymentMethod ON

					IF EXISTS(SELECT TOP 1 1 FROM tmpSMPaymentMethod WHERE strPaymentMethod = ''Prepay'')
					BEGIN
						INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort], [intOriginalId], [intConcurrencyId])
						SELECT 8, strPaymentMethod, strPaymentMethodCode, intAccountId, strPrintOption, ysnActive, intSort, intOriginalId, intConcurrencyId
						FROM tmpSMPaymentMethod
						WHERE strPaymentMethod = ''Prepay''
					END
					ELSE
					BEGIN
						INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
						SELECT 8, ''Prepay'', NULL, 0, NULL, 1, 0
					END
	
					DECLARE @add INT
					SELECT @add = COUNT(*) FROM tmpSMPaymentMethod WHERE intPaymentMethodID = 8

					INSERT INTO tblSMPaymentMethod(intPaymentMethodID, strPaymentMethod, strPaymentMethodCode, strPrefix, intNumber, intAccountId, strPrintOption, ysnActive, intSort, intOriginalId, intConcurrencyId)
					SELECT intPaymentMethodID + @add, strPaymentMethod, strPaymentMethodCode, strPrefix, intNumber, intAccountId, strPrintOption, ysnActive, intSort, intOriginalId, intConcurrencyId
					FROM tmpSMPaymentMethod
					WHERE strPaymentMethod NOT IN (SELECT strPaymentMethod FROM tblSMPaymentMethod)
					
					SET IDENTITY_INSERT tblSMPaymentMethod OFF

					UPDATE APPayment SET intPaymentMethodId = Orig.intPaymentMethodID
					FROM tblAPPayment APPayment
					INNER JOIN tmpSMPaymentMethod Temp ON APPayment.intPaymentMethodId = Temp.intPaymentMethodID
					INNER JOIN tblSMPaymentMethod Orig ON Temp.strPaymentMethod = Orig.strPaymentMethod

					UPDATE Sites SET intPaymentMethodId = Orig.intPaymentMethodID
					FROM tblCCSite Sites
					INNER JOIN tmpSMPaymentMethod Temp ON Sites.intPaymentMethodId = Temp.intPaymentMethodID
					INNER JOIN tblSMPaymentMethod Orig ON Temp.strPaymentMethod = Orig.strPaymentMethod

					UPDATE ARPayment SET intPaymentMethodId = Orig.intPaymentMethodID
					FROM tblARPayment ARPayment
					INNER JOIN tmpSMPaymentMethod Temp ON ARPayment.intPaymentMethodId = Temp.intPaymentMethodID
					INNER JOIN tblSMPaymentMethod Orig ON Temp.strPaymentMethod = Orig.strPaymentMethod

					UPDATE ARInvoice SET intPaymentMethodId = Orig.intPaymentMethodID
					FROM tblARInvoice ARInvoice
					INNER JOIN tmpSMPaymentMethod Temp ON ARInvoice.intPaymentMethodId = Temp.intPaymentMethodID
					INNER JOIN tblSMPaymentMethod Orig ON Temp.strPaymentMethod = Orig.strPaymentMethod

				END
			')
			
			EXEC
			('
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = ''CF Invoice'' AND intPaymentMethodID = 9)
				BEGIN

					IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''tmpSMPaymentMethod'')
					BEGIN
						DROP TABLE tmpSMPaymentMethod
					END
				
					IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS where CONSTRAINT_NAME = ''FK_dbo.tblAPPayment_tblSMPaymentMethod_intPaymentMethodId'')
					BEGIN
						ALTER TABLE tblAPPayment DROP CONSTRAINT [FK_dbo.tblAPPayment_tblSMPaymentMethod_intPaymentMethodId]
					END

					IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS where CONSTRAINT_NAME = ''FK_tblCCSite_tblSMPaymentMethod_intPaymentMethodId'')
					BEGIN
						ALTER TABLE tblCCSite DROP CONSTRAINT FK_tblCCSite_tblSMPaymentMethod_intPaymentMethodId
					END

					IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS where CONSTRAINT_NAME = ''FK_tblARInvoice_tblSMPaymentMethod_intPaymentMethodId'')
					BEGIN
						ALTER TABLE tblARInvoice DROP CONSTRAINT FK_tblARInvoice_tblSMPaymentMethod_intPaymentMethodId
					END
					
					IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = ''tblSMPaymentMethod'' AND [COLUMN_NAME] = ''strPrefix'') 
					BEGIN
						ALTER TABLE tblSMPaymentMethod 
						ALTER COLUMN [strPrefix] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL
					END
									
					SELECT * INTO tmpSMPaymentMethod FROM tblSMPaymentMethod WHERE intPaymentMethodID > 8

					DELETE FROM tblSMPaymentMethod WHERE intPaymentMethodID > 8

					SET IDENTITY_INSERT tblSMPaymentMethod ON

					IF EXISTS(SELECT TOP 1 1 FROM tmpSMPaymentMethod WHERE strPaymentMethod = ''CF Invoice'')
					BEGIN
						INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort], [intOriginalId], [intConcurrencyId])
						SELECT 9, strPaymentMethod, strPaymentMethodCode, intAccountId, strPrintOption, ysnActive, intSort, intOriginalId, intConcurrencyId
						FROM tmpSMPaymentMethod
						WHERE strPaymentMethod = ''CF Invoice''
					END
					ELSE
					BEGIN
						INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
						SELECT 9, ''CF Invoice'', NULL, 0, NULL, 1, 0
					END
	
					DECLARE @add INT
					SELECT @add = COUNT(*) FROM tmpSMPaymentMethod WHERE intPaymentMethodID = 9

					INSERT INTO tblSMPaymentMethod(intPaymentMethodID, strPaymentMethod, strPaymentMethodCode, strPrefix, intNumber, intAccountId, strPrintOption, ysnActive, intSort, intOriginalId, intConcurrencyId)
					SELECT intPaymentMethodID + @add, strPaymentMethod, strPaymentMethodCode, strPrefix, intNumber, intAccountId, strPrintOption, ysnActive, intSort, intOriginalId, intConcurrencyId
					FROM tmpSMPaymentMethod
					WHERE strPaymentMethod NOT IN (SELECT strPaymentMethod FROM tblSMPaymentMethod)
										
					SET IDENTITY_INSERT tblSMPaymentMethod OFF

					UPDATE APPayment SET intPaymentMethodId = Orig.intPaymentMethodID
					FROM tblAPPayment APPayment
					INNER JOIN tmpSMPaymentMethod Temp ON APPayment.intPaymentMethodId = Temp.intPaymentMethodID
					INNER JOIN tblSMPaymentMethod Orig ON Temp.strPaymentMethod = Orig.strPaymentMethod

					UPDATE Sites SET intPaymentMethodId = Orig.intPaymentMethodID
					FROM tblCCSite Sites
					INNER JOIN tmpSMPaymentMethod Temp ON Sites.intPaymentMethodId = Temp.intPaymentMethodID
					INNER JOIN tblSMPaymentMethod Orig ON Temp.strPaymentMethod = Orig.strPaymentMethod

					UPDATE ARPayment SET intPaymentMethodId = Orig.intPaymentMethodID
					FROM tblARPayment ARPayment
					INNER JOIN tmpSMPaymentMethod Temp ON ARPayment.intPaymentMethodId = Temp.intPaymentMethodID
					INNER JOIN tblSMPaymentMethod Orig ON Temp.strPaymentMethod = Orig.strPaymentMethod

					UPDATE ARInvoice SET intPaymentMethodId = Orig.intPaymentMethodID
					FROM tblARInvoice ARInvoice
					INNER JOIN tmpSMPaymentMethod Temp ON ARInvoice.intPaymentMethodId = Temp.intPaymentMethodID
					INNER JOIN tblSMPaymentMethod Orig ON Temp.strPaymentMethod = Orig.strPaymentMethod

				END
			')		
			
			EXEC
			('
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = ''Cash'' AND intPaymentMethodID = 10)
				BEGIN

					IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''tmpSMPaymentMethod'')
					BEGIN
						DROP TABLE tmpSMPaymentMethod
					END
				
					IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS where CONSTRAINT_NAME = ''FK_dbo.tblAPPayment_tblSMPaymentMethod_intPaymentMethodId'')
					BEGIN
						ALTER TABLE tblAPPayment DROP CONSTRAINT [FK_dbo.tblAPPayment_tblSMPaymentMethod_intPaymentMethodId]
					END

					IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS where CONSTRAINT_NAME = ''FK_tblCCSite_tblSMPaymentMethod_intPaymentMethodId'')
					BEGIN
						ALTER TABLE tblCCSite DROP CONSTRAINT FK_tblCCSite_tblSMPaymentMethod_intPaymentMethodId
					END

					IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS where CONSTRAINT_NAME = ''FK_tblARInvoice_tblSMPaymentMethod_intPaymentMethodId'')
					BEGIN
						ALTER TABLE tblARInvoice DROP CONSTRAINT FK_tblARInvoice_tblSMPaymentMethod_intPaymentMethodId
					END
					
					IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = ''tblSMPaymentMethod'' AND [COLUMN_NAME] = ''strPrefix'') 
					BEGIN
						ALTER TABLE tblSMPaymentMethod 
						ALTER COLUMN [strPrefix] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL
					END
									
					SELECT * INTO tmpSMPaymentMethod FROM tblSMPaymentMethod WHERE intPaymentMethodID > 9

					DELETE FROM tblSMPaymentMethod WHERE intPaymentMethodID > 9

					SET IDENTITY_INSERT tblSMPaymentMethod ON

					IF EXISTS(SELECT TOP 1 1 FROM tmpSMPaymentMethod WHERE strPaymentMethod = ''Cash'')
					BEGIN
						INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort], [intOriginalId], [intConcurrencyId])
						SELECT 10, strPaymentMethod, strPaymentMethodCode, intAccountId, strPrintOption, ysnActive, intSort, intOriginalId, intConcurrencyId
						FROM tmpSMPaymentMethod
						WHERE strPaymentMethod = ''Cash''
					END
					ELSE
					BEGIN
						INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
						SELECT 10, ''Cash'', NULL, 0, NULL, 1, 0
					END
	
					DECLARE @add INT
					SELECT @add = COUNT(*) FROM tmpSMPaymentMethod WHERE intPaymentMethodID = 10

					INSERT INTO tblSMPaymentMethod(intPaymentMethodID, strPaymentMethod, strPaymentMethodCode, strPrefix, intNumber, intAccountId, strPrintOption, ysnActive, intSort, intOriginalId, intConcurrencyId)
					SELECT intPaymentMethodID + @add, strPaymentMethod, strPaymentMethodCode, strPrefix, intNumber, intAccountId, strPrintOption, ysnActive, intSort, intOriginalId, intConcurrencyId
					FROM tmpSMPaymentMethod
					WHERE strPaymentMethod NOT IN (SELECT strPaymentMethod FROM tblSMPaymentMethod)
										
					SET IDENTITY_INSERT tblSMPaymentMethod OFF

					UPDATE APPayment SET intPaymentMethodId = Orig.intPaymentMethodID
					FROM tblAPPayment APPayment
					INNER JOIN tmpSMPaymentMethod Temp ON APPayment.intPaymentMethodId = Temp.intPaymentMethodID
					INNER JOIN tblSMPaymentMethod Orig ON Temp.strPaymentMethod = Orig.strPaymentMethod

					UPDATE Sites SET intPaymentMethodId = Orig.intPaymentMethodID
					FROM tblCCSite Sites
					INNER JOIN tmpSMPaymentMethod Temp ON Sites.intPaymentMethodId = Temp.intPaymentMethodID
					INNER JOIN tblSMPaymentMethod Orig ON Temp.strPaymentMethod = Orig.strPaymentMethod

					UPDATE ARPayment SET intPaymentMethodId = Orig.intPaymentMethodID
					FROM tblARPayment ARPayment
					INNER JOIN tmpSMPaymentMethod Temp ON ARPayment.intPaymentMethodId = Temp.intPaymentMethodID
					INNER JOIN tblSMPaymentMethod Orig ON Temp.strPaymentMethod = Orig.strPaymentMethod

					UPDATE ARInvoice SET intPaymentMethodId = Orig.intPaymentMethodID
					FROM tblARInvoice ARInvoice
					INNER JOIN tmpSMPaymentMethod Temp ON ARInvoice.intPaymentMethodId = Temp.intPaymentMethodID
					INNER JOIN tblSMPaymentMethod Orig ON Temp.strPaymentMethod = Orig.strPaymentMethod

				END
			')

			EXEC
			('
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = ''Credit Card'' AND intPaymentMethodID = 11)
				BEGIN

					IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''tmpSMPaymentMethod'')
					BEGIN
						DROP TABLE tmpSMPaymentMethod
					END
				
					IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS where CONSTRAINT_NAME = ''FK_dbo.tblAPPayment_tblSMPaymentMethod_intPaymentMethodId'')
					BEGIN
						ALTER TABLE tblAPPayment DROP CONSTRAINT [FK_dbo.tblAPPayment_tblSMPaymentMethod_intPaymentMethodId]
					END

					IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS where CONSTRAINT_NAME = ''FK_tblCCSite_tblSMPaymentMethod_intPaymentMethodId'')
					BEGIN
						ALTER TABLE tblCCSite DROP CONSTRAINT FK_tblCCSite_tblSMPaymentMethod_intPaymentMethodId
					END

					IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS where CONSTRAINT_NAME = ''FK_tblARInvoice_tblSMPaymentMethod_intPaymentMethodId'')
					BEGIN
						ALTER TABLE tblARInvoice DROP CONSTRAINT FK_tblARInvoice_tblSMPaymentMethod_intPaymentMethodId
					END
					
					IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = ''tblSMPaymentMethod'' AND [COLUMN_NAME] = ''strPrefix'') 
					BEGIN
						ALTER TABLE tblSMPaymentMethod 
						ALTER COLUMN [strPrefix] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL
					END
									
					SELECT * INTO tmpSMPaymentMethod FROM tblSMPaymentMethod WHERE intPaymentMethodID > 10

					DELETE FROM tblSMPaymentMethod WHERE intPaymentMethodID > 10

					SET IDENTITY_INSERT tblSMPaymentMethod ON

					IF EXISTS(SELECT TOP 1 1 FROM tmpSMPaymentMethod WHERE strPaymentMethod = ''Credit Card'')
					BEGIN
						INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort], [intOriginalId], [intConcurrencyId])
						SELECT 11, strPaymentMethod, strPaymentMethodCode, intAccountId, strPrintOption, ysnActive, intSort, intOriginalId, intConcurrencyId
						FROM tmpSMPaymentMethod
						WHERE strPaymentMethod = ''Credit Card''
					END
					ELSE
					BEGIN
						INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
						SELECT 11, ''Credit Card'', NULL, 0, NULL, 1, 0
					END
	
					DECLARE @add INT
					SELECT @add = COUNT(*) FROM tmpSMPaymentMethod WHERE intPaymentMethodID = 11

					INSERT INTO tblSMPaymentMethod(intPaymentMethodID, strPaymentMethod, strPaymentMethodCode, strPrefix, intNumber, intAccountId, strPrintOption, ysnActive, intSort, intOriginalId, intConcurrencyId)
					SELECT intPaymentMethodID + @add, strPaymentMethod, strPaymentMethodCode, strPrefix, intNumber, intAccountId, strPrintOption, ysnActive, intSort, intOriginalId, intConcurrencyId
					FROM tmpSMPaymentMethod
					WHERE strPaymentMethod NOT IN (SELECT strPaymentMethod FROM tblSMPaymentMethod)
										
					SET IDENTITY_INSERT tblSMPaymentMethod OFF

					UPDATE APPayment SET intPaymentMethodId = Orig.intPaymentMethodID
					FROM tblAPPayment APPayment
					INNER JOIN tmpSMPaymentMethod Temp ON APPayment.intPaymentMethodId = Temp.intPaymentMethodID
					INNER JOIN tblSMPaymentMethod Orig ON Temp.strPaymentMethod = Orig.strPaymentMethod

					UPDATE Sites SET intPaymentMethodId = Orig.intPaymentMethodID
					FROM tblCCSite Sites
					INNER JOIN tmpSMPaymentMethod Temp ON Sites.intPaymentMethodId = Temp.intPaymentMethodID
					INNER JOIN tblSMPaymentMethod Orig ON Temp.strPaymentMethod = Orig.strPaymentMethod

					UPDATE ARPayment SET intPaymentMethodId = Orig.intPaymentMethodID
					FROM tblARPayment ARPayment
					INNER JOIN tmpSMPaymentMethod Temp ON ARPayment.intPaymentMethodId = Temp.intPaymentMethodID
					INNER JOIN tblSMPaymentMethod Orig ON Temp.strPaymentMethod = Orig.strPaymentMethod

					UPDATE ARInvoice SET intPaymentMethodId = Orig.intPaymentMethodID
					FROM tblARInvoice ARInvoice
					INNER JOIN tmpSMPaymentMethod Temp ON ARInvoice.intPaymentMethodId = Temp.intPaymentMethodID
					INNER JOIN tblSMPaymentMethod Orig ON Temp.strPaymentMethod = Orig.strPaymentMethod

				END
			')	
		END
	END
GO