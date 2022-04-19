CREATE PROCEDURE [dbo].[uspCRMDuplicateBrand]
	 @BrandId			INT
	,@NewBrandId		INT				= NULL	OUTPUT
	,@RaiseError		BIT				= 0
	,@ErrorMessage		NVARCHAR(250)	= NULL	OUTPUT
AS

BEGIN

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF

IF @RaiseError = 1
	SET XACT_ABORT ON


DECLARE @InitTranCount INT
		,@Savepoint NVARCHAR(32)

SET @InitTranCount = @@TRANCOUNT
SET @Savepoint = SUBSTRING(('ARDuplicateInvoice' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

IF ISNULL(@RaiseError,0) = 0	
BEGIN
	IF @InitTranCount = 0
		BEGIN TRANSACTION
	ELSE
		SAVE TRANSACTION @Savepoint
END

--Insert Brand
BEGIN TRY
	INSERT INTO tblCRMBrand
	(
		 [strBrand]
		,[strFileType]
		,[strIntegrationObject]
		,[strLoginUrl]
		,[strUserName]
		,[strPassword]
		,[strSendType]
		,[strFrequency]
		,[strDayOfWeek]
		,[strEnvironmentType]
		,[ysnHoldSchedule]
		,[dtmStartTime]
		,[dtmApprovedDate]
		,[intVendorId]
		,[intVendorContactId]
		,[strNote]
		,[intConcurrencyId]
	 )

	 SELECT [strBrand]				= Brand.[strBrand] + ' - Copy'
			,[strFileType]			= Brand.[strFileType]
			,[strIntegrationObject]	= Brand.[strIntegrationObject]
			,[strLoginUrl]			= Brand.[strLoginUrl]
			,[strUserName]			= Brand.[strUserName]
			,[strPassword]			= Brand.[strPassword]
			,[strSendType]			= Brand.[strSendType]
			,[strFrequency]			= Brand.[strFrequency]
			,[strDayOfWeek]			= Brand.[strDayOfWeek]
			,[strEnvironmentType]	= Brand.[strEnvironmentType]
			,[ysnHoldSchedule]		= 1
			,[dtmStartTime]			= Brand.[dtmStartTime]
			,[dtmApprovedDate]		= Brand.[dtmApprovedDate]
			,[intVendorId]			= Brand.[intVendorId]
			,[intVendorContactId]	= Brand.[intVendorContactId]
			,[strNote]			    = Brand.[strNote]
			,[intConcurrencyId]		= 1
	 FROM tblCRMBrand Brand
	 WHERE Brand.intBrandId = @BrandId

	 SET @NewBrandId = SCOPE_IDENTITY()

	 --Insert Brand Mapping

	 INSERT INTO tblCRMBrandFieldMapping
	 (
		 [intBrandId]
		,[strBrandFieldName]
		,[strI21FieldName]
		,[strComment]
		,[strCustomValue]
		,[intConcurrencyId]
	 )
	 SELECT   [intBrandId]			= @NewBrandId
			, [strBrandFieldName]	= BrandFieldMapping.[strBrandFieldName]
			, [strI21FieldName]		= BrandFieldMapping.[strI21FieldName]
			, [strComment]			= BrandFieldMapping.[strComment]
			, [strCustomValue]		= BrandFieldMapping.[strCustomValue]
			, [intConcurrencyId]	= 1
	 FROM tblCRMBrandFieldMapping BrandFieldMapping
	 WHERE BrandFieldMapping.intBrandId = @BrandId

END TRY
BEGIN CATCH
			IF ISNULL(@RaiseError,0) = 0
			BEGIN
				IF @InitTranCount = 0
					IF (XACT_STATE()) <> 0
						ROLLBACK TRANSACTION
				ELSE
					IF (XACT_STATE()) <> 0
						ROLLBACK TRANSACTION @Savepoint
			END

			SET @ErrorMessage = ERROR_MESSAGE();
			IF ISNULL(@RaiseError,0) = 1
				RAISERROR(@ErrorMessage, 16, 1);
			RETURN
END CATCH

IF ISNULL(@RaiseError,0) = 0
BEGIN

	IF @InitTranCount = 0
		BEGIN
			IF (XACT_STATE()) = -1
				ROLLBACK TRANSACTION
			IF (XACT_STATE()) = 1
				COMMIT TRANSACTION
		END		
	ELSE
		BEGIN
			IF (XACT_STATE()) = -1
				ROLLBACK TRANSACTION  @Savepoint
			--IF (XACT_STATE()) = 1
			--	COMMIT TRANSACTION  @Savepoint
		END	
END
	
RETURN 1;

END

GO