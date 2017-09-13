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
