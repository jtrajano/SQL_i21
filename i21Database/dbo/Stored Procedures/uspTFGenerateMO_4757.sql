CREATE PROCEDURE [dbo].[uspTFGenerateMO_4757]
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
		
		, @dblLine1_A NUMERIC(18, 6) = 0.00
		, @dblLine1_E NUMERIC(18, 6) = 0.00
		, @dblLine1_F NUMERIC(18, 6) = 0.00		
		, @dblLine2_A NUMERIC(18, 6) = 0.00
		, @dblLine2_C NUMERIC(18, 6) = 0.00
		, @dblLine2_D NUMERIC(18, 6) = 0.00
		, @dblLine2_E NUMERIC(18, 6) = 0.00
		, @dblLine2_F NUMERIC(18, 6) = 0.00
		, @dblLine2_G NUMERIC(18, 6) = 0.00
		, @dblLine3_B NUMERIC(18, 6) = 0.00
		, @dblLine3_F NUMERIC(18, 6) = 0.00
		, @dblLine3_H NUMERIC(18, 6) = 0.00
		, @dblLine4_H NUMERIC(18, 6) = 0.00
		, @dblLine5_A NUMERIC(18, 6) = 0.00
		, @dblLine5_B NUMERIC(18, 6) = 0.00
		, @dblLine5_C NUMERIC(18, 6) = 0.00
		, @dblLine5_D NUMERIC(18, 6) = 0.00
		, @dblLine5_E NUMERIC(18, 6) = 0.00
		, @dblLine5_F NUMERIC(18, 6) = 0.00
		, @dblLine5_G NUMERIC(18, 6) = 0.00
		, @dblLine5_H NUMERIC(18, 6) = 0.00
		, @dblLine6_A NUMERIC(18, 6) = 0.00
		, @dblLine6_B NUMERIC(18, 6) = 0.00
		, @dblLine6_C NUMERIC(18, 6) = 0.00
		, @dblLine6_D NUMERIC(18, 6) = 0.00
		, @dblLine6_E NUMERIC(18, 6) = 0.00
		, @dblLine6_F NUMERIC(18, 6) = 0.00
		, @dblLine6_G NUMERIC(18, 6) = 0.00
		, @dblLine7_A NUMERIC(18, 6) = 0.00
		, @dblLine7_B NUMERIC(18, 6) = 0.00
		, @dblLine7_C NUMERIC(18, 6) = 0.00
		, @dblLine7_D NUMERIC(18, 6) = 0.00
		, @dblLine7_E NUMERIC(18, 6) = 0.00
		, @dblLine7_F NUMERIC(18, 6) = 0.00
		, @dblLine7_G NUMERIC(18, 6) = 0.00
		, @dblLine7_A_Rate NUMERIC(18, 6) = 0.00
		, @dblLine7_B_Rate NUMERIC(18, 6) = 0.00
		, @dblLine7_C_Rate NUMERIC(18, 6) = 0.00
		, @dblLine7_D_Rate NUMERIC(18, 6) = 0.00
		, @dblLine7_E_Rate NUMERIC(18, 6) = 0.00
		, @dblLine7_F_Rate NUMERIC(18, 6) = 0.00
		, @dblLine7_G_Rate NUMERIC(18, 6) = 0.00
		, @strLine7_A_Rate NVARCHAR(20) = NULL
		, @strLine7_B_Rate NVARCHAR(20) = NULL
		, @strLine7_C_Rate NVARCHAR(20) = NULL
		, @strLine7_D_Rate NVARCHAR(20) = NULL
		, @strLine7_E_Rate NVARCHAR(20) = NULL
		, @strLine7_F_Rate NVARCHAR(20) = NULL
		, @strLine7_G_Rate NVARCHAR(20) = NULL
		, @dblLine8_A NUMERIC(18, 6) = 0.00
		, @dblLine8_B NUMERIC(18, 6) = 0.00
		, @dblLine8_C NUMERIC(18, 6) = 0.00
		, @dblLine8_D NUMERIC(18, 6) = 0.00
		, @dblLine8_E NUMERIC(18, 6) = 0.00
		, @dblLine8_F NUMERIC(18, 6) = 0.00
		, @dblLine8_G NUMERIC(18, 6) = 0.00
		, @dblLine9_A NUMERIC(18, 6) = 0.00
		, @dblLine9_B NUMERIC(18, 6) = 0.00
		, @dblLine9_C NUMERIC(18, 6) = 0.00
		, @dblLine9_D NUMERIC(18, 6) = 0.00
		, @dblLine9_E NUMERIC(18, 6) = 0.00
		, @dblLine9_F NUMERIC(18, 6) = 0.00
		, @dblLine9_G NUMERIC(18, 6) = 0.00
		, @dblLine9_H NUMERIC(18, 6) = 0.00

		-- PART 2
		, @dblLine10_A NUMERIC(18, 6) = 0.00
		, @dblLine10_B NUMERIC(18, 6) = 0.00
		, @dblLine10_C NUMERIC(18, 6) = 0.00
		, @dblLine10_D NUMERIC(18, 6) = 0.00
		, @dblLine10_E NUMERIC(18, 6) = 0.00
		, @dblLine10_F NUMERIC(18, 6) = 0.00
		, @dblLine10_G NUMERIC(18, 6) = 0.00
		, @dblLine10_H NUMERIC(18, 6) = 0.00
		, @dblLine10_A_Rate NUMERIC(18, 6) = 0.00
		, @dblLine10_B_Rate NUMERIC(18, 6) = 0.00
		, @dblLine10_C_Rate NUMERIC(18, 6) = 0.00
		, @dblLine10_D_Rate NUMERIC(18, 6) = 0.00
		, @dblLine10_E_Rate NUMERIC(18, 6) = 0.00
		, @dblLine10_F_Rate NUMERIC(18, 6) = 0.00
		, @dblLine10_G_Rate NUMERIC(18, 6) = 0.00
		, @dblLine10_H_Rate NUMERIC(18, 6) = 0.00
		, @strLine10_A_Rate NVARCHAR(20) = NULL
		, @strLine10_B_Rate NVARCHAR(20) = NULL
		, @strLine10_C_Rate NVARCHAR(20) = NULL
		, @strLine10_D_Rate NVARCHAR(20) = NULL
		, @strLine10_E_Rate NVARCHAR(20) = NULL
		, @strLine10_F_Rate NVARCHAR(20) = NULL
		, @strLine10_G_Rate NVARCHAR(20) = NULL
		, @strLine10_H_Rate NVARCHAR(20) = NULL
		, @dblLine11_A NUMERIC(18, 6) = 0.00
		, @dblLine11_B NUMERIC(18, 6) = 0.00
		, @dblLine11_C NUMERIC(18, 6) = 0.00
		, @dblLine11_D NUMERIC(18, 6) = 0.00
		, @dblLine11_E NUMERIC(18, 6) = 0.00
		, @dblLine11_F NUMERIC(18, 6) = 0.00
		, @dblLine11_G NUMERIC(18, 6) = 0.00
		, @dblLine11_H NUMERIC(18, 6) = 0.00
		, @dblLine11_A_Rate NUMERIC(18, 6) = 0.00
		, @dblLine11_B_Rate NUMERIC(18, 6) = 0.00
		, @dblLine11_C_Rate NUMERIC(18, 6) = 0.00
		, @dblLine11_D_Rate NUMERIC(18, 6) = 0.00
		, @dblLine11_E_Rate NUMERIC(18, 6) = 0.00
		, @dblLine11_F_Rate NUMERIC(18, 6) = 0.00
		, @dblLine11_G_Rate NUMERIC(18, 6) = 0.00
		, @dblLine11_H_Rate NUMERIC(18, 6) = 0.00
		, @strLine11_A_Rate NVARCHAR(20) = NULL
		, @strLine11_B_Rate NVARCHAR(20) = NULL
		, @strLine11_C_Rate NVARCHAR(20) = NULL
		, @strLine11_D_Rate NVARCHAR(20) = NULL
		, @strLine11_E_Rate NVARCHAR(20) = NULL
		, @strLine11_F_Rate NVARCHAR(20) = NULL
		, @strLine11_G_Rate NVARCHAR(20) = NULL
		, @strLine11_H_Rate NVARCHAR(20) = NULL
		, @dblLine12_A NUMERIC(18, 6) = 0.00
		, @dblLine12_B NUMERIC(18, 6) = 0.00
		, @dblLine12_C NUMERIC(18, 6) = 0.00
		, @dblLine12_D NUMERIC(18, 6) = 0.00
		, @dblLine12_E NUMERIC(18, 6) = 0.00
		, @dblLine12_F NUMERIC(18, 6) = 0.00
		, @dblLine12_G NUMERIC(18, 6) = 0.00
		, @dblLine12_H NUMERIC(18, 6) = 0.00

		-- PART 3
		, @dblLine13 NUMERIC(18, 6) = 0.00
		, @dblLine14 NUMERIC(18, 6) = 0.00
		, @dblLine14a NUMERIC(18, 6) = 0.00
		, @dblLine15 NUMERIC(18, 6) = 0.00
		, @dblLine16 NUMERIC(18, 6) = 0.00
		, @dblLine16a NUMERIC(18, 6) = 0.00
		, @strLine16a NVARCHAR(20) = NULL
		, @dblLine17 NUMERIC(18, 6) = 0.00
		, @strLine17 NVARCHAR(20) = NULL
		, @dblLine18 NUMERIC(18, 6) = 0.00

		-- PART 4
		, @dblLine19 NUMERIC(18, 6) = 0.00
		, @dblLine20 NUMERIC(18, 6) = 0.00
		, @dblLine21 NUMERIC(18, 6) = 0.00
		, @dblLine22 NUMERIC(18, 6) = 0.00
		, @dblLine22a NUMERIC(18, 6) = 0.00
		, @strLine22a NVARCHAR(20) = NULL
		, @dblLine23 NUMERIC(18, 6) = 0.00
		, @strLine23 NVARCHAR(20) = NULL
		, @dblLine24 NUMERIC(18, 6) = 0.00

		-- PART - 5
		, @dblLine25 NUMERIC(18, 6) = 0.00
		, @dblLine26 NUMERIC(18, 6) = 0.00
		, @dblLine27 NUMERIC(18, 6) = 0.00
		, @dblLine28 NUMERIC(18, 6) = 0.00
		, @dblLine29 NUMERIC(18, 6) = 0.00
		, @dblLine30 NUMERIC(18, 6) = 0.00
		, @strLine30 NVARCHAR(20) = NULL
		, @dblLine31 NUMERIC(18, 6) = 0.00
		, @strLine31 NVARCHAR(20) = NULL
		, @dblLine32 NUMERIC(18, 6) = 0.00
		, @dblLine33 NUMERIC(18, 6) = 0.00
		, @strLine33 NVARCHAR(20) = NULL
		, @dblLine34 NUMERIC(18, 6) = 0.00

		-- RECEIPT LINE
		, @dblReceiptLine1_A NUMERIC(18, 6) = 0.00
		, @dblReceiptLine1_B NUMERIC(18, 6) = 0.00
		, @dblReceiptLine1_C NUMERIC(18, 6) = 0.00
		, @dblReceiptLine1_E NUMERIC(18, 6) = 0.00
		, @dblReceiptLine1_F NUMERIC(18, 6) = 0.00
		, @dblReceiptLine1_G NUMERIC(18, 6) = 0.00
		, @dblReceiptLine1_H NUMERIC(18, 6) = 0.00
		, @dblReceiptLine1_I NUMERIC(18, 6) = 0.00
		, @dblReceiptLine2_A NUMERIC(18, 6) = 0.00
		, @dblReceiptLine2_B NUMERIC(18, 6) = 0.00
		, @dblReceiptLine2_C NUMERIC(18, 6) = 0.00
		, @dblReceiptLine2_E NUMERIC(18, 6) = 0.00
		, @dblReceiptLine2_F NUMERIC(18, 6) = 0.00
		, @dblReceiptLine2_G NUMERIC(18, 6) = 0.00
		, @dblReceiptLine2_H NUMERIC(18, 6) = 0.00
		, @dblReceiptLine2_I NUMERIC(18, 6) = 0.00
		, @dblReceiptLine3_A NUMERIC(18, 6) = 0.00
		, @dblReceiptLine3_B NUMERIC(18, 6) = 0.00
		, @dblReceiptLine3_C NUMERIC(18, 6) = 0.00
		, @dblReceiptLine3_E NUMERIC(18, 6) = 0.00
		, @dblReceiptLine3_F NUMERIC(18, 6) = 0.00
		, @dblReceiptLine3_G NUMERIC(18, 6) = 0.00
		, @dblReceiptLine3_H NUMERIC(18, 6) = 0.00
		, @dblReceiptLine3_I NUMERIC(18, 6) = 0.00
		, @dblReceiptLine4_A NUMERIC(18, 6) = 0.00
		, @dblReceiptLine4_B NUMERIC(18, 6) = 0.00
		, @dblReceiptLine4_C NUMERIC(18, 6) = 0.00
		, @dblReceiptLine4_E NUMERIC(18, 6) = 0.00
		, @dblReceiptLine4_F NUMERIC(18, 6) = 0.00
		, @dblReceiptLine4_G NUMERIC(18, 6) = 0.00
		, @dblReceiptLine4_H NUMERIC(18, 6) = 0.00
		, @dblReceiptLine4_I NUMERIC(18, 6) = 0.00
		, @dblReceiptLine5_A NUMERIC(18, 6) = 0.00
		, @dblReceiptLine5_C NUMERIC(18, 6) = 0.00
		, @dblReceiptLine5_D NUMERIC(18, 6) = 0.00
		, @dblReceiptLine5_E NUMERIC(18, 6) = 0.00
		, @dblReceiptLine5_F NUMERIC(18, 6) = 0.00
		, @dblReceiptLine5_G NUMERIC(18, 6) = 0.00
		, @dblReceiptLine5_H NUMERIC(18, 6) = 0.00
		, @dblReceiptLine5_I NUMERIC(18, 6) = 0.00
		, @dblReceiptLine5a_B NUMERIC(18, 6) = 0.00
		, @dblReceiptLine5a_F NUMERIC(18, 6) = 0.00
		, @dblReceiptLine5a_I NUMERIC(18, 6) = 0.00
		, @dblReceiptLine6_A NUMERIC(18, 6) = 0.00
		, @dblReceiptLine6_E NUMERIC(18, 6) = 0.00
		, @dblReceiptLine6_F NUMERIC(18, 6) = 0.00
		, @dblReceiptLine6_I NUMERIC(18, 6) = 0.00
		, @dblReceiptLine7_F NUMERIC(18, 6) = 0.00
		, @dblReceiptLine8_A NUMERIC(18, 6) = 0.00
		, @dblReceiptLine8_B NUMERIC(18, 6) = 0.00
		, @dblReceiptLine8_C NUMERIC(18, 6) = 0.00
		, @dblReceiptLine8_E NUMERIC(18, 6) = 0.00
		, @dblReceiptLine8_F NUMERIC(18, 6) = 0.00
		, @dblReceiptLine8_H NUMERIC(18, 6) = 0.00
		, @dblReceiptLine9_A NUMERIC(18, 6) = 0.00
		, @dblReceiptLine9_B NUMERIC(18, 6) = 0.00
		, @dblReceiptLine9_C NUMERIC(18, 6) = 0.00
		, @dblReceiptLine9_D NUMERIC(18, 6) = 0.00
		, @dblReceiptLine9_E NUMERIC(18, 6) = 0.00
		, @dblReceiptLine9_F NUMERIC(18, 6) = 0.00
		, @dblReceiptLine9_G NUMERIC(18, 6) = 0.00
		, @dblReceiptLine9_H NUMERIC(18, 6) = 0.00
		, @dblReceiptLine9_I NUMERIC(18, 6) = 0.00

		-- DISBURSEMENT LINE
		, @dblDisbLine10_A NUMERIC(18, 6) = 0.00
		, @dblDisbLine10_B NUMERIC(18, 6) = 0.00	
		, @dblDisbLine10_C NUMERIC(18, 6) = 0.00	
		, @dblDisbLine10_D NUMERIC(18, 6) = 0.00	
		, @dblDisbLine10_E NUMERIC(18, 6) = 0.00	
		, @dblDisbLine10_F NUMERIC(18, 6) = 0.00
		, @dblDisbLine10_G NUMERIC(18, 6) = 0.00
		, @dblDisbLine10_H NUMERIC(18, 6) = 0.00
		, @dblDisbLine10_I NUMERIC(18, 6) = 0.00		
		, @dblDisbLine11_I NUMERIC(18, 6) = 0.00
		, @dblDisbLine12_B NUMERIC(18, 6) = 0.00
		, @dblDisbLine12_F NUMERIC(18, 6) = 0.00
		, @dblDisbLine12_I NUMERIC(18, 6) = 0.00
		, @dblDisbLine13_A NUMERIC(18, 6) = 0.00
		, @dblDisbLine13_B NUMERIC(18, 6) = 0.00
		, @dblDisbLine13_C NUMERIC(18, 6) = 0.00
		, @dblDisbLine13_E NUMERIC(18, 6) = 0.00
		, @dblDisbLine13_F NUMERIC(18, 6) = 0.00
		, @dblDisbLine13_G NUMERIC(18, 6) = 0.00
		, @dblDisbLine13_H NUMERIC(18, 6) = 0.00
		, @dblDisbLine13_I NUMERIC(18, 6) = 0.00
		, @dblDisbLine14_A NUMERIC(18, 6) = 0.00
		, @dblDisbLine14_B NUMERIC(18, 6) = 0.00
		, @dblDisbLine14_C NUMERIC(18, 6) = 0.00
		, @dblDisbLine14_E NUMERIC(18, 6) = 0.00
		, @dblDisbLine14_F NUMERIC(18, 6) = 0.00
		, @dblDisbLine14_G NUMERIC(18, 6) = 0.00
		, @dblDisbLine14_H NUMERIC(18, 6) = 0.00
		, @dblDisbLine14_I NUMERIC(18, 6) = 0.00
		, @dblDisbLine15_F NUMERIC(18, 6) = 0.00
		, @dblDisbLine16_A NUMERIC(18, 6) = 0.00
		, @dblDisbLine16_B NUMERIC(18, 6) = 0.00
		, @dblDisbLine16_C NUMERIC(18, 6) = 0.00
		, @dblDisbLine16_D NUMERIC(18, 6) = 0.00
		, @dblDisbLine16_E NUMERIC(18, 6) = 0.00
		, @dblDisbLine16_F NUMERIC(18, 6) = 0.00
		, @dblDisbLine16_G NUMERIC(18, 6) = 0.00
		, @dblDisbLine16_H NUMERIC(18, 6) = 0.00
		, @dblDisbLine16_I NUMERIC(18, 6) = 0.00
		, @dblDisbLine17_B NUMERIC(18, 6) = 0.00
		, @dblDisbLine17_F NUMERIC(18, 6) = 0.00
		, @dblDisbLine17_I NUMERIC(18, 6) = 0.00
		, @dblDisbLine17a_B NUMERIC(18, 6) = 0.00
		, @dblDisbLine17a_F NUMERIC(18, 6) = 0.00
		, @dblDisbLine17a_I NUMERIC(18, 6) = 0.00
		, @dblDisbLine18_D NUMERIC(18, 6) = 0.00
		, @dblDisbLine18_H NUMERIC(18, 6) = 0.00

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

		-- Line 1
		SELECT @dblReceiptLine1_A = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '1' and strType = 'Gasoline'
		SELECT @dblReceiptLine1_B = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '1' and strType = '100% Ethyl Alcohol'
		SELECT @dblReceiptLine1_C = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '1' and strType = 'Gasohol'
		SELECT @dblReceiptLine1_E = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '1' and strType = 'Aviation Gas'
		SELECT @dblReceiptLine1_F = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '1' and strType = 'Clear Diesel/Clear Kerosene'
		SELECT @dblReceiptLine1_G = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '1' and strType = 'Jet Fuel'
		SELECT @dblReceiptLine1_H = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '1' and strType = 'LNG'
		SELECT @dblReceiptLine1_I = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '1' and strType = 'Dyed Diesel/Dyed Kerosene'

		-- Line 2
		SELECT @dblReceiptLine2_A = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '1B' and strType = 'Gasoline'
		SELECT @dblReceiptLine2_B = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '1B' and strType = '100% Ethyl Alcohol'
		SELECT @dblReceiptLine2_C = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '1B' and strType = 'Gasohol'
		SELECT @dblReceiptLine2_E = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '1B' and strType = 'Aviation Gas'
		SELECT @dblReceiptLine2_F = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '1B' and strType = 'Clear Diesel/Clear Kerosene'
		SELECT @dblReceiptLine2_G = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '1B' and strType = 'Jet Fuel'
		SELECT @dblReceiptLine2_H = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '1B' and strType = 'LNG'
		SELECT @dblReceiptLine2_I = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '1B' and strType = 'Dyed Diesel/Dyed Kerosene'

		-- Line 3
		SELECT @dblReceiptLine3_A = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '1C' and strType = 'Gasoline'
		SELECT @dblReceiptLine3_B = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '1C' and strType = '100% Ethyl Alcohol'
		SELECT @dblReceiptLine3_C = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '1C' and strType = 'Gasohol'
		SELECT @dblReceiptLine3_E = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '1C' and strType = 'Aviation Gas'
		SELECT @dblReceiptLine3_F = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '1C' and strType = 'Clear Diesel/Clear Kerosene'
		SELECT @dblReceiptLine3_G = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '1C' and strType = 'Jet Fuel'
		SELECT @dblReceiptLine3_H = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '1C' and strType = 'LNG'
		SELECT @dblReceiptLine3_I = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '1C' and strType = 'Dyed Diesel/Dyed Kerosene'

		-- Line 4
		SELECT @dblReceiptLine4_A = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '1E' and strType = 'Gasoline'
		SELECT @dblReceiptLine4_B = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '1E' and strType = '100% Ethyl Alcohol'
		SELECT @dblReceiptLine4_C = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '1E' and strType = 'Gasohol'
		SELECT @dblReceiptLine4_E = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '1E' and strType = 'Aviation Gas'
		SELECT @dblReceiptLine4_F = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '1E' and strType = 'Clear Diesel/Clear Kerosene'
		SELECT @dblReceiptLine4_G = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '1E' and strType = 'Jet Fuel'
		SELECT @dblReceiptLine4_H = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '1E' and strType = 'LNG'
		SELECT @dblReceiptLine4_I = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '1E' and strType = 'Dyed Diesel/Dyed Kerosene'

		-- Line 5
		SELECT @dblReceiptLine5_A = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '2A' and strType = 'Gasoline'
		SELECT @dblReceiptLine5_C = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '2A' and strType = 'Gasohol'
		SELECT @dblReceiptLine5_D = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '2A' and strType = 'CNG/Propane'
		SELECT @dblReceiptLine5_E = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '2A' and strType = 'Aviation Gas'
		SELECT @dblReceiptLine5_F = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '2A' and strType = 'Clear Diesel/Clear Kerosene'
		SELECT @dblReceiptLine5_G = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '2A' and strType = 'Jet Fuel'
		SELECT @dblReceiptLine5_H = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '2A' and strType = 'LNG'
		SELECT @dblReceiptLine5_I = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '2A' and strType = 'Dyed Diesel/Dyed Kerosene'


		-- Line 5a
	
		-- Line 6
		SELECT @dblReceiptLine6_A = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '2B' and strType = 'Gasoline'	
		SELECT @dblReceiptLine6_E = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '2B' and strType = 'Aviation Gas'
		SELECT @dblReceiptLine6_F = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '2B' and strType = 'Clear Diesel/Clear Kerosene'
		SELECT @dblReceiptLine6_I = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '2B' and strType = 'Dyed Diesel/Dyed Kerosene'

		-- Line 7
		SELECT @dblReceiptLine7_F = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '2G' and strType = 'Clear Diesel/Clear Kerosene'

		-- Line 8

		-- Line 9
		SET @dblReceiptLine9_A = @dblReceiptLine1_A + @dblReceiptLine2_A + @dblReceiptLine3_A + @dblReceiptLine4_A + @dblReceiptLine5_A + @dblReceiptLine6_A
		SET @dblReceiptLine9_B = @dblReceiptLine1_B + @dblReceiptLine2_B + @dblReceiptLine3_B + @dblReceiptLine4_B + @dblReceiptLine5a_B 
		SET @dblReceiptLine9_C = @dblReceiptLine1_C + @dblReceiptLine2_C + @dblReceiptLine3_C + @dblReceiptLine4_C + @dblReceiptLine5_C 
		SET @dblReceiptLine9_D = @dblReceiptLine5_D
		SET @dblReceiptLine9_E = @dblReceiptLine1_E + @dblReceiptLine2_E + @dblReceiptLine3_E + @dblReceiptLine4_E + @dblReceiptLine5_E + @dblReceiptLine6_E 
		SET @dblReceiptLine9_F = @dblReceiptLine1_F + @dblReceiptLine2_F + @dblReceiptLine3_F + @dblReceiptLine4_F + @dblReceiptLine5_F + @dblReceiptLine5a_F + @dblReceiptLine6_F + @dblReceiptLine7_F + + @dblReceiptLine8_F 
		SET @dblReceiptLine9_G = @dblReceiptLine1_G + @dblReceiptLine2_G + @dblReceiptLine3_G + @dblReceiptLine4_G + @dblReceiptLine5_G
		SET @dblReceiptLine9_H = @dblReceiptLine1_H + @dblReceiptLine2_H + @dblReceiptLine3_H + @dblReceiptLine4_H + @dblReceiptLine5_H
		SET @dblReceiptLine9_I = @dblReceiptLine1_I + @dblReceiptLine2_I + @dblReceiptLine3_I + @dblReceiptLine4_I + @dblReceiptLine5_I + @dblReceiptLine5a_I + @dblReceiptLine6_I


		-- DISBURSEMENT
		-- Line 10


		-- Line 11
		SELECT @dblDisbLine11_I = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '5' and strType = 'Dyed Diesel/Dyed Kerosene'

		-- Line 12
		SELECT @dblDisbLine12_B = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '10G' and strType = '100% Ethyl Alcohol'
		SELECT @dblDisbLine12_F = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '10G' and strType = 'Clear Diesel/Clear Kerosene'
		SELECT @dblDisbLine12_I = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '10G' and strType = 'Dyed Diesel/Dyed Kerosene'

		-- Line 13
		SELECT @dblDisbLine13_A = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode LIKE '7A%' and strType = 'Gasoline'
		SELECT @dblDisbLine13_B = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode LIKE '7A%' and strType = '100% Ethyl Alcohol'
		SELECT @dblDisbLine13_C = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode LIKE '7A%' and strType = 'Gasohol'
		SELECT @dblDisbLine13_E = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode LIKE '7A%' and strType = 'Aviation Gas'
		SELECT @dblDisbLine13_F = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode LIKE '7A%' and strType = 'Clear Diesel/Clear Kerosene'
		SELECT @dblDisbLine13_G = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode LIKE '7A%' and strType = 'Jet Fuel'
		SELECT @dblDisbLine13_H = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode LIKE '7A%' and strType = 'LNG'
		SELECT @dblDisbLine13_I = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode LIKE '7A%' and strType = 'Dyed Diesel/Dyed Kerosene'

		-- Line 14
		SELECT @dblDisbLine14_A = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode LIKE '7B%' and strType = 'Gasoline'
		SELECT @dblDisbLine14_B = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode LIKE '7B%' and strType = '100% Ethyl Alcohol'
		SELECT @dblDisbLine14_C = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode LIKE '7B%' and strType = 'Gasohol'
		SELECT @dblDisbLine14_E = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode LIKE '7B%' and strType = 'Aviation Gas'
		SELECT @dblDisbLine14_F = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode LIKE '7B%' and strType = 'Clear Diesel/Clear Kerosene'
		SELECT @dblDisbLine14_G = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode LIKE '7B%' and strType = 'Jet Fuel'
		SELECT @dblDisbLine14_H = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode LIKE '7B%' and strType = 'LNG'
		SELECT @dblDisbLine14_I = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode LIKE '7B%' and strType = 'Dyed Diesel/Dyed Kerosene'

		-- Line 15
		SELECT @dblDisbLine14_F = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '10J' and strType = 'Clear Diesel/Clear Kerosene'

		-- Line 16

		-- Line 17
		SELECT @dblDisbLine17_B = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '5W' and strType = '100% Ethyl Alcohol'
		SELECT @dblDisbLine17_F = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '5W' and strType = 'Clear Diesel/Clear Kerosene'
		SELECT @dblDisbLine17_I = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '5W' and strType = 'Dyed Diesel/Dyed Kerosene'

		-- Line 17a
		SELECT @dblDisbLine17a_B = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '10A' and strType = '100% Ethyl Alcohol'
		SELECT @dblDisbLine17a_F = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '10A' and strType = 'Clear Diesel/Clear Kerosene'
		SELECT @dblDisbLine17a_I = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '10A' and strType = 'Dyed Diesel/Dyed Kerosene'

		-- Line 18
		SELECT @dblDisbLine18_D = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '10A' and strType = 'CNG/Propane'
		SELECT @dblDisbLine18_H = SUM(ISNULL(dblGross,0)) FROM vyuTFGetTransaction WHERE uniqTransactionGuid = @Guid AND strFormCode = '4757' AND strScheduleCode = '10A' and strType = 'LNG'


		-- Page 1
		-- Part 1
		SET @dblLine1_A = @dblReceiptLine6_A 
		SET @dblLine1_E = @dblReceiptLine6_E
		SET @dblLine1_F = @dblReceiptLine6_F
		SET @dblLine2_A = @dblReceiptLine5_A
		SET @dblLine2_C = @dblReceiptLine5_C
		SET @dblLine2_D = @dblReceiptLine5_D
		SET @dblLine2_E = @dblReceiptLine5_E
		SET @dblLine2_F = @dblReceiptLine5_F
		SET @dblLine2_G = @dblReceiptLine5_G
		SET @dblLine3_B = @dblDisbLine17_B 
		SET @dblLine3_F = @dblDisbLine17_F
		SET @dblLine3_H = @dblDisbLine17_I
		SET @dblLine4_H = @dblDisbLine11_I
		SET @dblLine5_A = @dblLine1_A + @dblLine2_A 
		SET @dblLine5_B = @dblLine3_B 
		SET @dblLine5_C = @dblLine2_C
		SET @dblLine5_D = @dblLine2_D
		SET @dblLine5_E = @dblLine1_E + @dblLine2_E
		SET @dblLine5_F = @dblLine1_F + @dblLine2_F + @dblLine3_F
		SET @dblLine5_G = @dblLine2_G
		SET @dblLine5_H = @dblLine3_H + @dblLine4_H
		
		SET @dblLine6_A = @dblDisbLine14_A
		SET @dblLine6_B = @dblDisbLine14_B
		SET @dblLine6_C = @dblDisbLine14_C
		SET @dblLine6_E = @dblDisbLine14_E
		SET @dblLine6_F = @dblDisbLine14_F 
		SET @dblLine6_G = @dblDisbLine14_H

		SELECT @strLine7_A_Rate = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MO4757-Ln7a'
		SELECT @strLine7_B_Rate = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MO4757-Ln7b'
		SELECT @strLine7_C_Rate = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MO4757-Ln7c'
		SELECT @strLine7_D_Rate = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MO4757-Ln7d'
		SELECT @strLine7_E_Rate = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MO4757-Ln7e'
		SELECT @strLine7_F_Rate = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MO4757-Ln7f'
		SELECT @strLine7_G_Rate = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MO4757-Ln7g'

		SET @dblLine7_A_Rate = CONVERT(NUMERIC(18, 6), @strLine7_A_Rate)
		SET @dblLine7_B_Rate = CONVERT(NUMERIC(18, 6), @strLine7_B_Rate)
		SET @dblLine7_C_Rate = CONVERT(NUMERIC(18, 6), @strLine7_C_Rate)
		SET @dblLine7_D_Rate = CONVERT(NUMERIC(18, 6), @strLine7_D_Rate)
		SET @dblLine7_E_Rate = CONVERT(NUMERIC(18, 6), @strLine7_E_Rate)
		SET @dblLine7_F_Rate = CONVERT(NUMERIC(18, 6), @strLine7_F_Rate)
		SET @dblLine7_G_Rate = CONVERT(NUMERIC(18, 6), @strLine7_G_Rate)

		SET @dblLine7_A = @dblLine6_A * @dblLine7_A_Rate
		SET @dblLine7_B = @dblLine6_B * @dblLine7_B_Rate
		SET @dblLine7_C = @dblLine6_C * @dblLine7_C_Rate
		SET @dblLine7_D = @dblLine6_D * @dblLine7_D_Rate
		SET @dblLine7_E = @dblLine6_E * @dblLine7_E_Rate
		SET @dblLine7_F = @dblLine6_F * @dblLine7_F_Rate
		SET @dblLine7_G = @dblLine6_G * @dblLine7_G_Rate

		SET @dblLine8_A = @dblLine6_A - @dblLine7_A
		SET @dblLine8_B = @dblLine6_B - @dblLine7_B
		SET @dblLine8_C = @dblLine6_C - @dblLine7_C
		SET @dblLine8_D = @dblLine6_D - @dblLine7_D
		SET @dblLine8_E = @dblLine6_E - @dblLine7_E
		SET @dblLine8_F = @dblLine6_F - @dblLine7_F
		SET @dblLine8_G = @dblLine6_G - @dblLine7_G

		SET @dblLine9_A = @dblLine5_A - @dblLine8_A
		SET @dblLine9_B = @dblLine5_B - @dblLine8_B
		SET @dblLine9_C = @dblLine5_C - @dblLine8_C
		SET @dblLine9_D = @dblLine5_D - @dblLine8_D
		SET @dblLine9_E = @dblLine5_E - @dblLine8_E
		SET @dblLine9_F = @dblLine5_F - @dblLine8_F
		SET @dblLine9_G = @dblLine5_G - @dblLine8_G

		-- PART 2
		SELECT @strLine10_A_Rate = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MO4757-Ln10a'
		SELECT @strLine10_B_Rate = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MO4757-Ln10b'
		SELECT @strLine10_C_Rate = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MO4757-Ln10c'
		SELECT @strLine10_D_Rate = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MO4757-Ln10d'
		SELECT @strLine10_E_Rate = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MO4757-Ln10e'
		SELECT @strLine10_F_Rate = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MO4757-Ln10f'
		SELECT @strLine10_G_Rate = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MO4757-Ln10g'

		SET @strLine10_A_Rate = CONVERT(NUMERIC(18, 6), @strLine10_A_Rate)
		SET @strLine10_B_Rate = CONVERT(NUMERIC(18, 6), @strLine10_B_Rate)
		SET @strLine10_C_Rate = CONVERT(NUMERIC(18, 6), @strLine10_C_Rate)
		SET @dblLine10_D_Rate = CONVERT(NUMERIC(18, 6), @strLine10_D_Rate)
		SET @dblLine10_E_Rate = CONVERT(NUMERIC(18, 6), @strLine10_E_Rate)
		SET @dblLine10_F_Rate = CONVERT(NUMERIC(18, 6), @strLine10_F_Rate)
		SET @dblLine10_G_Rate = CONVERT(NUMERIC(18, 6), @strLine10_G_Rate)

		SET @dblLine10_A = @dblLine9_A * @strLine10_A_Rate
		SET @dblLine10_B = @dblLine9_B * @strLine10_B_Rate
		SET @dblLine10_C = @dblLine9_C * @strLine10_C_Rate
		SET @dblLine10_D = @dblLine9_D * @strLine10_D_Rate
		SET @dblLine10_E = @dblLine9_E * @strLine10_E_Rate
		SET @dblLine10_F = @dblLine9_F * @strLine10_F_Rate
		SET @dblLine10_G = @dblLine9_G * @strLine10_G_Rate

		SELECT @strLine11_A_Rate = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MO4757-Ln11a'
		SELECT @strLine11_B_Rate = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MO4757-Ln11b'
		SELECT @strLine11_C_Rate = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MO4757-Ln11c'
		SELECT @strLine11_D_Rate = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MO4757-Ln11d'
		SELECT @strLine11_E_Rate = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MO4757-Ln11e'
		SELECT @strLine11_F_Rate = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MO4757-Ln11f'
		SELECT @strLine11_G_Rate = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MO4757-Ln11g'

		SET @dblLine11_A_Rate = CONVERT(NUMERIC(18, 6), @strLine11_A_Rate)
		SET @dblLine11_B_Rate = CONVERT(NUMERIC(18, 6), @strLine11_B_Rate)
		SET @dblLine11_C_Rate = CONVERT(NUMERIC(18, 6), @strLine11_C_Rate)
		SET @dblLine11_D_Rate = CONVERT(NUMERIC(18, 6), @strLine11_D_Rate)
		SET @dblLine11_E_Rate = CONVERT(NUMERIC(18, 6), @strLine11_E_Rate)
		SET @dblLine11_F_Rate = CONVERT(NUMERIC(18, 6), @strLine11_F_Rate)
		SET @dblLine11_G_Rate = CONVERT(NUMERIC(18, 6), @strLine11_G_Rate)

		SET @dblLine12_A = @dblLine10_A - @dblLine11_A_Rate
		SET @dblLine12_B = @dblLine10_B - @dblLine11_B_Rate
		SET @dblLine12_C = @dblLine10_C - @dblLine11_C_Rate
		SET @dblLine12_D = @dblLine10_D - @dblLine11_D_Rate
		SET @dblLine12_E = @dblLine10_E - @dblLine11_E_Rate
		SET @dblLine12_F = @dblLine10_F - @dblLine11_F_Rate
		SET @dblLine12_G = @dblLine10_G - @dblLine11_G_Rate

		-- PART 3
		SET @dblLine13 = (@dblReceiptLine5_A + @dblReceiptLine5_C + @dblReceiptLine5_D + @dblReceiptLine5_E + @dblReceiptLine5_F + @dblReceiptLine5_G + @dblReceiptLine5_H + @dblReceiptLine5_I + @dblReceiptLine6_A + @dblReceiptLine6_E + @dblReceiptLine6_F + @dblReceiptLine6_I + @dblDisbLine17_B + @dblDisbLine17_F + @dblDisbLine17_I + @dblDisbLine17a_B + @dblDisbLine17a_F + @dblDisbLine17a_I) - (@dblDisbLine18_D + @dblDisbLine18_H) 	
		SET @dblLine14 = @dblDisbLine14_A + @dblDisbLine14_B + @dblDisbLine14_C + @dblDisbLine14_E + @dblDisbLine14_F + @dblDisbLine14_G + @dblDisbLine14_H + @dblDisbLine14_I
		SET @dblLine15 = @dblLine13 - @dblLine14

		SELECT @strLine16a = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MO4757-Ln16'
	
		SET @dblLine16a = CONVERT(NUMERIC(18, 6), @strLine16a)

		SET @dblLine16 = @dblLine15 * @dblLine16a

		SELECT @strLine17 = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MO4757-Ln17'
		SET @dblLine17 = CONVERT(NUMERIC(18, 6), @strLine17)

		SET @dblLine18 = @dblLine16 - @dblLine17
		SET @dblLine19 = @dblLine15
		SET @dblLine21 = @dblLine19 - @dblLine20	

		SELECT @strLine22a = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MO4757-Ln22'
		SET @dblLine22a = CONVERT(NUMERIC(18, 6), @strLine22a)

		SET @dblLine22 = @dblLine21 * @dblLine22a

		SELECT @strLine23 = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MO4757-Ln23'
		SET @dblLine23 = CONVERT(NUMERIC(18, 6), @strLine23)

		SET @dblLine24 = @dblLine22 - @dblLine23

		-- PART 5
		SET @dblLine25 = @dblLine12_A + @dblLine12_B + @dblLine12_C + @dblLine12_D + @dblLine12_F + @dblLine12_G + @dblLine12_H
		SET @dblLine26 = @dblLine12_E
		SET @dblLine27 = @dblLine18
		SET @dblLine28 = @dblLine24
		SET @dblLine29 = @dblLine25 + @dblLine26 + @dblLine27 + @dblLine28

		SELECT @strLine30 = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MO4757-Ln30'
		SET @dblLine30 = CONVERT(NUMERIC(18, 6), @strLine30)

		SELECT @strLine31 = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MO4757-Ln31'
		SET @dblLine31 = CONVERT(NUMERIC(18, 6), @strLine31)
		
		SET @dblLine32 = @dblLine29 + @dblLine30 + @dblLine31

		SELECT @strLine33 = ISNULL(strConfiguration, '0') FROM tblTFReportingComponentConfiguration WHERE strTemplateItemId = 'MO4757-Ln33'
		SET @dblLine33 = CONVERT(NUMERIC(18, 6), @strLine33)

		SET @dblLine34 = @dblLine32 + @dblLine33

	END

	SELECT dtmFrom = @dtmFrom 
		, dtmTo = @dtmTo 
		, dblLine1_A = @dblLine1_A 
		, dblLine1_E = @dblLine1_E 
		, dblLine1_F = @dblLine1_F 		
		, dblLine2_A = @dblLine2_A 
		, dblLine2_C = @dblLine2_C 
		, dblLine2_D = @dblLine2_D 
		, dblLine2_E = @dblLine2_E 
		, dblLine2_F = @dblLine2_F 
		, dblLine2_G = @dblLine2_G 
		, dblLine3_B = @dblLine3_B 
		, dblLine3_F = @dblLine3_F 
		, dblLine3_H = @dblLine3_H 
		, dblLine4_H = @dblLine4_H 
		, dblLine5_A = @dblLine5_A 
		, dblLine5_B = @dblLine5_B 
		, dblLine5_C = @dblLine5_C 
		, dblLine5_D = @dblLine5_D 
		, dblLine5_E = @dblLine5_E 
		, dblLine5_F = @dblLine5_F 
		, dblLine5_G = @dblLine5_G 
		, dblLine5_H = @dblLine5_H 
		, dblLine6_A = @dblLine6_A 
		, dblLine6_B = @dblLine6_B 
		, dblLine6_C = @dblLine6_C 
		, dblLine6_D = @dblLine6_D 
		, dblLine6_E = @dblLine6_E 
		, dblLine6_F = @dblLine6_F 
		, dblLine6_G = @dblLine6_G 
		, dblLine7_A = @dblLine7_A 
		, dblLine7_B = @dblLine7_B 
		, dblLine7_C = @dblLine7_C 
		, dblLine7_D = @dblLine7_D 
		, dblLine7_E = @dblLine7_E 
		, dblLine7_F = @dblLine7_F 
		, dblLine7_G = @dblLine7_G 
		, strLine7_A_Rate = @strLine7_A_Rate 
		, strLine7_B_Rate = @strLine7_B_Rate 
		, strLine7_C_Rate = @strLine7_C_Rate 
		, strLine7_D_Rate = @strLine7_D_Rate 
		, strLine7_E_Rate = @strLine7_E_Rate
		, strLine7_F_Rate = @strLine7_F_Rate 
		, strLine7_G_Rate = @strLine7_G_Rate 
		, dblLine8_A = @dblLine8_A 
		, dblLine8_B = @dblLine8_B 
		, dblLine8_C = @dblLine8_C 
		, dblLine8_D = @dblLine8_D 
		, dblLine8_E = @dblLine8_E 
		, dblLine8_F = @dblLine8_F 
		, dblLine8_G = @dblLine8_G 
		, dblLine9_A = @dblLine9_A 
		, dblLine9_B = @dblLine9_B 
		, dblLine9_C = @dblLine9_C 
		, dblLine9_D = @dblLine9_D 
		, dblLine9_E = @dblLine9_E 
		, dblLine9_F = @dblLine9_F 
		, dblLine9_G = @dblLine9_G 
		, dblLine9_H = @dblLine9_H 
		-- PART 2
		, dblLine10_A = @dblLine10_A 
		, dblLine10_B = @dblLine10_B 
		, dblLine10_C = @dblLine10_C 
		, dblLine10_D = @dblLine10_D 
		, dblLine10_E = @dblLine10_E 
		, dblLine10_F = @dblLine10_F 
		, dblLine10_G = @dblLine10_G 
		, dblLine10_H = @dblLine10_H 
		, strLine10_A_Rate = @strLine10_A_Rate 
		, strLine10_B_Rate = @strLine10_B_Rate 
		, strLine10_C_Rate = @strLine10_C_Rate 
		, strLine10_D_Rate = @strLine10_D_Rate 
		, strLine10_E_Rate = @strLine10_E_Rate 
		, strLine10_F_Rate = @strLine10_F_Rate 
		, strLine10_G_Rate = @strLine10_G_Rate 
		, strLine10_H_Rate = @strLine10_H_Rate 
		, strLine11_A_Rate = @strLine11_A_Rate 
		, strLine11_B_Rate = @strLine11_B_Rate 
		, strLine11_C_Rate = @strLine11_C_Rate 
		, strLine11_D_Rate = @strLine11_D_Rate 
		, strLine11_E_Rate = @strLine11_E_Rate 
		, strLine11_F_Rate = @strLine11_F_Rate 
		, strLine11_G_Rate = @strLine11_G_Rate 
		, strLine11_H_Rate = @strLine11_H_Rate 
		, dblLine12_A = @dblLine12_A 
		, dblLine12_B = @dblLine12_B 
		, dblLine12_C = @dblLine12_C 
		, dblLine12_D = @dblLine12_D 
		, dblLine12_E = @dblLine12_E 
		, dblLine12_F = @dblLine12_F 
		, dblLine12_G = @dblLine12_G 
		, dblLine12_H = @dblLine12_H 
		-- PART 3
		, dblLine13 = @dblLine13
		, dblLine14 = @dblLine14 
		, dblLine14a = @dblLine14a 
		, dblLine15 = @dblLine15 
		, dblLine16 = @dblLine16 
		, strLine16a = @strLine16a 
		, strLine17 = @strLine17 
		, dblLine18 = @dblLine18 
		-- PART 4
		, dblLine19 = @dblLine19 
		, dblLine20 = @dblLine20 
		, dblLine21 = @dblLine21 
		, dblLine22 = @dblLine22 
		, strLine22a = @strLine22a 
		, strLine23 = @strLine23 
		, dblLine24 = @dblLine24 
		-- PART 5
		, dblLine25 = @dblLine25 
		, dblLine26 = @dblLine26 
		, dblLine27 = @dblLine27 
		, dblLine28 = @dblLine28 
		, dblLine29 = @dblLine29 
		, strLine30 = @strLine30 
		, strLine31 = @strLine31 
		, dblLine32 = @dblLine32 
		, strLine33 = @strLine33 
		, dblLine34 = @dblLine34 
		-- RECEIPT
		, dblReceiptLine1_A = @dblReceiptLine1_A 
		, dblReceiptLine1_B = @dblReceiptLine1_B 
		, dblReceiptLine1_C = @dblReceiptLine1_C 
		, dblReceiptLine1_E = @dblReceiptLine1_E 
		, dblReceiptLine1_F = @dblReceiptLine1_F 
		, dblReceiptLine1_G = @dblReceiptLine1_G 
		, dblReceiptLine1_H = @dblReceiptLine1_H 
		, dblReceiptLine1_I = @dblReceiptLine1_I 
		, dblReceiptLine2_A = @dblReceiptLine2_A 
		, dblReceiptLine2_B = @dblReceiptLine2_B 
		, dblReceiptLine2_C = @dblReceiptLine2_C 
		, dblReceiptLine2_E = @dblReceiptLine2_E 
		, dblReceiptLine2_F = @dblReceiptLine2_F 
		, dblReceiptLine2_G = @dblReceiptLine2_G 
		, dblReceiptLine2_H = @dblReceiptLine2_H 
		, dblReceiptLine2_I = @dblReceiptLine2_I 
		, dblReceiptLine3_A = @dblReceiptLine3_A 
		, dblReceiptLine3_B = @dblReceiptLine3_B 
		, dblReceiptLine3_C = @dblReceiptLine3_C 
		, dblReceiptLine3_E = @dblReceiptLine3_E 
		, dblReceiptLine3_F = @dblReceiptLine3_F 
		, dblReceiptLine3_G = @dblReceiptLine3_G 
		, dblReceiptLine3_H = @dblReceiptLine3_H 
		, dblReceiptLine3_I = @dblReceiptLine3_I 
		, dblReceiptLine4_A = @dblReceiptLine4_A 
		, dblReceiptLine4_B = @dblReceiptLine4_B 
		, dblReceiptLine4_C = @dblReceiptLine4_C 
		, dblReceiptLine4_E = @dblReceiptLine4_E 
		, dblReceiptLine4_F = @dblReceiptLine4_F 
		, dblReceiptLine4_G = @dblReceiptLine4_G 
		, dblReceiptLine4_H = @dblReceiptLine4_H 
		, dblReceiptLine4_I = @dblReceiptLine4_I 
		, dblReceiptLine5_A = @dblReceiptLine5_A 
		, dblReceiptLine5_C = @dblReceiptLine5_C 
		, dblReceiptLine5_D = @dblReceiptLine5_D 
		, dblReceiptLine5_E = @dblReceiptLine5_E 
		, dblReceiptLine5_F = @dblReceiptLine5_F 
		, dblReceiptLine5_G = @dblReceiptLine5_G 
		, dblReceiptLine5_H = @dblReceiptLine5_H 
		, dblReceiptLine5_I = @dblReceiptLine5_I 
		, dblReceiptLine5a_B = @dblReceiptLine5a_B 
		, dblReceiptLine5a_F = @dblReceiptLine5a_F 
		, dblReceiptLine5a_I = @dblReceiptLine5a_I 
		, dblReceiptLine6_A = @dblReceiptLine6_A 
		, dblReceiptLine6_E = @dblReceiptLine6_E 
		, dblReceiptLine6_F = @dblReceiptLine6_F 
		, dblReceiptLine6_I = @dblReceiptLine6_I 
		, dblReceiptLine7_F = @dblReceiptLine7_F 
		, dblReceiptLine8_A = @dblReceiptLine8_A 
		, dblReceiptLine8_B = @dblReceiptLine8_B 
		, dblReceiptLine8_C = @dblReceiptLine8_C 
		, dblReceiptLine8_E = @dblReceiptLine8_E 
		, dblReceiptLine8_F = @dblReceiptLine8_F 
		, dblReceiptLine8_H = @dblReceiptLine8_H 
		, dblReceiptLine9_A = @dblReceiptLine9_A 
		, dblReceiptLine9_B = @dblReceiptLine9_B 
		, dblReceiptLine9_C = @dblReceiptLine9_C 
		, dblReceiptLine9_D = @dblReceiptLine9_D 
		, dblReceiptLine9_E = @dblReceiptLine9_E 
		, dblReceiptLine9_F = @dblReceiptLine9_F 
		, dblReceiptLine9_G = @dblReceiptLine9_G 
		, dblReceiptLine9_H = @dblReceiptLine9_H 
		, dblReceiptLine9_I = @dblReceiptLine9_I 
		-- DISBURSEMENT
		, dblDisbLine10_A = @dblDisbLine10_A 
		, dblDisbLine10_B = @dblDisbLine10_B 
		, dblDisbLine10_C = @dblDisbLine10_C 
		, dblDisbLine10_D = @dblDisbLine10_D 
		, dblDisbLine10_E = @dblDisbLine10_E 
		, dblDisbLine10_F = @dblDisbLine10_F 
		, dblDisbLine10_G = @dblDisbLine10_G 
		, dblDisbLine10_H = @dblDisbLine10_H 
		, dblDisbLine10_I = @dblDisbLine10_I 
		, dblDisbLine11_I = @dblDisbLine11_I 
		, dblDisbLine12_B = @dblDisbLine12_B 
		, dblDisbLine12_F = @dblDisbLine12_F 
		, dblDisbLine12_I = @dblDisbLine12_I 
		, dblDisbLine13_A = @dblDisbLine13_A 
		, dblDisbLine13_B = @dblDisbLine13_B 
		, dblDisbLine13_C = @dblDisbLine13_C 
		, dblDisbLine13_E = @dblDisbLine13_E 
		, dblDisbLine13_F = @dblDisbLine13_F 
		, dblDisbLine13_G = @dblDisbLine13_G 
		, dblDisbLine13_H = @dblDisbLine13_H 
		, dblDisbLine13_I = @dblDisbLine13_I 
		, dblDisbLine14_A = @dblDisbLine14_A 
		, dblDisbLine14_B = @dblDisbLine14_B 
		, dblDisbLine14_C = @dblDisbLine14_C 
		, dblDisbLine14_E = @dblDisbLine14_E 
		, dblDisbLine14_F = @dblDisbLine14_F 
		, dblDisbLine14_G = @dblDisbLine14_G 
		, dblDisbLine14_H = @dblDisbLine14_H 
		, dblDisbLine14_I = @dblDisbLine14_I 
		, dblDisbLine15_F = @dblDisbLine15_F 
		, dblDisbLine16_A = @dblDisbLine16_A 
		, dblDisbLine16_B = @dblDisbLine16_B 
		, dblDisbLine16_C = @dblDisbLine16_C 
		, dblDisbLine16_D = @dblDisbLine16_D 
		, dblDisbLine16_E = @dblDisbLine16_E 
		, dblDisbLine16_F = @dblDisbLine16_F 
		, dblDisbLine16_G = @dblDisbLine16_G 
		, dblDisbLine16_H = @dblDisbLine16_H 
		, dblDisbLine16_I = @dblDisbLine16_I 
		, dblDisbLine17_B = @dblDisbLine17_B 
		, dblDisbLine17_F = @dblDisbLine17_F 
		, dblDisbLine17_I = @dblDisbLine17_I 
		, dblDisbLine17a_B = @dblDisbLine17a_B 
		, dblDisbLine17a_F = @dblDisbLine17a_F 
		, dblDisbLine17a_I = @dblDisbLine17a_I 
		, dblDisbLine18_D = @dblDisbLine18_D 
		, dblDisbLine18_H = @dblDisbLine18_H 



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