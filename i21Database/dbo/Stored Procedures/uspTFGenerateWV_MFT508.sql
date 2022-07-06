CREATE PROCEDURE [dbo].[uspTFGenerateWV_MFT508]
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
	DECLARE @dtmFrom DATE 
		, @dtmTo DATE 
		
		, @dblS1L1 NUMERIC(18, 6) = 0.00
		, @dblS1L2 NUMERIC(18, 6) = 0.00
		, @dblS1L3 NUMERIC(18, 6) = 0.00
		, @dblS1L4 NUMERIC(18, 6) = 0.00
		, @dblS1L5 NUMERIC(18, 6) = 0.00
		, @dblS1L6 NUMERIC(18, 6) = 0.00
		, @dblS1L7 NUMERIC(18, 6) = 0.00
		, @dblS1L8 NUMERIC(18, 6) = 0.00
		, @dblS1L9 NUMERIC(18, 6) = 0.00
		, @dblS1L10 NUMERIC(18, 6) = 0.00
		, @dblS1L11 NUMERIC(18, 6) = 0.00
		, @dblS1L12 NUMERIC(18, 6) = 0.00
		, @dblS1L13 NUMERIC(18, 6) = 0.00
		, @dblS1L14 NUMERIC(18, 6) = 0.00
		, @dblS2L1_A NUMERIC(18, 6) = 0.00
		, @dblS2L1_B NUMERIC(18, 6) = 0.00
		, @dblS2L1_C NUMERIC(18, 6) = 0.00
		, @dblS2L1_D NUMERIC(18, 6) = 0.00
		
		, @dblS2L2_A NUMERIC(18, 6) = 0.00	
		, @dblS2L2_B NUMERIC(18, 6) = 0.00
		, @dblS2L2_C NUMERIC(18, 6) = 0.00
		, @dblS2L2_D NUMERIC(18, 6) = 0.00
		, @dblS2L3_A NUMERIC(18, 6) = 0.00
		, @dblS2L3_B NUMERIC(18, 6) = 0.00
		, @dblS2L3_C NUMERIC(18, 6) = 0.00
		, @dblS2L3_D NUMERIC(18, 6) = 0.00
		, @dblS2L4_A NUMERIC(18, 6) = 0.00
		, @dblS2L4_B NUMERIC(18, 6) = 0.00
		, @dblS2L4_C NUMERIC(18, 6) = 0.00
		, @dblS2L4_D NUMERIC(18, 6) = 0.00
		, @dblS2L5_A NUMERIC(18, 6) = 0.00
		, @dblS2L5_B NUMERIC(18, 6) = 0.00
		, @dblS2L5_C NUMERIC(18, 6) = 0.00
		, @dblS2L5_D NUMERIC(18, 6) = 0.00

		, @dblS2L6_A NUMERIC(18, 6) = 0.00
		, @dblS2L6_B NUMERIC(18, 6) = 0.00
		, @dblS2L6_C NUMERIC(18, 6) = 0.00
		, @dblS2L6_D NUMERIC(18, 6) = 0.00
		, @dblS2L6_E NUMERIC(18, 6) = 0.00
		, @dblS2L7_A NUMERIC(18, 6) = 0.00
		, @dblS2L7_B NUMERIC(18, 6) = 0.00
		, @dblS2L7_C NUMERIC(18, 6) = 0.00
		, @dblS2L7_D NUMERIC(18, 6) = 0.00
		, @dblS2L7_E NUMERIC(18, 6) = 0.00
		, @dblS2L8_A NUMERIC(18, 6) = 0.00
		, @dblS2L8_B NUMERIC(18, 6) = 0.00
		, @dblS2L8_C NUMERIC(18, 6) = 0.00
		, @dblS2L8_D NUMERIC(18, 6) = 0.00
		, @dblS2L8_E NUMERIC(18, 6) = 0.00
		, @dblS2L9_A NUMERIC(18, 6) = 0.00
		, @dblS2L9_B NUMERIC(18, 6) = 0.00
		, @dblS2L9_C NUMERIC(18, 6) = 0.00
		, @dblS2L9_D NUMERIC(18, 6) = 0.00
		, @dblS2L10_A NUMERIC(18, 6) = 0.00
		, @dblS2L10_B NUMERIC(18, 6) = 0.00
		, @dblS2L10_C NUMERIC(18, 6) = 0.00
		, @dblS2L10_D NUMERIC(18, 6) = 0.00
		, @dblS2L11_B NUMERIC(18, 6) = 0.00
		, @dblS2L12_B NUMERIC(18, 6) = 0.00
		, @dblS2L13_B NUMERIC(18, 6) = 0.00
		, @dblS2L14_A NUMERIC(18, 6) = 0.00
		, @dblS2L14_B NUMERIC(18, 6) = 0.00
		, @dblS2L14_C NUMERIC(18, 6) = 0.00
		, @dblS2L14_D NUMERIC(18, 6) = 0.00

		, @dblS2L15 NUMERIC(18, 6) = 0.00

		, @dblS3L1_A NUMERIC(18, 6) = 0.00
		, @dblS3L1_B NUMERIC(18, 6) = 0.00
		, @dblS3L1_C NUMERIC(18, 6) = 0.00
		, @dblS3L1_D NUMERIC(18, 6) = 0.00
		, @dblS3L2_A NUMERIC(18, 6) = 0.00
		, @dblS3L2_B NUMERIC(18, 6) = 0.00
		, @dblS3L2_C NUMERIC(18, 6) = 0.00
		, @dblS3L2_D NUMERIC(18, 6) = 0.00
		, @dblS3L3_A NUMERIC(18, 6) = 0.00
		, @dblS3L3_B NUMERIC(18, 6) = 0.00
		, @dblS3L3_C NUMERIC(18, 6) = 0.00
		, @dblS3L3_D NUMERIC(18, 6) = 0.00
		, @dblS3L4_A NUMERIC(18, 6) = 0.00
		, @dblS3L4_B NUMERIC(18, 6) = 0.00
		, @dblS3L4_C NUMERIC(18, 6) = 0.00
		, @dblS3L4_D NUMERIC(18, 6) = 0.00
		, @dblS3L4_E NUMERIC(18, 6) = 0.00	
		, @dblS3L5_A NUMERIC(18, 6) = 0.00
		, @dblS3L5_B NUMERIC(18, 6) = 0.00
		, @dblS3L5_C NUMERIC(18, 6) = 0.00
		, @dblS3L5_D NUMERIC(18, 6) = 0.00
		, @dblS3L6_A NUMERIC(18, 6) = 0.00
		, @dblS3L6_B NUMERIC(18, 6) = 0.00
		, @dblS3L6_C NUMERIC(18, 6) = 0.00
		, @dblS3L6_D NUMERIC(18, 6) = 0.00

		, @dblS3L7 NUMERIC(18, 6) = 0.00

		, @dblS4L1 NUMERIC(18, 6) = 0.00
		, @dblS4L2 NUMERIC(18, 6) = 0.00
		, @dblS4L3 NUMERIC(18, 6) = 0.00
		, @dblS4L4 NUMERIC(18, 6) = 0.00

		, @strS2L4_A_Rate NVARCHAR(20) = NULL
		, @strS2L4_B_Rate NVARCHAR(20) = NULL
		, @strS2L4_C_Rate NVARCHAR(20) = NULL
		, @strS2L4_D_Rate NVARCHAR(20) = NULL

		, @strS2L9_A_Rate NVARCHAR(20) = NULL
		, @strS2L9_B_Rate NVARCHAR(20) = NULL
		, @strS2L9_C_Rate NVARCHAR(20) = NULL
		, @strS2L9_D_Rate NVARCHAR(20) = NULL

		, @strS2L12_B_Rate NVARCHAR(20) = NULL

		, @strS3L2_A_Rate NVARCHAR(20) = NULL
		, @strS3L2_B_Rate NVARCHAR(20) = NULL
		, @strS3L2_C_Rate NVARCHAR(20) = NULL
		, @strS3L2_D_Rate NVARCHAR(20) = NULL

		, @strS3L5_A_Rate NVARCHAR(20) = NULL
		, @strS3L5_B_Rate NVARCHAR(20) = NULL
		, @strS3L5_C_Rate NVARCHAR(20) = NULL
		, @strS3L5_D_Rate NVARCHAR(20) = NULL
		, @strS1L2_Rate NVARCHAR(20) = NULL
		, @dblS1L2_Rate NUMERIC(18, 6) = 0.00
		, @strS1L5 NVARCHAR(20) = NULL
		, @strS1L6 NVARCHAR(20) = NULL
		, @strS1L9 NVARCHAR(20) = NULL
		, @strS1L10 NVARCHAR(20) = NULL
		, @strS2L11_B NVARCHAR(20) = NULL

		, @strS1L5Date NVARCHAR(20) = NULL
		, @strS1L6Date NVARCHAR(20) = NULL
		, @strS1L13 NVARCHAR(20) = NULL
		, @strS1L14 NVARCHAR(20) = NULL

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

		DECLARE @TaxAuthorityId INT
		, @Guid NVARCHAR(100)

		DECLARE @transaction TFReportTransaction

		SELECT TOP 1 @Guid = [from] FROM @Params WHERE [fieldname] = 'strGuid'

		SELECT @dtmFrom = MIN(dtmReportingPeriodBegin) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid
		SELECT @dtmTo = MAX(dtmReportingPeriodEnd) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid

		-- SECTION 2
		SELECT @dblS2L1_A = ISNULL(SUM(dblBillQty),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-508' AND strScheduleCode = '2' and strType = 'Gasoline'
		SELECT @dblS2L1_B = ISNULL(SUM(dblBillQty),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-508' AND strScheduleCode = '2' and strType = 'Gasohol'
		SELECT @dblS2L1_C = ISNULL(SUM(dblBillQty),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-508' AND strScheduleCode = '2' and strType = 'Undyed Diesel/Kerosene'
		SELECT @dblS2L1_D = ISNULL(SUM(dblBillQty),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-508' AND strScheduleCode = '2' and strType = 'Compressed Natural Gas'
		
		SELECT @dblS2L2_A = ISNULL(SUM(dblBillQty),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-508' AND strScheduleCode = '11' and strType = 'Gasoline'
		SELECT @dblS2L2_B = ISNULL(SUM(dblBillQty),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-508' AND strScheduleCode = '11' and strType = 'Gasohol'
		SELECT @dblS2L2_C = ISNULL(SUM(dblBillQty),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-508' AND strScheduleCode = '11' and strType = 'Undyed Diesel/Kerosene'
		SELECT @dblS2L2_D = ISNULL(SUM(dblBillQty),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-508' AND strScheduleCode = '11' and strType = 'Compressed Natural Gas'
		
		SET @dblS2L3_A = @dblS2L1_A + @dblS2L2_A
		SET @dblS2L3_B = @dblS2L1_B + @dblS2L2_B
		SET @dblS2L3_C = @dblS2L1_C + @dblS2L2_C
		SET @dblS2L3_D = @dblS2L1_D + @dblS2L2_D

		SELECT @strS2L4_A_Rate = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT508-S2L4A_RATE'
		SELECT @strS2L4_B_Rate = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT508-S2L4B_RATE'
		SELECT @strS2L4_C_Rate = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT508-S2L4C_RATE'
		SELECT @strS2L4_D_Rate = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT508-S2L4D_RATE'

		SET @dblS2L4_A = CONVERT(NUMERIC(18, 6), @strS2L4_A_Rate)
		SET @dblS2L4_B = CONVERT(NUMERIC(18, 6), @strS2L4_B_Rate)
		SET @dblS2L4_C = CONVERT(NUMERIC(18, 6), @strS2L4_C_Rate)
		SET @dblS2L4_D = CONVERT(NUMERIC(18, 6), @strS2L4_D_Rate)

		SET @dblS2L5_A = @dblS2L3_A * @dblS2L4_A
		SET @dblS2L5_B = @dblS2L3_B * @dblS2L4_B
		SET @dblS2L5_C = @dblS2L3_C * @dblS2L4_C
		SET @dblS2L5_D = @dblS2L3_D * @dblS2L4_D

		SELECT @dblS2L6_A = ISNULL(SUM(dblBillQty),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-508' AND strScheduleCode = '2' and strType = 'Dyed Diesel/Kerosene'
		SELECT @dblS2L6_B = ISNULL(SUM(dblBillQty),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-508' AND strScheduleCode = '2' and strType = 'Propane/LPG'
		SELECT @dblS2L6_C = ISNULL(SUM(dblBillQty),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-508' AND strScheduleCode = '2' and strType = 'Aviation Gas'
		SELECT @dblS2L6_D = ISNULL(SUM(dblBillQty),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-508' AND strScheduleCode = '2' and strType = 'Aviation Jet Fuel'
		SELECT @dblS2L6_E = ISNULL(SUM(dblBillQty),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-508' AND strScheduleCode = '2' and strType = 'LNG'

		SELECT @dblS2L7_A = ISNULL(SUM(dblBillQty),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-508' AND strScheduleCode = '11' and strType = 'Dyed Diesel/Kerosene'
		SELECT @dblS2L7_B = ISNULL(SUM(dblBillQty),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-508' AND strScheduleCode = '11' and strType = 'Propane/LPG'
		SELECT @dblS2L7_C = ISNULL(SUM(dblBillQty),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-508' AND strScheduleCode = '11' and strType = 'Aviation Gas'
		SELECT @dblS2L7_D = ISNULL(SUM(dblBillQty),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-508' AND strScheduleCode = '11' and strType = 'Aviation Jet Fuel'
		SELECT @dblS2L7_E = ISNULL(SUM(dblBillQty),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-508' AND strScheduleCode = '11' and strType = 'LNG'

		SET @dblS2L8_A = @dblS2L6_A + @dblS2L7_A
		SET @dblS2L8_B = @dblS2L6_B + @dblS2L7_B
		SET @dblS2L8_C = @dblS2L6_C + @dblS2L7_C 
		SET @dblS2L8_D = @dblS2L6_D + @dblS2L7_D
		SET @dblS2L8_E = @dblS2L6_E + @dblS2L7_E

		SELECT @strS2L9_A_Rate = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT508-S2L9A_RATE'
		SELECT @strS2L9_B_Rate = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT508-S2L9B_RATE'
		SELECT @strS2L9_C_Rate = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT508-S2L9C_RATE'
		SELECT @strS2L9_D_Rate = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT508-S2L9D_RATE'

		SET @dblS2L9_A = CONVERT(NUMERIC(18, 6), @strS2L9_A_Rate)
		SET @dblS2L9_B = CONVERT(NUMERIC(18, 6), @strS2L9_B_Rate)
		SET @dblS2L9_C = CONVERT(NUMERIC(18, 6), @strS2L9_C_Rate)
		SET @dblS2L9_D = CONVERT(NUMERIC(18, 6), @strS2L9_D_Rate)

		SET @dblS2L10_A = @dblS2L8_A * @dblS2L9_A
		SET @dblS2L10_B = @dblS2L8_B * @dblS2L9_B
		SET @dblS2L10_C = @dblS2L8_C * @dblS2L9_C
		SET @dblS2L10_D = @dblS2L8_D * @dblS2L9_D

		SELECT @strS2L11_B = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT508-S2L11B'
		SET @dblS2L11_B = CONVERT(NUMERIC(18, 6), @strS2L11_B)

		SELECT @strS2L12_B_Rate = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT508-S2L12B_RATE'
		SET @dblS2L12_B = CONVERT(NUMERIC(18, 6), @strS2L12_B_Rate)

		SET @dblS2L13_B = @dblS2L11_B * @dblS2L12_B

		SET @dblS2L14_A = @dblS2L10_A 
		SET @dblS2L14_B = @dblS2L10_B + @dblS2L13_B 
		SET @dblS2L14_C = @dblS2L10_C
		SET @dblS2L14_D = @dblS2L10_D

		SET @dblS2L15 = @dblS2L5_A + @dblS2L5_B + @dblS2L5_C + @dblS2L5_D + @dblS2L14_A + @dblS2L14_B + @dblS2L14_C + @dblS2L14_D
		
		-- SECTION 3
		SELECT @dblS3L1_A = ISNULL(SUM(dblBillQty),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-508' AND strScheduleCode = '11A' and strType = 'Gasoline'
		SELECT @dblS3L1_B = ISNULL(SUM(dblBillQty),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-508' AND strScheduleCode = '11A' and strType = 'Gasohol'
		SELECT @dblS3L1_C = ISNULL(SUM(dblBillQty),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-508' AND strScheduleCode = '11A' and strType = 'Undyed Diesel/Kerosene'
		SELECT @dblS3L1_D = ISNULL(SUM(dblBillQty),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-508' AND strScheduleCode = '11A' and strType = 'Compressed Natural Gas'
	
		SELECT @strS3L2_A_Rate = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT508-S3L2A_RATE'
		SELECT @strS3L2_B_Rate = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT508-S3L2B_RATE'
		SELECT @strS3L2_C_Rate = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT508-S3L2C_RATE'
		SELECT @strS3L2_D_Rate = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT508-S3L2D_RATE'

		SET @dblS3L2_A = CONVERT(NUMERIC(18, 6), @strS3L2_A_Rate)
		SET @dblS3L2_B = CONVERT(NUMERIC(18, 6), @strS3L2_B_Rate)
		SET @dblS3L2_C = CONVERT(NUMERIC(18, 6), @strS3L2_C_Rate)
		SET @dblS3L2_D = CONVERT(NUMERIC(18, 6), @strS3L2_D_Rate)

		SET @dblS3L3_A = @dblS3L1_A * @dblS3L2_A
		SET @dblS3L3_B = @dblS3L1_B * @dblS3L2_B
		SET @dblS3L3_C = @dblS3L1_C * @dblS3L2_C
		SET @dblS3L3_D = @dblS3L1_D * @dblS3L2_D

		SELECT @dblS3L4_A = ISNULL(SUM(dblBillQty),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-508' AND strScheduleCode = '11A' and strType = 'Dyed Diesel/Kerosene'
		SELECT @dblS3L4_B = ISNULL(SUM(dblBillQty),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-508' AND strScheduleCode = '11A' and strType = 'Propane/LPG'
		SELECT @dblS3L4_C = ISNULL(SUM(dblBillQty),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-508' AND strScheduleCode = '11A' and strType = 'Aviation Gas'
		SELECT @dblS3L4_D = ISNULL(SUM(dblBillQty),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-508' AND strScheduleCode = '11A' and strType = 'Aviation Jet Fuel'
		SELECT @dblS3L4_E = ISNULL(SUM(dblBillQty),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-508' AND strScheduleCode = '11A' and strType = 'LNG'

		SELECT @strS3L5_A_Rate = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT508-S3L5A_RATE'
		SELECT @strS3L5_B_Rate = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT508-S3L5B_RATE'
		SELECT @strS3L5_C_Rate = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT508-S3L5C_RATE'
		SELECT @strS3L5_D_Rate = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT508-S3L5D_RATE'

		SET @dblS3L5_A = CONVERT(NUMERIC(18, 6), @strS3L5_A_Rate)
		SET @dblS3L5_B = CONVERT(NUMERIC(18, 6), @strS3L5_B_Rate)
		SET @dblS3L5_C = CONVERT(NUMERIC(18, 6), @strS3L5_C_Rate)
		SET @dblS3L5_D = CONVERT(NUMERIC(18, 6), @strS3L5_D_Rate)


		SET @dblS3L6_A = @dblS3L4_A * @dblS3L5_A
		SET @dblS3L6_B = @dblS3L4_B * @dblS3L5_B
		SET @dblS3L6_C = @dblS3L4_C * @dblS3L5_C
		SET @dblS3L6_D = @dblS3L4_D * @dblS3L5_D

		SET @dblS3L7 = @dblS3L3_A + @dblS3L3_B + @dblS3L3_C + @dblS3L3_D + @dblS3L6_A + @dblS3L6_B + @dblS3L6_C + @dblS3L6_D

		-- SECTION 4
		SET @dblS4L1 = @dblS2L15
		SET @dblS4L2 = @dblS3L7
		SET @dblS4L3 = CASE WHEN @dblS4L2 > @dblS4L1 THEN 0 ELSE  @dblS4L1 - @dblS4L2 END
		SET @dblS4L4 = CASE WHEN @dblS4L1 > @dblS4L2 THEN 0 ELSE  @dblS4L2 - @dblS4L1 END

		-- SECTION 1
		SET @dblS1L1 = @dblS4L3

		SELECT @strS1L2_Rate = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT508-S1L2_RATE'
		SET @dblS1L2_Rate = CONVERT(NUMERIC(18, 6), @strS1L2_Rate)
		SET @dblS1L2 = @dblS1L1 * @dblS1L2_Rate

		SET @dblS1L3 = @dblS1L1 - @dblS1L2
		SET @dblS1L4 = @dblS4L4

		SELECT @strS1L5Date = NULLIF(strConfiguration,'') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT508-S1L5Date'
		SELECT @strS1L6Date = NULLIF(strConfiguration,'') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT508-S1L6Date'

		SELECT @strS1L5 = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT508-S1L5'
		SELECT @strS1L6 = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT508-S1L6'
		SET @dblS1L5 = CONVERT(NUMERIC(18, 6), @strS1L5)
		SET @dblS1L6 = CONVERT(NUMERIC(18, 6), @strS1L6)

		SET @dblS1L7 = @dblS1L4 + @dblS1L5 + @dblS1L6

		SET @dblS1L8 = CASE WHEN @dblS1L7 > @dblS1L3 THEN 0 ELSE @dblS1L3 - @dblS1L7 END

		SELECT @strS1L9 = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT508-S1L9'
		SET @dblS1L9 = CONVERT(NUMERIC(18, 6), @strS1L9)
		
		SELECT @strS1L10 = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT508-S1L10'
		SET @dblS1L10 = CONVERT(NUMERIC(18, 6), @strS1L10)

		SET @dblS1L11 = @dblS1L8 + @dblS1L9 + @dblS1L10

		SET @dblS1L12 = CASE WHEN @dblS1L3 > @dblS1L7 THEN 0 ELSE (@dblS1L7 - @dblS1L3) END

		SELECT @strS1L13 = NULLIF(strConfiguration,'') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT508-S1L13'
		SELECT @strS1L14 = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT508-S1L14'

		SET @dblS1L13 = CASE WHEN @strS1L13 IS NULL THEN @dblS1L12 ELSE CONVERT(NUMERIC(18, 6), ISNULL(@strS1L13, 0)) END
		SET @dblS1L14 = CONVERT(NUMERIC(18, 6), @strS1L14)
	END

	SELECT dtmFrom = @dtmFrom 
		, dtmTo = @dtmTo 
		, dblS1L1  =  @dblS1L1 
		, dblS1L2  =  @dblS1L2 
		, dblS1L3  =  @dblS1L3 
		, dblS1L4  =  @dblS1L4 
		, dblS1L5  =  @dblS1L5 
		, dblS1L6  =  @dblS1L6 
		, dblS1L7  =  @dblS1L7 
		, dblS1L8  =  @dblS1L8 
		, dblS1L9  =  @dblS1L9 
		, dblS1L10  =  @dblS1L10 
		, dblS1L11  =  @dblS1L11 
		, dblS1L12  =  @dblS1L12 
		, dblS1L13  =  @dblS1L13 
		, dblS1L14  =  @dblS1L14 
		, dblS2L1_A  =  @dblS2L1_A 
		, dblS2L1_B  =  @dblS2L1_B 
		, dblS2L1_C  =  @dblS2L1_C 
		, dblS2L1_D  =  @dblS2L1_D 
		, dblS2L2_A  =  @dblS2L2_A 
		, dblS2L2_B  =  @dblS2L2_B 
		, dblS2L2_C  =  @dblS2L2_C 
		, dblS2L2_D  =  @dblS2L2_D 
		, dblS2L3_A  =  @dblS2L3_A 
		, dblS2L3_B  =  @dblS2L3_B 
		, dblS2L3_C  =  @dblS2L3_C 
		, dblS2L3_D  =  @dblS2L3_D 
		, dblS2L4_A  =  @dblS2L4_A 
		, dblS2L4_B  =  @dblS2L4_B 
		, dblS2L4_C  =  @dblS2L4_C 
		, dblS2L4_D  =  @dblS2L4_D 
		, dblS2L5_A  =  @dblS2L5_A 
		, dblS2L5_B  =  @dblS2L5_B 
		, dblS2L5_C  =  @dblS2L5_C 
		, dblS2L5_D  =  @dblS2L5_D 
		, dblS2L6_A  =  @dblS2L6_A 
		, dblS2L6_B  =  @dblS2L6_B 
		, dblS2L6_C  =  @dblS2L6_C 
		, dblS2L6_D  =  @dblS2L6_D 
		, dblS2L6_E  =  @dblS2L6_E 
		, dblS2L7_A  =  @dblS2L7_A 
		, dblS2L7_B  =  @dblS2L7_B 
		, dblS2L7_C  =  @dblS2L7_C 
		, dblS2L7_D  =  @dblS2L7_D 
		, dblS2L7_E  =  @dblS2L7_E 
		, dblS2L8_A  =  @dblS2L8_A 
		, dblS2L8_B  =  @dblS2L8_B 
		, dblS2L8_C  =  @dblS2L8_C 
		, dblS2L8_D  =  @dblS2L8_D 
		, dblS2L8_E  =  @dblS2L8_E 
		, dblS2L9_A  =  @dblS2L9_A 
		, dblS2L9_B  =  @dblS2L9_B 
		, dblS2L9_C  =  @dblS2L9_C 
		, dblS2L9_D  =  @dblS2L9_D

		, dblS2L10_A  =  @dblS2L10_A 
		, dblS2L10_B  =  @dblS2L10_B 
		, dblS2L10_C  =  @dblS2L10_C 
		, dblS2L10_D  =  @dblS2L10_D

		, dblS2L11_B  =  @dblS2L11_B 
		, dblS2L12_B  =  @dblS2L12_B 
		, dblS2L13_B  =  @dblS2L13_B 
		, dblS2L14_A  =  @dblS2L14_A 
		, dblS2L14_B  =  @dblS2L14_B 
		, dblS2L14_C  =  @dblS2L14_C 
		, dblS2L14_D  =  @dblS2L14_D
		, dblS2L15  =  @dblS2L15 
		, dblS3L1_A  =  @dblS3L1_A 
		, dblS3L1_B  =  @dblS3L1_B 
		, dblS3L1_C  =  @dblS3L1_C 
		, dblS3L1_D  =  @dblS3L1_D 
		, dblS3L2_A  =  @dblS3L2_A 
		, dblS3L2_B  =  @dblS3L2_B 
		, dblS3L2_C  =  @dblS3L2_C 
		, dblS3L2_D  =  @dblS3L2_D 
		, dblS3L3_A  =  @dblS3L3_A 
		, dblS3L3_B  =  @dblS3L3_B 
		, dblS3L3_C  =  @dblS3L3_C 
		, dblS3L3_D  =  @dblS3L3_D 
		, dblS3L4_A  =  @dblS3L4_A 
		, dblS3L4_B  =  @dblS3L4_B 
		, dblS3L4_C  =  @dblS3L4_C 
		, dblS3L4_D  =  @dblS3L4_D 
		, dblS3L4_E  =  @dblS3L4_E 
		, dblS3L5_A  =  @dblS3L5_A 
		, dblS3L5_B  =  @dblS3L5_B 
		, dblS3L5_C  =  @dblS3L5_C 
		, dblS3L5_D  =  @dblS3L5_D 
		, dblS3L6_A  =  @dblS3L6_A 
		, dblS3L6_B  =  @dblS3L6_B 
		, dblS3L6_C  =  @dblS3L6_C 
		, dblS3L6_D  =  @dblS3L6_D
		, dblS3L7  =  @dblS3L7 
		, dblS4L1  =  @dblS4L1 
		, dblS4L2  =  @dblS4L2 
		, dblS4L3  =  @dblS4L3 
		, dblS4L4  =  @dblS4L4 
		, strS2L4_A_Rate =  @strS2L4_A_Rate
		, strS2L4_B_Rate =  @strS2L4_B_Rate
		, strS2L4_C_Rate =  @strS2L4_C_Rate
		, strS2L4_D_Rate =  @strS2L4_D_Rate
		, strS2L9_A_Rate =  @strS2L9_A_Rate
		, strS2L9_B_Rate =  @strS2L9_B_Rate
		, strS2L9_C_Rate =  @strS2L9_C_Rate
		, strS2L9_D_Rate =  @strS2L9_D_Rate
		, strS2L12_B_Rate =  @strS2L12_B_Rate
		, strS3L2_A_Rate =  @strS3L2_A_Rate
		, strS3L2_B_Rate =  @strS3L2_B_Rate
		, strS3L2_C_Rate =  @strS3L2_C_Rate
		, strS3L2_D_Rate =  @strS3L2_D_Rate
		, strS3L5_A_Rate =  @strS3L5_A_Rate
		, strS3L5_B_Rate =  @strS3L5_B_Rate
		, strS3L5_C_Rate =  @strS3L5_C_Rate
		, strS3L5_D_Rate =  @strS3L5_D_Rate
		, strS1L2_Rate =  @strS1L2_Rate
		, dblS1L2_Rate  =  @dblS1L2_Rate 
		, strS1L5 =  @strS1L5
		, strS1L6 =  @strS1L6
		, strS1L9 =  @strS1L9
		, strS1L10 =  @strS1L10
		, strS2L11_B = @strS2L11_B
		, strS1L5Date = @strS1L5Date
		, strS1L6Date = @strS1L6Date

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
