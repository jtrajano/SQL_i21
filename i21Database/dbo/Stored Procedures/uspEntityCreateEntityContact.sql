
CREATE PROCEDURE [dbo].[uspEntityCreateEntityContact]
	@EntityContact EntityContact READONLY
	,@ContactId int = null OUT
AS 

BEGIN
	
			
	BEGIN TRANSACTION;	
		BEGIN TRY

			BEGIN -- Validation: only one entity at a time
				IF (select count(*) from @EntityContact) > 1 
				BEGIN
					RAISERROR('Insertion of more than one contact not allowed', 16,1)
				END
			END

			set @ContactId = NULL

			BEGIN -- DML EntityContact
				insert into tblEntityContact
				(
					intEntityId
					,strTitle
					,strDepartment
					,strMobile
					,strPhone
					,strPhone2
					,strEmail2
					,strFax
					,strNotes
					,strContactMethod
					,strTimezone
					,strContactNumber
				)
				select
					EntityId
					,Title
					,Department
					,Mobile
					,Phone
					,Phone2
					,Email2
					,Fax
					,Notes
					,ContactMethod
					,Timezone
					,ContactNumber					
				from @EntityContact
			END

			set @ContactId = SCOPE_IDENTITY()
		END TRY

		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION;
			--THROW;
			-- all the code below will be obsolete (but will still work) with SQL2012
			-- a single THROW will throw this error
			    DECLARE @ErrorMessage NVARCHAR(4000);
				DECLARE @ErrorSeverity INT;
				DECLARE @ErrorState INT;

				SELECT 
					@ErrorMessage = ERROR_MESSAGE(),
					@ErrorSeverity = ERROR_SEVERITY(),
					@ErrorState = ERROR_STATE();

				RAISERROR (@ErrorMessage, -- Message text.
						   @ErrorSeverity, -- Severity.
						   @ErrorState -- State.
						   );
		END CATCH

		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION;			
			
END

GO
