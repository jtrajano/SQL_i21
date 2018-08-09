CREATE PROCEDURE [dbo].[uspSMCSVDynamicImportProcess]
@ImportId	INT,
	@LogId		INT
AS
BEGIN
	
	--SET QUOTED_IDENTIFIER OFF
	--SET ANSI_NULLS ON
	SET NOCOUNT ON
	--SET ANSI_WARNINGS OFF
	--SET XACT_ABORT ON

	

	DECLARE @Header  table
	(
		id int, 
		sv nvarchar(max) COLLATE Latin1_General_CI_AS
	)
	DECLARE @Value  table
	(
		id int, 
		sv nvarchar(max) COLLATE Latin1_General_CI_AS
	)

	DECLARE @ImportData TABLE
	(
		id					INT IDENTITY(1,1) NOT NULL,
		--strHeader			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
		strData				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
		intSort				INT NOT NULL,
		intLinkedId			INT NOT NULL
	)

	
	DECLARE @HeaderValue NVARCHAR(MAX)
	SELECT 
		@HeaderValue = strData  + ','
		FROM tblSMCSVDynamicImportLogDetail 
			WHERE intCSVDynamicImportLogId = @LogId and intSort = 0



	INSERT INTO @ImportData(strData, intSort, intLinkedId)
	SELECT 
		ISNULL(strData, '') + ','
		,intSort
		,intCSVDynamicImportLogDetailId
		FROM tblSMCSVDynamicImportLogDetail 
			WHERE intCSVDynamicImportLogId = @LogId and intSort > 0


	INSERT INTO @Header(id, sv)
	SELECT RecordKey, Record  
		FROM dbo.fnCFSplitString(@HeaderValue, ',')


	DECLARE @CurrentImportData		INT
	DECLARE @CurrentImportLinked	INT
	DECLARE @CurrentValue			NVARCHAR(MAX)
	DECLARE @command				NVARCHAR(MAX)
	DECLARE @requiredValue			NVARCHAR(MAX)
	DECLARE @ResultMessage			NVARCHAR(MAX)
	DECLARE @ValidationMessageOut	NVARCHAR(MAX)
	DECLARE @ParmDefinition			NVARCHAR(MAX)
	SET @ParmDefinition = N'@ValidationMessage NVARCHAR(MAX) OUTPUT'
	declare @c int 
	set @c = 0
	WHILE EXISTS(SELECT TOP 1 1 FROM @ImportData)
	BEGIN
		set @c = @c + 1
		--print @c
		SET @command = ''
		SET @requiredValue = ''
		SET @ResultMessage = ''
		select @command = strCommand 
			from tblSMCSVDynamicImport 
				where intCSVDynamicImportId = @ImportId

		DELETE FROM @Value


		SELECT TOP 1 @CurrentImportData		= id,
				@CurrentValue				= strData,
				@CurrentImportLinked		=  intLinkedId
			FROM @ImportData
	
		INSERT INTO @Value(id, sv)
		SELECT RecordKey, Record  
			FROM dbo.fnCFSplitString(@CurrentValue, '"')

		UPDATE @Value  SET sv = REPLACE(sv,',','-^-') 
			where sv not like '%,' and sv not like ',%'

		declare @NewLine as nvarchar(max)		
		set @NewLine = ''
		select  @NewLine = COALESCE(ISNULL(@NewLine, ''),',') + sv from @Value
		
		DELETE FROM @Value
		INSERT INTO @Value(id, sv)
		SELECT RecordKey, Record  
			FROM dbo.fnCFSplitString(@NewLine, ',')

	 
		select 
			@requiredValue = COALESCE(@requiredValue + ', ', '') + RTRIM(LTRIM(B.strDisplayName))		
			from tblSMCSVDynamicImportParameter B
				join @Header C
					on B.strDisplayName = C.sv
				join @Value D
					on D.id = C.id
		where B.ysnRequired = 1 and D.sv = '' and B.intCSVDynamicImportId = @ImportId
	

		--SELECT @requiredValue
		
		IF @requiredValue = ''
		BEGIN
			select @command =  (REPLACE(@command, '@' + B.strColumnName + '@' , REPLACE(ISNULL(D.sv, ''), '-^-', ',')  ))
				from tblSMCSVDynamicImportParameter B
					left join @Header C
						on B.strDisplayName = C.sv
					left join @Value D
						on D.id = C.id	
				WHERE B.intCSVDynamicImportId = @ImportId	

			SET @ResultMessage = 'Success'		
			DECLARE @TransactionId NVARCHAR(100)
			SET @TransactionId = 'CUSTOMER_IMPORT'

			--IF @@TRANCOUNT = 0
				--BEGIN TRANSACTION --@TransactionId
			--ELSE
			--System.Data.Entity.TransactionalBehavior.
			--BEGIN TRANSACTION
			BEGIN TRY
	            declare @trancount int;
				set @trancount = @@trancount;   
				if @trancount = 0
					begin transaction
				else
					save transaction @TransactionId;

				--PRINT 
				--SET @TransactionId = 'CUSTOMER_IMPORT' + CAST(NEWID() AS NVARCHAR(50))
				--SAVE TRANSACTION @TransactionId
				--select  @command
				EXEC sp_executesql @command, @ParmDefinition, @ValidationMessage = @ValidationMessageOut OUTPUT

				IF ISNULL(@ValidationMessageOut, '') <> ''
				BEGIN
					SET @ResultMessage = @ResultMessage + ' but with some invalid value : ' + @ValidationMessageOut
				END

				if @trancount = 0   
					COMMIT TRANSACTION


			END TRY
			BEGIN CATCH
				SET @ResultMessage = ERROR_MESSAGE()
				declare @error int, @message varchar(4000), @xstate int;
				select @error = ERROR_NUMBER(),
					@message = ERROR_MESSAGE(), 
					@xstate = XACT_STATE();
				if @xstate = -1
					rollback;
				if @xstate = 1 and @trancount = 0
					rollback
				if @xstate = 1 and @trancount > 0
					rollback transaction @TransactionId;


			END CATCH			
			
		END

		ELSE

		BEGIN
			SET @ResultMessage = 'Required field missing : ' + @requiredValue
		END

	
		DELETE FROM @ImportData WHERE id = @CurrentImportData

		update tblSMCSVDynamicImportLogDetail 
					set strResult = @ResultMessage
				WHERE intCSVDynamicImportLogDetailId = @CurrentImportLinked 
	
	END


	--select * from tblSMCSVDynamicImportLogDetail
	RETURN 0;
END