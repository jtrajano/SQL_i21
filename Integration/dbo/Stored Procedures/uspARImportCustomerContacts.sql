GO
IF EXISTS(select top 1 1 FROM sys.procedures WHERE name = 'uspARImportCustomerContacts')
	DROP PROCEDURE uspARImportCustomerContacts
GO

CREATE PROCEDURE [dbo].[uspARImportCustomerContacts]
	@Checking BIT = 0,
	@Total INT = 0 OUTPUT
AS 

BEGIN

	IF(@Checking = 0)
		BEGIN
			-- Temp Table with Autonumber to hold the Contacts to be imported
			DECLARE @sscon_cus_no NVARCHAR(200)

			DECLARE @Contacts TABLE (
				  id					INT IDENTITY(1,1)
				, sscon_contact_id		NVARCHAR(MAX)
				, sscon_cus_no			NVARCHAR(MAX)
				, sscon_contact_title	NVARCHAR(MAX)
				, sscon_email			NVARCHAR(MAX)
				, sscon_first_name		NVARCHAR(MAX)
				, sscon_last_name		NVARCHAR(MAX)
				, sscon_suffix			NVARCHAR(MAX)
				, sscon_work_no			NVARCHAR(MAX)
				, sscon_work_ext		NVARCHAR(MAX)
				, sscon_cell_no			NVARCHAR(MAX)
				, sscon_cell_ext		NVARCHAR(MAX)
				, sscon_fax_no			NVARCHAR(MAX)
				, sscon_fax_ext			NVARCHAR(MAX)
			)

			SELECT ED.coefd_contact_id
				 , ED.coefd_cus_no
				 , STUFF(ISNULL((SELECT ',' + CASE WHEN x.coefd_eform_type = 'INV' THEN 'Invoices,Credit Memo,Debit Memo,Cash Refund,Cash,Sales Order'
											   WHEN x.coefd_eform_type = 'STM' OR x.coefd_eform_type = 'GST' THEN 'Statements'									
											   WHEN x.coefd_eform_type = 'GTX' THEN 'Scale'
											   WHEN x.coefd_eform_type = 'GCO' OR x.coefd_eform_type = 'ACO' THEN 'Contracts'
											   WHEN x.coefd_eform_type = 'RPQ' THEN 'Transport Quote'
											   WHEN x.coefd_eform_type = 'CFI' THEN 'CF Invoice'
											   WHEN x.coefd_eform_type = 'EFT' THEN 'AR Remittance'
											   WHEN x.coefd_eform_type = 'CCR' THEN 'Dealer CC Notification'
											   WHEN x.coefd_eform_type = 'GSE' THEN 'Settlement'
											   WHEN x.coefd_eform_type = 'POR' THEN 'Purchase Order'
											   END
			FROM coefdmst x
			WHERE x.coefd_contact_id = ED.coefd_contact_id AND x.coefd_cus_no = ED.coefd_cus_no
			GROUP BY x.coefd_eform_type
			FOR XML PATH (''), TYPE).value('.','VARCHAR(max)'), ''), 1, 1, '') as Form_type
			INTO #tmpcoefd
			FROM coefdmst ED 
			WHERE ED.coefd_by_email = 'Y'  --and ED.coefd_cus_no = 'AIRTEX'
			GROUP BY ED.coefd_contact_id, ED.coefd_cus_no, ED.coefd_eform_type
						
			BEGIN -- Get Customers to be imported to #tmpContacts
				INSERT INTO @Contacts (
					  sscon_contact_id
					, sscon_cus_no 
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
				SELECT sscon_contact_id		= ISNULL(sscon_contact_id, '')
					, sscon_cus_no			= ISNULL(sscon_cus_no, '')
					, sscon_contact_title	= ISNULL(sscon_contact_title, '')
					, sscon_email			= RTRIM(LTRIM(ISNULL(sscon_email, '')))
					, sscon_first_name		= ISNULL(sscon_first_name, '')
					, sscon_last_name		= ISNULL(sscon_last_name, '')
					, sscon_suffix			= ISNULL(sscon_suffix, '')
					, sscon_work_no			= ISNULL(sscon_work_no, '')
					, sscon_work_ext		= ISNULL(sscon_work_ext, '')
					, sscon_cell_no			= ISNULL(sscon_cell_no, '')
					, sscon_cell_ext		= ISNULL(sscon_cell_ext, '')
					, sscon_fax_no			= ISNULL(sscon_fax_no, '')
					, sscon_fax_ext			= ISNULL(sscon_fax_ext, '')
				FROM ssconmst sscon
				WHERE sscon_cus_no LIKE '%[a-z0-9]%'
			END
				-- LOOP Insertions
				WHILE EXISTS (SELECT TOP 1 1 FROM @Contacts)
				BEGIN
					DECLARE @id 				INT
					DECLARE @intEntityId 		INT
					DECLARE @sscon_contact_id 	NVARCHAR(20)					
					DECLARE @Name				NVARCHAR(200)

					SELECT TOP 1 @id = id
						       , @sscon_cus_no = sscon_cus_no
							   , @sscon_contact_id = sscon_contact_id
					FROM @Contacts
					
					BEGIN -- Create entity record for Contacts
						SELECT TOP 1 @intEntityId = intEntityId 
						FROM tblARCustomer 
						WHERE strCustomerNumber = @sscon_cus_no
					END

					IF EXISTS(SELECT TOP 1 1 
							  FROM tblEMEntity A 
							  INNER JOIN tblEMEntityToContact B ON A.intEntityId = B.intEntityId 
							  INNER JOIN tblEMEntity C ON B.intEntityContactId = C.intEntityId
							  WHERE A.intEntityId = @intEntityId 
							    AND C.strContactNumber = @sscon_contact_id 
					)
					BEGIN
						goto ContinueLoop;
					END
					BEGIN -- Create Contact record
						DECLARE @EntityContact	AS EntityContact
						DECLARE @ContactNumber	NVARCHAR(200)
						DECLARE @Title			NVARCHAR(200)
						DECLARE @CP				NVARCHAR(200)
						DECLARE @WorkPhone		NVARCHAR(200)
						DECLARE @Fax			NVARCHAR(200)
						DECLARE @Email          NVARCHAR(200)
						DECLARE @intContactId	INT
				
						SELECT TOP 1
							@Name			= rtrim(ltrim(sscon_last_name)) + ', ' + rtrim(ltrim(sscon_first_name)) + ' ' + rtrim(ltrim(sscon_suffix)),
							@ContactNumber	= rtrim(ltrim(sscon_contact_id)),
							@Title			= substring((rtrim(ltrim(sscon_contact_title))), 1,35),
							@CP				= isnull(nullif(ltrim((rtrim(rtrim(ltrim(sscon_cell_no)) + ' x' + rtrim(ltrim(sscon_cell_ext))))), 'x'), ''),
							@WorkPhone		= isnull(nullif(ltrim((rtrim(rtrim(ltrim(sscon_work_no)) + ' x' + rtrim(ltrim(sscon_work_ext))))), 'x'), ''),
							@Fax			= isnull(nullif(ltrim((rtrim(rtrim(ltrim(sscon_fax_no)) + ' x' + rtrim(ltrim(sscon_fax_ext))))), 'x'), ''),
							@Email			= rtrim(ltrim(sscon_email))
						FROM @Contacts 
						WHERE id = @id
				
						INSERT INTO tblEMEntity(strName, strContactNumber, strTitle, strEmail)
						SELECT @Name, @ContactNumber, @Title, @Email
				
						SET @intContactId = @@IDENTITY
						
						IF @CP <> ''
						BEGIN
							IF EXISTS(SELECT TOP 1 1 FROM tblEMContactDetailType WHERE strType = 'Phone' and strField = 'Home')
							BEGIN
								INSERT INTO tblEMContactDetail (intEntityId, strValue, intContactDetailTypeId)
								SELECT TOP 1 @intContactId, @CP, intContactDetailTypeId FROM tblEMContactDetailType WHERE strType = 'Phone' and strField = 'Home' 
							END

							INSERT INTO tblEMEntityPhoneNumber(intEntityId, strPhone)
							SELECT @intContactId, @CP
						END

						IF @WorkPhone <> ''
						BEGIN
							IF EXISTS(SELECT TOP 1 1 FROM tblEMContactDetailType WHERE strType = 'Phone' and strField = 'Work')
							BEGIN
								INSERT INTO tblEMContactDetail (intEntityId, strValue, intContactDetailTypeId)
								SELECT TOP 1 @intContactId, @WorkPhone, intContactDetailTypeId FROM tblEMContactDetailType WHERE strType = 'Phone' and strField = 'Work' 
							END
						END

						IF @Fax <> ''
						BEGIN
							IF EXISTS(SELECT TOP 1 1 FROM tblEMContactDetailType WHERE strType = 'Phone' and strField = 'Fax')
							BEGIN
								INSERT INTO tblEMContactDetail (intEntityId, strValue, intContactDetailTypeId)
								SELECT TOP 1 @intContactId, @Fax, intContactDetailTypeId FROM tblEMContactDetailType WHERE strType = 'Phone' and strField = 'Fax' 
							END
						END

						IF @Email <> ''
						BEGIN
							IF EXISTS(SELECT TOP 1 1 FROM tblEMContactDetailType WHERE strType = 'Email' and strField = 'Alt Email')
							BEGIN
								INSERT INTO tblEMContactDetail (intEntityId, strValue, intContactDetailTypeId)
								SELECT TOP 1 @intContactId, @Email, intContactDetailTypeId FROM tblEMContactDetailType WHERE strType = 'Email' and strField = 'Alt Email' 
							END
						END
					
					END
					BEGIN --LOCATION
						DECLARE @EntityLocationName NVARCHAR(50)
						DECLARE @LoopCounter INT
						
						SET @EntityLocationName = @Name +'_'+@ContactNumber+ 'Loc'						
						SET @LoopCounter = 1

						WHILE EXISTS(SELECT TOP 1 1 FROM tblEMEntityLocation WHERE strLocationName = @EntityLocationName)
						BEGIN
							SET @EntityLocationName = CAST(@LoopCounter AS NVARCHAR) + @EntityLocationName					
							SET @LoopCounter = @LoopCounter + 1
						END

						IF @intEntityId IS NOT NULL 
							BEGIN 
								INSERT INTO tblEMEntityLocation(intEntityId, strLocationName, ysnDefaultLocation)
								SELECT @intEntityId, @EntityLocationName, 0
							END
					END
					BEGIN -- Create Customer to Contact
						DECLARE @CustomerNo 			NVARCHAR(MAX)
							  , @intEntityCustomerId 	INT

						SELECT TOP 1 @CustomerNo = sscon_cus_no FROM @Contacts WHERE id = @id
						SELECT TOP 1 @intEntityCustomerId = intEntityId FROM tblARCustomer WHERE strCustomerNumber = @CustomerNo 

						IF @intEntityId IS NOT NULL 
							BEGIN
								INSERT INTO tblEMEntityToContact(intEntityId, intEntityContactId, ysnDefaultContact, ysnPortalAccess)
								SELECT @intEntityId, @intContactId, 0, 0
							END
					END			

					ContinueLoop:					
			
					DELETE @Contacts WHERE id = @id
				END

			--UPDATE E-DISTRIBUTION FORM TYPEs
			UPDATE ENT 
			SET ENT.strEmailDistributionOption = EMAILD.Form_type 
			FROM tblEMEntityToContact ETC 
			INNER JOIN tblEMEntity ENT ON ENT.intEntityId = ETC.intEntityContactId
			INNER JOIN ssconmst CON ON CON.sscon_contact_id COLLATE SQL_Latin1_General_CP1_CS_AS = ENT.strContactNumber COLLATE SQL_Latin1_General_CP1_CS_AS AND CON.sscon_cus_no = @sscon_cus_no
			INNER JOIN (
				SELECT DISTINCT *
				FROM #tmpcoefd 
			) EMAILD ON EMAILD.coefd_contact_id = CON.sscon_contact_id AND EMAILD.coefd_cus_no = CON.sscon_cus_no

			--UPDATE DEFAULT CUSTOMER CONTACT
			IF OBJECT_ID('tempdb..##CONTACTNODEFAULT') IS NOT NULL DROP TABLE #CONTACTNODEFAULT	

			SELECT C.intEntityId, CETC.intEntityContactId
			INTO #CONTACTNODEFAULT
			FROM tblARCustomer C
			CROSS APPLY (
				SELECT TOP 1 ETC.intEntityToContactId, ETC.intEntityContactId
				FROM tblEMEntityToContact ETC
				WHERE ETC.intEntityId = C.intEntityId
			) CETC
			LEFT JOIN (
				SELECT intEntityId		= EC.intEntityId
					 , intContactCount = COUNT(1)
				FROM tblEMEntityToContact EC
				WHERE EC.ysnDefaultContact = 1
				GROUP BY EC.intEntityId
			) CONTACT1 ON C.intEntityId = CONTACT1.intEntityId
			WHERE CONTACT1.intEntityId IS NULL
			  AND CETC.intEntityToContactId IS NOT NULL
 
			--UPDATE CONTACT AS DEFAULT
			UPDATE ETC
			SET ysnDefaultContact = CAST(1 AS BIT)
			FROM tblEMEntityToContact ETC
			INNER JOIN #CONTACTNODEFAULT CD ON ETC.intEntityId = CD.intEntityId
			AND ETC.intEntityContactId = CD.intEntityContactId
			CROSS APPLY (
				SELECT EC.intEntityToContactId
				FROM tblEMEntityToContact EC
				INNER JOIN #CONTACTNODEFAULT ED ON EC.intEntityId = ED.intEntityId
				WHERE EC.ysnDefaultContact = 0
				  AND EC.intEntityToContactId = ETC.intEntityToContactId	
				  AND EC.intEntityId = CD.intEntityId
			) DC

			--UPDATE CUSTOMER DEFAULT CONTACT
			UPDATE C
			SET intDefaultContactId = CETC.intEntityContactId
			FROM tblARCustomer C
			CROSS APPLY (
				SELECT TOP 1 ETC.intEntityContactId
				FROM tblEMEntityToContact ETC
				WHERE ETC.ysnDefaultContact = 1
				  AND ETC.intEntityId = C.intEntityId	
			) CETC
			WHERE C.intDefaultContactId IS NULL
		END

	IF(@Checking = 1)
		BEGIN
			SELECT @Total = COUNT(sscon_contact_id) 
			FROM ssconmst O
			INNER JOIN tblARCustomer CUS ON O.sscon_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS
			LEFT JOIN tblEMEntity CON ON O.sscon_contact_id COLLATE Latin1_General_CI_AS = CON.strContactNumber COLLATE Latin1_General_CI_AS
			WHERE CON.strContactNumber IS NULL 
			  AND O.sscon_contact_id = UPPER(O.sscon_contact_id ) COLLATE Latin1_General_CS_AS
			  AND O.sscon_cus_no LIKE '%[a-z0-9]%'
		END
END

GO