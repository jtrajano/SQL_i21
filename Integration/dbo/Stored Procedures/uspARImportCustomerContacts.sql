IF EXISTS(select top 1 1 from sys.procedures where name = 'uspARImportCustomerContacts')
	DROP PROCEDURE uspARImportCustomerContacts
GO

CREATE PROCEDURE [dbo].[uspARImportCustomerContacts]
AS 

BEGIN

-- Temp Table with Autonumber to hold the Contacts to be imported
DECLARE @Contacts TABLE
(
	 id int identity(1,1)
	, sscon_contact_id nvarchar(max)
	, sscon_cus_no nvarchar(max)
	, sscon_email nvarchar(max)
	, sscon_first_name nvarchar(max)
	, sscon_last_name nvarchar(max)
	, sscon_work_no nvarchar(max)
	, sscon_work_ext nvarchar(max)
	, sscon_cell_no nvarchar(max)
	, sscon_cell_ext nvarchar(max))

	
	BEGIN -- Get Customers to be imported to #tmpContacts
		INSERT INTO @Contacts
		(
			sscon_contact_id
			, sscon_cus_no 
			, sscon_email 
			, sscon_first_name 
			, sscon_last_name 
			, sscon_work_no 
			, sscon_work_ext 
			, sscon_cell_no 
			, sscon_cell_ext 
		)
		SELECT 
			isnull(sscon_contact_id, '')
			, isnull(sscon_cus_no, '')
			, isnull(sscon_email, '')
			, isnull(sscon_first_name, '')
			, isnull(sscon_last_name, '')
			, isnull(sscon_work_no, '')
			, isnull(sscon_work_ext, '')
			, isnull(sscon_cell_no, '')
			, isnull(sscon_cell_ext, '')
		FROM ssconmst sscon
		WHERE 
			sscon_cus_no LIKE '%[a-z0-9]%'
			AND 
				(
					sscon_email not in 
					(
						select isnull(strEmail, '') COLLATE SQL_Latin1_General_CP1_CS_AS 
						from tblEntity E inner join tblEntityContact EC on E.intEntityId = EC.intEntityId
						WHERE isnull(strEmail, '') like '%[a-z0-9]%' 
					) 
					OR isnull(sscon_email, '') = ''
				)
			AND sscon_cus_no in (select strCustomerNumber collate SQL_Latin1_General_CP1_CS_AS from tblARCustomer)
			AND rtrim(ltrim(sscon_last_name)) + ', ' + rtrim(ltrim(sscon_first_name))
			not in (
				select strName COLLATE SQL_Latin1_General_CP1_CS_AS from tblEntity E inner join tblEntityContact EC on E.intEntityId = EC.intEntityId
			)

	END
		-- LOOP Insertions
		WHILE exists (select top 1 1 from @Contacts)
		BEGIN
			DECLARE @id int
			select top 1 @id = id from @Contacts

			BEGIN -- Create entity record for Contacts

				declare @Entity as Entity

				insert @Entity
				select top 1 
					rtrim(ltrim(sscon_last_name)) + ', ' + rtrim(ltrim(sscon_first_name)), sscon_email, '', '' , 0, '', '', '', '', null, null
				from @Contacts where id = @id
				--select * from @Entity
					declare @intEntityId int
					exec uspEntityCreateEntity @Entity , @intEntityId OUT
			
			END

			BEGIN -- Create Contact record
				declare @EntityContact as EntityContact
				insert @EntityContact
				select top 1
					@intEntityId
					, rtrim(ltrim(sscon_contact_id))
					, ''
					, ''
					, rtrim(ltrim(sscon_cell_no)) + ' x' + rtrim(ltrim(sscon_cell_ext))
					, rtrim(ltrim(sscon_work_no)) + ' x' + rtrim(ltrim(sscon_work_ext))
					, '' , '', '', '', '', ''
				from @Contacts where id = @id
				--select * from @EntityContact
					declare @intContactId int
					exec [uspEntityCreateEntityContact] @EntityContact, @intContactId OUT
			END

			BEGIN -- Create Customer to Contact

				declare @CustomerNo nvarchar(max), @intCustomerId int

				select top 1 @CustomerNo = sscon_cus_no from @Contacts where id = @id
				select top 1 @intCustomerId = intCustomerId from tblARCustomer where strCustomerNumber = @CustomerNo 

				insert into tblARCustomerToContact
				(
					 intCustomerId
					, intContactId
					, intEntityLocationId
					, strUserType
					, ysnPortalAccess
				)
				select
					@intCustomerId
					, @intContactId
					, null
					, 'User'
					, 0

			END
			
			----TODO1: remove this select and delete tblEntity and tblEntityContact
			--	select * from tblEntity where intEntityId = @intEntityId
			--	select * from tblEntityContact where intContactId = @intContactId 
				
			--	delete from tblEntityContact where intContactId = @intContactId 
			--	delete from tblEntity where intEntityId = @intEntityId
			---- End of TODO1
			
				delete from @Entity
				delete from @EntityContact 
				delete from @Contacts where id = @id

		END
END
	

GO




--exec [uspARImportCustomerContacts]


-- 3. Insert tbl tblARCustomerToContact




--tblEntityContact

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
--select * from tblEntityContact where intContactId = @intContactId

--delete from tblEntityContact where intContactId = @intContactId

