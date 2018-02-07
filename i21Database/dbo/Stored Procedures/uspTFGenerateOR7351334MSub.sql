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
		INSERT INTO @transaction (strFormCode, strScheduleCode, strProductCode, dblReceived )
		SELECT strFormCode, strScheduleCode, strProductCode, dblReceived = SUM(ISNULL(dblQtyShipped, 0.00))
		FROM vyuTFGetTransaction
		WHERE uniqTransactionGuid = @Guid AND strScheduleCode = '2'
		GROUP BY strFormCode, strScheduleCode, strProductCode

		-- Begin/End Inventory
		INSERT INTO @Report
		SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY strOregonFacilityNumber, strProductCode DESC) AS intId, * FROM (
		SELECT B.lineValue AS strLine, 
			Inventory.strOregonFacilityNumber, 
			Inventory.strProductCode,
			CASE WHEN B.lineValue = 'Line 3' THEN Inventory.strProductCode 
				WHEN B.lineValue = 'Line 4' THEN CONVERT(NVARCHAR(30), CONVERT(NUMERIC(18, 0), Inventory.dblBeginInventory)) 
				WHEN B.lineValue = 'Line 7' THEN CONVERT(NVARCHAR(30), CONVERT(NUMERIC(18, 0),Inventory.dblEndInventory)) ELSE NULL END AS data,
			Inventory.dtmBeginDate, 
			Inventory.dtmEndDate
		FROM dbo.vyuTFGetTaxAuthorityBeginEndInventory Inventory
		CROSS JOIN
		 (SELECT A.lineValue FROM (SELECT 'Line 2' AS lineValue
				  UNION ALL SELECT 'Line 4' AS lineValue
                  UNION ALL SELECT 'Line 5' AS lineValue
                  UNION ALL SELECT 'Line 6' AS lineValue
                  UNION ALL SELECT 'Line 7' AS lineValue
				  UNION ALL SELECT 'Line 8' AS lineValue) A) B
         --(SELECT A.lineValue FROM (SELECT 'Line 2' AS lineValue
         --          UNION ALL SELECT 'Line 3' AS lineValue
         --          UNION ALL SELECT 'Line 4' AS lineValue
         --          UNION ALL SELECT 'Line 5' AS lineValue
         --          UNION ALL SELECT 'Line 6' AS lineValue
         --          UNION ALL SELECT 'Line 7' AS lineValue) A) B
		WHERE Inventory.dtmBeginDate <= @dtmFrom AND Inventory.dtmEndDate >= @dtmTo
		) trans

		DECLARE @ReportSummary TFReportOR7351334MSubSummary

		INSERT INTO @ReportSummary (strFacilityNumber, strProductCode, dtmBeginDate, dtmEndDate)
		SELECT DISTINCT strFacilityNumber, strProductCode, dtmBeginDate, dtmEndDate FROM @Report --WHERE strLine = 'Line 5'

		WHILE EXISTS(SELECT TOP 1 1 FROM @ReportSummary) -- LOOP ON INVENTORY RECEIPT ITEM ID/S
		BEGIN
			
			DECLARE @strProductCode NVARCHAR(100) = NULL
			, @intId INT = NULL
			, @dblTotalLine4 NUMERIC(18, 0) = NULL
			, @dblTotalLine5 NUMERIC(18, 0) = NULL
			, @dblTotalLine6 NUMERIC(18, 0) = NULL
			, @dblTotalLine7 NUMERIC(18, 0) = NULL
			, @dblTotalLine8 NUMERIC(18, 0) = NULL
			, @strFacilityNumber NVARCHAR(200) = NULL
			, @dtmBeginDate DATETIME = NULL
			, @dtmEndDate DATETIME = NULL

			SELECT TOP 1 @strFacilityNumber = strFacilityNumber, @strProductCode = strProductCode, @dtmBeginDate = dtmBeginDate, @dtmEndDate = dtmEndDate FROM @ReportSummary

			-- Line 5
			SELECT @dblTotalLine5 = ISNULL(SUM(dblReceived), 0) FROM @transaction WHERE strProductCode = @strProductCode
			UPDATE @Report SET strData = CONVERT(NVARCHAR(30), ISNULL(@dblTotalLine5, 0)) WHERE strFacilityNumber = @strFacilityNumber AND strProductCode = @strProductCode AND dtmBeginDate = @dtmBeginDate AND dtmEndDate = @dtmEndDate AND strLine = 'Line 5'				
			
			-- Line 4
			SELECT  @dblTotalLine4 = SUM(CONVERT(NUMERIC(18, 0),ISNULL(strData,0))) FROM @Report WHERE strFacilityNumber = @strFacilityNumber AND strProductCode = @strProductCode AND dtmBeginDate = @dtmBeginDate AND dtmEndDate = @dtmEndDate AND strLine = 'Line 4'
					
			-- Line 6
			SET @dblTotalLine6 = @dblTotalLine5 + @dblTotalLine4
			UPDATE @Report SET strData = CONVERT(NVARCHAR(30), ISNULL(@dblTotalLine6, 0)) WHERE strFacilityNumber = @strFacilityNumber AND strProductCode = @strProductCode AND dtmBeginDate = @dtmBeginDate AND dtmEndDate = @dtmEndDate AND strLine = 'Line 6'

			-- Get Line 7
			SELECT  @dblTotalLine7 = SUM(CONVERT(NUMERIC(18, 0),ISNULL(strData,0))) FROM @Report WHERE strFacilityNumber = @strFacilityNumber AND strProductCode = @strProductCode AND dtmBeginDate = @dtmBeginDate AND dtmEndDate = @dtmEndDate AND strLine = 'Line 7'

			-- Line 8
			SET @dblTotalLine8 = @dblTotalLine6 - @dblTotalLine7
			UPDATE @Report SET strData = CONVERT(NVARCHAR(30), ISNULL(@dblTotalLine8, 0)) WHERE strFacilityNumber = @strFacilityNumber AND strProductCode = @strProductCode AND dtmBeginDate = @dtmBeginDate AND dtmEndDate = @dtmEndDate AND strLine = 'Line 8'

			DELETE @ReportSummary WHERE strFacilityNumber = @strFacilityNumber AND strProductCode = @strProductCode AND dtmBeginDate = @dtmBeginDate AND dtmEndDate = @dtmEndDate

		END	

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