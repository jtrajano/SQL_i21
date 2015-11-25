CREATE PROCEDURE [dbo].[uspCTGetEventMailContent]
AS

BEGIN	
	DECLARE @intEventId INT,@intContractEventId INT,@style NVARCHAR(MAX),@html NVARCHAR(MAX),@row  NVARCHAR(MAX)
	DECLARE @strContractNumber NVARCHAR(MAX),@strName NVARCHAR(MAX),@strCustomerContract NVARCHAR(MAX),@dtmContractDate NVARCHAR(MAX),@newRow NVARCHAR(MAX),@newHTML NVARCHAR(MAX)
	DECLARE @Mail NVARCHAR(MAX),@strContractEventId  NVARCHAR(MAX)

	DECLARE @tblTempFinal TABLE
	(
		intId				INT IDENTITY(1,1),
		strSubject			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS ,
		strMailContent		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS ,
		strMailTo			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS ,
		strContractEventId	NVARCHAR(MAX) COLLATE Latin1_General_CI_AS 
	)

	SET @style =	'<style type="text/css" scoped>
					table.GeneratedTable {
						width:80%;
						background-color:#FFFFFF;
						border-collapse:collapse;border-width:2px;
						border-color:#000000;
						border-style:solid;
						color:#000000;
					}

					table.GeneratedTable td, table.GeneratedTable th {
						border-width:2px;
						border-color:#000000;
						border-style:solid;
						padding:3px;
					}

					table.GeneratedTable thead {
						background-color:#FFFFFF;
					}
					</style>'

	SET @html = '<html>
					<body>
					<p>htmlTitle</p>

					<table class="GeneratedTable">
						<tbody>
							<tr>
								<td>Contract Number</td>
								<td>Entity</td>
								<td>Entity Contract</td>
								<td>Contract Date</td>
							</tr>
						</tbody>
					</table>

					<p>Please do not reply to this e-mail, this is sent from an unattended mail box.</p>
					</body>
				</html>'
				
	SET @row = 	'<tr>
					<td>&nbsp;ContractNumber</td>
					<td>&nbsp;Entity</td>
					<td>&nbsp;CustomerContract</td>
					<td>&nbsp;ContractDate</td>
				</tr>'
				
	IF OBJECT_ID('tempdb..#tblTempEventMail') IS NOT NULL  						
		DROP TABLE #tblTempEventMail						

	SELECT	*
	INTO	#tblTempEventMail
	FROM
	(
		SELECT	CE.intContractEventId,
				CH.strContractNumber,
				EY.strName,
				CH.strCustomerContract,
				CH.dtmContractDate,
				CE.intEventId,
				EV.ysnSummarized,
				dbo.fnCTGetEventRecipientEmail(EV.intEventId) strMailTo,
				EV.strSubject,
				EV.strMessage
				
		FROM	tblCTContractEvent	CE
		JOIN	tblCTEvent			EV	ON	EV.intEventId			=	CE.intEventId
		JOIN	tblCTContractDetail CD	ON	CD.intContractDetailId	=	CE.intContractDetailId
		JOIN	tblCTContractHeader CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
		JOIN	tblEntity			EY	ON	EY.intEntityId			=	CH.intEntityId

		WHERE	EV.strAlertType = 'Reminder' AND dtmActualEventDate IS NULL AND   
				DATEADD(d,
						CASE WHEN strReminderCondition = 'day(s) before due date' THEN -1 * intDaysToRemind ELSE intDaysToRemind END,
						dtmExpectedEventDate
				)	=	DATEADD(d, 0, DATEDIFF(d, 0, GETDATE()))

	)t WHERE LTRIM(RTRIM(ISNULL(strMailTo,''))) <> ''

	DECLARE @strMailTo NVARCHAR(MAX),@strSubject NVARCHAR(MAX),@strMessage NVARCHAR(MAX)

	SELECT	@intEventId = MIN(intEventId) FROM #tblTempEventMail WHERE ysnSummarized = 1
	WHILE	ISNULL(@intEventId,0) > 0
	BEGIN
			SELECT	@Mail = '',@newHTML = @html,@newRow = '',@strContractEventId = ''
			SELECT	@intContractEventId = MIN(intContractEventId) FROM #tblTempEventMail WHERE intEventId = @intEventId
			
			WHILE	ISNULL(@intContractEventId,0) > 0
			BEGIN
					SELECT	@strContractNumber		=	strContractNumber,
							@strName				=	strName, 
							@strCustomerContract	=	strCustomerContract,
							@dtmContractDate		=	CONVERT(NVARCHAR(30),dtmContractDate,106),
							@strMailTo				=	strMailTo,
							@strSubject				=	strSubject,
							@strMessage				=	strMessage
					FROM	#tblTempEventMail
					WHERE	intContractEventId = @intContractEventId
					
					SELECT	@strContractEventId	= 	@strContractEventId +LTRIM(@intContractEventId) +','	
					
					SELECT	@newRow = REPLACE(REPLACE(REPLACE(REPLACE(@row,'ContractNumber',@strContractNumber),'Entity',@strName),'CustomerContract',@strCustomerContract),'ContractDate',@dtmContractDate)
					SELECT	@newHTML = REPLACE(@newHTML,'</tbody>',@newRow+'</tbody>')
					
					SELECT	@intContractEventId = MIN(intContractEventId) FROM #tblTempEventMail WHERE intEventId = @intEventId AND intContractEventId > @intContractEventId
			END
			SELECT	@newHTML = REPLACE(@newHTML,'htmlTitle',@strMessage)
			SELECT	@Mail = @style + @newHTML
			
			SELECT  @strContractEventId = CASE @strContractEventId WHEN NULL THEN NULL ELSE ( CASE LEN(@strContractEventId) WHEN 0 THEN @strContractEventId ELSE LEFT(@strContractEventId, LEN(@strContractEventId) - 1) END ) END
			
			INSERT	INTO @tblTempFinal
			SELECT	@strSubject,@Mail,@strMailTo,@strContractEventId
			
			SELECT	@intEventId = MIN(intEventId) FROM #tblTempEventMail WHERE ysnSummarized = 1 AND intEventId > @intEventId
	END

	SELECT	@intContractEventId = MIN(intContractEventId) FROM #tblTempEventMail WHERE ysnSummarized = 0

	WHILE	ISNULL(@intContractEventId,0) > 0
	BEGIN
			SELECT	@Mail = '',@newHTML = '',@newRow = ''
			
			SELECT	@strContractNumber		=	strContractNumber,
					@strName				=	strName, 
					@strCustomerContract	=	strCustomerContract,
					@dtmContractDate		=	CONVERT(NVARCHAR(30),dtmContractDate,106),
					@strMailTo				=	strMailTo,
					@strSubject				=	strSubject,
					@strMessage				=	strMessage
			FROM	#tblTempEventMail
			WHERE	intContractEventId = @intContractEventId
				
			SELECT	@newRow = REPLACE(REPLACE(REPLACE(REPLACE(@row,'ContractNumber',@strContractNumber),'Entity',@strName),'CustomerContract',@strCustomerContract),'ContractDate',@dtmContractDate)
			SELECT	@newHTML = REPLACE(@html,'</tbody>',@newRow+'</tbody>')
			
			SELECT	@newHTML = REPLACE(@newHTML,'htmlTitle',@strMessage)
			SELECT	@Mail = @style + @newHTML
			
			SELECT  @strContractEventId = LTRIM(@intContractEventId)

			INSERT	INTO @tblTempFinal
			SELECT	@strSubject,@Mail,@strMailTo,@strContractEventId
			
			SELECT	@intContractEventId = MIN(intContractEventId) FROM #tblTempEventMail WHERE intContractEventId > @intContractEventId AND ysnSummarized = 0
	END

	SELECT * FROM @tblTempFinal
END