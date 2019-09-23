GO
IF EXISTS(SELECT TOP 1 1 FROM sys.procedures WHERE name = 'uspAPImportVendorContact')
	DROP PROCEDURE uspAPImportVendorContact
GO

CREATE PROCEDURE [dbo].[uspAPImportVendorContact]
	@Checking BIT = 0,
	@Total INT = 0 OUTPUT
AS

BEGIN

IF(@Checking = 0)
BEGIN
-- Temp Table with Autonumber to hold the Contacts to be imported
DECLARE @Contacts TABLE
(
	 id INT IDENTITY(1,1)
	, sscon_contact_id NVARCHAR(max)
	, sscon_vnd_no NVARCHAR(max)
	, sscon_contact_title NVARCHAR(max)
	, sscon_email NVARCHAR(max)
	, sscon_first_name NVARCHAR(max)
	, sscon_last_name NVARCHAR(max)
	, sscon_suffix NVARCHAR(max)
	, sscon_work_no NVARCHAR(max)
	, sscon_work_ext NVARCHAR(max)
	, sscon_cell_no NVARCHAR(max)
	, sscon_cell_ext NVARCHAR(max)
	, sscon_fax_no NVARCHAR(max)
	, sscon_fax_ext NVARCHAR(max)
)

-- SELECT ED.coefd_contact_id, ED.coefd_cus_no,
--        STUFF(ISNULL((SELECT ',' + CASE WHEN x.coefd_eform_type = 'INV' THEN 'Invoices,Credit Memo,Debit Memo,Cash Refund,Cash,Sales Order'
-- 								   WHEN x.coefd_eform_type = 'STM' OR x.coefd_eform_type = 'GST' THEN 'Statements'
-- 								   WHEN x.coefd_eform_type = 'GTX' THEN 'Scale'
-- 								   WHEN x.coefd_eform_type = 'GCO' OR x.coefd_eform_type = 'ACO' THEN 'Contracts'
-- 								   WHEN x.coefd_eform_type = 'RPQ' THEN 'Transport Quote'
-- 								   WHEN x.coefd_eform_type = 'CFI' THEN 'CF Invoice'
-- 								   WHEN x.coefd_eform_type = 'EFT' THEN 'AP Remittance'
-- 								   WHEN x.coefd_eform_type = 'CCR' THEN 'Dealer CC Notification'
-- 								   WHEN x.coefd_eform_type = 'GSE' THEN 'Settlement'
-- 								   WHEN x.coefd_eform_type = 'POR' THEN 'Purchase Order'
-- 								   END
--                 FROM coefdmst x
--                WHERE x.coefd_contact_id = ED.coefd_contact_id AND x.coefd_cus_no = ED.coefd_cus_no
--             GROUP BY x.coefd_eform_type
--              FOR XML PATH (''), TYPE).value('.','VARCHAR(max)'), ''), 1, 1, '') as Form_type
--   INTO #tmpcoefd
--   FROM coefdmst ED WHERE ED.coefd_by_email = 'Y'  --AND ED.coefd_cus_no = 'AIRTEX'
--   GROUP BY ED.coefd_contact_id, ED.coefd_cus_no, ED.coefd_eform_type

	DECLARE @sscon_vnd_no NVARCHAR(200)
	BEGIN -- Get Customers to be imported to #tmpContacts
		INSERT INTO @Contacts
		(
			sscon_contact_id
			, sscon_vnd_no 
			, sscon_contact_title
			, sscon_email 
			, sscon_first_name 
			, sscon_last_name 
			, sscon_suffix
			, sscon_work_no
			, sscon_work_ext 
			, sscon_cell_no 
			, sscon_cell_ext 
			, sscon_fax_no
			, sscon_fax_ext
		)
		SELECT
			isnull(sscon_contact_id, '')
			, isnull(sscon_vnd_no, '')
			, isnull(sscon_contact_title, '')
			, RTRIM(LTRIM(isnull(sscon_email, '')))
			, isnull(sscon_first_name, '')
			, isnull(sscon_last_name, '')
			, isnull(sscon_suffix, '')
			, isnull(sscon_work_no, '')
			, isnull(sscon_work_ext, '')
			, isnull(sscon_cell_no, '')
			, isnull(sscon_cell_ext, '')
			, isnull(sscon_fax_no, '')
			, isnull(sscon_fax_ext, '')
		FROM ssconmst sscon
		WHERE 
			sscon_vnd_no LIKE '%[a-z0-9]%'
			AND sscon_vnd_no IN (SELECT strVendorId  collate SQL_Latin1_General_CP1_CS_AS FROM tblAPVendor )
	END
		-- LOOP Insertions
		WHILE EXISTS (SELECT TOP 1 1 FROM @Contacts)
		BEGIN
			DECLARE @id INT
			DECLARE @sscon_contact_id NVARCHAR(20)

			SELECT TOP 1 @id = id,
							@sscon_vnd_no = sscon_vnd_no,
							@sscon_contact_id = sscon_contact_id
			FROM @Contacts
			DECLARE @intEntityId INT
			DECLARE @Name		NVARCHAR(200)

			BEGIN -- Create entity record for Contacts

				SELECT @intEntityId = intEntityId FROM tblAPVendor WHERE strVendorId = @sscon_vnd_no
			
			END

			IF EXISTS(SELECT TOP 1  1 FROM tblEMEntity A
						JOIN tblEMEntityToContact B ON A.intEntityId = B.intEntityId
						JOIN tblEMEntity C ON B.intEntityContactId = C.intEntityId
							WHERE A.intEntityId = @intEntityId AND
								C.strContactNumber = @sscon_contact_id
					)
			BEGIN
				GOTO ContinueLoop;
			END
			BEGIN -- Create Contact record
				DECLARE @EntityContact as EntityContact
				DECLARE @ContactNumber	NVARCHAR(200)
				DECLARE @Title			NVARCHAR(200)
				DECLARE @CP				NVARCHAR(200)
				DECLARE @WorkPhone		NVARCHAR(200)
				DECLARE @Fax			NVARCHAR(200)
				DECLARE @Email          NVARCHAR(200)
				SELECT TOP 1
					@Name			= rtrim(ltrim(sscon_last_name)) + ', ' + rtrim(ltrim(sscon_first_name)) + ' ' + rtrim(ltrim(sscon_suffix)),
					@ContactNumber	= rtrim(ltrim(sscon_contact_id)),
					@Title			= substring((rtrim(ltrim(sscon_contact_title))), 1,35),
					@CP				= isnull(nullif(ltrim((rtrim(rtrim(ltrim(sscon_cell_no)) + ' x' + rtrim(ltrim(sscon_cell_ext))))), 'x'), ''),
					@WorkPhone		= isnull(nullif(ltrim((rtrim(rtrim(ltrim(sscon_work_no)) + ' x' + rtrim(ltrim(sscon_work_ext))))), 'x'), ''),
					@Fax			= isnull(nullif(ltrim((rtrim(rtrim(ltrim(sscon_fax_no)) + ' x' + rtrim(ltrim(sscon_fax_ext))))), 'x'), ''),
					@Email			= rtrim(ltrim(sscon_email))

				FROM @Contacts WHERE id = @id
				
				INSERT INTO tblEMEntity(strName, strContactNumber, strTitle, strEmail)
				SELECT @Name, @ContactNumber, @Title, @Email


				DECLARE @intContactId INT

				SET @intContactId = @@IDENTITY
				print @intContactId
				IF @CP <> ''
				BEGIN
					IF EXISTS(SELECT TOP 1 1 FROM tblEMContactDetailType WHERE strType = 'Phone' AND strField = 'Home')
					BEGIN
						INSERT INTO tblEMContactDetail (intEntityId, strValue, intContactDetailTypeId)
						SELECT TOP 1 @intContactId, @CP, intContactDetailTypeId FROM tblEMContactDetailType WHERE strType = 'Phone' AND strField = 'Home'
					END

					INSERT INTO tblEMEntityPhoneNumber(intEntityId, strPhone)
					SELECT @intContactId, @CP
				END

				IF @WorkPhone <> ''
				BEGIN
					IF EXISTS(SELECT TOP 1 1 FROM tblEMContactDetailType WHERE strType = 'Phone' AND strField = 'Work')
					BEGIN
						INSERT INTO tblEMContactDetail (intEntityId, strValue, intContactDetailTypeId)
						SELECT TOP 1 @intContactId, @WorkPhone, intContactDetailTypeId FROM tblEMContactDetailType WHERE strType = 'Phone' AND strField = 'Work'
					END
				END

				IF @Fax <> ''
				BEGIN
					IF EXISTS(SELECT TOP 1 1 FROM tblEMContactDetailType WHERE strType = 'Phone' AND strField = 'Fax')
					BEGIN
						INSERT INTO tblEMContactDetail (intEntityId, strValue, intContactDetailTypeId)
						SELECT TOP 1 @intContactId, @Fax, intContactDetailTypeId FROM tblEMContactDetailType WHERE strType = 'Phone' AND strField = 'Fax'
					END
				END

				IF @Email <> ''
				BEGIN
					IF EXISTS(SELECT TOP 1 1 FROM tblEMContactDetailType WHERE strType = 'Email' AND strField = 'Alt Email')
					BEGIN
						INSERT INTO tblEMContactDetail (intEntityId, strValue, intContactDetailTypeId)
						SELECT TOP 1 @intContactId, @Email, intContactDetailTypeId FROM tblEMContactDetailType WHERE strType = 'Email' AND strField = 'Alt Email'
					END
				END

					--exec [uspEntityCreateEntityContact] @EntityContact, @intContactId OUT
			END
			BEGIN --LOCATION

				DECLARE @EntityLocationName NVARCHAR(50)
				SET @EntityLocationName = @Name +'_'+@ContactNumber+ 'Loc'
				DECLARE @LoopCounter INT
				SET @LoopCounter = 1
				WHILE EXISTS(SELECT TOP 1 1 FROM tblEMEntityLocation WHERE strLocationName = @EntityLocationName)
				BEGIN
					SET @EntityLocationName = CAST(@LoopCounter AS NVARCHAR) + @EntityLocationName
					SET @LoopCounter = @LoopCounter + 1
				END
				INSERT INTO tblEMEntityLocation(intEntityId, strLocationName, ysnDefaultLocation)
				SELECT @intEntityId, @EntityLocationName, 0
			END
			BEGIN -- Create Customer to Contact

				DECLARE @CustomerNo NVARCHAR(max), @intEntityCustomerId INT

				SELECT TOP 1 @CustomerNo = sscon_vnd_no FROM @Contacts WHERE id = @id
				SELECT TOP 1 @intEntityCustomerId = intEntityId FROM tblAPVendor WHERE strVendorId = @CustomerNo

				INSERT INTO tblEMEntityToContact(intEntityId, intEntityContactId, ysnDefaultContact, ysnPortalAccess)
				SELECT @intEntityId, @intContactId, 0, 0


			END


			ContinueLoop:
			--UPDATE E-DISTRIBUTION FORM TYPEs

			UPDATE ENT SET ENT.strEmailDistributionOption =
			CASE WHEN (isnull(ENT.strName,'') LIKE '% REMITTANCE%'
			OR isnull(ENT.strName,'') LIKE '%EFT%'   )
			OR isnull(ENT.strEmail,'') <> ''
			THEN

			CASE
				WHEN CHARINDEX('AP Remittance', isnull(ENT.strEmailDistributionOption,'')) = 0

			THEN
				CASE WHEN   len(ltrim(rtrim(isnull(ENT.strEmailDistributionOption,'')))) = 0
					 then 'AP Remittance'
				ELSE
					',AP Remittance'
				END
			 ELSE
				ENT.strEmailDistributionOption

			 END


			 ELSE ENT.strEmailDistributionOption END
			--ED.Form_type
			FROM tblEMEntityToContact ETC
			JOIN tblEMEntity ENT ON ENT.intEntityId = ETC.intEntityContactId
			JOIN tblEMEntity ENT1 ON ENT1.intEntityId = ETC.intEntityId

			JOIN ssconmst CON ON CON.sscon_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS =ENT1.strEntityNo
			JOIN coefdmst efd ON efd.coefd_vnd_no = CON.sscon_vnd_no
			WHERE efd.coefd_eform_type ='EFT'

			DELETE FROM @Contacts WHERE id = @id

		END
END

IF(@Checking = 1)
BEGIN
	SELECT
	--@Total =
	 count(sscon_contact_id)
	FROM ssconmst
	LEFT JOIN tblEMEntity Ent
		ON ssconmst.sscon_contact_id COLLATE Latin1_General_CI_AS = Ent.strContactNumber COLLATE Latin1_General_CI_AS
	WHERE Ent.strContactNumber IS NULL AND ssconmst.sscon_contact_id  = UPPER(ssconmst.sscon_contact_id ) COLLATE Latin1_General_CS_AS
		AND sscon_vnd_no LIKE '%[a-z0-9]%'
		AND sscon_vnd_no IN (SELECT strVendorId collate SQL_Latin1_General_CP1_CS_AS FROM tblAPVendor)

END
END

	

	


