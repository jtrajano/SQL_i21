
-- =============================================
-- Author:		Jeffrey Trajano
-- Create date: 13-05-2020
-- Description:	For Undeposited Fund Report
-- =============================================
CREATE PROCEDURE uspCMUndepositedFundReport
    (@xmlParam NVARCHAR(MAX)= '')
AS

DECLARE @temp_xml_table TABLE (
	id INT IDENTITY(1,1)
	,[fieldname] NVARCHAR(50)
	,condition NVARCHAR(20)      
	,[from] NVARCHAR(50)
	,[to] NVARCHAR(50)
	,[join] NVARCHAR(10)
	,[datatype] NVARCHAR(50)
)
DECLARE @xmlDocumentId AS INT;

EXEC sp_xml_preparedocument @xmlDocumentId output, @xmlParam
INSERT INTO @temp_xml_table
SELECT *
FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)
WITH (
	[fieldname] nvarchar(50)
	, [condition] nvarchar(20)
	, [from] nvarchar(50)
	, [to] nvarchar(50)
	, [join] nvarchar(10)
	, [datatype] nvarchar(50)
)

DECLARE @dtmDateFrom DATETIME,@dtmDateTo DATETIME

IF EXISTS(SELECT 1 FROM @temp_xml_table)
BEGIN
	SELECT 
		@dtmDateFrom = [from],
		@dtmDateTo =  [to]
	FROM @temp_xml_table WHERE [fieldname] = 'dtmDate' --and condition in ('Equal To' , 'Between')

	SELECT @dtmDateFrom = isnull(@dtmDateFrom,'01/01/1900'),
		@dtmDateTo = isnull( @dtmDateTo , @dtmDateFrom)

	SELECT @dtmDateTo = DATEADD( SECOND,-1, DATEADD(DAY, 1 ,@dtmDateTo))

	SELECT * FROM dbo.fnCMUndepositedFundReport(@dtmDateFrom,@dtmDateTo)

END







