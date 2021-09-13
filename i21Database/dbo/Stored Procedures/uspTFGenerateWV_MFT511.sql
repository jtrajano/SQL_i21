CREATE PROCEDURE [dbo].[uspTFGenerateWV_MFT511]
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
		
		-- SECTION 1
		, @dblS1L1_A NUMERIC(18, 6) = 0.00
		, @dblS1L1_B NUMERIC(18, 6) = 0.00
		, @dblS1L1_C NUMERIC(18, 6) = 0.00
		, @dblS1L1_D NUMERIC(18, 6) = 0.00

		, @dblS1L2_A NUMERIC(18, 6) = 0.00
		, @dblS1L2_B NUMERIC(18, 6) = 0.00
		, @dblS1L2_C NUMERIC(18, 6) = 0.00
		, @dblS1L2_D NUMERIC(18, 6) = 0.00

		, @dblS1L3_A NUMERIC(18, 6) = 0.00
		, @dblS1L3_B NUMERIC(18, 6) = 0.00
		, @dblS1L3_C NUMERIC(18, 6) = 0.00
		, @dblS1L3_D NUMERIC(18, 6) = 0.00

		, @dblS1L4_A NUMERIC(18, 6) = 0.00
		, @dblS1L4_B NUMERIC(18, 6) = 0.00
		, @dblS1L4_C NUMERIC(18, 6) = 0.00
		, @dblS1L4_D NUMERIC(18, 6) = 0.00

		, @dblS1L5_A NUMERIC(18, 6) = 0.00
		, @dblS1L5_B NUMERIC(18, 6) = 0.00
		, @dblS1L5_C NUMERIC(18, 6) = 0.00
		, @dblS1L5_D NUMERIC(18, 6) = 0.00

		, @dblS1L6_A NUMERIC(18, 6) = 0.00
		, @dblS1L6_B NUMERIC(18, 6) = 0.00
		, @dblS1L6_C NUMERIC(18, 6) = 0.00
		, @dblS1L6_D NUMERIC(18, 6) = 0.00
		, @dblS1L6_E NUMERIC(18, 6) = 0.00

		, @dblS1L7_A NUMERIC(18, 6) = 0.00
		, @dblS1L7_B NUMERIC(18, 6) = 0.00
		, @dblS1L7_C NUMERIC(18, 6) = 0.00
		, @dblS1L7_D NUMERIC(18, 6) = 0.00
		, @dblS1L7_E NUMERIC(18, 6) = 0.00

		, @dblS1L8_A NUMERIC(18, 6) = 0.00
		, @dblS1L8_B NUMERIC(18, 6) = 0.00
		, @dblS1L8_C NUMERIC(18, 6) = 0.00
		, @dblS1L8_D NUMERIC(18, 6) = 0.00

		, @dblS1L9_A NUMERIC(18, 6) = 0.00
		, @dblS1L9_B NUMERIC(18, 6) = 0.00
		, @dblS1L9_C NUMERIC(18, 6) = 0.00
		, @dblS1L9_D NUMERIC(18, 6) = 0.00

		, @dblS1L10_A NUMERIC(18, 6) = 0.00
		, @dblS1L10_B NUMERIC(18, 6) = 0.00
		, @dblS1L10_C NUMERIC(18, 6) = 0.00
		, @dblS1L10_D NUMERIC(18, 6) = 0.00

		, @dblS1L11 NUMERIC(18, 6) = 0.00

		, @dblS1L12 NUMERIC(18, 6) = 0.00

		, @dblS1L12_Rate NUMERIC(18, 6) = 0.00

		, @dblS1L13 NUMERIC(18, 6) = 0.00


		-- SECTION 2
		, @dblS2L1 NUMERIC(18, 6) = 0.00
		, @dblS2L2 NUMERIC(18, 6) = 0.00
		, @dblS2L3 NUMERIC(18, 6) = 0.00
		, @dblS2L4 NUMERIC(18, 6) = 0.00
		, @dblS2L7 NUMERIC(18, 6) = 0.00

		-- SECTION 3
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
		
		-- CONFIG
		, @strS1L4_A_Rate NVARCHAR(20) = NULL
		, @strS1L4_B_Rate NVARCHAR(20) = NULL
		, @strS1L4_C_Rate NVARCHAR(20) = NULL
		, @strS1L4_D_Rate NVARCHAR(20) = NULL

		, @strS1L9_A_Rate NVARCHAR(20) = NULL
		, @strS1L9_B_Rate NVARCHAR(20) = NULL
		, @strS1L9_C_Rate NVARCHAR(20) = NULL
		, @strS1L9_D_Rate NVARCHAR(20) = NULL
		, @strS1L12_Rate NVARCHAR(20) = NULL

		, @strS2L5_Refund NVARCHAR(MAX) = NULL
		, @strS2L6_Credit NVARCHAR(20) = NULL
		, @strS2L7_TransferTo NVARCHAR(20) = NULL
		, @strS2L7_EndDate NVARCHAR(20) = NULL

		, @strS3L2_A_Rate NVARCHAR(20) = NULL
		, @strS3L2_B_Rate NVARCHAR(20) = NULL
		, @strS3L2_C_Rate NVARCHAR(20) = NULL
		, @strS3L2_D_Rate NVARCHAR(20) = NULL

		, @strS3L5_A_Rate NVARCHAR(20) = NULL
		, @strS3L5_B_Rate NVARCHAR(20) = NULL
		, @strS3L5_C_Rate NVARCHAR(20) = NULL
		, @strS3L5_D_Rate NVARCHAR(20) = NULL

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

		-- SECTION 1
		SELECT @dblS1L1_A = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-511' AND strScheduleCode = '7B' and strType = 'Gasoline'
		SELECT @dblS1L1_B = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-511' AND strScheduleCode = '7B' and strType = 'Gasohol'
		SELECT @dblS1L1_C = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-511' AND strScheduleCode = '7B' and strType = 'Undyed Diesel/Kerosene'
		SELECT @dblS1L1_D = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-511' AND strScheduleCode = '7B' and strType = 'Compressed Natural Gas'
		
		SELECT @dblS1L2_A = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-511' AND strScheduleCode = '11A' and strType = 'Gasoline'
		SELECT @dblS1L2_B = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-511' AND strScheduleCode = '11A' and strType = 'Gasohol'
		SELECT @dblS1L2_C = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-511' AND strScheduleCode = '11A' and strType = 'Undyed Diesel/Kerosene'
		SELECT @dblS1L2_D = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-511' AND strScheduleCode = '11A' and strType = 'Compressed Natural Gas'
		
		SET @dblS1L3_A = @dblS1L1_A + @dblS1L2_A
		SET @dblS1L3_B = @dblS1L1_B + @dblS1L2_B
		SET @dblS1L3_C = @dblS1L1_C + @dblS1L2_C
		SET @dblS1L3_D = @dblS1L1_D + @dblS1L2_D

		SELECT @strS1L4_A_Rate = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT511-S1L4A_RATE'
		SELECT @strS1L4_B_Rate = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT511-S1L4B_RATE'
		SELECT @strS1L4_C_Rate = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT511-S1L4C_RATE'
		SELECT @strS1L4_D_Rate = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT511-S1L4D_RATE'

		SET @dblS1L4_A = CONVERT(NUMERIC(18, 6), @strS1L4_A_Rate)
		SET @dblS1L4_B = CONVERT(NUMERIC(18, 6), @strS1L4_B_Rate)
		SET @dblS1L4_C = CONVERT(NUMERIC(18, 6), @strS1L4_C_Rate)
		SET @dblS1L4_D = CONVERT(NUMERIC(18, 6), @strS1L4_D_Rate)

		SET @dblS1L5_A = @dblS1L3_A * @dblS1L4_A
		SET @dblS1L5_B = @dblS1L3_B * @dblS1L4_B
		SET @dblS1L5_C = @dblS1L3_C * @dblS1L4_C
		SET @dblS1L5_D = @dblS1L3_D * @dblS1L4_D

		SELECT @dblS1L6_A = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-511' AND strScheduleCode = '7B' and strType = 'Dyed Diesel/Kerosene'
		SELECT @dblS1L6_B = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-511' AND strScheduleCode = '7B' and strType = 'Propane/LPG'
		SELECT @dblS1L6_C = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-511' AND strScheduleCode = '7B' and strType = 'Aviation Gas'
		SELECT @dblS1L6_D = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-511' AND strScheduleCode = '7B' and strType = 'Aviation Jet Fuel'
		SELECT @dblS1L6_E = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-511' AND strScheduleCode = '7B' and strType = 'LNG'

		SELECT @dblS1L7_A = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-511' AND strScheduleCode = '11A' and strType = 'Dyed Diesel/Kerosene'
		SELECT @dblS1L7_B = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-511' AND strScheduleCode = '11A' and strType = 'Propane/LPG'
		SELECT @dblS1L7_C = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-511' AND strScheduleCode = '11A' and strType = 'Aviation Gas'
		SELECT @dblS1L7_D = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-511' AND strScheduleCode = '11A' and strType = 'Aviation Jet Fuel'
		SELECT @dblS1L7_E = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-511' AND strScheduleCode = '11A' and strType = 'LNG'

		SET @dblS1L8_A = @dblS1L6_A + @dblS1L7_A
		SET @dblS1L8_B = @dblS1L6_B + @dblS1L7_B
		SET @dblS1L8_C = @dblS1L6_C + @dblS1L6_D + @dblS1L7_C + @dblS1L7_D
		SET @dblS1L8_D = @dblS1L6_E + @dblS1L7_E

		SELECT @strS1L9_A_Rate = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT511-S1L9A_RATE'
		SELECT @strS1L9_B_Rate = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT511-S1L9B_RATE'
		SELECT @strS1L9_C_Rate = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT511-S1L9C_RATE'
		SELECT @strS1L9_D_Rate = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT511-S1L9D_RATE'
		SELECT @strS1L12_Rate = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT511-S1L12_LESS_DISCOUNT_RATE'

		SET @dblS1L9_A = CONVERT(NUMERIC(18, 6), @strS1L9_A_Rate)
		SET @dblS1L9_B = CONVERT(NUMERIC(18, 6), @strS1L9_B_Rate)
		SET @dblS1L9_C = CONVERT(NUMERIC(18, 6), @strS1L9_C_Rate)
		SET @dblS1L9_D = CONVERT(NUMERIC(18, 6), @strS1L9_D_Rate)
		SET @dblS1L12_Rate = CONVERT(NUMERIC(18, 6), @strS1L12_Rate)

		SET @dblS1L10_A = @dblS1L8_A * @dblS1L9_A
		SET @dblS1L10_B = @dblS1L8_B * @dblS1L9_B
		SET @dblS1L10_C = @dblS1L8_C * @dblS1L9_C
		SET @dblS1L10_D = @dblS1L8_D * @dblS1L9_D

		SET @dblS1L11 = (@dblS1L5_A + @dblS1L5_B + @dblS1L5_C + @dblS1L5_D) + (@dblS1L10_A + @dblS1L10_B + @dblS1L10_C + @dblS1L10_D)
		SET @dblS1L12 = @dblS1L11 * @dblS1L12_Rate
		SET @dblS1L13 = @dblS1L11 - @dblS1L12


		-- SECTION 2
		SELECT @strS2L5_Refund = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT511-S2L5_REFUND'
		SELECT @strS2L6_Credit = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT511-S2L6_CREDIT'
		SELECT @strS2L7_TransferTo = strConfiguration FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT511-S2L7_CREDIT_TRANSFER_TO'
		SELECT @strS2L7_EndDate = strConfiguration FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT511-S2L7_CREDIT_PERIOD_END_DATE'

		SET @dblS2L1 = @dblS3L7
		SET @dblS2L2 = @dblS1L12
		IF (@dblS2L2 > @dblS2L1) BEGIN SET @dblS2L3 = 0 END
		ELSE BEGIN SET @dblS2L3 = @dblS2L1 - @dblS2L2 END
		IF (@dblS2L1 > @dblS2L2) BEGIN SET @dblS2L4 = 0 END
		ELSE BEGIN SET @dblS2L4 = @dblS2L2 - @dblS2L1 END

		-- SECTION 3
		SELECT @dblS3L1_A = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-511' AND strScheduleCode = '11' and strType = 'Gasoline'
		SELECT @dblS3L1_B = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-511' AND strScheduleCode = '11' and strType = 'Gasohol'
		SELECT @dblS3L1_C = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-511' AND strScheduleCode = '11' and strType = 'Undyed Diesel/Kerosene'
		SELECT @dblS3L1_D = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-511' AND strScheduleCode = '11' and strType = 'Compressed Natural Gas'

		SELECT @strS3L2_A_Rate = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT511-S3L2A_RATE'
		SELECT @strS3L2_B_Rate = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT511-S3L2B_RATE'
		SELECT @strS3L2_C_Rate = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT511-S3L2C_RATE'
		SELECT @strS3L2_D_Rate = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT511-S3L2D_RATE'

		SET @dblS3L2_A = CONVERT(NUMERIC(18, 6), @strS3L2_A_Rate)
		SET @dblS3L2_B = CONVERT(NUMERIC(18, 6), @strS3L2_B_Rate)
		SET @dblS3L2_C = CONVERT(NUMERIC(18, 6), @strS3L2_C_Rate)
		SET @dblS3L2_D = CONVERT(NUMERIC(18, 6), @strS3L2_D_Rate)

		SET @dblS3L3_A = @dblS3L1_A * @dblS3L2_A
		SET @dblS3L3_B = @dblS3L1_B * @dblS3L2_B
		SET @dblS3L3_C = @dblS3L1_C * @dblS3L2_C
		SET @dblS3L3_D = @dblS3L1_D * @dblS3L2_D

		SELECT @dblS3L4_A = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-511' AND strScheduleCode = '11' and strType = 'Dyed Diesel/Kerosene'
		SELECT @dblS3L4_B = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-511' AND strScheduleCode = '11' and strType = 'Propane/LPG'
		SELECT @dblS3L4_C = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-511' AND strScheduleCode = '11' and strType = 'Aviation Gas'
		SELECT @dblS3L4_D = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-511' AND strScheduleCode = '11' and strType = 'Aviation Jet Fuel'
		SELECT @dblS3L4_E = ISNULL(SUM(dblGross),0) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = 'MFT-511' AND strScheduleCode = '11' and strType = 'LNG'

		SELECT @strS3L5_A_Rate = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT511-S3L5A_RATE'
		SELECT @strS3L5_B_Rate = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT511-S3L5B_RATE'
		SELECT @strS3L5_C_Rate = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT511-S3L5C_RATE'
		SELECT @strS3L5_D_Rate = ISNULL(NULLIF(strConfiguration,''), '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'WVMFT511-S3L5D_RATE'

		SET @dblS3L5_A = CONVERT(NUMERIC(18, 6), @strS3L5_A_Rate)
		SET @dblS3L5_B = CONVERT(NUMERIC(18, 6), @strS3L5_B_Rate)
		SET @dblS3L5_C = CONVERT(NUMERIC(18, 6), @strS3L5_C_Rate)
		SET @dblS3L5_D = CONVERT(NUMERIC(18, 6), @strS3L5_D_Rate)
		
		SET @dblS3L6_A = @dblS3L4_A * @dblS3L5_A
		SET @dblS3L6_B = @dblS3L4_B * @dblS3L5_B
		SET @dblS3L6_C = @dblS3L4_C * @dblS3L5_C
		SET @dblS3L6_D = @dblS3L4_D * @dblS3L5_D

		SET @dblS3L7 = (@dblS3L3_A + @dblS3L3_B + @dblS3L3_C + @dblS3L3_D) + (@dblS3L6_A + @dblS3L6_B + @dblS3L6_C + @dblS3L6_D)

	END

	SELECT 
		  dtmFrom = @dtmFrom
		, dtmTo = @dtmTo
		
		-- SECTION 1
		, dblS1L1_A = @dblS1L1_A
		, dblS1L1_B = @dblS1L1_B 
		, dblS1L1_C = @dblS1L1_C 
		, dblS1L1_D = @dblS1L1_D 
		 		   
		, dblS1L2_A = @dblS1L2_A 
		, dblS1L2_B = @dblS1L2_B 
		, dblS1L2_C = @dblS1L2_C 
		, dblS1L2_D = @dblS1L2_D 
		 		   
		, dblS1L3_A = @dblS1L3_A 
		, dblS1L3_B = @dblS1L3_B 
		, dblS1L3_C = @dblS1L3_C 
		, dblS1L3_D = @dblS1L3_D 
		 		   
		, dblS1L4_A = @dblS1L4_A 
		, dblS1L4_B = @dblS1L4_B 
		, dblS1L4_C = @dblS1L4_C 
		, dblS1L4_D = @dblS1L4_D 
		 		   
		, dblS1L5_A = @dblS1L5_A 
		, dblS1L5_B = @dblS1L5_B 
		, dblS1L5_C = @dblS1L5_C 
		, dblS1L5_D = @dblS1L5_D 
		 		   
		, dblS1L6_A = @dblS1L6_A 
		, dblS1L6_B = @dblS1L6_B 
		, dblS1L6_C = @dblS1L6_C 
		, dblS1L6_D = @dblS1L6_D 
		, dblS1L6_E = @dblS1L6_E 
		 		   
		, dblS1L7_A = @dblS1L7_A 
		, dblS1L7_B = @dblS1L7_B 
		, dblS1L7_C = @dblS1L7_C 
		, dblS1L7_D = @dblS1L7_D 
		, dblS1L7_E = @dblS1L7_E 
		 		   
		, dblS1L8_A = @dblS1L8_A 
		, dblS1L8_B = @dblS1L8_B 
		, dblS1L8_C = @dblS1L8_C 
		, dblS1L8_D = @dblS1L8_D 
		 		   
		, dblS1L9_A = @dblS1L9_A 
		, dblS1L9_B = @dblS1L9_B 
		, dblS1L9_C = @dblS1L9_C 
		, dblS1L9_D = @dblS1L9_D 
		 		   
		, dblS1L10_A = @dblS1L10_A
		, dblS1L10_B = @dblS1L10_B
		, dblS1L10_C = @dblS1L10_C
		, dblS1L10_D = @dblS1L10_D
		 		   
		, dblS1L11 = @dblS1L11 	   	 
		, dblS1L12 = @dblS1L12 
		, dblS1L13 = @dblS1L13 
					 

		-- SECTION 2
		, dblS2L1 = @dblS2L1 
		, dblS2L2 = @dblS2L2 
		, dblS2L3 = @dblS2L3 
		, dblS2L4 = @dblS2L4 
		--, dblS2L5 = @dblS2L5 
		--, dblS2L6 = @dblS2L6 
		, dblS2L7 = @dblS2L7 
		  
		-- SECTION
		, dblS3L1_A = @dblS3L1_A 
		, dblS3L1_B = @dblS3L1_B 
		, dblS3L1_C = @dblS3L1_C 
		, dblS3L1_D = @dblS3L1_D 
		  			
		, dblS3L2_A = @dblS3L2_A 
		, dblS3L2_B = @dblS3L2_B 
		, dblS3L2_C = @dblS3L2_C 
		, dblS3L2_D = @dblS3L2_D 
		  			
		, dblS3L3_A = @dblS3L3_A 
		, dblS3L3_B = @dblS3L3_B 
		, dblS3L3_C = @dblS3L3_C 
		, dblS3L3_D = @dblS3L3_D 
		  			
		, dblS3L4_A = @dblS3L4_A 
		, dblS3L4_B = @dblS3L4_B 
		, dblS3L4_C = @dblS3L4_C 
		, dblS3L4_D = @dblS3L4_D 
		, dblS3L4_E = @dblS3L4_E 
		  			
		, dblS3L5_A = @dblS3L5_A 
		, dblS3L5_B = @dblS3L5_B 
		, dblS3L5_C = @dblS3L5_C 
		, dblS3L5_D = @dblS3L5_D 
		  			
		, dblS3L6_A = @dblS3L6_A 
		, dblS3L6_B = @dblS3L6_B 
		, dblS3L6_C = @dblS3L6_C 
		, dblS3L6_D = @dblS3L6_D 
		  
		, dblS3L7 = @dblS3L7 
		  
		-- CONFIG
		, strS1L4_A_Rate = @strS1L4_A_Rate 
		, strS1L4_B_Rate = @strS1L4_B_Rate 
		, strS1L4_C_Rate = @strS1L4_C_Rate 
		, strS1L4_D_Rate = @strS1L4_D_Rate 
		  				 
		, strS1L9_A_Rate = @strS1L9_A_Rate 
		, strS1L9_B_Rate = @strS1L9_B_Rate 
		, strS1L9_C_Rate = @strS1L9_C_Rate 
		, strS1L9_D_Rate = @strS1L9_D_Rate
		, strS1L12_Rate = @strS1L12_Rate

		, strS2L5_Refund = @strS2L5_Refund
		, strS2L6_Credit = @strS2L6_Credit 
		, strS2L7_TransferTo = @strS2L7_TransferTo
		, strS2L7_EndDate = @strS2L7_EndDate

		, strS3L2_A_Rate = @strS3L2_A_Rate 
		, strS3L2_B_Rate = @strS3L2_B_Rate 
		, strS3L2_C_Rate = @strS3L2_C_Rate 
		, strS3L2_D_Rate = @strS3L2_D_Rate 
		  				 
		, strS3L5_A_Rate = @strS3L5_A_Rate 
		, strS3L5_B_Rate = @strS3L5_B_Rate 
		, strS3L5_C_Rate = @strS3L5_C_Rate 
		, strS3L5_D_Rate = @strS3L5_D_Rate 

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