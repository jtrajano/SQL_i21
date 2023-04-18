CREATE PROCEDURE [dbo].[uspSCGrainBankStatementReport]
	@xmlParam NVARCHAR(MAX) = ''
AS
begin
	SET FMTONLY OFF
	SET NOCOUNT ON
	
	
	DECLARE @strCompanyName			NVARCHAR(500),
			@strAddress				NVARCHAR(500),
			@strCounty				NVARCHAR(500),
			@strCity				NVARCHAR(500),
			@strState				NVARCHAR(500),
			@strZip					NVARCHAR(500),
			@strCountry				NVARCHAR(500),
			@intEntityId			INT,
			@intItemId				INT,
			@dtmStartDate			DateTime,
			@dtmEndDate			    DateTime,
			@strItemNo				NVARCHAR(100),
			@intStorageTypeId		INT,
			@strStorageType			NVARCHAR(100),						
			@xmlDocumentId			INT

	DECLARE @ErrMsg NVARCHAR(MAX)

	IF LTRIM(RTRIM(@xmlParam)) = ''
		SET @xmlParam = NULL

	-- XML Parameter Table
	DECLARE @temp_xml_table TABLE 
	(
		id int identity(1,1)
		,[fieldname] NVARCHAR(50)
		,[condition] NVARCHAR(20)
		,[from] NVARCHAR(MAX)
		,[to] NVARCHAR(MAX)
		,[join] NVARCHAR(10)
		,[begingroup] NVARCHAR(50)
		,[endgroup] NVARCHAR(50)
		,[datatype] NVARCHAR(50)
	)

	EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT,@xmlParam

	INSERT INTO @temp_xml_table
	SELECT *
	FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2) WITH 
	(
		[fieldname] NVARCHAR(50)
		,[condition] NVARCHAR(20)
		,[from] NVARCHAR(50)
		,[to] NVARCHAR(50)
		,[join] NVARCHAR(10)
		,[begingroup] NVARCHAR(50)
		,[endgroup] NVARCHAR(50)
		,[datatype] NVARCHAR(50)
	)
	

	SELECT  @intStorageTypeId=[from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intStorageTypeId'

	SELECT  @intItemId=[from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intItemId'

	SELECT	@intEntityId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intEntityId'

	SELECT	@dtmStartDate = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'dtmStartDate'

	SELECT	@dtmEndDate = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'dtmEndDate'

	DECLARE @ENTITY_ID INT = @intEntityId
	DECLARE @STORAGE_SCHEDULE_TYPE_ID  INT = @intStorageTypeId
	--DECLARE @CUSTOMER_STORAGE INT = 179
	DECLARE @BEGINNING_BALANCE NUMERIC(18, 4)
	DECLARE @ENDING_BALANCE NUMERIC(18, 4)

	DECLARE @TRANSACTION_TYPE_GENERATE INT = 1
	DECLARE @TRANSACTION_TYPE_TRANSFER INT = 3
	DECLARE @TRANSACTION_TYPE_SETTLEMENT INT = 4
	DECLARE @TRANSACTION_TYPE_INVOICED INT = 6

	SET @dtmEndDate = ISNULL(@dtmEndDate, GetDATE()+3650)
	SELECT	@strCompanyName	=	CASE WHEN LTRIM(RTRIM(strCompanyName)) = '' THEN NULL ELSE LTRIM(RTRIM(strCompanyName)) END,
			@strAddress		=	CASE WHEN LTRIM(RTRIM(strAddress)) = '' THEN NULL ELSE LTRIM(RTRIM(strAddress)) END,
			@strCounty		=	CASE WHEN LTRIM(RTRIM(strCounty)) = '' THEN NULL ELSE LTRIM(RTRIM(strCounty)) END,
			@strCity		=	CASE WHEN LTRIM(RTRIM(strCity)) = '' THEN NULL ELSE LTRIM(RTRIM(strCity)) END,
			@strState		=	CASE WHEN LTRIM(RTRIM(strState)) = '' THEN NULL ELSE LTRIM(RTRIM(strState)) END,
			@strZip			=	CASE WHEN LTRIM(RTRIM(strZip)) = '' THEN NULL ELSE LTRIM(RTRIM(strZip)) END,
			@strCountry		=	CASE WHEN LTRIM(RTRIM(strCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(strCountry)) END
	FROM	tblSMCompanySetup

	

	-- #SCENARIO TO CHECK - MANUAL DISTRIBUTION FOR GB
	-- #SCENARIO TO CHECK - TICKET SPLIT
	DECLARE @DATA_TABLE AS TABLE(
	
		intStorageHistoryId		INT
		,dblUnits				NUMERIC(18,4)
		,intCustomerStorageId	INT
		,intEntityId			INT
		,intStorageTypeId		INT
		,intStorageScheduleId	INT
		,dtmTransactionDate		DATE
		,intItemId				INT
		,strTransactionId		NVARCHAR(100)
		,strTransactionType		NVARCHAR(100)
		,dblRunningUnits		NUMERIC(18,4)
		,intRowNumber			INT
		,intGrainBankUnitMeasureId INT


	)
	
	DECLARE @BALANCES AS TABLE(
	
		ID						INT IDENTITY(1,1)
		,intEntityId			INT
		,intItemId				INT
		,intStorageTypeId		INT
		,intStorageScheduleId	INT
		,dblBeginningBalance	NUMERIC(18,4)
		,dblEndingBalance	NUMERIC(18,4)
	)
	

	
	DECLARE @COMPANY_PREFERENCE_REPORT_UOM AS INT
	DECLARE @COMPANY_PREFERENCE_REPORT_UOM_STRING AS NVARCHAR(100)
	
	DECLARE @COMPANY_PREFERENCE_GRAIN_BANK_UOM_STRING AS NVARCHAR(100)
	SELECT @COMPANY_PREFERENCE_REPORT_UOM =  COMPANY_PREFERENCE.intUnitMeasureId
		,@COMPANY_PREFERENCE_REPORT_UOM_STRING = UNIT_MEASURE.strSymbol
		,@COMPANY_PREFERENCE_GRAIN_BANK_UOM_STRING = UNIT_MEASURE_GRAIN_BANK.strSymbol
	FROM tblGRCompanyPreference COMPANY_PREFERENCE 
		JOIN tblICUnitMeasure UNIT_MEASURE ON COMPANY_PREFERENCE.intUnitMeasureId = UNIT_MEASURE.intUnitMeasureId
		JOIN tblICUnitMeasure UNIT_MEASURE_GRAIN_BANK ON COMPANY_PREFERENCE.intGrainBankUnitMeasureId = UNIT_MEASURE_GRAIN_BANK.intUnitMeasureId

	INSERT INTO @BALANCES
	SELECT 
		intEntityId 
		, intItemId
		, intStorageTypeId
		, intStorageScheduleId
		, SUM(
			CASE WHEN @COMPANY_PREFERENCE_REPORT_UOM <> intGrainBankUnitMeasureId THEN
				round(dbo.fnGRConvertQuantityToTargetItemUOM(
									intItemId
									, intGrainBankUnitMeasureId
									, @COMPANY_PREFERENCE_REPORT_UOM
									, dblUnits) , 4) 
			ELSE
				ISNULL(dblUnits,0)
			END
			
			)
		, 0
	FROM dbo.vyuSCGrainBankTransactions
		
	WHERE dtmTransactionDate < @dtmStartDate
	GROUP BY intEntityId 
		, intItemId
		, intStorageTypeId
		, intStorageScheduleId


	;WITH GRAINBANK_TRANSACTION AS 
	(
	  SELECT 
  
		intStorageHistoryId, 
		dblUnits, 
		intCustomerStorageId,
		intEntityId,
		intStorageTypeId,
		intStorageScheduleId,	
		dtmTransactionDate,
		strTransactionId,
		strTransactionType,
		rn = ROW_NUMBER() OVER (PARTITION BY intEntityId, intItemId, intStorageTypeId,intStorageScheduleId ORDER BY intStorageHistoryId),
		intItemId,
		intGrainBankUnitMeasureId
		FROM dbo.vyuSCGrainBankTransactions
		/*WHERE intEntityId = 1581
		ORDER BY intStorageTypeId */
	), GRAINBANK_TRANSACTION_LOOP AS
	(
		SELECT 
			intStorageHistoryId, 
			rn, 
			dblUnits, 
			GRAINBANK_TRANSACTION.intCustomerStorageId,
			GRAINBANK_TRANSACTION.intEntityId,
			intStorageTypeId,
			intStorageScheduleId,
			dtmTransactionDate,
			intItemId,		
			strTransactionId,
			strTransactionType,

			dblRunningUnits = CAST(dblUnits AS NUMERIC(18, 4)),
			intGrainBankUnitMeasureId
			
		FROM GRAINBANK_TRANSACTION
			WHERE rn = 1

		UNION ALL

		SELECT 
			GRAINBANK_TRANSACTION.intStorageHistoryId, 
			GRAINBANK_TRANSACTION.rn, 
			GRAINBANK_TRANSACTION.dblUnits, 
			GRAINBANK_TRANSACTION.intCustomerStorageId,
			GRAINBANK_TRANSACTION.intEntityId,
			GRAINBANK_TRANSACTION.intStorageTypeId,
			GRAINBANK_TRANSACTION.intStorageScheduleId,
		
			GRAINBANK_TRANSACTION.dtmTransactionDate,
			GRAINBANK_TRANSACTION.intItemId,		
			GRAINBANK_TRANSACTION.strTransactionId,
			GRAINBANK_TRANSACTION.strTransactionType,

		
			dblRunningUnits = CAST(GRAINBANK_TRANSACTION_LOOP.dblRunningUnits + GRAINBANK_TRANSACTION.dblUnits AS NUMERIC(18, 4)),
			GRAINBANK_TRANSACTION.intGrainBankUnitMeasureId

			FROM GRAINBANK_TRANSACTION_LOOP 
			INNER JOIN GRAINBANK_TRANSACTION
				ON GRAINBANK_TRANSACTION.rn = GRAINBANK_TRANSACTION_LOOP.rn + 1
					AND GRAINBANK_TRANSACTION_LOOP.intEntityId = GRAINBANK_TRANSACTION.intEntityId
					AND GRAINBANK_TRANSACTION_LOOP.intStorageTypeId = GRAINBANK_TRANSACTION.intStorageTypeId
					AND GRAINBANK_TRANSACTION_LOOP.intStorageScheduleId = GRAINBANK_TRANSACTION.intStorageScheduleId
					AND GRAINBANK_TRANSACTION_LOOP.intItemId = GRAINBANK_TRANSACTION.intItemId
	)
	INSERT INTO @DATA_TABLE
	(
		intStorageHistoryId		
		,dblUnits				
		,intCustomerStorageId	
		,intEntityId			
		,intStorageTypeId		
		,intStorageScheduleId	
		,dtmTransactionDate		
		,intItemId				
		,strTransactionId		
		,strTransactionType		
		,dblRunningUnits		
		,intRowNumber
		,intGrainBankUnitMeasureId
	)
	SELECT 
		intStorageHistoryId,
		dblUnits, 
		intCustomerStorageId,
		intEntityId,
		intStorageTypeId,
		intStorageScheduleId,
	
		dtmTransactionDate,
		intItemId,		
		strTransactionId,
		strTransactionType,

		dblRunningUnits,
		rn AS intRowNumber,
		intGrainBankUnitMeasureId
	FROM GRAINBANK_TRANSACTION_LOOP
	WHERE  (@ENTITY_ID IS NULL OR intEntityId = @ENTITY_ID )
		AND (@intItemId IS NULL OR intItemId = @intItemId)
		AND intStorageTypeId = @intStorageTypeId
		
		AND (dtmTransactionDate >= @dtmStartDate
				AND dtmTransactionDate <= @dtmEndDate
			)
		/*
		AND intCustomerStorageId = @CUSTOMER_STORAGE
		AND intStorageTypeId = @STORAGE_SCHEDULE_TYPE_ID*/
	ORDER BY intStorageTypeId, intStorageScheduleId, GRAINBANK_TRANSACTION_LOOP.rn


	
	MERGE INTO @BALANCES AS [Target]
	USING (
		
		SELECT 
			intEntityId 
			, intItemId
			, intStorageTypeId
			, intStorageScheduleId
			, SUM(
			CASE WHEN @COMPANY_PREFERENCE_REPORT_UOM <> intGrainBankUnitMeasureId THEN
				round(dbo.fnGRConvertQuantityToTargetItemUOM(
									intItemId
									, intGrainBankUnitMeasureId
									, @COMPANY_PREFERENCE_REPORT_UOM
									, dblUnits) , 4) 
			ELSE
				ISNULL(dblUnits,0)
			END
			
			) dblEndingBalance			
		FROM @DATA_TABLE		
		GROUP BY intEntityId 
			, intItemId
			, intStorageTypeId
			, intStorageScheduleId
			

	)
	AS [Source]
		ON [Target].intEntityId = [Source].intEntityId
			AND [Target].intItemId = [Source].intItemId
			AND [Target].intStorageTypeId = [Source].intStorageTypeId
			AND [Target].intStorageScheduleId = [Source].intStorageScheduleId
	WHEN MATCHED THEN
		UPDATE SET dblEndingBalance = [Target].dblBeginningBalance + ISNULL([Source].dblEndingBalance, 0)
	WHEN NOT MATCHED BY TARGET THEN
	INSERT (intEntityId			
			,intItemId				
			,intStorageTypeId		
			,intStorageScheduleId	
			,dblBeginningBalance	
			,dblEndingBalance
	)
	VALUES ([Source].intEntityId			
			,[Source].intItemId				
			,[Source].intStorageTypeId		
			,[Source].intStorageScheduleId	
			,0
			,[Source].dblEndingBalance);

	SELECT 

		DATA_TABLE.intStorageHistoryId		
		,DATA_TABLE.dblUnits				
		,DATA_TABLE.intCustomerStorageId	
		,DATA_TABLE.intEntityId			
		,DATA_TABLE.intStorageTypeId		
		,DATA_TABLE.intStorageScheduleId	
		,DATA_TABLE.dtmTransactionDate		
		,DATA_TABLE.intItemId				
		,DATA_TABLE.strTransactionId		
		,DATA_TABLE.strTransactionType		
		,DATA_TABLE.dblRunningUnits		
		,DATA_TABLE.intRowNumber 
		, ENTITY.strEntityNo
		, ENTITY.strName
		, ENTITY_LOCATION.strAddress
		, ITEM.strItemNo

		, BALANCES.dblBeginningBalance AS dblBeginningBalance
		, BALANCES.dblEndingBalance AS dblEndingBalance

		, @COMPANY_PREFERENCE_REPORT_UOM_STRING AS strBalanceUOM
		, @COMPANY_PREFERENCE_GRAIN_BANK_UOM_STRING AS strUnitUOM
		, @dtmStartDate AS dtmStartDate
		, @dtmEndDate AS dtmEndDate


		, @strAddress AS strCompanyAddress
	FROM @DATA_TABLE DATA_TABLE
		LEFT JOIN @BALANCES BALANCES
			ON DATA_TABLE.intEntityId = BALANCES.intEntityId
				AND DATA_TABLE.intItemId = BALANCES.intItemId 
				AND DATA_TABLE.intStorageTypeId = BALANCES.intStorageTypeId 
				AND DATA_TABLE.intStorageScheduleId = BALANCES.intStorageScheduleId 		
		JOIN tblEMEntity ENTITY
			ON DATA_TABLE.intEntityId = ENTITY.intEntityId
		JOIN tblEMEntityLocation ENTITY_LOCATION
			ON ENTITY.intEntityId = ENTITY_LOCATION.intEntityId
				AND ENTITY_LOCATION.ysnDefaultLocation = 1
		JOIN tblICItem ITEM
			ON DATA_TABLE.intItemId= ITEM.intItemId

	


end
