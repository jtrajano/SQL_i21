GO

IF EXISTS(select top 1 1 from sys.procedures where name = 'uspARContactOriginSync')
	DROP PROCEDURE uspARContactOriginSync
GO

IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()) = 1
BEGIN
EXEC( 'CREATE PROCEDURE [dbo].[uspARContactOriginSync]
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
				sscon_first_name = (CASE WHEN CHARINDEX('', '', E.strName) > 0 THEN SUBSTRING(SUBSTRING(E.strName,1,30), 0, CHARINDEX('', '',E.strName)) ELSE SUBSTRING(E.strName,1,30)END),
				sscon_last_name = (CASE WHEN CHARINDEX('', '', E.strName) > 0 THEN SUBSTRING(SUBSTRING(E.strName,1,30),CHARINDEX('', '',E.strName) + 2, LEN(E.strName))END),
				sscon_contact_title = Contact.strTitle,
				sscon_work_no = (CASE WHEN CHARINDEX('' x'', Contact.strPhone) > 0 THEN SUBSTRING(SUBSTRING(Contact.strPhone,1,30), 0, CHARINDEX('' x'',Contact.strPhone)) ELSE SUBSTRING(Contact.strPhone,1,30)END),
				sscon_work_ext = (CASE WHEN CHARINDEX('' x'', Contact.strPhone) > 0 THEN SUBSTRING(SUBSTRING(Contact.strPhone,1,30),CHARINDEX('' x'',Contact.strPhone) + 2, LEN(Contact.strPhone))END),
				sscon_cell_no = (CASE WHEN CHARINDEX('' x'', Contact.strMobile) > 0 THEN SUBSTRING(SUBSTRING(Contact.strMobile,1,30), 0, CHARINDEX('' x'',Contact.strMobile)) ELSE SUBSTRING(Contact.strMobile,1,30)END),
				sscon_cell_ext = (CASE WHEN CHARINDEX('' x'', Contact.strMobile) > 0 THEN SUBSTRING(SUBSTRING(Contact.strMobile,1,30),CHARINDEX('' x'',Contact.strMobile) + 2, LEN(Contact.strMobile))END),
				sscon_fax_no = Contact.strFax,
				sscon_email = E.strEmail
			FROM tblEntityContact Contact
				INNER JOIN tblEntity E ON E.intEntityId = Contact.intEntityId
				WHERE Contact.strContactNumber = @ContactNumber
		END
		--INSERT IF NOT EXIST IN THE ORIGIN
		ELSE
			INSERT INTO ssconmst(
				sscon_first_name,
				sscon_last_name,
				sscon_contact_title,
				sscon_work_no,
				sscon_work_ext,
				sscon_cell_no,
				sscon_cell_ext,
				sscon_fax_no,
				sscon_email
			)
			SELECT
				(CASE WHEN CHARINDEX('', '', E.strName) > 0 THEN SUBSTRING(SUBSTRING(E.strName,1,30), 0, CHARINDEX('', '',E.strName)) ELSE SUBSTRING(E.strName,1,30)END) AS LastName,
				(CASE WHEN CHARINDEX('', '', E.strName) > 0 THEN SUBSTRING(SUBSTRING(E.strName,1,30),CHARINDEX('', '',E.strName) + 2, LEN(E.strName))END) AS FirstName,
				Contact.strTitle,
				(CASE WHEN CHARINDEX('' x'', Contact.strPhone) > 0 THEN SUBSTRING(SUBSTRING(Contact.strPhone,1,30), 0, CHARINDEX('' x'',Contact.strPhone)) ELSE SUBSTRING(Contact.strPhone,1,30)END) AS Phone,
				(CASE WHEN CHARINDEX('' x'', Contact.strPhone) > 0 THEN SUBSTRING(SUBSTRING(Contact.strPhone,1,30),CHARINDEX('' x'',Contact.strPhone) + 2, LEN(Contact.strPhone))END) AS ExtPhone,
				(CASE WHEN CHARINDEX('' x'', Contact.strMobile) > 0 THEN SUBSTRING(SUBSTRING(Contact.strMobile,1,30), 0, CHARINDEX('' x'',Contact.strMobile)) ELSE SUBSTRING(Contact.strMobile,1,30)END) AS Moblie,
				(CASE WHEN CHARINDEX('' x'', Contact.strMobile) > 0 THEN SUBSTRING(SUBSTRING(Contact.strMobile,1,30),CHARINDEX('' x'',Contact.strMobile) + 2, LEN(Contact.strMobile))END) AS ExtMoblie,
				Contact.strFax,
				E.strEmail,
				'''',
				'''',
				''''
			FROM tblEntityContact Contact
				INNER JOIN tblEntity E ON E.intEntityId = Contact.intEntityId
				WHERE Contact.strContactNumber = @ContactNumber
	

	RETURN;
	END'
	)
END

