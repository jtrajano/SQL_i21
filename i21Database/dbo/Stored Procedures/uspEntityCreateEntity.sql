CREATE PROCEDURE [dbo].[uspEntityCreateEntity]
	@Entity Entity READONLY
	,@EntityId int = null OUT
AS 

BEGIN
		
	BEGIN TRANSACTION;	
		BEGIN TRY

			BEGIN -- Validation: only one entity at a time
				IF (select count(*) from @Entity) > 1 
				BEGIN
					RAISERROR('Insertion of more than one entity not allowed', 16,1)
				END
			END
			
			--BEGIN --Validation: no same entity with the same email and name
			
			--	DECLARE @name nvarchar(100)
			--	DECLARE @email nvarchar(75)
			
			--	select top 1 @name = name, @email = email from @Entity

			--	IF exists (select top 1 1 from tblEntity where strEmail = @email and strName = @name)
			--	BEGIN
			--		RAISERROR('Entity with the same name and email already exists', 16,1)
			--	END

			--END


			set @EntityId = NULL
			
			
			BEGIN -- DML: Insert Entity
				insert into tblEntity
				(
					strName
					, strEmail
					, strWebsite
					, strInternalNotes
					, ysnPrint1099
					, str1099Name
					, str1099Form
					, str1099Type
					, strFederalTaxId
					, dtmW9Signed
					, imgPhoto
				)	
				select 
					Name
					, Email
					, Website
					, InternalNotes
					, Print1099
					, [1099Name]
					, [1099Form]
					, [1099Type]
					, FederalTaxId
					, W9Signed
					, Photo
				from @Entity 
			END

			set @EntityId = SCOPE_IDENTITY()

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