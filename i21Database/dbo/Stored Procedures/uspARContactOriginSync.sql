CREATE PROCEDURE [dbo].[uspARContactOriginSync]
	@ContactNumber NVARCHAR(20) = NULL

	AS
		
	--================================================
	--     UPDATE/INSERT IN ORIGIN	
	--================================================
	IF(@ContactNumber IS NOT NULL) 
	BEGIN
		--UPDATE IF EXIST IN THE ORIGIN
		IF(EXISTS(SELECT 1 FROM ssconmst WHERE sscon_contact_id = UPPER(@ContactNumber)))
		BEGIN			
			UPDATE ssconmst
				SET 
				sscon_last_name = SUBSTRING((CASE WHEN CHARINDEX(', ', Contact.strName) > 0 THEN SUBSTRING(SUBSTRING(Contact.strName,1,30), 0, CHARINDEX(', ',Contact.strName)) ELSE SUBSTRING(Contact.strName,1,30)END), 1, 20),
				sscon_first_name = SUBSTRING((CASE WHEN CHARINDEX(', ', Contact.strName) > 0 THEN SUBSTRING(SUBSTRING(Contact.strName,1,30),CHARINDEX(', ',Contact.strName) + 2, LEN(Contact.strName))END), 1, 20),
				sscon_contact_title = Contact.strTitle,
				sscon_work_no = (CASE WHEN CHARINDEX('x', Contact.strPhone) > 0 THEN SUBSTRING(SUBSTRING(Contact.strPhone,1,15), 0, CHARINDEX('x',Contact.strPhone)) ELSE SUBSTRING(Contact.strPhone,1,15)END),
				sscon_work_ext = (CASE WHEN CHARINDEX('x', Contact.strPhone) > 0 THEN SUBSTRING(SUBSTRING(Contact.strPhone,1,4),CHARINDEX('x',Contact.strPhone) + 1, LEN(Contact.strPhone))END),
				sscon_cell_no = (CASE WHEN CHARINDEX('x', Contact.strMobile) > 0 THEN SUBSTRING(SUBSTRING(Contact.strMobile,1,15), 0, CHARINDEX('x',Contact.strMobile)) ELSE SUBSTRING(Contact.strMobile,1,15)END),
				sscon_cell_ext = (CASE WHEN CHARINDEX('x', Contact.strMobile) > 0 THEN SUBSTRING(SUBSTRING(Contact.strMobile,1,4),CHARINDEX('x',Contact.strMobile) + 1, LEN(Contact.strMobile))END),
				sscon_fax_no = (CASE WHEN CHARINDEX('x', Contact.strFax) > 0 THEN SUBSTRING(SUBSTRING(Contact.strFax,1,15), 0, CHARINDEX('x',Contact.strFax)) ELSE SUBSTRING(Contact.strFax,1,15)END),
				sscon_fax_ext = (CASE WHEN CHARINDEX('x', Contact.strFax) > 0 THEN SUBSTRING(SUBSTRING(Contact.strFax,1,4),CHARINDEX('x',Contact.strFax) + 1, LEN(Contact.strFax))END),

				sscon_email = E.strEmail
			FROM tblEMEntity Contact
				INNER JOIN [tblEMEntityToContact] EntToCon
					on EntToCon.intEntityContactId = Contact.intEntityId
				INNER JOIN tblEMEntity E ON E.intEntityId = EntToCon.intEntityId
				WHERE UPPER(Contact.strContactNumber) = UPPER(@ContactNumber) AND UPPER(sscon_contact_id) = SUBSTRING(UPPER(@ContactNumber),1,20)

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
				SUBSTRING((CASE WHEN CHARINDEX(', ', E.strName) > 0 THEN SUBSTRING(SUBSTRING(E.strName,1,30), 0, CHARINDEX(', ',E.strName)) ELSE SUBSTRING(E.strName,1,30)END), 1, 20) AS LastName,
				SUBSTRING((CASE WHEN CHARINDEX(', ', E.strName) > 0 THEN SUBSTRING(SUBSTRING(E.strName,1,30),CHARINDEX(', ',E.strName) + 2, LEN(E.strName))END), 1, 20) AS FirstName,
				Contact.strTitle,
				(CASE WHEN CHARINDEX('x', Contact.strPhone) > 0 THEN SUBSTRING(SUBSTRING(Contact.strPhone,1,15), 0, CHARINDEX('x',Contact.strPhone)) ELSE SUBSTRING(Contact.strPhone,1,15)END) AS Phone,
				(CASE WHEN CHARINDEX('x', Contact.strPhone) > 0 THEN SUBSTRING(SUBSTRING(Contact.strPhone,1,4),CHARINDEX('x',Contact.strPhone) + 1, LEN(Contact.strPhone))END) AS ExtPhone,
				(CASE WHEN CHARINDEX('x', Contact.strMobile) > 0 THEN SUBSTRING(SUBSTRING(Contact.strMobile,1,15), 0, CHARINDEX('x',Contact.strMobile)) ELSE SUBSTRING(Contact.strMobile,1,15)END) AS Moblie,
				(CASE WHEN CHARINDEX('x', Contact.strMobile) > 0 THEN SUBSTRING(SUBSTRING(Contact.strMobile,1,4),CHARINDEX('x',Contact.strMobile) + 1, LEN(Contact.strMobile))END) AS ExtMoblie,
				(CASE WHEN CHARINDEX('x', Contact.strFax) > 0 THEN SUBSTRING(SUBSTRING(Contact.strFax,1,15), 0, CHARINDEX('x',Contact.strFax)) ELSE SUBSTRING(Contact.strFax,1,15)END) AS Fax,
				(CASE WHEN CHARINDEX('x', Contact.strFax) > 0 THEN SUBSTRING(SUBSTRING(Contact.strFax,1,4),CHARINDEX('x',Contact.strFax) + 1, LEN(Contact.strFax))END) AS ExtFax,
				E.strEmail,
				'',
				'',
				''
			FROM tblEMEntity Contact
				INNER JOIN [tblEMEntityToContact] EntToCon
					on EntToCon.intEntityContactId = Contact.intEntityId
				INNER JOIN tblEMEntity E ON E.intEntityId = EntToCon.intEntityId
				INNER JOIN tblARCustomer C on C.[intEntityId] = EntToCon.intEntityId
				WHERE UPPER(Contact.strContactNumber) = UPPER(@ContactNumber) AND C.strCustomerNumber <> ''
			--FROM tblEMEntityContact Contact
			--	INNER JOIN tblEMEntity E ON E.intEntityId = Contact.intEntityContactId
			--	INNER JOIN tblARCustomerToContact  CusToCon ON Contact.intEntityContactId = CusToCon.intEntityContactId
			--	INNER JOIN tblARCustomer Cus ON CusToCon.intEntityContactId = Cus.[intEntityCustomerId]
			--	WHERE Contact.strContactNumber = @ContactNumber			
		END

	RETURN;
	END