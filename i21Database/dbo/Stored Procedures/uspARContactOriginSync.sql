CREATE PROCEDURE [dbo].[uspARContactOriginSync]
	@ContactNumber NVARCHAR(20) = NULL,
	@EntityId INT = NULL

	AS

	DECLARE @EntityNo NVARCHAR(50)
	SET @EntityNo = NULL
	IF @EntityId is not null
	BEGIN		

		SELECT @EntityNo = strCustomerNumber from tblEMEntityToContact A
			JOIN tblARCustomer B
				ON A.intEntityId = B.intEntityId 
		WHERE A.intEntityContactId = @EntityId
	END		
	--================================================
	--     UPDATE/INSERT IN ORIGIN	
	--================================================
	IF(@ContactNumber IS NOT NULL) 
	BEGIN
		--UPDATE IF EXIST IN THE ORIGIN
		IF(@EntityNo <> '' AND EXISTS(SELECT 1 FROM ssconmst WHERE LTRIM(RTRIM(sscon_contact_id)) = UPPER( LTRIM(RTRIM(@ContactNumber)) ) AND LTRIM(RTRIM(sscon_cus_no)) = UPPER(LTRIM(RTRIM(@EntityNo))) ))
		BEGIN			
			UPDATE ssconmst
				SET 
				sscon_last_name = SUBSTRING((CASE WHEN CHARINDEX(', ', Contact.strName) > 0 THEN SUBSTRING(SUBSTRING(Contact.strName,1,30), 0, CHARINDEX(', ',Contact.strName)) ELSE SUBSTRING(Contact.strName,1,30)END), 1, 20),
				sscon_first_name = SUBSTRING((CASE WHEN CHARINDEX(', ', Contact.strName) > 0 THEN SUBSTRING(SUBSTRING(Contact.strName,1,30),CHARINDEX(', ',Contact.strName) + 2, LEN(Contact.strName))END), 1, 20),
				sscon_contact_title = Contact.strTitle,
				sscon_work_no = (CASE WHEN CHARINDEX('x', ISNULL(P.strPhone,'')) > 0 THEN SUBSTRING(SUBSTRING(ISNULL(P.strPhone,''),1,15), 0, CHARINDEX('x',ISNULL(P.strPhone,''))) ELSE SUBSTRING(ISNULL(P.strPhone,''),1,15)END),
				sscon_work_ext = (CASE WHEN CHARINDEX('x', ISNULL(P.strPhone,'')) > 0 THEN SUBSTRING(SUBSTRING(ISNULL(P.strPhone,''),CHARINDEX('x',ISNULL(P.strPhone,'')) + 1, LEN(ISNULL(P.strPhone,''))) ,1,4) END),
				sscon_cell_no = (CASE WHEN CHARINDEX('x', ISNULL(M.strPhone,'')) > 0 THEN SUBSTRING(SUBSTRING(ISNULL(M.strPhone,''),1,15), 0, CHARINDEX('x',ISNULL(M.strPhone,''))) ELSE SUBSTRING(ISNULL(M.strPhone,''),1,15)END),
				sscon_cell_ext = (CASE WHEN CHARINDEX('x', ISNULL(ISNULL(M.strPhone,''),'')) > 0 THEN SUBSTRING(SUBSTRING(ISNULL(M.strPhone,''),CHARINDEX('x',ISNULL(M.strPhone,'')) + 1, LEN(ISNULL(M.strPhone,''))) ,1,4) END),
				sscon_fax_no = (CASE WHEN CHARINDEX('x', ISNULL(F.strValue,'')) > 0 THEN SUBSTRING(SUBSTRING(ISNULL(F.strValue,''),1,15), 0, CHARINDEX('x',ISNULL(F.strValue,''))) ELSE SUBSTRING(ISNULL(F.strValue,''),1,15)END),
				sscon_fax_ext = (CASE WHEN CHARINDEX('x', ISNULL(F.strValue,'')) > 0 THEN SUBSTRING(SUBSTRING(ISNULL(F.strValue,''),CHARINDEX('x',ISNULL(F.strValue,'')) + 1, LEN(ISNULL(F.strValue,''))) ,1,4) END),

				sscon_email = Contact.strEmail
			FROM tblEMEntity Contact
				INNER JOIN [tblEMEntityToContact] EntToCon
					on EntToCon.intEntityContactId = Contact.intEntityId
				INNER JOIN tblEMEntity E ON E.intEntityId = EntToCon.intEntityId
				INNER JOIN vyuEMEntityType ET
					ON ET.intEntityId = E.intEntityId and Customer = 1
				LEFT JOIN tblEMEntityPhoneNumber P
					ON P.intEntityId = Contact.intEntityId
				LEFT JOIN tblEMEntityMobileNumber M
					ON M.intEntityId = Contact.intEntityId
				LEFT JOIN  tblEMContactDetail F 
					ON F.intEntityId = Contact.intEntityId AND 
						F.intContactDetailTypeId = ( SELECT TOP 1 intContactDetailTypeId from tblEMContactDetailType where strType = 'Phone' and strField = 'Fax' )
				WHERE UPPER(Contact.strContactNumber) = UPPER(@ContactNumber) AND UPPER(sscon_contact_id) = SUBSTRING(UPPER(@ContactNumber),1,20)
				AND (@EntityId is null or Contact.intEntityId = @EntityId)

		END
		--INSERT IF NOT EXIST IN THE ORIGIN
		ELSE
		BEGIN

			INSERT INTO ssconmst(
				sscon_contact_id,
				sscon_cus_no,
				sscon_last_name,
				sscon_first_name,
				sscon_contact_title,
				sscon_work_no,
				sscon_work_ext,
				sscon_cell_no,
				sscon_cell_ext,
				sscon_fax_no,
				sscon_fax_ext,
				sscon_email,
				--not to be null on origin
				sscon_lead_id, 
				sscon_loc_id,
				sscon_vnd_no
			)
			SELECT TOP 1
				SUBSTRING(UPPER(Contact.strContactNumber),1,20),
				SUBSTRING(C.strCustomerNumber,1,10),--E.strEntityNo,
				--Substring names to avoid SQL truncation error
				SUBSTRING((CASE WHEN CHARINDEX(', ', Contact.strName) > 0 THEN SUBSTRING(SUBSTRING(Contact.strName,1,30), 0, CHARINDEX(', ',Contact.strName)) ELSE SUBSTRING(Contact.strName,1,30)END), 1, 20) AS LastName,
				SUBSTRING((CASE WHEN CHARINDEX(', ', Contact.strName) > 0 THEN SUBSTRING(SUBSTRING(Contact.strName,1,30),CHARINDEX(', ',Contact.strName) + 2, LEN(Contact.strName))END), 1, 20) AS FirstName,
				Contact.strTitle,
				(CASE WHEN CHARINDEX('x', ISNULL(P.strPhone,'')) > 0 THEN SUBSTRING(SUBSTRING(ISNULL(P.strPhone,''),1,15), 0, CHARINDEX('x',ISNULL(P.strPhone,''))) ELSE SUBSTRING(ISNULL(P.strPhone,''),1,15)END) AS Phone,
				(CASE WHEN CHARINDEX('x', ISNULL(P.strPhone,'')) > 0 THEN SUBSTRING(SUBSTRING(ISNULL(P.strPhone,''),CHARINDEX('x',ISNULL(P.strPhone,'')) + 1, LEN(ISNULL(P.strPhone,''))) ,1,4) END) AS ExtPhone,
				(CASE WHEN CHARINDEX('x', ISNULL(M.strPhone,'')) > 0 THEN SUBSTRING(SUBSTRING(ISNULL(M.strPhone,''),1,15), 0, CHARINDEX('x',ISNULL(M.strPhone,''))) ELSE SUBSTRING(ISNULL(M.strPhone,''),1,15)END) AS Moblie,
				(CASE WHEN CHARINDEX('x', ISNULL(M.strPhone,'')) > 0 THEN SUBSTRING(SUBSTRING(ISNULL(M.strPhone,''),CHARINDEX('x',ISNULL(M.strPhone,'')) + 1, LEN(ISNULL(M.strPhone,''))) ,1,4) END) AS ExtMoblie,
				(CASE WHEN CHARINDEX('x', ISNULL(F.strValue,'')) > 0 THEN SUBSTRING(SUBSTRING(ISNULL(F.strValue,''),1,15), 0, CHARINDEX('x',ISNULL(F.strValue,''))) ELSE SUBSTRING(ISNULL(F.strValue,''),1,15)END) AS Fax,
				(CASE WHEN CHARINDEX('x', ISNULL(F.strValue,'')) > 0 THEN SUBSTRING(SUBSTRING(ISNULL(F.strValue,''),CHARINDEX('x',ISNULL(F.strValue,'')) + 1, LEN(ISNULL(F.strValue,''))) ,1,4) END) AS ExtFax,
				Contact.strEmail,
				'',
				'',
				''
			FROM tblEMEntity Contact
				INNER JOIN [tblEMEntityToContact] EntToCon
					on EntToCon.intEntityContactId = Contact.intEntityId
				INNER JOIN tblEMEntity E ON E.intEntityId = EntToCon.intEntityId
				INNER JOIN tblARCustomer C on C.[intEntityId] = EntToCon.intEntityId				
				INNER JOIN vyuEMEntityType ET
					ON ET.intEntityId = E.intEntityId and Customer = 1
				LEFT JOIN tblEMEntityPhoneNumber P
					ON P.intEntityId = Contact.intEntityId
				LEFT JOIN tblEMEntityMobileNumber M
					ON M.intEntityId = Contact.intEntityId
				LEFT JOIN  tblEMContactDetail F 
					ON F.intEntityId = Contact.intEntityId AND 
						F.intContactDetailTypeId = ( SELECT TOP 1 intContactDetailTypeId from tblEMContactDetailType where strType = 'Phone' and strField = 'Fax' )
				WHERE UPPER(Contact.strContactNumber) = UPPER(@ContactNumber) AND C.strCustomerNumber <> ''
				AND (@EntityId is null or Contact.intEntityId = @EntityId)
			--FROM tblEMEntityContact Contact
			--	INNER JOIN tblEMEntity E ON E.intEntityId = Contact.intEntityContactId
			--	INNER JOIN tblARCustomerToContact  CusToCon ON Contact.intEntityContactId = CusToCon.intEntityContactId
			--	INNER JOIN tblARCustomer Cus ON CusToCon.intEntityContactId = Cus.[intEntityCustomerId]
			--	WHERE Contact.strContactNumber = @ContactNumber			
		END

	RETURN;
	END