CREATE PROCEDURE [dbo].[uspGRDestinationWeightVarianceVarianceReport]
	@xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN TRY
	SET FMTONLY OFF

	IF OBJECT_ID('tempdb..##tmpTblGRDestinationWeightVariance') IS NOT NULL
		DROP TABLE ##tmpTblGRDestinationWeightVariance
	
	IF OBJECT_ID('tempdb..##tmpTblGRDestinationWeightVarianceLogs') IS NOT NULL
		DROP TABLE ##tmpTblGRDestinationWeightVarianceLogs

	DECLARE @ErrMsg NVARCHAR(MAX)

	IF LTRIM(RTRIM(@xmlParam)) = ''
		SET @xmlParam = NULL

	-- XML Parameter Table
	DECLARE @temp_xml_table TABLE 
	(
		[fieldname] NVARCHAR(50)
		,[condition] NVARCHAR(20)
		,[from] NVARCHAR(MAX)
		,[to] NVARCHAR(MAX)
		,[join] NVARCHAR(10)
		,[begingroup] NVARCHAR(50)
		,[endgroup] NVARCHAR(50)
		,[datatype] NVARCHAR(50)
	)
	DECLARE @xmlDocumentId AS INT

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

	-- Query Parameters
	DECLARE 
		@dblVariancePercentageFrom DECIMAL(18, 6)
		,@dblVariancePercentageTo DECIMAL(18, 6)
		,@dtmTicketDateTimeFrom DATETIME
		,@dtmTicketDateTimeTo DATETIME
		,@strCommodity NVARCHAR(40)
		,@strCustomerName NVARCHAR(100)
		,@strLocationName NVARCHAR(50)
		,@ysnHasVariance BIT
		,@ysnPrintReadings BIT;

	SELECT @dblVariancePercentageFrom = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dblVariancePercentage';

	SELECT @dblVariancePercentageTo = [to]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dblVariancePercentage';

	SELECT @dtmTicketDateTimeFrom = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dtmTicketDateTime';

	SELECT @dtmTicketDateTimeTo = [to]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dtmTicketDateTime';

	SELECT @strCommodity = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strCommodity';

	SELECT @strCustomerName = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strCustomerName';

	SELECT @strLocationName = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strLocationName';

	SELECT @ysnHasVariance = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'ysnHasVariance';

	SELECT @ysnPrintReadings = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'ysnPrintReadings';

	-- Selection Query from View
	SELECT
		*
		-- This flag will be used internally to check if there's still a need to check the audit log
		-- ,[ysnHasOriginWeight] = CAST((CASE WHEN RESULT.intParentTicketId IS NULL THEN 0 ELSE 1 END) AS BIT)
	INTO ##tmpTblGRDestinationWeightVariance
	FROM vyuGRDestinationWeightVarianceReportView RESULT
	WHERE
	-- Filters
	-- dtmTicketDateTime Parameter
	(
		(
			@dtmTicketDateTimeFrom IS NOT NULL
			AND @dtmTicketDateTimeTo IS NULL
			AND dbo.fnRemoveTimeOnDate(RESULT.dtmTicketDateTime) = dbo.fnRemoveTimeOnDate(@dtmTicketDateTimeFrom)
		)
		OR
		(
			@dtmTicketDateTimeFrom IS NOT NULL
			AND @dtmTicketDateTimeTo IS NOT NULL
			AND dbo.fnRemoveTimeOnDate(RESULT.dtmTicketDateTime) BETWEEN dbo.fnRemoveTimeOnDate(@dtmTicketDateTimeFrom) AND dbo.fnRemoveTimeOnDate(@dtmTicketDateTimeTo)
		)
		OR
		@dtmTicketDateTimeFrom IS NULL
	)
	-- strCommodity Parameter
	AND RESULT.strCommodity = ISNULL(@strCommodity, RESULT.strCommodity)
	-- strCustomerName Parameter
	AND RESULT.strCustomerName = ISNULL(@strCustomerName, RESULT.strCustomerName)
	-- strLocationName Paramter
	AND RESULT.strLocationName = ISNULL(@strLocationName, RESULT.strLocationName);

	-- Store audit logs of tickets in another temp table
	SELECT AULOG.dtmDate, AL.intAuditId, AL.strChange, AL.strFrom, AL.strTo, TR.intRecordId, AULOG.intLogId, AL.strAction
	INTO ##tmpTblGRDestinationWeightVarianceLogs
	FROM ##tmpTblGRDestinationWeightVariance RES
	INNER JOIN tblSMTransaction TR
		ON TR.intRecordId = RES.intTicketId
	INNER JOIN tblSMLog AULOG
		ON TR.intTransactionId = AULOG.intTransactionId
	INNER JOIN tblSMAudit AL
		ON AULOG.intLogId = AL.intLogId	
	-- WHERE RES.ysnHasOriginWeight = 0;
		-- AND AL.strChange IN ('Inventory Shipment', 'dblGrossWeight', 'dblGrossWeight1', 'dblGrossWeight2', 'dblTareWeight', 'dblTareWeight1', 'dblTareWeight2')

	-- Retrieve final result
	SELECT 
		*
		-- Optionally display ticket grades
		,[strGradeReading] = CASE WHEN @ysnPrintReadings = 1
			THEN
				SUBSTRING((
					SELECT ','+ ICI2.strItemNo + '=' + LTRIM(STR(QMD2.dblGradeReading, 10, 2))
					FROM tblSCTicket SC2
					INNER JOIN tblQMTicketDiscount QMD2
						ON QMD2.intTicketId = SC2.intTicketId and QMD2.strSourceType = 'Scale'
					INNER JOIN tblGRDiscountScheduleCode DSC2
						ON QMD2.intDiscountScheduleCodeId = DSC2.intDiscountScheduleCodeId
					INNER JOIN tblICItem ICI2
						ON ICI2.intItemId = DSC2.intItemId
					WHERE QMD2.dblGradeReading > 0 and SC2.intTicketId = RESULT.intTicketId
					FOR XML PATH('')
				),2,1000)
			ELSE NULL END
		,[ysnPrintReadings] = @ysnPrintReadings
	FROM ( -- RESULT
		SELECT
			*
			,[dblVarianceWeight] = TMP2.dblDestinationNetWeight - TMP2.dblOriginNetWeight
			,[dblVariancePercentage] = ((TMP2.dblDestinationNetWeight - TMP2.dblOriginNetWeight) / TMP2.dblOriginNetWeight) * 100
			,[ysnHasVariance] = CAST((CASE WHEN (TMP2.dblDestinationNetWeight - TMP2.dblOriginNetWeight) = 0 THEN 0 ELSE 1 END) AS BIT)
			,[dblOriginNetWeightSplit] = (TMP2.dblOriginNetWeight * TMP2.dblSplitPercent) / 100
			,[dblDestinationNetWeightSplit] = (TMP2.dblDestinationNetWeight * TMP2.dblSplitPercent) / 100
		FROM ( -- TMP2
			SELECT
				*,
				[dblOriginNetWeight] = (TMP.dblOriginLogGrossWeight + TMP.dblOriginLogGrossWeight1 + TMP.dblOriginLogGrossWeight2)
						- (TMP.dblOriginLogTareWeight + TMP.dblOriginLogTareWeight1 + TMP.dblOriginLogTareWeight2)
					-- Compute total destination net weight
				,[dblDestinationNetWeight] = (TMP.dblDestinationGrossWeight + TMP.dblDestinationGrossWeight1 + TMP.dblDestinationGrossWeight2)
						- (TMP.dblDestinationTareWeight + TMP.dblDestinationTareWeight1 + TMP.dblDestinationTareWeight2)
				,[dblOriginGrossWeightTotal] = (TMP.dblOriginLogGrossWeight + TMP.dblOriginLogGrossWeight1 + TMP.dblOriginLogGrossWeight2)
				,[dblOriginTareWeightTotal] = (TMP.dblOriginLogTareWeight + TMP.dblOriginLogTareWeight1 + TMP.dblOriginLogTareWeight2)
			FROM ( -- TMP
				SELECT 
					RES.*
					-- Retrieve Origin Weights from Audit Logs. Set to destination weight if there's no log for the specific weight
					-- Gross Weights
					,[dblOriginLogGrossWeight] = ISNULL((SELECT MAX(CAST(strFrom AS DECIMAL(13, 3)))
															FROM ##tmpTblGRDestinationWeightVarianceLogs LOGS
															WHERE [intLogId] = FIRSTPOSTLOG.intLogId
															AND strChange = 'dblGrossWeight'
														), RES.dblDestinationGrossWeight)
					,[dblOriginLogGrossWeight1] = ISNULL((SELECT MAX(CAST(strFrom AS DECIMAL(13, 3)))
															FROM ##tmpTblGRDestinationWeightVarianceLogs LOGS
															WHERE [intLogId] = FIRSTPOSTLOG.intLogId
															AND strChange = 'dblGrossWeight1'
														), RES.dblDestinationGrossWeight1)
					,[dblOriginLogGrossWeight2] = ISNULL((SELECT MAX(CAST(strFrom AS DECIMAL(13, 3)))
															FROM ##tmpTblGRDestinationWeightVarianceLogs LOGS
															WHERE [intLogId] = FIRSTPOSTLOG.intLogId
															AND strChange = 'dblGrossWeight2'
														), RES.dblDestinationGrossWeight2)
					-- -- Tare Weights
					,[dblOriginLogTareWeight] = ISNULL((SELECT MAX(CAST(strFrom AS DECIMAL(13, 3)))
															FROM ##tmpTblGRDestinationWeightVarianceLogs LOGS
															WHERE [intLogId] = FIRSTPOSTLOG.intLogId
															AND strChange = 'dblTareWeight'
														), RES.dblDestinationTareWeight)
					,[dblOriginLogTareWeight1] = ISNULL((SELECT MAX(CAST(strFrom AS DECIMAL(13, 3)))
															FROM ##tmpTblGRDestinationWeightVarianceLogs LOGS
															WHERE [intLogId] = FIRSTPOSTLOG.intLogId
															AND strChange = 'dblTareWeight1'
														), RES.dblDestinationTareWeight1)
					,[dblOriginLogTareWeight2] = ISNULL((SELECT MAX(CAST(strFrom AS DECIMAL(13, 3)))
															FROM ##tmpTblGRDestinationWeightVarianceLogs LOGS
															WHERE [intLogId] = FIRSTPOSTLOG.intLogId
															AND strChange = 'dblTareWeight2'
														), RES.dblDestinationTareWeight2)
				FROM ##tmpTblGRDestinationWeightVariance RES
				-- Get log ID when the ticket was last distributed
				OUTER APPLY (
					SELECT [intLogId] = MAX(intLogId)
					FROM ##tmpTblGRDestinationWeightVarianceLogs LOGS
					WHERE intRecordId = RES.intTicketId
					AND strChange = 'Inventory Shipment'
				) DISTLOG
				-- Get the first Log ID for destination posting after distribution of the ticket
				OUTER APPLY (
					SELECT [intLogId] = MIN(intLogId)
					FROM ##tmpTblGRDestinationWeightVarianceLogs LOGS
					WHERE
						-- strChange IN ('dblGrossWeight', 'dblGrossWeight1', 'dblGrossWeight2', 'dblTareWeight', 'dblTareWeight1', 'dblTareWeight2')
						strAction = 'Updated'
						AND intLogId > DISTLOG.intLogId
						AND intRecordId = RES.intTicketId
				) FIRSTPOSTLOG
			) TMP
		) TMP2
	) RESULT
	WHERE
		-- dblVariancePercentage Parameter
		(
			(
				@dblVariancePercentageFrom IS NOT NULL
				AND @dblVariancePercentageTo IS NULL
				AND RESULT.dblVariancePercentage = @dblVariancePercentageFrom
			)
			OR
			(
				@dblVariancePercentageFrom IS NOT NULL
				AND @dblVariancePercentageTo IS NOT NULL
				AND RESULT.dblVariancePercentage BETWEEN @dblVariancePercentageFrom AND @dblVariancePercentageTo
			)
			OR
			@dblVariancePercentageFrom IS NULL
		)
		-- ysnHasVariance Parameter
		AND RESULT.ysnHasVariance = ISNULL(@ysnHasVariance, RESULT.ysnHasVariance)

END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH
