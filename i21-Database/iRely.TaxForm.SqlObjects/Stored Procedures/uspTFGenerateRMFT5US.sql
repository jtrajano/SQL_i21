CREATE PROCEDURE [dbo].[uspTFGenerateRMFT5US]
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
		dblLine1_Col1 NUMERIC
		, dblLine1_Col2 NUMERIC
		, dblLine2a_Col1 NUMERIC
		, dblLine2a_Col2 NUMERIC
		, dblLine2b_Col1 NUMERIC
		, dblLine2b_Col2 NUMERIC
		, dblLine3_Col1 NUMERIC
		, dblLine3_Col2 NUMERIC
		, dblLine4_Col1 NUMERIC
		, dblLine4_Col2 NUMERIC
		, dblLine5_Col1 NUMERIC
		, dblLine5_Col2 NUMERIC
		, dblLine6a_Col1 NUMERIC
		, dblLine6b_Col1 NUMERIC
		, dblLine6b_Col2 NUMERIC
		, dblLine6c_Col1 NUMERIC
		, dblLine7_Col1 NUMERIC
		, dblLine7_Col2 NUMERIC
		, dblLine8_Col1 NUMERIC
		, dblLine8_Col2 NUMERIC
		, dblLine9_Col1 NUMERIC
		, dblLine9_Col2 NUMERIC
		, dblLine10_Col1 NUMERIC
		, dblLine10_Col2 NUMERIC
		, dblLine11_Col1 NUMERIC
		, dblLine11_Col2 NUMERIC
		, dblLine12_Col1 NUMERIC
		, dblLine12_Col2 NUMERIC
		, dblLine13_Col1 NUMERIC
		, dblLine13_Col2 NUMERIC
		, dblLine14 NUMERIC
		, dblLine15a NUMERIC(18,2)
		, dblLine15b NUMERIC(18,2)
		, dblLine15c NUMERIC(18,2)
		, dblLine16 NUMERIC(18,2)
		, dblLine17 NUMERIC(18,2)
		, dblLine18 NUMERIC(18,2)
		, dblLine19 NUMERIC(18,2)
		, dblUstRate NUMERIC(18,2)
		, dblEifRate NUMERIC(18,2)
		, dblColDisc NUMERIC(18,2)
		, strRecLicense NVARCHAR(50)
		, dtmFrom DATE
		, dtmTo DATE)

	DECLARE @dblLine1_Col1 NUMERIC =0
		, @dblLine1_Col2 NUMERIC = 0
		, @dblLine2a_Col1 NUMERIC = 0
		, @dblLine2a_Col2 NUMERIC = 0
		, @dblLine2b_Col1 NUMERIC = 0
		, @dblLine2b_Col2 NUMERIC = 0
		, @dblLine3_Col1 NUMERIC = 0
		, @dblLine3_Col2 NUMERIC = 0
		, @dblLine4_Col1 NUMERIC = 0
		, @dblLine4_Col2 NUMERIC = 0
		, @dblLine5_Col1 NUMERIC = 0
		, @dblLine5_Col2 NUMERIC = 0
		, @dblLine6a_Col1 NUMERIC = 0
		, @dblLine6b_Col1 NUMERIC = 0
		, @dblLine6b_Col2 NUMERIC = 0
		, @dblLine6c_Col1 NUMERIC = 0
		, @dblLine7_Col1 NUMERIC = 0
		, @dblLine7_Col2 NUMERIC = 0
		, @dblLine8_Col1 NUMERIC = 0
		, @dblLine8_Col2 NUMERIC = 0
		, @dblLine9_Col1 NUMERIC = 0
		, @dblLine9_Col2 NUMERIC = 0
		, @dblLine10_Col1 NUMERIC = 0
		, @dblLine10_Col2 NUMERIC = 0
		, @dblLine11_Col1 NUMERIC = 0
		, @dblLine11_Col2 NUMERIC = 0
		, @dblLine12_Col1 NUMERIC = 0
		, @dblLine12_Col2 NUMERIC = 0
		, @dblLine13_Col1 NUMERIC = 0
		, @dblLine13_Col2 NUMERIC = 0
		, @dblLine14 NUMERIC = 0
		, @dblLine15a NUMERIC(18,2) = 0
		, @dblLine15b NUMERIC(18,2) = 0
		, @dblLine15c NUMERIC(18,2) = 0
		, @dblLine16 NUMERIC(18,2) = 0
		, @dblLine17 NUMERIC(18,2) = 0
		, @dblLine18 NUMERIC(18,2) = 0
		, @dblLine19 NUMERIC(18,2) = 0
		, @dblUstRate NUMERIC(18,2) = 0
		, @dblEifRate NUMERIC(18,2) = 0
		, @dblColDisc NUMERIC(18,2) = 0
		, @strRecLicense NVARCHAR(50)
		, @dtmFrom DATE 
		, @dtmTo DATE
 
	IF (ISNULL(@xmlParam,'') != '')
	BEGIN

		DECLARE @Guid NVARCHAR(250),
			@idoc INT

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

		SELECT TOP 1 @Guid = [from] FROM @Params WHERE [fieldname] = 'strGuid'


		SELECT @dblUstRate = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(decimal(18,2), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'RMFT-5-US-USTRate'
		SELECT @dblEifRate = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(decimal(18,2), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'RMFT-5-US-EIFRate'
		SELECT @dblColDisc = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(decimal(18,2), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'RMFT-5-US-ColDisc'	
		SELECT @strRecLicense = ISNULL(strConfiguration, '') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'RMFT-5-US-RecLicense'
		SELECT @dtmFrom = MIN(dtmReportingPeriodBegin) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid
		SELECT @dtmTo = MAX(dtmReportingPeriodEnd) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid
	
		-- Line 1
		SELECT @dblLine1_Col1 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC, strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'RMFT-5-US-Line1Col1'
		SELECT @dblLine1_Col2 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC, strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'RMFT-5-US-Line1Col2'

		-- Line 2a
		SELECT @dblLine2a_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode IN ('A','DA','SA')
		SELECT @dblLine2a_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'LA'

		-- Line 2b
		SELECT @dblLine2b_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode IN ('E','SE','LE') AND strType = 'Dyed Diesel'
		SELECT @dblLine2b_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'LE' AND strType = 'Dyed Diesel'

		-- Line 3
		SET @dblLine3_Col1 = ISNULL(@dblLine1_Col1, 0) +  ISNULL(@dblLine2a_Col1, 0) +  ISNULL(@dblLine2b_Col1, 0) 
		SET @dblLine3_Col2 =  ISNULL(@dblLine1_Col2, 0) +  ISNULL(@dblLine2a_Col2, 0) +  ISNULL(@dblLine2b_Col2, 0)

		-- Line 4
		SELECT @dblLine4_Col1 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC, strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'RMFT-5-US-Line4Col1'
		SELECT @dblLine4_Col2 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC, strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'RMFT-5-US-Line4Col2'

		-- Line 5
		SET @dblLine5_Col1 = ISNULL(@dblLine3_Col1, 0) -  ISNULL(@dblLine4_Col1, 0)
		SET @dblLine5_Col2 = ISNULL(@dblLine3_Col2, 0) -  ISNULL(@dblLine4_Col2, 0)

		-- Line 6a
		SELECT @dblLine6a_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'LB' AND strType = 'Diesel Sold to Railroads'
		
		-- Line 6b
		SELECT @dblLine6b_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'LB' AND strType = 'Kerosene Sold to Air Carriers'
		SELECT @dblLine6b_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'LB' AND strType IN ('Aviation Fuel', '1-K Kerosene Sold to Air Carriers')
	
		-- Line 6c
		SELECT @dblLine6c_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'LB' AND strType = 'Diesel Sold to Ships'

		-- Line 7
		SELECT @dblLine7_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode IN ('C','DC','SC')
		SELECT @dblLine7_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'LC'

		-- Line 8
		SELECT @dblLine8_Col1 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode IN ('D','DD','SD')
		SELECT @dblLine8_Col2 = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strScheduleCode = 'LD'

		-- Line 9
		SELECT @dblLine9_Col1 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC, strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'RMFT-5-US-Line9Col1'
		SELECT @dblLine9_Col2 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC, strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'RMFT-5-US-Line9Col2'

		-- Line 10
		SET @dblLine10_Col1 = ISNULL(@dblLine6a_Col1, 0) + ISNULL(@dblLine6b_Col1, 0) + ISNULL(@dblLine6c_Col1, 0) + ISNULL(@dblLine7_Col1, 0) + ISNULL(@dblLine8_Col1, 0) + ISNULL(@dblLine9_Col1, 0)
		SET @dblLine10_Col2 = ISNULL(@dblLine6b_Col2, 0) + ISNULL(@dblLine7_Col2, 0) + ISNULL(@dblLine8_Col2, 0) + ISNULL(@dblLine9_Col2, 0)

		-- Line 11
		SET @dblLine11_Col1 = ISNULL(@dblLine5_Col1, 0) - ISNULL(@dblLine10_Col1, 0)
		SET @dblLine11_Col2 = ISNULL(@dblLine5_Col2, 0) - ISNULL(@dblLine10_Col2, 0)

		-- Line 12
		SET @dblLine12_Col1 = @dblLine2b_Col1
		SET @dblLine12_Col2 = @dblLine2b_Col2

		-- Line 13
		SET @dblLine13_Col1 = ISNULL(@dblLine11_Col1, 0) - ISNULL(@dblLine12_Col1, 0)
		SET @dblLine13_Col2 = ISNULL(@dblLine11_Col2, 0) - ISNULL(@dblLine12_Col2, 0)

		-- Line 14
		SET @dblLine14 = ISNULL(@dblLine13_Col1, 0) + ISNULL(@dblLine13_Col2, 0)

		-- Line 15
		IF  @dblLine14 > 0
		BEGIN
			SET @dblLine15a = @dblLine14 * @dblUstRate
			SET @dblLine15b = @dblLine14 * @dblEifRate
			SET @dblLine15c = @dblLine15a + @dblLine15b
		END

		-- Line 16
		SET @dblLine16 = @dblLine15c * @dblColDisc

		-- Line 17
		SET @dblLine17 = @dblLine15c - @dblLine16

		-- Line 18
		SELECT @dblLine18 = CASE WHEN ISNULL(strConfiguration, '') = '' THEN 0 ELSE CONVERT(NUMERIC(18,2), strConfiguration) END FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'RMFT-5-US-Line18'

		-- Line 19
		SET @dblLine19 = @dblLine17 - @dblLine18

	END

	INSERT INTO @Output VALUES(
		@dblLine1_Col1
		, @dblLine1_Col2
		, @dblLine2a_Col1
		, @dblLine2a_Col2
		, @dblLine2b_Col1
		, @dblLine2b_Col2
		, @dblLine3_Col1
		, @dblLine3_Col2
		, @dblLine4_Col1
		, @dblLine4_Col2
		, @dblLine5_Col1
		, @dblLine5_Col2
		, @dblLine6a_Col1
		, @dblLine6b_Col1
		, @dblLine6b_Col2
		, @dblLine6c_Col1
		, @dblLine7_Col1
		, @dblLine7_Col2
		, @dblLine8_Col1
		, @dblLine8_Col2
		, @dblLine9_Col1
		, @dblLine9_Col2
		, @dblLine10_Col1
		, @dblLine10_Col2
		, @dblLine11_Col1
		, @dblLine11_Col2
		, @dblLine12_Col1
		, @dblLine12_Col2
		, @dblLine13_Col1
		, @dblLine13_Col2
		, @dblLine14
		, @dblLine15a
		, @dblLine15b
		, @dblLine15c
		, @dblLine16
		, @dblLine17
		, @dblLine18
		, @dblLine19
		, @dblUstRate
		, @dblEifRate
		, @dblColDisc
		, @strRecLicense
		, @dtmFrom 
		, @dtmTo)

	SELECT * FROM @Output
	RETURN;

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