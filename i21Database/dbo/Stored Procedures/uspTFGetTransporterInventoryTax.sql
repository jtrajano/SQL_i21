CREATE PROCEDURE [dbo].[uspTFGetTransporterInventoryTax]    
 @Guid NVARCHAR(50)    
 , @ReportingComponentId NVARCHAR(MAX)    
 , @DateFrom DATETIME    
 , @DateTo DATETIME    
 , @IsEdi BIT    
 , @Refresh BIT    
    
AS    
    
SET QUOTED_IDENTIFIER OFF    
SET ANSI_NULLS ON    
SET NOCOUNT ON    
SET XACT_ABORT ON		
SET ANSI_WARNINGS OFF    
    
DECLARE @ErrorMessage NVARCHAR(4000)    
DECLARE @ErrorSeverity INT    
DECLARE @ErrorState INT    
    
BEGIN TRY    
   
   	IF @Refresh = 1
	BEGIN
		DELETE FROM tblTFTransaction
	END

	EXEC uspTFGetTransporterBulkInvoiceTax @Guid = @Guid, @ReportingComponentId = @ReportingComponentId, @DateFrom =@DateFrom , @DateTo =@DateTo  , @IsEdi = @IsEdi, @Refresh =0   , @IsTransporter = 1  
	
	EXEC uspTFGetTransporterCustomerInvoiceTax @Guid = @Guid, @ReportingComponentId = @ReportingComponentId, @DateFrom =@DateFrom , @DateTo =@DateTo  , @IsEdi = @IsEdi, @Refresh =0 , @IsTransporter = 1

   
END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH