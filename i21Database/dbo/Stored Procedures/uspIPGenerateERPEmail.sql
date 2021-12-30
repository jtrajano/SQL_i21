CREATE PROCEDURE uspIPGenerateERPEmail @strMessageType NVARCHAR(50) = ''
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

	IF @strMessageType = 'Item'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Location</th>
							<th>&nbsp;Item No</th>
							<th>&nbsp;Description</th>
							<th>&nbsp;Commodity</th>
							<th>&nbsp;Category</th>
							<th>&nbsp;Action</th>
							<th>&nbsp;Message</th>
						</tr>'

		IF @strStatus = 'Success'
		BEGIN
			IF EXISTS (
				SELECT 1
				FROM tblIPItemArchive WITH (NOLOCK)
				WHERE intActionId = 1
					AND ysnMailSent = 0
				)
			BEGIN
				SELECT @strDetail = @strDetail + '<tr>' + 
					   '<td>&nbsp;' + ISNULL(CL.strLocationName, '') + '</td>' + 
					   '<td>&nbsp;' + ISNULL(t.strItemNo, '') + '</td>' + 
					   '<td>&nbsp;' + ISNULL(t.strDescription, '') + '</td>' + 
					   '<td>&nbsp;' + ISNULL(t.strCommodity, '') + '</td>' + 
					   '<td>&nbsp;' + ISNULL(t.strCategoryCode, '') + '</td>' + 
					   '<td>&nbsp;' + CASE WHEN t.intActionId=1 THEN 'Create' WHEN t.intActionId=4 THEN 'Delete' Else 'Update' End + '</td>' + 
					   '<td>&nbsp;' + ISNULL('Success', '') + '</td>' + 
				'</tr>'
				FROM tblIPItemArchive t WITH (NOLOCK)
				LEFT JOIN tblSMCompanyLocation CL WITH (NOLOCK) ON CL.strLotOrigin = t.strCompanyLocation
				WHERE t.intActionId = 1
					AND t.ysnMailSent = 0
			
				UPDATE tblIPItemArchive
				SET ysnMailSent = 1
				WHERE intActionId = 1
					AND ysnMailSent = 0
			END
		END
		ELSE IF @strStatus = 'Failure'
		BEGIN
			IF EXISTS (
				SELECT 1
				FROM tblIPItemError WITH (NOLOCK)
				WHERE ysnMailSent = 0
				)
			BEGIN
				SELECT @strDetail = @strDetail + '<tr>' + 
					   '<td>&nbsp;' + ISNULL(CL.strLocationName, '') + '</td>' + 
					   '<td>&nbsp;' + ISNULL(t.strItemNo, '') + '</td>' + 
					   '<td>&nbsp;' + ISNULL(t.strDescription, '') + '</td>' + 
					   '<td>&nbsp;' + ISNULL(t.strCommodity, '') + '</td>' + 
					   '<td>&nbsp;' + ISNULL(t.strCategoryCode, '') + '</td>' + 
					   '<td>&nbsp;' + CASE WHEN t.intActionId=1 THEN 'Create' WHEN t.intActionId=4 THEN 'Delete' Else 'Update' End + '</td>' + 
					   '<td>&nbsp;' + ISNULL(t.strErrorMessage, '') + '</td>' + 
				'</tr>'
				FROM tblIPItemError t WITH (NOLOCK)
				LEFT JOIN tblSMCompanyLocation CL WITH (NOLOCK) ON CL.strLotOrigin = t.strCompanyLocation
				WHERE t.ysnMailSent = 0

				UPDATE tblIPItemError
				SET ysnMailSent = 1
				WHERE ysnMailSent = 0
			END
		END
	END

	IF @strMessageType = 'Customer'
	BEGIN
		SET @strHeader = '<tr>
							<th>&nbsp;Location</th>
							<th>&nbsp;Contract No</th>
							<th>&nbsp;Customer</th>
						</tr>'

		SELECT @strDetail = @strDetail + '<tr>' + 
				'<td>&nbsp;' + ISNULL(CL.strLocationName, '') + '</td>' + 
				'<td>&nbsp;' + ISNULL(CH.strContractNumber, '') + '</td>' + 
				'<td>&nbsp;' + ISNULL(E.strName, '') + '</td>' + 
		'</tr>'
		FROM tblCTContractHeader CH WITH (NOLOCK)
		JOIN tblCTContractDetail CD WITH (NOLOCK) ON CD.intContractHeaderId = CH.intContractHeaderId
			AND CH.intContractTypeId = 2
		JOIN tblSMCompanyLocation CL WITH (NOLOCK) ON CL.intCompanyLocationId = CD.intCompanyLocationId
		JOIN tblARCustomer C WITH (NOLOCK) ON C.intEntityId = CH.intEntityId
		JOIN tblEMEntity E WITH (NOLOCK) ON E.intEntityId = C.intEntityId
			AND ISNULL(C.strLinkCustomerNumber, '') = ''
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
