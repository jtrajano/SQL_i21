CREATE PROCEDURE [dbo].[uspIPTransferOrderWithoutBOL]
AS
DECLARE @strStyle NVARCHAR(MAX)
	,@strHtml NVARCHAR(MAX)
	,@strHeader NVARCHAR(MAX)
	,@strDetail NVARCHAR(MAX) = ''
	,@strMessage NVARCHAR(MAX)
	,@dtmCurrentDate datetime

SELECT @dtmCurrentDate = CONVERT(DATETIME, CONVERT(CHAR, Getdate(), 101))

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
						<th>&nbsp;Inventory Transfer (IT) Number</th>
						<th>&nbsp;Inventory Transfer (IT) Date</th>
						<th>&nbsp;From Company Location</th>
						<th>&nbsp;To Company Location</th>
						<th>&nbsp;ShipVia</th>

						<th>&nbsp;Trailer Id</th>
												<th>&nbsp;Status</th>
					</tr>'
SELECT @strDetail = @strDetail + '<tr>
			 <td>&nbsp;' + IT.strTransferNo + '</td>'+
			'<td>&nbsp;' + Convert(char,IT.dtmTransferDate,101) + '</td>' +
			'<td>&nbsp;' + SL.strLocationName  + '</td>' + 
			'<td>&nbsp;' + DL.strLocationName + '</td>' + 
			'<td>&nbsp;' + IsNULL(E.strName,'')  + '</td>'+

			'<td>&nbsp;' + IsNULL(IT.strTrailerId,'') + '</td>'+
						'<td>&nbsp;' + S.strStatus  + '</td></tr>'
	FROM dbo.tblICInventoryTransfer IT
	JOIN dbo.tblSMCompanyLocation SL on SL.intCompanyLocationId =IT.intFromLocationId 
	JOIN dbo.tblSMCompanyLocation DL on DL.intCompanyLocationId =IT.intToLocationId 
	JOIN dbo.tblEMEntity E on E.intEntityId =IT.intShipViaId 
	JOIN dbo.tblICStatus S on S.intStatusId =IT.intStatusId 
	WHERE IsNULL(IT.strBolNumber,'')=''
	AND IT.ysnShipmentRequired =1
	AND IT.dtmTransferDate =@dtmCurrentDate

SET @strHtml = REPLACE(@strHtml, '@header', @strHeader)
SET @strHtml = REPLACE(@strHtml, '@detail', @strDetail)
SET @strMessage = @strStyle + @strHtml

IF ISNULL(@strDetail, '') = ''
	SET @strMessage = ''

SELECT @strMessage AS strMessage
