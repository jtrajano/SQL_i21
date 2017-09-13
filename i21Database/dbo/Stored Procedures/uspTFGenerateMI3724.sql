CREATE PROCEDURE [dbo].[uspTFGenerateMI3724]
	@xmlparam NVARCHAR(MAX) = NULL
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

		, dblLine10_Col1 NUMERIC(18,0)
		, dblLine10_Col2 NUMERIC(18,0)
		, dblLine10_Col3 NUMERIC(18,0)
		, dblLine10_Col4 NUMERIC(18,0)
		, dblLine10_Col5 NUMERIC(18,0)
		, dblLine10_Col6 NUMERIC(18,0)

		, dblLine11_Col1 NUMERIC(18,0)
		, dblLine11_Col2 NUMERIC(18,0)
		, dblLine11_Col3 NUMERIC(18,0)
		, dblLine11_Col4 NUMERIC(18,0)
		, dblLine11_Col5 NUMERIC(18,0)
		, dblLine11_Col6 NUMERIC(18,0)

		, dblLine12_Col1 NUMERIC(18,0)
		, dblLine12_Col2 NUMERIC(18,0)
		, dblLine12_Col3 NUMERIC(18,0)
		, dblLine12_Col4 NUMERIC(18,0)
		, dblLine12_Col5 NUMERIC(18,0)
		, dblLine12_Col6 NUMERIC(18,0)
	)

	IF (ISNULL(@xmlparam,'') = '')
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
			EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlparam
		
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

				, @dblLine10_Col1 NUMERIC(18,0)
				, @dblLine10_Col2 NUMERIC(18,0)
				, @dblLine10_Col3 NUMERIC(18,0)
				, @dblLine10_Col4 NUMERIC(18,0)
				, @dblLine10_Col5 NUMERIC(18,0)
				, @dblLine10_Col6 NUMERIC(18,0)

				, @dblLine11_Col1 NUMERIC(18,0)
				, @dblLine11_Col2 NUMERIC(18,0)
				, @dblLine11_Col3 NUMERIC(18,0)
				, @dblLine11_Col4 NUMERIC(18,0)
				, @dblLine11_Col5 NUMERIC(18,0)
				, @dblLine11_Col6 NUMERIC(18,0)

				, @dblLine12_Col1 NUMERIC(18,0)
				, @dblLine12_Col2 NUMERIC(18,0)
				, @dblLine12_Col3 NUMERIC(18,0)
				, @dblLine12_Col4 NUMERIC(18,0)
				, @dblLine12_Col5 NUMERIC(18,0)
				, @dblLine12_Col6 NUMERIC(18,0)


			SELECT @dblLine8_Col1 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '14A' AND strType = 'Gasoline'
			SELECT @dblLine8_Col2 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '14A' AND strType = 'Aviation Gasoline'
			SELECT @dblLine8_Col3 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '14A' AND strType = 'Jet Fuel'
			SELECT @dblLine8_Col4 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '14A' AND strType = 'Undyed Diesel'
			SELECT @dblLine8_Col5 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '14A' AND strType = 'Dyed Diesel'
			SELECT @dblLine8_Col6 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '14A' AND strType = 'Other'

			SELECT @dblLine9_Col1 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '14B' AND strType = 'Gasoline'
			SELECT @dblLine9_Col2 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '14B' AND strType = 'Aviation Gasoline'
			SELECT @dblLine9_Col3 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '14B' AND strType = 'Jet Fuel'
			SELECT @dblLine9_Col4 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '14B' AND strType = 'Undyed Diesel'
			SELECT @dblLine9_Col5 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '14B' AND strType = 'Dyed Diesel'
			SELECT @dblLine9_Col6 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '14B' AND strType = 'Other'

			SELECT @dblLine10_Col1 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '11A' AND strType = 'Gasoline'
			SELECT @dblLine10_Col2 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '11A' AND strType = 'Aviation Gasoline'
			SELECT @dblLine10_Col3 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '11A' AND strType = 'Jet Fuel'
			SELECT @dblLine10_Col4 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '11A' AND strType = 'Undyed Diesel'
			SELECT @dblLine10_Col5 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '11A' AND strType = 'Dyed Diesel'
			SELECT @dblLine10_Col6 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '11A' AND strType = 'Other'

			SELECT @dblLine11_Col1 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '11B' AND strType = 'Gasoline'
			SELECT @dblLine11_Col2 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '11B' AND strType = 'Aviation Gasoline'
			SELECT @dblLine11_Col3 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '11B' AND strType = 'Jet Fuel'
			SELECT @dblLine11_Col4 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '11B' AND strType = 'Undyed Diesel'
			SELECT @dblLine11_Col5 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '11B' AND strType = 'Dyed Diesel'
			SELECT @dblLine11_Col6 = SUM(dblGross) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '11B' AND strType = 'Other'

			SET @dblLine12_Col1 = ISNULL(@dblLine8_Col1, 0) + ISNULL(@dblLine9_Col1, 0) + ISNULL(@dblLine10_Col1, 0) + ISNULL(@dblLine11_Col1, 0)
			SET @dblLine12_Col2 = ISNULL(@dblLine8_Col2, 0) + ISNULL(@dblLine9_Col2, 0) + ISNULL(@dblLine10_Col2, 0) + ISNULL(@dblLine11_Col2, 0)
			SET @dblLine12_Col3 = ISNULL(@dblLine8_Col3, 0) + ISNULL(@dblLine9_Col3, 0) + ISNULL(@dblLine10_Col3, 0) + ISNULL(@dblLine11_Col3, 0)
			SET @dblLine12_Col4 = ISNULL(@dblLine8_Col4, 0) + ISNULL(@dblLine9_Col4, 0) + ISNULL(@dblLine10_Col4, 0) + ISNULL(@dblLine11_Col4, 0)
			SET @dblLine12_Col5 = ISNULL(@dblLine8_Col5, 0) + ISNULL(@dblLine9_Col5, 0) + ISNULL(@dblLine10_Col5, 0) + ISNULL(@dblLine11_Col5, 0)
			SET @dblLine12_Col6 = ISNULL(@dblLine8_Col6, 0) + ISNULL(@dblLine9_Col6, 0) + ISNULL(@dblLine10_Col6, 0) + ISNULL(@dblLine11_Col6, 0)

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
				, @dblLine10_Col1 
				, @dblLine10_Col2 
				, @dblLine10_Col3 
				, @dblLine10_Col4 
				, @dblLine10_Col5 
				, @dblLine10_Col6 
				, @dblLine11_Col1 
				, @dblLine11_Col2 
				, @dblLine11_Col3 
				, @dblLine11_Col4 
				, @dblLine11_Col5 
				, @dblLine11_Col6 
				, @dblLine12_Col1 
				, @dblLine12_Col2 
				, @dblLine12_Col3 
				, @dblLine12_Col4 
				, @dblLine12_Col5 
				, @dblLine12_Col6)

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
