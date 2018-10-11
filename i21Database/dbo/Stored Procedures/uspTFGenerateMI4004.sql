CREATE PROCEDURE [dbo].[uspTFGenerateMI4004]
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

	DECLARE @Output TABLE(
		  dblLine8_Col1 NUMERIC(18,0)
		, dblLine8_Col2 NUMERIC(18,0)
		, dblLine8_Col3 NUMERIC(18,0)
		, dblLine8_Col4 NUMERIC(18,0)
		, dblLine8_Col5 NUMERIC(18,0)
		, dblLine8_Col6 NUMERIC(18,0)
		, dblLine9_Col1 NUMERIC(18,0)
		, dblLine9_Col2 NUMERIC(18,0)
		, dblLine9_Col3 NUMERIC(18,0)
		, dblLine9_Col4 NUMERIC(18,0)
		, dblLine9_Col5 NUMERIC(18,0)
		, dblLine9_Col6 NUMERIC(18,0)
		, dtmFrom DATE
		, dtmTo DATE
	)

	DECLARE @dblLine8_Col1 NUMERIC(18,0)
		, @dblLine8_Col2 NUMERIC(18,0)
		, @dblLine8_Col3 NUMERIC(18,0)
		, @dblLine8_Col4 NUMERIC(18,0)
		, @dblLine8_Col5 NUMERIC(18,0)
		, @dblLine8_Col6 NUMERIC(18,0)
		, @dblLine9_Col1 NUMERIC(18,0)
		, @dblLine9_Col2 NUMERIC(18,0)
		, @dblLine9_Col3 NUMERIC(18,0)
		, @dblLine9_Col4 NUMERIC(18,0)
		, @dblLine9_Col5 NUMERIC(18,0)
		, @dblLine9_Col6 NUMERIC(18,0)

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

		SELECT @dblLine8_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '7A' AND strType = 'Gasoline'
		SELECT @dblLine8_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '7A' AND strType = 'Dyed Diesel'
		SELECT @dblLine8_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '7A' AND strType = 'Undyed Diesel'
		SELECT @dblLine8_Col4 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '7A' AND strType = 'Aviation'
		SELECT @dblLine8_Col5 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '7A' AND strType = 'Jet Fuel'
		SELECT @dblLine8_Col6 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '7A' AND strType = 'Other'

		SELECT @dblLine9_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '7B' AND strType = 'Gasoline'
		SELECT @dblLine9_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '7B' AND strType = 'Dyed Diesel'
		SELECT @dblLine9_Col3 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '7B' AND strType = 'Undyed Diesel'
		SELECT @dblLine9_Col4 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '7B' AND strType = 'Aviation'
		SELECT @dblLine9_Col5 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '7B' AND strType = 'Jet Fuel'
		SELECT @dblLine9_Col6 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '7B' AND strType = 'Other'

		INSERT INTO @Output VALUES(
			  @dblLine8_Col1 
			, @dblLine8_Col2 
			, @dblLine8_Col3 
			, @dblLine8_Col4 
			, @dblLine8_Col5 
			, @dblLine8_Col6 
			, @dblLine9_Col1 
			, @dblLine9_Col2 
			, @dblLine9_Col3 
			, @dblLine9_Col4 
			, @dblLine9_Col5 
			, @dblLine9_Col6 
			, @dtmFrom 
			, @dtmTo)

	END
	
	SELECT * FROM @Output	
	
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