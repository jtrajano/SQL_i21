CREATE PROCEDURE [dbo].[uspTFGenerateRMFT5]
	@XMLParam NVARCHAR(MAX) = NULL

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
		dblLine1_Col1 NUMERIC(18,6)
		, dblLine1_Col2 NUMERIC(18,6)
		, dblLine1_Col3 NUMERIC(18,6)
		, dblLine2a_Col1 NUMERIC(18,6)
		, dblLine2a_Col2 NUMERIC(18,6)
		, dblLine2a_Col3 NUMERIC(18,6)
		, dblLine2b_Col1 NUMERIC(18,6)
		, dblLine2b_Col2 NUMERIC(18,6)
		, dblLine2b_Col3 NUMERIC(18,6)
		, dblLine2c_Col1 NUMERIC(18,6)
		, dblLine2c_Col2 NUMERIC(18,6)
		, dblLine2c_Col3 NUMERIC(18,6)
		, dblLine3_Col1 NUMERIC(18,6)
		, dblLine3_Col2 NUMERIC(18,6)
		, dblLine3_Col3 NUMERIC(18,6)
		, dblLine4_Col1 NUMERIC(18,6)
		, dblLine4_Col2 NUMERIC(18,6)
		, dblLine4_Col3 NUMERIC(18,6)
		, dblLine5_Col1 NUMERIC(18,6)
		, dblLine5_Col2 NUMERIC(18,6)
		, dblLine5_Col3 NUMERIC(18,6)
		, dblLine6_Col1 NUMERIC(18,6)
		, dblLine6_Col2 NUMERIC(18,6)
		, dblLine6_Col3 NUMERIC(18,6)
		, dblLine7_Col1 NUMERIC(18,6)
		, dblLine7_Col2 NUMERIC(18,6)
		, dblLine7_Col3 NUMERIC(18,6)
		, dblLine8a_Col1 NUMERIC(18,6)
		, dblLine8a_Col2 NUMERIC(18,6)
		, dblLine8a_Col3 NUMERIC(18,6)
		, dblLine8b_Col1 NUMERIC(18,6)
		, dblLine8b_Col2 NUMERIC(18,6)
		, dblLine8b_Col3 NUMERIC(18,6)
		, dblLine8c_Col1 NUMERIC(18,6)
		, dblLine8c_Col2 NUMERIC(18,6)
		, dblLine8c_Col3 NUMERIC(18,6)
		, dblLine9_Col1 NUMERIC(18,6)
		, dblLine9_Col2 NUMERIC(18,6)
		, dblLine9_Col3 NUMERIC(18,6)
		, dblLine10a_Col1 NUMERIC(18,6)
		, dblLine10a_Col2 NUMERIC(18,6)
		, dblLine10a_Col3 NUMERIC(18,6)
		, dblLine10b_Col1 NUMERIC(18,6)
		, dblLine10b_Col2 NUMERIC(18,6)
		, dblLine10b_Col3 NUMERIC(18,6)
		, dblLine11_Col1 NUMERIC(18,6)
		, dblLine11_Col2 NUMERIC(18,6)
		, dblLine11_Col3 NUMERIC(18,6)
		, dblLine12_Col1 NUMERIC(18,6)
		, dblLine12_Col2 NUMERIC(18,6)
		, dblLine12_Col3 NUMERIC(18,6)
		, dblLine13_Col1 NUMERIC(18,6)
		, dblLine13_Col2 NUMERIC(18,6)
		, dblLine13_Col3 NUMERIC(18,6)
		, dblLine14_Col1 NUMERIC(18,6)
		, dblLine14_Col2 NUMERIC(18,6)
		, dblLine14_Col3 NUMERIC(18,6)
		, dblLine15_Col1 NUMERIC(18,6)
		, dblLine15_Col2 NUMERIC(18,6)
		, dblLine15_Col3 NUMERIC(18,6)
		, dblLine16_Col1 NUMERIC(18,6)
		, dblLine16_Col2 NUMERIC(18,6)
		, dblLine16_Col3 NUMERIC(18,6)
		, dblLine17_Col1 NUMERIC(18,6)
		, dblLine17_Col2 NUMERIC(18,6)
		, dblLine17_Col3 NUMERIC(18,6)
		, dblLine18_Col1 NUMERIC(18,6)
		, dblLine18_Col2 NUMERIC(18,6)
		, dblLine18_Col3 NUMERIC(18,6)
		, strDistLicense NVARCHAR(50)
		, strSupplierLicense NVARCHAR(50)
		, dtmFrom DATE
		, dtmTo DATE)

	IF (ISNULL(@XMLParam,'') = '')
	BEGIN 
		SELECT * FROM @Output
		RETURN;
	END
	ELSE
	BEGIN
		
		DECLARE @Guid NVARCHAR(250)
		, @FormCodeParam NVARCHAR(MAX)
		, @ScheduleCodeParam NVARCHAR(MAX)
		, @ReportingComponentId NVARCHAR(MAX)

		DECLARE @idoc INT
		EXEC sp_xml_preparedocument @idoc OUTPUT, @XMLParam
		
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

		SELECT TOP 1 @Guid = [from] FROM @Params WHERE [fieldname] = 'Guid'

		DECLARE @dblLine1_Col1 NUMERIC(18,6)
			,@dblLine1_Col2 NUMERIC(18,6)
			,@dblLine1_Col3 NUMERIC(18,6)
			,@dblLine2a_Col1 NUMERIC(18,6)
			,@dblLine2a_Col2 NUMERIC(18,6)
			,@dblLine2a_Col3 NUMERIC(18,6)
			,@dblLine2b_Col1 NUMERIC(18,6)
			,@dblLine2b_Col2 NUMERIC(18,6)
			,@dblLine2b_Col3 NUMERIC(18,6)
			,@dblLine2c_Col1 NUMERIC(18,6)
			,@dblLine2c_Col2 NUMERIC(18,6)
			,@dblLine2c_Col3 NUMERIC(18,6)
			,@dblLine3_Col1 NUMERIC(18,6)
			,@dblLine3_Col2 NUMERIC(18,6)
			,@dblLine3_Col3 NUMERIC(18,6)
			,@dblLine4_Col1 NUMERIC(18,6)
			,@dblLine4_Col2 NUMERIC(18,6)
			,@dblLine4_Col3 NUMERIC(18,6)
			,@dblLine5_Col1 NUMERIC(18,6)
			,@dblLine5_Col2 NUMERIC(18,6)
			,@dblLine5_Col3 NUMERIC(18,6)
			,@dblLine6_Col1 NUMERIC(18,6)
			,@dblLine6_Col2 NUMERIC(18,6)
			,@dblLine6_Col3 NUMERIC(18,6)
			,@dblLine7_Col1 NUMERIC(18,6)
			,@dblLine7_Col2 NUMERIC(18,6)
			,@dblLine7_Col3 NUMERIC(18,6)
			,@dblLine8a_Col1 NUMERIC(18,6)
			,@dblLine8a_Col2 NUMERIC(18,6)
			,@dblLine8a_Col3 NUMERIC(18,6)
			,@dblLine8b_Col1 NUMERIC(18,6)
			,@dblLine8b_Col2 NUMERIC(18,6)
			,@dblLine8b_Col3 NUMERIC(18,6)
			,@dblLine8c_Col1 NUMERIC(18,6)
			,@dblLine8c_Col2 NUMERIC(18,6)
			,@dblLine8c_Col3 NUMERIC(18,6)
			,@dblLine9_Col1 NUMERIC(18,6)
			,@dblLine9_Col2 NUMERIC(18,6)
			,@dblLine9_Col3 NUMERIC(18,6)
			,@dblLine10a_Col1 NUMERIC(18,6)
			,@dblLine10a_Col2 NUMERIC(18,6)
			,@dblLine10a_Col3 NUMERIC(18,6)
			,@dblLine10b_Col1 NUMERIC(18,6)
			,@dblLine10b_Col2 NUMERIC(18,6)
			,@dblLine10b_Col3 NUMERIC(18,6)
			,@dblLine11_Col1 NUMERIC(18,6)
			,@dblLine11_Col2 NUMERIC(18,6)
			,@dblLine11_Col3 NUMERIC(18,6)
			,@dblLine12_Col1 NUMERIC(18,6)
			,@dblLine12_Col2 NUMERIC(18,6)
			,@dblLine12_Col3 NUMERIC(18,6)
			,@dblLine13_Col1 NUMERIC(18,6)
			,@dblLine13_Col2 NUMERIC(18,6)
			,@dblLine13_Col3 NUMERIC(18,6)
			,@dblLine14_Col1 NUMERIC(18,6)
			,@dblLine14_Col2 NUMERIC(18,6)
			,@dblLine14_Col3 NUMERIC(18,6)
			,@dblLine15_Col1 NUMERIC(18,6)
			,@dblLine15_Col2 NUMERIC(18,6)
			,@dblLine15_Col3 NUMERIC(18,6)
			,@dblLine16_Col1 NUMERIC(18,6)
			,@dblLine16_Col2 NUMERIC(18,6)
			,@dblLine16_Col3 NUMERIC(18,6)
			,@dblLine17_Col1 NUMERIC(18,6)
			,@dblLine17_Col2 NUMERIC(18,6)
			,@dblLine17_Col3 NUMERIC(18,6)
			,@dblLine18_Col1 NUMERIC(18,6)
			,@dblLine18_Col2 NUMERIC(18,6)
			,@dblLine18_Col3 NUMERIC(18,6)
			,@strDistLicense NVARCHAR(50)
			,@strSupplierLicense NVARCHAR(50)
			,@dtmFrom DATE
			,@dtmTo DATE

		-- Set value here

		--SET @dblLine1_Col1 = 0.0
		--SET @dblLine1_Col2 = 0.0
		--SET @dblLine1_Col3 = 0.0

		SELECT @dblLine2a_Col1 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'A'
		SELECT @dblLine2a_Col2 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'SA'
		SELECT @dblLine2a_Col3 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'DA'

		SELECT @dblLine2b_Col1 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'E'
		SELECT @dblLine2b_Col2 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'SE'
		--SET @dblLine2b_Col3 = 0.0

		SELECT @dblLine2c_Col1 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'GA-1'
		--SET @dblLine2c_Col2 = 0.0
		--SET @dblLine2c_Col3 = 0.0

		--SET @dblLine3_Col1 = 0.0
		--SET @dblLine3_Col2 = 0.0
		--SET @dblLine3_Col3 = 0.0

		--SET @dblLine4_Col1 = 0.0
		--SET @dblLine4_Col2 = 0.0
		--SET @dblLine4_Col3 = 0.0

		--SET @dblLine5_Col1 = 0.0
		--SET @dblLine5_Col2 = 0.0
		--SET @dblLine5_Col3 = 0.0

		SELECT @dblLine6_Col1 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'B'
		SELECT @dblLine6_Col2 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'SB'
		SELECT @dblLine6_Col3 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'DB'

		SELECT @dblLine7_Col1 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'C'
		SELECT @dblLine7_Col2 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'SC'
		SELECT @dblLine7_Col3 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'DC'

		SELECT @dblLine8a_Col1 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'D'
		SELECT @dblLine8a_Col2 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'SD'
		SELECT @dblLine8a_Col3 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'DD'

		--SET @dblLine8b_Col1 = 0.0
		--SET @dblLine8b_Col2 = 0.0
		SELECT @dblLine8b_Col3 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'DD-1'
		
		--SET @dblLine8c_Col1 = 0.0
		--SET @dblLine8c_Col2 = 0.0
		--SET @dblLine8c_Col3 = 0.0

		--SET @dblLine9_Col1 = 0.0
		--SET @dblLine9_Col2 = 0.0
		--SET @dblLine9_Col3 = 0.0

		--SET @dblLine10a_Col1 = 0.0
		--SET @dblLine10a_Col2 = 0.0
		--SET @dblLine10a_Col3 = 0.0

		--SET @dblLine10b_Col1 = 0.0
		--SET @dblLine10b_Col2 = 0.0
		--SET @dblLine10b_Col3 = 0.0

		--SET @dblLine11_Col1 = 0.0
		--SET @dblLine11_Col2 = 0.0
		--SET @dblLine11_Col3 = 0.0

		--SET @dblLine12_Col1 = 0.0
		--SET @dblLine12_Col2 = 0.0
		--SET @dblLine12_Col3 = 0.0

		--SET @dblLine13_Col1 = 0.0
		--SET @dblLine13_Col2 = 0.0
		--SET @dblLine13_Col3 = 0.0

		--SET @dblLine14_Col1 = 0.0
		--SET @dblLine14_Col2 = 0.0
		--SET @dblLine14_Col3 = 0.0

		--SET @dblLine15_Col1 = 0.0
		--SET @dblLine15_Col2 = 0.0
		--SET @dblLine15_Col3 = 0.0

		--SET @dblLine16_Col1 = 0.0
		--SET @dblLine16_Col2 = 0.0
		--SET @dblLine16_Col3 = 0.0

		SELECT @dblLine17_Col1 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'E'
		SELECT @dblLine17_Col2 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'SE'
		--SET @dblLine17_Col3 = 0.0

		--SET @dblLine18_Col1 = 0.0
		--SET @dblLine18_Col2 = 0.0
		--SET @dblLine18_Col3 = 0.0

		SET @strDistLicense = NULL
		SET @strSupplierLicense = NULL
		SET @dtmFrom = NULL
		SET @dtmTo = NULL
		
		-- INSERT
		INSERT INTO @Output VALUES(
			@dblLine1_Col1
			,@dblLine1_Col2
			,@dblLine1_Col3
			,@dblLine2a_Col1
			,@dblLine2a_Col2
			,@dblLine2a_Col3
			,@dblLine2b_Col1
			,@dblLine2b_Col2
			,@dblLine2b_Col3
			,@dblLine2c_Col1
			,@dblLine2c_Col2
			,@dblLine2c_Col3
			,@dblLine3_Col1
			,@dblLine3_Col2
			,@dblLine3_Col3
			,@dblLine4_Col1
			,@dblLine4_Col2
			,@dblLine4_Col3
			,@dblLine5_Col1
			,@dblLine5_Col2
			,@dblLine5_Col3
			,@dblLine6_Col1
			,@dblLine6_Col2
			,@dblLine6_Col3
			,@dblLine7_Col1
			,@dblLine7_Col2
			,@dblLine7_Col3
			,@dblLine8a_Col1
			,@dblLine8a_Col2
			,@dblLine8a_Col3
			,@dblLine8b_Col1
			,@dblLine8b_Col2
			,@dblLine8b_Col3
			,@dblLine8c_Col1
			,@dblLine8c_Col2
			,@dblLine8c_Col3
			,@dblLine9_Col1
			,@dblLine9_Col2
			,@dblLine9_Col3
			,@dblLine10a_Col1
			,@dblLine10a_Col2
			,@dblLine10a_Col3
			,@dblLine10b_Col1
			,@dblLine10b_Col2
			,@dblLine10b_Col3
			,@dblLine11_Col1
			,@dblLine11_Col2
			,@dblLine11_Col3
			,@dblLine12_Col1
			,@dblLine12_Col2
			,@dblLine12_Col3
			,@dblLine13_Col1
			,@dblLine13_Col2
			,@dblLine13_Col3
			,@dblLine14_Col1
			,@dblLine14_Col2
			,@dblLine14_Col3
			,@dblLine15_Col1
			,@dblLine15_Col2
			,@dblLine15_Col3
			,@dblLine16_Col1
			,@dblLine16_Col2
			,@dblLine16_Col3
			,@dblLine17_Col1
			,@dblLine17_Col2
			,@dblLine17_Col3
			,@dblLine18_Col1
			,@dblLine18_Col2
			,@dblLine18_Col3
			,@strDistLicense
			,@strSupplierLicense
			,@dtmFrom
			,@dtmTo
		)

		SELECT * FROM @Output

		Return;
	END


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