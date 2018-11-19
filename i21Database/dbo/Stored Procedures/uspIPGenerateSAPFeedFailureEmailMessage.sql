﻿CREATE PROCEDURE [dbo].[uspIPGenerateSAPFeedFailureEmailMessage]
	@strMessageType NVARCHAR(50)
AS
BEGIN TRY
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

If @strMessageType='PO'
Begin
	SET @strHeader = '<tr>
						<th>&nbsp;Contract No</th>
						<th>&nbsp;Sequence No</th>
						<th>&nbsp;Type</th>
						<th>&nbsp;PO No</th>
						<th>&nbsp;Commodity</th>
						<th>&nbsp;Ack Message</th>
					</tr>'
	
	Select @strDetail=@strDetail + 
	'<tr>
		   <td>&nbsp;'  + ISNULL(strContractNumber,'') + '</td>'
		+ '<td>&nbsp;' + ISNULL(CONVERT(VARCHAR,intContractSeq),'') + '</td>'
		+ '<td>&nbsp;' + CASE WHEN UPPER(strRowState)='ADDED' THEN 'Create' When UPPER(strRowState)='DELETE' THEN 'Delete' Else 'Update' End + '</td>'
		+ '<td>&nbsp;' + ISNULL(strERPPONumber,'') + '</td>'
		+ '<td>&nbsp;' + ISNULL(strCommodityCode,'') + '</td>'
		+ '<td>&nbsp;' + ISNULL(strMessage,'') + '</td>
	</tr>'
	From tblCTContractFeed WITH (NOLOCK)
	Where strFeedStatus='Ack Rcvd' AND ISNULL(strMessage,'') NOT IN ('', 'Success') AND GETDATE() > DATEADD(MI,@intDuration,dtmFeedCreated)
	AND ISNULL(ysnMailSent,0)=0

	Update tblCTContractFeed Set ysnMailSent=1
	Where strFeedStatus='Ack Rcvd' AND ISNULL(strMessage,'') NOT IN ('', 'Success') AND GETDATE() > DATEADD(MI,@intDuration,dtmFeedCreated)
	AND ISNULL(ysnMailSent,0)=0
End

If @strMessageType='Shipment'
Begin
	SET @strHeader = '<tr>
						<th>&nbsp;Shipment No</th>
						<th>&nbsp;Type</th>
						<th>&nbsp;Delivery No</th>
						<th>&nbsp;Commodity</th>
						<th>&nbsp;Ack Message</th>
					</tr>'
	
	Select @strDetail=@strDetail + 
	'<tr>
		   <td>&nbsp;'  + ISNULL(strLoadNumber,'') + '</td>'
		+ '<td>&nbsp;' + CASE WHEN UPPER(strMessageState)='ADDED' THEN 'Create' When UPPER(strMessageState)='DELETE' THEN 'Delete' Else 'Update' End + '</td>'
		+ '<td>&nbsp;' + ISNULL(strExternalShipmentNumber,'') + '</td>'
		+ '<td>&nbsp;' + ISNULL((select TOP 1 strCommodityCode from tblLGLoadDetailStg WITH (NOLOCK) Where intLoadStgId=lg.intLoadStgId),'') + '</td>'
		+ '<td>&nbsp;' + ISNULL(strMessage,'') + '</td>
	</tr>'
	From tblLGLoadStg lg WITH (NOLOCK)
	Where strFeedStatus='Ack Rcvd' AND ISNULL(strMessage,'') NOT IN ('', 'Success') AND GETDATE() > DATEADD(MI,@intDuration,dtmFeedCreated)
	AND ISNULL(ysnMailSent,0)=0

	Update tblLGLoadStg Set ysnMailSent=1
	Where strFeedStatus='Ack Rcvd' AND ISNULL(strMessage,'') NOT IN ('', 'Success') AND GETDATE() > DATEADD(MI,@intDuration,dtmFeedCreated)
	AND ISNULL(ysnMailSent,0)=0
End

If @strMessageType='Receipt'
Begin
	SET @strHeader = '<tr>
						<th>&nbsp;Receipt No</th>
						<th>&nbsp;Commodity</th>
						<th>&nbsp;Ack Message</th>
					</tr>'
	
	Select @strDetail=@strDetail + 
	'<tr>
		   <td>&nbsp;'  + ISNULL(strExternalRefNo,'') + '</td>'
		   + '<td>&nbsp;' + ISNULL((select TOP 1 strCommodityCode from tblICCommodity c Join tblICItem i on c.intCommodityId=i.intCommodityId 
		   Join tblICInventoryReceiptItem ri on i.intItemId=ri.intItemId
		   Join tblICInventoryReceipt rh on ri.intInventoryReceiptId=rh.intInventoryReceiptId Where rh.strReceiptNumber=r.strExternalRefNo),'') + '</td>'
		+ '<td>&nbsp;' + ISNULL(strErrorMessage,'') + '</td>
	</tr>'
	From tblIPReceiptError r
	Where strPartnerNo='i212SAP' AND GETDATE() > DATEADD(MI,@intDuration,dtmTransactionDate)
	AND ISNULL(ysnMailSent,0)=0 AND ISNULL(strErrorMessage,'') <>'Success'

	Update tblIPReceiptError Set ysnMailSent=1
	Where strPartnerNo='i212SAP' AND GETDATE() > DATEADD(MI,@intDuration,dtmTransactionDate) AND ISNULL(strErrorMessage,'') <>'Success'
	AND ISNULL(ysnMailSent,0)=0
End

If @strMessageType='MBN Receipt'
Begin
	SET @strHeader = '<tr>
						<th>&nbsp;Delivery No</th>
						<th>&nbsp;Message</th>
					</tr>'
	
	Select @strDetail=@strDetail + 
	'<tr>
		   <td>&nbsp;'  + ISNULL(strDeliveryNo,'') + '</td>'
		+ '<td>&nbsp;' + ISNULL(strErrorMessage,'') + '</td>
	</tr>'
	From tblIPReceiptError r
	Where strPartnerNo='0012XI01'
	AND ISNULL(ysnMailSent,0)=0 AND ISNULL(strErrorMessage,'') <>'Success'

	Update tblIPReceiptError Set ysnMailSent=1
	Where strPartnerNo='0012XI01' AND ISNULL(strErrorMessage,'') <>'Success'
	AND ISNULL(ysnMailSent,0)=0
End

Set @strHtml=REPLACE(@strHtml,'@header',@strHeader)
Set @strHtml=REPLACE(@strHtml,'@detail',@strDetail)
Set @strMessage=@strStyle + @strHtml

If ISNULL(@strDetail,'')=''
	Set @strMessage=''

Select @strMessage AS strMessage
END TRY

BEGIN CATCH
	SELECT '' AS strMessage
END CATCH
