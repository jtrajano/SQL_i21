CREATE PROCEDURE [dbo].[uspSCGetDiscountRead]
	@xmlParam NVARCHAR(MAX) = NULL
AS
-- Sanitize the @xmlParam 
IF LTRIM(RTRIM(@xmlParam)) = '' 
	SET @xmlParam = NULL 

DECLARE @ErrMsg NVARCHAR(MAX)
DECLARE @intColumnKey INT
DECLARE @strColumnName NVARCHAR(40)
DECLARE @strColumnSuffix NVARCHAR(40)
DECLARE @SqlAddColumn NVARCHAR(MAX)
DECLARE @strItemNo NVARCHAR(MAX)
		,@intTicketId AS INT
		,@intCompanyLocationId AS INT
		,@xmlDocumentId	AS INT;

	DECLARE @temp_xml_table TABLE (
		 [id]			INT IDENTITY(1,1)
		,[fieldname]	NVARCHAR(50)
		,[condition]	NVARCHAR(20)
		,[from]			NVARCHAR(100)
		,[to]			NVARCHAR(100)
		,[join]			NVARCHAR(10)
		,[begingroup]	NVARCHAR(50)
		,[endgroup]		NVARCHAR(50)
		,[datatype]		NVARCHAR(50)
	)

	DECLARE @temp_SOA_table TABLE(
		 [strCustomerName]			NVARCHAR(100)
		,[strAccountStatusCode]		NVARCHAR(5)
		,[strLocationName]			NVARCHAR(50)
		,[ysnPrintZeroBalance]		BIT
		,[ysnPrintCreditBalance]	BIT
		,[ysnIncludeBudget]			BIT
		,[ysnPrintOnlyPastDue]		BIT
		,[strStatementFormat]		NVARCHAR(100)	
		,[dtmDateFrom]				DATETIME
		,[dtmDateTo]				DATETIME
	)
	-- Prepare the XML 
	EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT, @xmlParam


	-- Insert the XML to the xml table. 		
	INSERT INTO @temp_xml_table
	SELECT *
	FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)
	WITH (
		  [fieldname]  NVARCHAR(50)
		, [condition]  NVARCHAR(20)
		, [from]	   NVARCHAR(100)
		, [to]		   NVARCHAR(100)
		, [join]	   NVARCHAR(10)
		, [begingroup] NVARCHAR(50)
		, [endgroup]   NVARCHAR(50)
		, [datatype]   NVARCHAR(50)
	)

	-- Gather the variables values from the xml table.
	SELECT @intTicketId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intTicketId'

	SELECT @intCompanyLocationId = intProcessingLocationId FROM tblSCTicket WHERE intTicketId = @intTicketId;

BEGIN TRY
	IF OBJECT_ID('tempdb..#tblSCDiscountReading') IS NOT NULL
		DROP TABLE #tblSCDiscountReading

	CREATE TABLE #tblSCDiscountReading 
	(
		 [intTicketId] INT,
		 [intItemId] INT,
		 [strItemNo] NVARCHAR(40)
		 UNIQUE ([intItemId])
	)

	IF OBJECT_ID('tempdb..#tblRequiredColumns') IS NOT NULL
		DROP TABLE #tblRequiredColumns

	CREATE TABLE #tblRequiredColumns 
	(
		 [intColumnKey] INT IDENTITY(1,1)
		,[strColumnName] NVARCHAR(100) COLLATE Latin1_General_CI_AS
	)

	INSERT INTO #tblSCDiscountReading(intTicketId, intItemId,strItemNo)
	SELECT QMTicket.intTicketId, GRDiscount.intItemId, IC.strItemNo
	FROM tblGRDiscountScheduleCode GRDiscount 
	LEFT JOIN tblQMTicketDiscount QMTicket ON QMTicket.intDiscountScheduleCodeId = GRDiscount.intDiscountScheduleCodeId
	LEFT JOIN vyuGRGetDiscountCode GRDiscountCode ON GRDiscountCode.intItemId = QMTicket.intTicketId
	LEFT JOIN tblICItem IC ON  IC.intItemId = GRDiscount.intItemId
	WHERE QMTicket.intTicketId = @intTicketId AND GRDiscount.intCompanyLocationId = @intCompanyLocationId

	IF EXISTS (SELECT TOP 1 * FROM #tblSCDiscountReading)
	BEGIN
		INSERT INTO #tblRequiredColumns ([strColumnName])
		SELECT DISTINCT '[' + strItemNo + ' Discount]'
		FROM #tblSCDiscountReading
			
		UNION			
		SELECT DISTINCT '[' + strItemNo + ' Item Key]'
		FROM #tblSCDiscountReading

		IF EXISTS (SELECT 1 FROM #tblRequiredColumns)
		BEGIN
			SELECT @intColumnKey = MIN(intColumnKey)
			FROM #tblRequiredColumns

			WHILE @intColumnKey > 0
			BEGIN
				SET @strColumnName = NULL
				SET @strColumnSuffix = NULL
				SET @SqlAddColumn = NULL
				SET @strItemNo = NULL

				SELECT @strColumnName = strColumnName
				FROM #tblRequiredColumns
				WHERE intColumnKey = @intColumnKey
					
				SET @strColumnSuffix = RIGHT(@strColumnName, 9)					
				SET @strItemNo = REPLACE(@strColumnName, '[', '''')
				SET @strItemNo = REPLACE(@strItemNo, ']', '''')

				IF @strColumnSuffix = 'Discount]'
				BEGIN
					
				SET @SqlAddColumn = 'ALTER TABLE #tblSCDiscountReading ADD ' + @strColumnName + ' DECIMAL(24,10) NULL'
				EXEC (@SqlAddColumn)
				SET @SqlAddColumn = NULL
					
					SET @strItemNo = REPLACE(@strItemNo, ' Discount', '')
					SET @SqlAddColumn = 'UPDATE SC SET SC.' + @strColumnName + '= QM.dblDiscountDue 
											FROM #tblSCDiscountReading SC 
											LEFT JOIN tblQMTicketDiscount QM on QM.intTicketId=SC.intTicketId
											WHERE SC.strItemNo=' + @strItemNo
												

					EXEC (@SqlAddColumn)
				END
				ELSE IF @strColumnSuffix = 'Item Key]'
				BEGIN
				SET @SqlAddColumn = 'ALTER TABLE #tblSCDiscountReading ADD ' + @strColumnName + ' INT NULL'
				EXEC (@SqlAddColumn)
				SET @SqlAddColumn = NULL
					
					SET @strItemNo = REPLACE(@strItemNo, ' Item Key', '')
					SET @SqlAddColumn = 'UPDATE SC SET SC.' + @strColumnName + '= SC.intItemId 
											FROM #tblSCDiscountReading SC WHERE SC.strItemNo=' + @strItemNo

					EXEC (@SqlAddColumn)
				END

				SELECT @intColumnKey = MIN(intColumnKey)
				FROM #tblRequiredColumns
				WHERE intColumnKey > @intColumnKey
			END
		END
	END
	SELECT * FROM #tblSCDiscountReading
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
	
END CATCH
