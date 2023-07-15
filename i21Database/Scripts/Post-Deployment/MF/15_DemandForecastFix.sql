PRINT 'Demand Forecast Fix'
GO

IF (SELECT ISNULL(ysnDemandForecastDataFix, 0) FROM tblMFCompanyPreference) = 0
	BEGIN
		DECLARE @negativeValue AS TABLE 
		(
			id INT
		);

		DECLARE @positiveValue AS TABLE 
		(
			id INT
		);

		INSERT INTO @negativeValue (id)
		SELECT intInvPlngReportMasterID
		FROM tblCTInvPlngReportAttributeValue
		WHERE intReportAttributeID = 8 AND CAST(ISNULL(NULLIF(strValue, ''), 0) AS NUMERIC(36, 20)) < 0 ;

		INSERT INTO @positiveValue (id)
		SELECT intInvPlngReportMasterID
		FROM tblCTInvPlngReportAttributeValue
		WHERE intReportAttributeID = 8 AND CAST(ISNULL(NULLIF(strValue, ''), 0) AS NUMERIC(36, 20)) > 0 ;


		UPDATE tblCTInvPlngReportAttributeValue
		SET strValue = ABS(CAST(strValue AS NUMERIC(38,6)))
		/* Forecast Attributee */
		WHERE intReportAttributeID = 8 AND intInvPlngReportMasterID IN (SELECT DISTINCT id FROM @negativeValue) AND CAST(ISNULL(NULLIF(strValue, ''), 0) AS NUMERIC(36, 20)) <> 0;

		UPDATE tblCTInvPlngReportAttributeValue
		SET strValue = -ABS(CAST(strValue AS NUMERIC(38,6)))
		/* Forecast Attributee */
		WHERE intReportAttributeID = 8 AND intInvPlngReportMasterID IN (SELECT DISTINCT id FROM @positiveValue) AND CAST(ISNULL(NULLIF(strValue, ''), 0) AS NUMERIC(36, 20)) <> 0;

		UPDATE tblMFCompanyPreference
		SET ysnDemandForecastDataFix = 1;
	END

PRINT 'End of Demand Forecast Fix'
GO