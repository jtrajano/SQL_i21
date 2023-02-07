CREATE PROCEDURE [dbo].[uspGREndOfMonthProcedureReport]
	@xmlParam NVARCHAR(MAX) = NULL  
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN TRY

	-- Start extracting parameters from XML
	DECLARE
        @xmlDocumentId INT
        ,@strReportLogId AS NVARCHAR(100)
	EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT, @xmlParam

	DECLARE @temp_xml_table TABLE 
	(  
		[fieldname]		NVARCHAR(50),
		condition		NVARCHAR(20),
		[from]			NVARCHAR(50),
		[to]			NVARCHAR(50),
		[join]			NVARCHAR(10),
		[begingroup]	NVARCHAR(50),
		[endgroup]		NVARCHAR(50),
		[datatype]		NVARCHAR(50)
	)

	INSERT INTO @temp_xml_table
	SELECT *  
	FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)
	WITH (  
		[fieldname]		NVARCHAR(50),
		[condition]		NVARCHAR(20),
		[from]			NVARCHAR(50),
		[to]			NVARCHAR(50),
		[join]			NVARCHAR(10),
		[begingroup]	NVARCHAR(50),
		[endgroup]		NVARCHAR(50),
		[datatype]		NVARCHAR(50)
	)

    INSERT INTO @temp_xml_table
    SELECT *
    FROM OPENXML(@xmlDocumentId, 'xmlparam/dummies/filter', 2) WITH 
    (
        [fieldname] NVARCHAR(50)
        ,condition NVARCHAR(20)
        ,[from] NVARCHAR(4000)
        ,[to] NVARCHAR(4000)
        ,[join] NVARCHAR(10)
        ,[begingroup] NVARCHAR(50)
        ,[endgroup] NVARCHAR(50)
        ,[datatype] NVARCHAR(50)
    )

    SELECT @strReportLogId = [from]
    FROM @temp_xml_table
    WHERE [fieldname] = 'strReportLogId'

    IF @strReportLogId IS NOT NULL
    BEGIN
        IF EXISTS (SELECT TOP 1 1 FROM tblSRReportLog WHERE strReportLogId = @strReportLogId)
        BEGIN
            RETURN
        END
        ELSE
        BEGIN
            INSERT INTO tblSRReportLog (strReportLogId, dtmDate) VALUES (@strReportLogId, GETUTCDATE())
        END
    END

	DECLARE @strPeriodName NVARCHAR(50)

	SELECT TOP 1 @strPeriodName = [from]
	FROM @temp_xml_table WHERE [fieldname] = 'strPeriod'
	-- End extraction of parameters from XML

    IF @strPeriodName IS NULL
        SELECT TOP 1 @strPeriodName = strPeriod FROM tblGLFiscalYearPeriod WHERE dtmEndDate <= GETDATE() ORDER BY dtmEndDate DESC

    -- Main Report
	SELECT * FROM dbo.fnGREndOfMonthProcedureInventory(@strPeriodName) R

END TRY

BEGIN CATCH
	DECLARE @ErrMsg NVARCHAR(MAX)
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH