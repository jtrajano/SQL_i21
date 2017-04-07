GO
PRINT 'START TF TA'
GO
DECLARE @strTaxAuthority NVARCHAR(5)


		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'AL')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('AL','Alabama', 'FALSE',	'FALSE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'AL', strDescription = 'Alabama', ysnPaperVersionAvailable = 'FALSE', ysnElectronicVersionAvailable = 'FALSE' WHERE strTaxAuthorityCode = 'AL'
		END


		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'AK')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('AK','Alaska', 'FALSE',	'FALSE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'AK', strDescription = 'Alaska', ysnPaperVersionAvailable = 'FALSE', ysnElectronicVersionAvailable = 'FALSE' WHERE  strTaxAuthorityCode = 'AK'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'AZ')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('AZ','Arizona', 'FALSE',	'FALSE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'AZ', strDescription = 'Arizona', ysnPaperVersionAvailable = 'FALSE', ysnElectronicVersionAvailable = 'FALSE' WHERE  strTaxAuthorityCode = 'AZ'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'AR')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('AR','Arkansas', 'TRUE',	'TRUE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'AR', strDescription = 'Arkansas', ysnPaperVersionAvailable = 'TRUE', ysnElectronicVersionAvailable = 'TRUE' WHERE strTaxAuthorityCode = 'AR'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'CA')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('CA','California', 'TRUE',	'FALSE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'CA', strDescription = 'California', ysnPaperVersionAvailable = 'TRUE', ysnElectronicVersionAvailable = 'FALSE' WHERE strTaxAuthorityCode = 'CA'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'CO')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('CO','Colorado', 'TRUE',	'TRUE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'CO', strDescription = 'Colorado', ysnPaperVersionAvailable = 'TRUE', ysnElectronicVersionAvailable = 'TRUE' WHERE strTaxAuthorityCode = 'CO'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'CT')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('CT','Connecticut', 'FALSE',	'FALSE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'CT', strDescription = 'Connecticut', ysnPaperVersionAvailable = 'FALSE', ysnElectronicVersionAvailable = 'FALSE' WHERE strTaxAuthorityCode = 'CT'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'DE')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('DE','Delaware', 'FALSE', 'FALSE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'DE', strDescription = 'Delaware', ysnPaperVersionAvailable = 'FALSE', ysnElectronicVersionAvailable = 'FALSE' WHERE strTaxAuthorityCode = 'DE'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'FL')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('FL','Florida', 'TRUE', 'TRUE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'FL', strDescription = 'Florida', ysnPaperVersionAvailable = 'TRUE', ysnElectronicVersionAvailable = 'TRUE' WHERE strTaxAuthorityCode = 'FL'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'GA')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('GA','Georgia', 'FALSE', 'FALSE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'GA', strDescription = 'Georgia', ysnPaperVersionAvailable = 'FALSE', ysnElectronicVersionAvailable = 'FALSE' WHERE strTaxAuthorityCode = 'GA'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'HI')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('HI','Hawaii', 'FALSE', 'FALSE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'HI', strDescription = 'Hawaii', ysnPaperVersionAvailable = 'FALSE', ysnElectronicVersionAvailable = 'FALSE' WHERE strTaxAuthorityCode = 'HI'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'ID')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('ID','Idaho', 'TRUE', 'TRUE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'ID', strDescription = 'Idaho', ysnPaperVersionAvailable = 'TRUE', ysnElectronicVersionAvailable = 'TRUE' WHERE strTaxAuthorityCode = 'ID'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'IL')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('IL','Illinois', 'TRUE', 'TRUE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'IL', strDescription = 'Illinois', ysnPaperVersionAvailable = 'TRUE', ysnElectronicVersionAvailable = 'TRUE' WHERE strTaxAuthorityCode = 'IL'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'IN')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('IN','Indiana', 'TRUE', 'TRUE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'IN', strDescription = 'Indiana', ysnPaperVersionAvailable = 'TRUE', ysnElectronicVersionAvailable = 'TRUE' WHERE strTaxAuthorityCode = 'IN'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'IA')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('IA','Iowa', 'TRUE', 'TRUE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'IA', strDescription = 'Iowa', ysnPaperVersionAvailable = 'TRUE', ysnElectronicVersionAvailable = 'TRUE' WHERE strTaxAuthorityCode = 'IA'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'KS')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('KS','Kansas', 'TRUE', 'TRUE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'KS', strDescription = 'Kansas', ysnPaperVersionAvailable = 'TRUE', ysnElectronicVersionAvailable = 'TRUE' WHERE strTaxAuthorityCode = 'KS'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'KY')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('KY','Kentucky', 'TRUE', 'TRUE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'KY', strDescription = 'Kentucky', ysnPaperVersionAvailable = 'TRUE', ysnElectronicVersionAvailable = 'TRUE' WHERE strTaxAuthorityCode = 'KY'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'LA')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('LA','Louisiana', 'FALSE', 'FALSE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'LA', strDescription = 'Louisiana', ysnPaperVersionAvailable = 'FALSE', ysnElectronicVersionAvailable = 'FALSE' WHERE strTaxAuthorityCode = 'LA'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'ME')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('ME','Maine', 'TRUE', 'FALSE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'ME', strDescription = 'Maine', ysnPaperVersionAvailable = 'TRUE', ysnElectronicVersionAvailable = 'FALSE' WHERE strTaxAuthorityCode = 'ME'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'MD')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('MD','Maryland', 'FALSE', 'FALSE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'MD', strDescription = 'Maryland', ysnPaperVersionAvailable = 'TRUE', ysnElectronicVersionAvailable = 'FALSE' WHERE strTaxAuthorityCode = 'MD'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'MA')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('MA','Massachusetts', 'FALSE', 'FALSE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'MA', strDescription = 'Massachusetts', ysnPaperVersionAvailable = 'TRUE', ysnElectronicVersionAvailable = 'FALSE' WHERE strTaxAuthorityCode = 'MA'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'MI')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('MI','Michigan', 'TRUE', 'TRUE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'MI', strDescription = 'Michigan', ysnPaperVersionAvailable = 'TRUE', ysnElectronicVersionAvailable = 'TRUE' WHERE strTaxAuthorityCode = 'MI'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'MN')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('MN','Minnesota', 'TRUE', 'TRUE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'MN', strDescription = 'Minnesota', ysnPaperVersionAvailable = 'TRUE', ysnElectronicVersionAvailable = 'TRUE' WHERE strTaxAuthorityCode = 'MN'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'MS')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('MS','Mississippi', 'TRUE', 'TRUE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'MS', strDescription = 'Mississippi', ysnPaperVersionAvailable = 'TRUE', ysnElectronicVersionAvailable = 'TRUE' WHERE strTaxAuthorityCode = 'MS'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'MO')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('MO','Missouri', 'TRUE', 'TRUE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'MO', strDescription = 'Missouri', ysnPaperVersionAvailable = 'TRUE', ysnElectronicVersionAvailable = 'TRUE' WHERE strTaxAuthorityCode = 'MO'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'MT')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('MT','Montana', 'TRUE', 'TRUE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'MT', strDescription = 'Montana', ysnPaperVersionAvailable = 'TRUE', ysnElectronicVersionAvailable = 'TRUE' WHERE strTaxAuthorityCode = 'MT'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'NE')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('NE','Nebraska', 'TRUE', 'TRUE', 'TRUE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'NE', strDescription = 'Nebraska', ysnPaperVersionAvailable = 'TRUE', ysnElectronicVersionAvailable = 'TRUE', ysnFilingForThisTA = 'TRUE' WHERE strTaxAuthorityCode = 'NE'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'NV')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('NV','Nevada', 'FALSE', 'FALSE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'NV', strDescription = 'Nevada', ysnPaperVersionAvailable = 'FALSE', ysnElectronicVersionAvailable = 'FALSE' WHERE strTaxAuthorityCode = 'NV'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'NH')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('NH','New Hampshire', 'FALSE', 'FALSE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'NH', strDescription = 'New Hampshire', ysnPaperVersionAvailable = 'FALSE', ysnElectronicVersionAvailable = 'FALSE' WHERE strTaxAuthorityCode = 'NH'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'NJ')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('NJ','New Jersey', 'TRUE', 'FALSE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'NJ', strDescription = 'New Jersey', ysnPaperVersionAvailable = 'TRUE', ysnElectronicVersionAvailable = 'FALSE' WHERE strTaxAuthorityCode = 'NJ'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'NM')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('NM','New Mexico', 'TRUE', 'TRUE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'NM', strDescription = 'New Mexico', ysnPaperVersionAvailable = 'FALSE', ysnElectronicVersionAvailable = 'FALSE' WHERE strTaxAuthorityCode = 'NM'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'NY')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('NY','New York', 'TRUE', 'FALSE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'NY', strDescription = 'New York', ysnPaperVersionAvailable = 'TRUE', ysnElectronicVersionAvailable = 'FALSE' WHERE strTaxAuthorityCode = 'NY'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'NC')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('NC','North Carolina', 'TRUE', 'TRUE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'NC', strDescription = 'North Carolina', ysnPaperVersionAvailable = 'TRUE', ysnElectronicVersionAvailable = 'TRUE' WHERE strTaxAuthorityCode = 'NC'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'ND')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('ND','North Dakota', 'FALSE', 'FALSE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'ND', strDescription = 'North Dakota', ysnPaperVersionAvailable = 'FALSE', ysnElectronicVersionAvailable = 'TRUE' WHERE strTaxAuthorityCode = 'ND'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'OH')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('OH','Ohio', 'TRUE', 'TRUE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'OH', strDescription = 'Ohio', ysnPaperVersionAvailable = 'TRUE', ysnElectronicVersionAvailable = 'TRUE' WHERE strTaxAuthorityCode = 'OH'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'OK')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('OK','Oklahoma', 'TRUE', 'FALSE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'OK', strDescription = 'Oklahoma', ysnPaperVersionAvailable = 'TRUE', ysnElectronicVersionAvailable = 'FALSE' WHERE strTaxAuthorityCode = 'OK'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'OR')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('OR','Oregon', 'TRUE', 'FALSE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'OR', strDescription = 'Oregon', ysnPaperVersionAvailable = 'TRUE', ysnElectronicVersionAvailable = 'FALSE' WHERE strTaxAuthorityCode = 'OR'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'PA')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('PA','Pennsylvania', 'TRUE', 'TRUE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'PA', strDescription = 'Pennsylvania', ysnPaperVersionAvailable = 'TRUE', ysnElectronicVersionAvailable = 'TRUE' WHERE strTaxAuthorityCode = 'PA'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'RI')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('RI','Rhode Island', 'FALSE', 'FALSE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'RI', strDescription = 'Rhode Island', ysnPaperVersionAvailable = 'FALSE', ysnElectronicVersionAvailable = 'FALSE' WHERE strTaxAuthorityCode = 'RI'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'SC')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('SC','South Carolina', 'TRUE', 'TRUE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'SC', strDescription = 'South Carolina', ysnPaperVersionAvailable = 'TRUE', ysnElectronicVersionAvailable = 'TRUE' WHERE strTaxAuthorityCode = 'SC'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'SD')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('SD','South Dakota', 'FALSE', 'FALSE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'SD', strDescription = 'South Dakota', ysnPaperVersionAvailable = 'FALSE', ysnElectronicVersionAvailable = 'FALSE' WHERE strTaxAuthorityCode = 'SD'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'TN')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('TN','Tennessee', 'TRUE', 'TRUE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'TN', strDescription = 'Tennessee', ysnPaperVersionAvailable = 'TRUE', ysnElectronicVersionAvailable = 'TRUE' WHERE strTaxAuthorityCode = 'TN'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'TX')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('TX','Texas', 'TRUE', 'TRUE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'TX', strDescription = 'Texas', ysnPaperVersionAvailable = 'TRUE', ysnElectronicVersionAvailable = 'TRUE' WHERE strTaxAuthorityCode = 'TX'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'UT')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('UT','Utah', 'TRUE', 'TRUE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'UT', strDescription = 'Utah', ysnPaperVersionAvailable = 'TRUE', ysnElectronicVersionAvailable = 'TRUE' WHERE strTaxAuthorityCode = 'UT'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'VT')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('VT','Vermont', 'FALSE', 'FALSE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'VT', strDescription = 'Vermont', ysnPaperVersionAvailable = 'FALSE', ysnElectronicVersionAvailable = 'FALSE' WHERE strTaxAuthorityCode = 'VT'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'VA')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('VA','Virginia', 'TRUE', 'TRUE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'VA', strDescription = 'Virginia', ysnPaperVersionAvailable = 'TRUE', ysnElectronicVersionAvailable = 'TRUE' WHERE strTaxAuthorityCode = 'VA'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'WA')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('WA','Washington', 'TRUE', 'FALSE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'WA', strDescription = 'Washington', ysnPaperVersionAvailable = 'TRUE', ysnElectronicVersionAvailable = 'FALSE' WHERE strTaxAuthorityCode = 'WA'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'WV')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('WV','West Virginia', 'TRUE', 'FALSE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'WV', strDescription = 'West Virginia', ysnPaperVersionAvailable = 'TRUE', ysnElectronicVersionAvailable = 'FALSE' WHERE strTaxAuthorityCode = 'WV'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'WI')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('WI','Wisconsin', 'FALSE', 'FALSE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'WI', strDescription = 'Wisconsin', ysnPaperVersionAvailable = 'FALSE', ysnElectronicVersionAvailable = 'FALSE' WHERE strTaxAuthorityCode = 'WI'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'WY')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('WY','Wyoming', 'TRUE', 'FALSE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'WY', strDescription = 'Wyoming', ysnPaperVersionAvailable = 'TRUE', ysnElectronicVersionAvailable = 'FALSE' WHERE strTaxAuthorityCode = 'WY'
		END

		SET @strTaxAuthority = (SELECT TOP 1 strTaxAuthorityCode FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'WY')
		IF @strTaxAuthority IS NULL
			BEGIN
				INSERT INTO [tblTFTaxAuthority]([strTaxAuthorityCode],[strDescription],[ysnPaperVersionAvailable],[ysnElectronicVersionAvailable],[ysnFilingForThisTA])
				VALUES('US','Federal Government', 'TRUE', 'FALSE', 'FALSE')
			END
		ELSE
		BEGIN
			UPDATE tblTFTaxAuthority SET strTaxAuthorityCode = 'US', strDescription = 'Federal Government', ysnPaperVersionAvailable = 'TRUE', ysnElectronicVersionAvailable = 'FALSE' WHERE strTaxAuthorityCode = 'US'
		END
GO
PRINT 'END TF TA'
GO