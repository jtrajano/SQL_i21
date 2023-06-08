CREATE PROCEDURE uspIPGenerateEmail_DA @strMessageType NVARCHAR(50) = ''
	,@strStatus NVARCHAR(50) = ''
AS
BEGIN TRY
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
							border-color:#d0d0d0;
							border-style:solid;
							padding:3px;
							background-color: #F1F4F8;
							color: #0f0f0f;
							font-size: 12px;
							font-family: Verdana, Geneva, Tahoma, sans-serif;
						}

						table.GeneratedTable th {
							border-width:1px;
							border-color:#d0d0d0;
							border-style:solid;
							background-color:#3572b0;
							color:white;
							padding:3px;
							font-size: 12px;
							font-family: Verdana, Geneva, Tahoma, sans-serif;
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

	IF @strMessageType = 'PO'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Contract No</th>
							<th>&nbsp;Seq No</th>
							<th>&nbsp;ERP PO Number</th>
							<th>&nbsp;Message</th>
						</tr>'

		IF EXISTS (
				SELECT 1
				FROM dbo.tblCTContractFeed t WITH (NOLOCK)
				WHERE t.intStatusId IN (1, 3)
					AND t.ysnMailSent = 0
				)
		BEGIN
			SELECT @strDetail = @strDetail + '<tr>' + 
				   '<td>&nbsp;' + ISNULL(CONVERT(NVARCHAR, t.strContractNumber), '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(LTRIM(t.intContractSeq), '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strERPPONumber, '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strMessage, '') + '</td>' + 
			'</tr>'
			FROM tblCTContractFeed t WITH (NOLOCK)
			WHERE t.intStatusId IN (1, 3)
				AND t.ysnMailSent = 0

			UPDATE t
			SET ysnMailSent = 1
			FROM tblCTContractFeed t
			WHERE t.intStatusId IN (1, 3)
				AND t.ysnMailSent = 0
		END
	END

	IF @strMessageType = 'Shipment'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Load No</th>
							<th>&nbsp;Message</th>
						</tr>'

		IF EXISTS (
				SELECT 1
				FROM dbo.tblLGLoadStg t WITH (NOLOCK)
				WHERE t.strFeedStatus IN ('NA')
					AND t.ysnMailSent = 0
				)
		BEGIN
			SELECT @strDetail = @strDetail + '<tr>' + 
				   '<td>&nbsp;' + ISNULL(CONVERT(NVARCHAR, t.strLoadNumber), '') + '</td>' + 
				   '<td>&nbsp;' + ISNULL(t.strMessage, '') + '</td>' + 
			'</tr>'
			FROM tblLGLoadStg t WITH (NOLOCK)
			WHERE t.strFeedStatus IN ('NA')
				AND t.ysnMailSent = 0

			UPDATE t
			SET ysnMailSent = 1
			FROM tblLGLoadStg t
			WHERE t.strFeedStatus IN ('NA')
				AND t.ysnMailSent = 0
		END
	END

	SET @strHtml = REPLACE(@strHtml, '@header', ISNULL(@strHeader, ''))
	SET @strHtml = REPLACE(@strHtml, '@detail', ISNULL(@strDetail, ''))
	SET @strMessage = @strStyle + @strHtml

	IF ISNULL(@strDetail, '') = ''
		SET @strMessage = ''

	SELECT @strMessage AS strMessage
END TRY

BEGIN CATCH
	SELECT '' AS strMessage
END CATCH
