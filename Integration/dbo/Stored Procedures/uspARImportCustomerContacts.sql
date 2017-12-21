GO
IF EXISTS(select top 1 1 from sys.procedures where name = 'uspARImportCustomerContacts')
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
DECLARE @Contacts TABLE
(
	 id int identity(1,1)
	, sscon_contact_id nvarchar(max)
	, sscon_cus_no nvarchar(max)
	, sscon_contact_title nvarchar(max)
	, sscon_email nvarchar(max)
	, sscon_first_name nvarchar(max)
	, sscon_last_name nvarchar(max)
	, sscon_suffix nvarchar(max)
	, sscon_work_no nvarchar(max)
	, sscon_work_ext nvarchar(max)
	, sscon_cell_no nvarchar(max)
	, sscon_cell_ext nvarchar(max)
	, sscon_fax_no nvarchar(max)
	, sscon_fax_ext nvarchar(max)
)

SELECT ED.coefd_contact_id, ED.coefd_cus_no,
       STUFF(ISNULL((SELECT ',' + CASE WHEN x.coefd_eform_type = 'INV' THEN 'Invoices,Credit Memo,Debit Memo,Cash Refund,Cash,Sales Order'
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
  FROM coefdmst ED WHERE ED.coefd_by_email = 'Y'  --and ED.coefd_cus_no = 'AIRTEX'
  GROUP BY ED.coefd_contact_id, ED.coefd_cus_no, ED.coefd_eform_type

	declare @sscon_cus_no nvarchar(200)
	BEGIN -- Get Customers to be imported to #tmpContacts
		INSERT INTO @Contacts
		(
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
		SELECT 
			isnull(sscon_contact_id, '')
			, isnull(sscon_cus_no, '')
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
			sscon_cus_no LIKE '%[a-z0-9]%'
			-- AND 
			-- 	(
			-- 		sscon_email not in 
			-- 		(
			-- 			select isnull(G.strEmail, '') COLLATE SQL_Latin1_General_CP1_CS_AS 
			-- 			from tblEMEntity E
			-- 				join tblEMEntityToContact F
			-- 					on E.intEntityId = F.intEntityId
			-- 				join tblEMEntity G
			-- 					on F.intEntityContactId = G.intEntityId
			-- 			WHERE isnull(G.strEmail, '') like '%[a-z0-9]%' 
			-- 		) 
			-- 		OR isnull(sscon_email, '') = ''
			-- 	)
			AND sscon_cus_no in (select strCustomerNumber collate SQL_Latin1_General_CP1_CS_AS from tblARCustomer)
			-- AND rtrim(ltrim(sscon_last_name)) + ', ' + rtrim(ltrim(sscon_first_name))
			-- not in (
			-- 	select G.strName COLLATE SQL_Latin1_General_CP1_CS_AS from tblEMEntity E
			-- 		join tblEMEntityToContact F
			-- 			on E.intEntityId = F.intEntityId
			-- 		join tblEMEntity G
			-- 			on F.intEntityContactId = G.intEntityId
			-- )
			-- and sscon_contact_id not in (select strContactNumber collate SQL_Latin1_General_CP1_CS_AS  
			-- 								from tblEMEntity where isnull(strContactNumber,'') <> '')

	END
		-- LOOP Insertions
		WHILE exists (select top 1 1 from @Contacts)
		BEGIN
			DECLARE @id int
			DECLARE @sscon_contact_id NVARCHAR(20)

			select top 1 @id = id, 
							@sscon_cus_no = sscon_cus_no,
							@sscon_contact_id = sscon_contact_id
			from @Contacts
			declare @intEntityId int
			declare @Name		nvarchar(200)

			BEGIN -- Create entity record for Contacts

				select @intEntityId = intEntityId from tblARCustomer where strCustomerNumber = @sscon_cus_no				
			
			END

			IF EXISTS(select TOP 1  1 from tblEMEntity A 
						join tblEMEntityToContact B on A.intEntityId = B.intEntityId 
						join tblEMEntity C on B.intEntityContactId = C.intEntityId
							WHERE A.intEntityId = @intEntityId and 
								C.strContactNumber = @sscon_contact_id 
					)
			BEGIN
				goto ContinueLoop;
			END
			BEGIN -- Create Contact record
				declare @EntityContact as EntityContact
				declare @ContactNumber	nvarchar(200)
				declare @Title			nvarchar(200)
				declare @CP				nvarchar(200)
				declare @WorkPhone		nvarchar(200)
				declare @Fax			nvarchar(200)
				declare @Email          nvarchar(200)
				
				select top 1
					@Name			= rtrim(ltrim(sscon_last_name)) + ', ' + rtrim(ltrim(sscon_first_name)) + ' ' + rtrim(ltrim(sscon_suffix)),
					@ContactNumber	= rtrim(ltrim(sscon_contact_id)),
					@Title			= substring((rtrim(ltrim(sscon_contact_title))), 1,35),
					@CP				= isnull(nullif(ltrim((rtrim(rtrim(ltrim(sscon_cell_no)) + ' x' + rtrim(ltrim(sscon_cell_ext))))), 'x'), ''),
					@WorkPhone		= isnull(nullif(ltrim((rtrim(rtrim(ltrim(sscon_work_no)) + ' x' + rtrim(ltrim(sscon_work_ext))))), 'x'), ''),
					@Fax			= isnull(nullif(ltrim((rtrim(rtrim(ltrim(sscon_fax_no)) + ' x' + rtrim(ltrim(sscon_fax_ext))))), 'x'), ''),
					@Email			= rtrim(ltrim(sscon_email))
				from @Contacts where id = @id
				
				insert into tblEMEntity(strName, strContactNumber, strTitle, strEmail)
				select @Name, @ContactNumber, @Title, @Email


				declare @intContactId int
				
				set @intContactId = @@IDENTITY
				if @CP <> ''
				begin
					if exists(select top 1 1 from tblEMContactDetailType where strType = 'Phone' and strField = 'Home')
					begin
						insert into tblEMContactDetail (intEntityId, strValue, intContactDetailTypeId)
						select top 1 @intContactId, @CP, intContactDetailTypeId from tblEMContactDetailType where strType = 'Phone' and strField = 'Home' 
					end

					insert into tblEMEntityPhoneNumber(intEntityId, strPhone)
					select @intContactId, @CP
				end

				if @WorkPhone <> ''
				begin
					if exists(select top 1 1 from tblEMContactDetailType where strType = 'Phone' and strField = 'Work')
					begin
						insert into tblEMContactDetail (intEntityId, strValue, intContactDetailTypeId)
						select top 1 @intContactId, @WorkPhone, intContactDetailTypeId from tblEMContactDetailType where strType = 'Phone' and strField = 'Work' 
					end
				end

				if @Fax <> ''
				begin
					if exists(select top 1 1 from tblEMContactDetailType where strType = 'Phone' and strField = 'Fax')
					begin
						insert into tblEMContactDetail (intEntityId, strValue, intContactDetailTypeId)
						select top 1 @intContactId, @Fax, intContactDetailTypeId from tblEMContactDetailType where strType = 'Phone' and strField = 'Fax' 
					end
				end

				if @Email <> ''
				begin
					if exists(select top 1 1 from tblEMContactDetailType where strType = 'Email' and strField = 'Alt Email')
					begin
						insert into tblEMContactDetail (intEntityId, strValue, intContactDetailTypeId)
						select top 1 @intContactId, @Email, intContactDetailTypeId from tblEMContactDetailType where strType = 'Email' and strField = 'Alt Email' 
					end
				end
					
					--exec [uspEntityCreateEntityContact] @EntityContact, @intContactId OUT
			END
			BEGIN --LOCATION

				DECLARE @EntityLocationName NVARCHAR(50)
				SET @EntityLocationName = @Name +'_'+@ContactNumber+ 'Loc'
				DECLARE @LoopCounter INT
				set @LoopCounter = 1
				WHILE EXISTS(SELECT TOP 1 1 FROM tblEMEntityLocation where strLocationName = @EntityLocationName)
				BEGIN
					SET @EntityLocationName = CAST(@LoopCounter AS NVARCHAR) + @EntityLocationName
				END
				insert into tblEMEntityLocation(intEntityId, strLocationName, ysnDefaultLocation)
				select @intEntityId, @EntityLocationName, 0
			END
			BEGIN -- Create Customer to Contact

				declare @CustomerNo nvarchar(max), @intEntityCustomerId int

				select top 1 @CustomerNo = sscon_cus_no from @Contacts where id = @id
				select top 1 @intEntityCustomerId = intEntityId from tblARCustomer where strCustomerNumber = @CustomerNo 

				insert into tblEMEntityToContact(intEntityId, intEntityContactId, ysnDefaultContact, ysnPortalAccess)
				select @intEntityId, @intContactId, 0, 0


			END
			

			ContinueLoop:
			--UPDATE E-DISTRIBUTION FORM TYPEs
			UPDATE ENT SET ENT.strEmailDistributionOption = ED.Form_type from tblEMEntityToContact ETC 
			INNER JOIN tblEMEntity ENT ON ENT.intEntityId = ETC.intEntityContactId
			INNER JOIN ssconmst CON ON CON.sscon_contact_id COLLATE SQL_Latin1_General_CP1_CS_AS 
						= ENT.strContactNumber COLLATE SQL_Latin1_General_CP1_CS_AS	AND CON.sscon_cus_no = @sscon_cus_no
			INNER JOIN #tmpcoefd ED ON ED.coefd_contact_id = CON.sscon_contact_id AND ED.coefd_cus_no = CON.sscon_cus_no
			
			
			----TODO1: remove this select and delete tblEMEntity and tblEMEntityContact
			--	select * from tblEMEntity where intEntityId = @intEntityId
			--	select * from tblEMEntityContact where intContactId = @intContactId 
				
			--	delete from tblEMEntityContact where intContactId = @intContactId 
			--	delete from tblEMEntity where intEntityId = @intEntityId
			---- End of TODO1		
				
				delete from @Contacts where id = @id

		END
END

IF(@Checking = 1)
BEGIN
	SELECT @Total =  count(sscon_contact_id) 
	FROM ssconmst
	LEFT JOIN tblEMEntity Con 
		ON ssconmst.sscon_contact_id COLLATE Latin1_General_CI_AS = Con.strContactNumber COLLATE Latin1_General_CI_AS
	WHERE Con.strContactNumber IS NULL AND ssconmst.sscon_contact_id  = UPPER(ssconmst.sscon_contact_id ) COLLATE Latin1_General_CS_AS
		and sscon_cus_no LIKE '%[a-z0-9]%'			
		AND sscon_cus_no in (select strCustomerNumber collate SQL_Latin1_General_CP1_CS_AS from tblARCustomer)
			-- AND rtrim(ltrim(sscon_last_name)) + ', ' + rtrim(ltrim(sscon_first_name))
			-- not in (
			-- 	select G.strName COLLATE SQL_Latin1_General_CP1_CS_AS from tblEMEntity E
			-- 		join tblEMEntityToContact F
			-- 			on E.intEntityId = F.intEntityId
			-- 		join tblEMEntity G
			-- 			on F.intEntityContactId = G.intEntityId
			-- )
			-- and sscon_contact_id not in (select strContactNumber collate SQL_Latin1_General_CP1_CS_AS  
			-- 								from tblEMEntity where isnull(strContactNumber,'') <> '')
	
END
END
	
	

	

GO




--exec [uspARImportCustomerContacts]


-- 3. Insert tbl tblARCustomerToContact




--tblEMEntityContact

---- TEST
--declare @EntityContact as EntityContact
--insert @EntityContact
--select 
--	1
--	, 'contactNo'
--	, 'title'
--	, 'department'
--	, 'mobile'
--	, 'phone'
--	, 'phone2'
--	, 'email2'
--	, 'fax'
--	, 'notes'
--	, 'contact method'
--	, 'timezone'

--declare @intContactId int
--exec [uspEntityCreateEntityContact] @EntityContact, @intContactId OUT
--select @intContactId
--select * from tblEMEntityContact where intContactId = @intContactId

--delete from tblEMEntityContact where intContactId = @intContactId

