CREATE PROCEDURE uspIPInterCompanySendEmail @strMessageType NVARCHAR(50)
	,@strStatus NVARCHAR(50)
AS
DECLARE @strStyle NVARCHAR(MAX)
	,@strHtml NVARCHAR(MAX)
	,@strHeader NVARCHAR(MAX)
	,@strDetail NVARCHAR(MAX) = ''
	,@strMessage NVARCHAR(MAX)

SET @strStyle = '<style type="text/css" scoped>
					table.GeneratedTable {
						width:80%;
						background-color:#FFFFFF;
						border-collapse:collapse;border-width:1px;
						border-color:#000000;
						border-style:solid;
						color:#000000;
					}

					table.GeneratedTable td {
						border-width:1px;
						border-color:#000000;
						border-style:solid;
						padding:3px;
					}

					table.GeneratedTable th {
						border-width:1px;
						border-color:#000000;
						border-style:solid;
						background-color:yellow;
						padding:3px;
					}

					table.GeneratedTable thead {
						background-color:#FFFFFF;
					}
					</style>'
SET @strHtml = '<html>
					<body>

					<table class="GeneratedTable">
						<tbody>
							@header
							@detail
						</tbody>
					</table>

					</body>
				</html>'

IF @strMessageType = 'Sample'
BEGIN
	SET @strHeader = '<tr>
						<th>&nbsp;Sample No</th>
						<th>&nbsp;Sample Type</th>
						<th>&nbsp;Row State</th>
						<th>&nbsp;From Company</th>
						<th>&nbsp;Message</th>
					</tr>'

	IF @strStatus = 'Success'
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(strNewSampleNumber, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strNewSampleTypeName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strFromCompanyName, '') + '</td>' + 
			   '<td>&nbsp;' + 'Success' + '</td>
		</tr>'
		FROM tblQMSampleStage WITH (NOLOCK)
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0

		UPDATE tblQMSampleStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
	ELSE
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(strNewSampleNumber, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strNewSampleTypeName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strRowState, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strFromCompanyName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(strMessage, '') + '</td>
		</tr>'
		FROM tblQMSampleStage WITH (NOLOCK)
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0

		UPDATE tblQMSampleStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
END

IF @strMessageType = 'DAP'
BEGIN
	SET @strHeader = '<tr>
						<th>&nbsp;Average No</th>
						<th>&nbsp;Date</th>
						<th>&nbsp;From Company</th>
						<th>&nbsp;Message</th>
					</tr>'

	IF @strStatus = 'Success'
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(S.strAverageNo, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(DAP.dtmDate, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(S.strFromCompanyName, '') + '</td>' + 
			   '<td>&nbsp;' + 'Success' + '</td>
		</tr>'
		FROM tblRKDailyAveragePriceStage S WITH (NOLOCK)
		JOIN tblRKDailyAveragePrice DAP ON DAP.intDailyAveragePriceId = S.intDailyAveragePriceId
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0

		UPDATE tblRKDailyAveragePriceStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Processed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
	ELSE
	BEGIN
		SELECT @strDetail = @strDetail + '<tr>
			   <td>&nbsp;' + ISNULL(S.strAverageNo, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(DAP.dtmDate, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(S.strFromCompanyName, '') + '</td>' + 
			   '<td>&nbsp;' + ISNULL(S.strMessage, '') + '</td>
		</tr>'
		FROM tblRKDailyAveragePriceStage S WITH (NOLOCK)
		JOIN tblRKDailyAveragePrice DAP ON DAP.intDailyAveragePriceId = S.intDailyAveragePriceId
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0

		UPDATE tblRKDailyAveragePriceStage
		SET ysnMailSent = 1
		WHERE ISNULL(strFeedStatus, '') = 'Failed'
			AND ISNULL(ysnMailSent, 0) = 0
	END
END

SET @strHtml = REPLACE(@strHtml, '@header', @strHeader)
SET @strHtml = REPLACE(@strHtml, '@detail', @strDetail)
SET @strMessage = @strStyle + @strHtml

IF ISNULL(@strDetail, '') = ''
	SET @strMessage = ''

SELECT @strMessage AS strMessage
