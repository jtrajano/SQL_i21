GO
IF EXISTS(select top 1 1 from sys.procedures where name = 'uspAPImportVendorContact')
	DROP PROCEDURE uspAPImportVendorContact
GO

CREATE PROCEDURE [dbo].[uspAPImportVendorContact]
	@UpdateVendorId nvarchar(max) = NULL
AS
BEGIN
	if(@UpdateVendorId IS NOT NULL)
	BEGIN
		SET @UpdateVendorId = dbo.fnTrim(@UpdateVendorId)
	END
	DECLARE @Contacts TABLE
	(
		 id int identity(1,1)
		, sscon_contact_id nvarchar(max)
		, sscon_vnd_no nvarchar(max)
		, sscon_contact_title nvarchar(max)
		, sscon_email nvarchar(max)
		, sscon_first_name nvarchar(max)
		, sscon_last_name nvarchar(max)
		, sscon_work_no nvarchar(max)
		, sscon_work_ext nvarchar(max)
		, sscon_cell_no nvarchar(max)
		, sscon_cell_ext nvarchar(max)
		, sscon_fax_no nvarchar(max)
		, sscon_fax_ext nvarchar(max)
	)
	

	BEGIN -- Get Customers to be imported to #tmpContacts
		INSERT INTO @Contacts
		(
			sscon_contact_id
			, sscon_vnd_no 
			, sscon_contact_title
			, sscon_email 
			, sscon_first_name 
			, sscon_last_name 
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
			, isnull(sscon_email, '')
			, isnull(sscon_first_name, '')
			, isnull(sscon_last_name, '')
			, isnull(sscon_work_no, '')
			, isnull(sscon_work_ext, '')
			, isnull(sscon_cell_no, '')
			, isnull(sscon_cell_ext, '')
			, isnull(sscon_fax_no, '')
			, isnull(sscon_fax_ext, '')
		FROM ssconmst sscon
		WHERE 
			sscon_vnd_no LIKE '%[a-z0-9]%'
			AND(
					(@UpdateVendorId IS NULL AND sscon_vnd_no in (select strVendorId collate SQL_Latin1_General_CP1_CS_AS from tblAPVendor))
					OR
					(@UpdateVendorId IS NOT NULL AND sscon_vnd_no COLLATE Latin1_General_CI_AS = @UpdateVendorId)
				)			
			AND rtrim(ltrim(sscon_last_name)) + ', ' + rtrim(ltrim(sscon_first_name))
			not in (
				select strName COLLATE SQL_Latin1_General_CP1_CS_AS from tblEMEntity E
			)

	END
	DECLARE @id int
	DECLARE @VendorId nvarchar(max)
	DECLARE @ContactId INT
	DECLARE @EntityId INT
	-- LOOP Insertions
	WHILE exists (select top 1 1 from @Contacts)
	BEGIN
			
		set @VendorId = null
		set @EntityId  = null
		select top 1 @id = id,@VendorId = sscon_vnd_no from @Contacts
		SELECT TOP 1 @EntityId = intEntityId FROM tblAPVendor where strVendorId = @VendorId;
		
		if @EntityId is not null
		BEGIN
			
			BEGIN -- Create Contact record				
				INSERT INTO tblEMEntity (
					strName
					, strEmail
					, strContactNumber
					, strTitle
					, strMobile
					, strPhone
					, strFax
				)
				select top 1
					rtrim(ltrim(sscon_last_name)) + ', ' + rtrim(ltrim(sscon_first_name))
					, rtrim(ltrim(sscon_email))					
					, substring(rtrim(ltrim(sscon_contact_id)),1,20)
					, substring((rtrim(ltrim(sscon_contact_title))), 1,35)					
					, isnull(nullif(ltrim((rtrim(rtrim(ltrim(sscon_cell_no)) + ' x' + rtrim(ltrim(sscon_cell_ext))))), 'x'), '')
					, isnull(nullif(ltrim((rtrim(rtrim(ltrim(sscon_work_no)) + ' x' + rtrim(ltrim(sscon_work_ext))))), 'x'), '')
					, isnull(nullif(ltrim((rtrim(rtrim(ltrim(sscon_fax_no)) + ' x' + rtrim(ltrim(sscon_fax_ext))))), 'x'), '')					
				from @Contacts where id = @id		
				
				set @ContactId = @@IDENTITY
				
				INSERT INTO [dbo].[tblEMEntityToContact]([intEntityId],[intEntityContactId],[intEntityLocationId],[ysnDefaultContact],[ysnPortalAccess],[strUserType])
				VALUES( @EntityId, @ContactId, NULL, 0 ,0 , 'User')
			END			
		END
		
		delete from @Contacts where id = @id

	END
END
