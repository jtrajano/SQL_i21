CREATE PROCEDURE [dbo].[uspTFGenerateOR7351334MSub]
	@xmlParam NVARCHAR(MAX) = NULL
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

	DECLARE @Report TFReportOR7351334MSub

	IF (ISNULL(@xmlParam,'') != '')
	BEGIN
		
		DECLARE @idoc INT
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlParam
		
		DECLARE @Params TABLE ([fieldname] NVARCHAR(50)
				, condition NVARCHAR(20)      
				, [from] NVARCHAR(50)
				, [to] NVARCHAR(50)
				, [join] NVARCHAR(10)
				, [begingroup] NVARCHAR(50)
				, [endgroup] NVARCHAR(50) 
				, [datatype] NVARCHAR(50)) 
        
		INSERT INTO @Params
		SELECT *
		FROM OPENXML(@idoc, 'xmlparam/filters/filter',2)
		WITH ([fieldname] NVARCHAR(50)
			, condition NVARCHAR(20)
			, [from] NVARCHAR(50)
			, [to] NVARCHAR(50)
			, [join] NVARCHAR(10)
			, [begingroup] NVARCHAR(50)
			, [endgroup] NVARCHAR(50)
			, [datatype] NVARCHAR(50))

		DECLARE @TaxAuthorityId INT, @Guid NVARCHAR(100)

		DECLARE @transaction TFReportTransaction
		DECLARE @dtmFrom DATETIME = NULL, @dtmTo DATETIME = NULL

		SELECT TOP 1 @Guid = [from] FROM @Params WHERE [fieldname] = 'strGuid'

		SELECT TOP 1 @TaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'OR'

		SELECT @dtmFrom = MIN(dtmReportingPeriodBegin) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid
		SELECT @dtmTo = MAX(dtmReportingPeriodEnd) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid

		-- Transaction
		INSERT INTO @transaction (strFormCode, strScheduleCode, strProductCode, dblReceived, strAltFacilityNumber)
		SELECT trans.strFormCode, trans.strScheduleCode, trans.strProductCode, dblReceived = ISNULL(trans.dblQtyShipped, 0.00), dynamicOR.strDestinationAltFacilityNumber
		FROM vyuTFGetTransaction trans INNER JOIN tblTFTransactionDynamicOR dynamicOR ON dynamicOR.intTransactionId = trans.intTransactionId
		WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '2'

		-- Begin/End Inventory
		INSERT INTO @Report 
		SELECT Inventory.strOregonFacilityNumber, 
			NULL strOperationType,
			Inventory.strProductCode,
			Inventory.dblBeginInventory,
			ISNULL(trans.dblReceived, 0) AS dblPurchase,
			Inventory.dblEndInventory,
			(Inventory.dblBeginInventory + ISNULL(trans.dblReceived, 0)) AS dblAvailable,
			((Inventory.dblBeginInventory + ISNULL(trans.dblReceived, 0)) - Inventory.dblEndInventory) AS dblHandled,
			Inventory.dtmBeginDate, 
			Inventory.dtmEndDate
		FROM dbo.vyuTFGetTaxAuthorityBeginEndInventory Inventory INNER JOIN @transaction trans ON trans.strProductCode = Inventory.strProductCode AND trans.strAltFacilityNumber = Inventory.strOregonFacilityNumber
		WHERE Inventory.dtmBeginDate <= @dtmFrom AND Inventory.dtmEndDate >= @dtmTo	

		DELETE @transaction

	END

	SELECT * FROM @Report

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
	)
END CATCH