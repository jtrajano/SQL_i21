CREATE PROCEDURE [dbo].[uspIPGenerateImportProcessFailureEmailMessage]
	@strMessageType NVARCHAR(50)
AS
Declare @strStyle  NVARCHAR(MAX),
		@strHtml   NVARCHAR(MAX),
		@strHeader NVARCHAR(MAX),
		@strDetail NVARCHAR(MAX)='',
		@strMessage NVARCHAR(MAX),
		@intDuration int=30

Select @intDuration=ISNULL(strValue,30) From tblIPSAPIDOCTag Where strMessageType='GLOBAL' AND strTag='FEED_READ_DURATION'

	SET @strStyle =	'<style type="text/css" scoped>
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

If @strMessageType='Item'
Begin
	SET @strHeader = '<tr>
						<th>&nbsp;Item No</th>
						<th>&nbsp;Description</th>
						<th>&nbsp;UOM</th>
						<th>&nbsp;Product Type</th>
						<th>&nbsp;Error Message</th>
					</tr>'
	
	Select @strDetail=@strDetail + 
	'<tr>
		   <td>&nbsp;'  + ISNULL(strItemNo,'') + '</td>'
		+ '<td>&nbsp;' + ISNULL(strDescription,'') + '</td>'
		+ '<td>&nbsp;' + ISNULL(strStockUOM,'') + '</td>'
		+ '<td>&nbsp;' + ISNULL(strProductType,'') + '</td>'
		+ '<td>&nbsp;' + ISNULL(strErrorMessage,'') + '</td>
	</tr>'
	From tblIPItemError 
	Where strImportStatus='Failed' AND ISNULL(strErrorMessage,'') <> '' AND ISNULL(ysnMailSent,0)=0

	Update tblIPItemError Set ysnMailSent=1
	Where strImportStatus='Failed' AND ISNULL(strErrorMessage,'') <> '' AND ISNULL(ysnMailSent,0)=0
End

If @strMessageType='Vendor'
Begin
	SET @strHeader = '<tr>
						<th>&nbsp;Name</th>
						<th>&nbsp;Account No</th>
						<th>&nbsp;Country</th>
						<th>&nbsp;Currency</th>
						<th>&nbsp;Error Message</th>
					</tr>'
	
	Select @strDetail=@strDetail + 
	'<tr>
		   <td>&nbsp;'  + ISNULL(strName,'') + '</td>'
		+ '<td>&nbsp;' + ISNULL(strAccountNo,'') + '</td>'
		+ '<td>&nbsp;' + ISNULL(strCountry,'') + '</td>'
		+ '<td>&nbsp;' + ISNULL(strCurrency,'') + '</td>'
		+ '<td>&nbsp;' + ISNULL(strErrorMessage,'') + '</td>
	</tr>'
	From tblIPEntityError
	Where strImportStatus='Failed' AND ISNULL(strErrorMessage,'') <> '' AND ISNULL(ysnMailSent,0)=0

	Update tblIPEntityError Set ysnMailSent=1
	Where strImportStatus='Failed' AND ISNULL(strErrorMessage,'') <> '' AND ISNULL(ysnMailSent,0)=0
End

Set @strHtml=REPLACE(@strHtml,'@header',@strHeader)
Set @strHtml=REPLACE(@strHtml,'@detail',@strDetail)
Set @strMessage=@strStyle + @strHtml

If ISNULL(@strDetail,'')=''
	Set @strMessage=''

Select @strMessage AS strMessage