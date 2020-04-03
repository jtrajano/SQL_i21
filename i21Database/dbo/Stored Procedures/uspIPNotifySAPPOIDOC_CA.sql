CREATE PROCEDURE uspIPNotifySAPPOIDOC_CA
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
SET @strHeader = '<tr>
						<th>&nbsp;Contract No</th>
						<th>&nbsp;Message</th>
						<th>&nbsp;Contract Feed Id</th>
						<th>&nbsp;Contract Header Id</th>
						<th>&nbsp;Contract Detail Id</th>
					</tr>'

SELECT @strDetail = @strDetail + '<tr>
		   <td>&nbsp;' + strContractNumber + '</td>' + '<td>&nbsp;' + ISNULL(strThirdPartyMessage, '') + '</td>' + '<td>&nbsp;' + Ltrim(intContractFeedId) + '</td>' + '<td>&nbsp;' + Ltrim(intContractHeaderId) + '</td>' + '<td>&nbsp;' + Ltrim(intContractDetailId) + '</td>
	</tr>'
FROM tblCTContractFeed
WHERE strThirdPartyFeedStatus = 'Failed'
	AND ISNULL(strThirdPartyMessage, '') <> ''
	AND ISNULL(ysnThirdPartyMailSent, 0) = 0

UPDATE tblCTContractFeed
SET ysnThirdPartyMailSent = 1
WHERE strThirdPartyFeedStatus = 'Failed'
	AND ISNULL(strThirdPartyMessage, '') <> ''
	AND ISNULL(ysnThirdPartyMailSent, 0) = 0

SET @strHtml = REPLACE(@strHtml, '@header', @strHeader)
SET @strHtml = REPLACE(@strHtml, '@detail', @strDetail)
SET @strMessage = @strStyle + @strHtml

IF ISNULL(@strDetail, '') = ''
	SET @strMessage = ''

SELECT @strMessage AS strMessage
