CREATE PROCEDURE [dbo].[uspIPGenerateSAPFeedFailureEmailMessage]
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

If @strMessageType='PO1'
Begin
	SET @strHeader = '<tr>
						<th>&nbsp;Contract No</th>
						<th>&nbsp;Sequence No</th>
						<th>&nbsp;Type</th>
						<th>&nbsp;PO No</th>
						<th>&nbsp;Commodity</th>
						<th>&nbsp;Message</th>
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
	From tblCTContractFeed 
	Where ISNULL(strMessage,'') NOT IN ('', 'Success') AND GETDATE() > DATEADD(MI,@intDuration,dtmFeedCreated)
	AND ISNULL(ysnMailSent,0)=0

	Update tblCTContractFeed Set ysnMailSent=1
	Where ISNULL(strMessage,'') NOT IN ('', 'Success') AND GETDATE() > DATEADD(MI,@intDuration,dtmFeedCreated)
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
	AND ISNULL(strMessage, '') NOT LIKE 'Received different Shipment Number from SAP%'
	AND ISNULL(ysnMailSent,0)=0

	Update tblLGLoadStg Set ysnMailSent=1
	Where strFeedStatus='Ack Rcvd' AND ISNULL(strMessage,'') NOT IN ('', 'Success') AND GETDATE() > DATEADD(MI,@intDuration,dtmFeedCreated)
	AND ISNULL(strMessage, '') NOT LIKE 'Received different Shipment Number from SAP%'
	AND ISNULL(ysnMailSent,0)=0
End

If @strMessageType='Shipment1'
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
	Where strFeedStatus='Ack Rcvd' AND ISNULL(strMessage,'') NOT IN ('', 'Success')
	AND ISNULL(strMessage, '') LIKE 'Received different Shipment Number from SAP%'
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
						<th>&nbsp;Partner</th>
					</tr>'
	
	Select @strDetail=@strDetail + 
	'<tr>
		   <td>&nbsp;'  + ISNULL(strDeliveryNo,'') + '</td>'
		+ '<td>&nbsp;' + ISNULL(strErrorMessage,'') + '</td>'
		+ '<td>&nbsp;' + CASE WHEN strPartnerNo='0012XI01' THEN 'MBN' When strPartnerNo='JMWPO01' THEN 'JMW' Else '' End + '</td>
	</tr>'
	From tblIPReceiptError r
	Where strPartnerNo IN ('0012XI01','JMWPO01')
	AND ISNULL(ysnMailSent,0)=0 AND ISNULL(strErrorMessage,'') <>'Success'

	Update tblIPReceiptError Set ysnMailSent=1
	Where strPartnerNo IN ('0012XI01','JMWPO01') AND ISNULL(strErrorMessage,'') <>'Success'
	AND ISNULL(ysnMailSent,0)=0
End

If @strMessageType='GL'
Begin
	SET @strHeader = '<tr>
						<th>&nbsp;Type</th>
						<th>&nbsp;Match No</th>
						<th>&nbsp;Book</th>
						<th>&nbsp;Market Name</th>
						<th>&nbsp;Reference No</th>
						<th>&nbsp;Ack Message</th>
					</tr>'
	
	Select @strDetail=@strDetail + 
	'<tr>
		   <td>&nbsp;'  + 'Future' + '</td>'
		+ '<td>&nbsp;' + ISNULL(CONVERT(VARCHAR,intMatchNo),'') + '</td>'
		+ '<td>&nbsp;' + ISNULL(strBook,'') + '</td>'
		+ '<td>&nbsp;' + ISNULL(strFutMarketName,'') + '</td>'
		+ '<td>&nbsp;' + ISNULL(strReferenceNo,'') + '</td>'
		+ '<td>&nbsp;' + ISNULL(strMessage,'') + '</td>
	</tr>'
	From tblRKStgMatchPnS 
	Where strStatus='Ack Rcvd' AND ISNULL(strMessage,'') NOT IN ('', 'Success') AND GETDATE() > DATEADD(MI,@intDuration,dtmPostingDate)
	AND ISNULL(ysnMailSent,0)=0

	Update tblRKStgMatchPnS Set ysnMailSent=1
	Where strStatus='Ack Rcvd' AND ISNULL(strMessage,'') NOT IN ('', 'Success') AND GETDATE() > DATEADD(MI,@intDuration,dtmPostingDate)
	AND ISNULL(ysnMailSent,0)=0

	Select @strDetail=@strDetail + 
	'<tr>
		   <td>&nbsp;'  + 'Option' + '</td>'
		+ '<td>&nbsp;' + ISNULL(CONVERT(VARCHAR,intMatchNo),'') + '</td>'
		+ '<td>&nbsp;' + ISNULL(strBook,'') + '</td>'
		+ '<td>&nbsp;' + ISNULL(strFutMarketName,'') + '</td>'
		+ '<td>&nbsp;' + ISNULL(strReferenceNo,'') + '</td>'
		+ '<td>&nbsp;' + ISNULL(strMessage,'') + '</td>
	</tr>'
	From tblRKStgOptionMatchPnS 
	Where strStatus='Ack Rcvd' AND ISNULL(strMessage,'') NOT IN ('', 'Success') AND GETDATE() > DATEADD(MI,@intDuration,dtmPostingDate)
	AND ISNULL(ysnMailSent,0)=0

	Update tblRKStgOptionMatchPnS Set ysnMailSent=1
	Where strStatus='Ack Rcvd' AND ISNULL(strMessage,'') NOT IN ('', 'Success') AND GETDATE() > DATEADD(MI,@intDuration,dtmPostingDate)
	AND ISNULL(ysnMailSent,0)=0
End

If @strMessageType='PO No Ack'
Begin
	SET @strHeader = '<tr>
						<th>&nbsp;Feed Status</th>
						<th>&nbsp;Contract No</th>
						<th>&nbsp;Seq No</th>
						<th>&nbsp;Row State</th>
						<th>&nbsp;PO No</th>
					</tr>'
	
	Select @strDetail=@strDetail + 
	'<tr>
		   <td>&nbsp;'  + ISNULL(strFeedStatus,'') + '</td>'
		+ '<td>&nbsp;' + ISNULL(strContractNumber,'') + '</td>'
		+ '<td>&nbsp;' + ISNULL(CONVERT(VARCHAR,intContractSeq),'') + '</td>'
		+ '<td>&nbsp;' + CASE WHEN UPPER(strRowState)='ADDED' THEN 'Create' When UPPER(strRowState)='DELETE' THEN 'Delete' Else 'Update' End + '</td>'
		+ '<td>&nbsp;' + ISNULL(strERPPONumber,'') + '</td>
	</tr>'
	FROM tblCTContractFeed
	WHERE ISNULL(strFeedStatus, '') = 'Awt Ack'
	--AND dtmFeedCreated > CONVERT(DATE, GETDATE() - 1)
End

If @strMessageType='GL No Ack'
Begin
	SET @strHeader = '<tr>
						<th>&nbsp;Type</th>
						<th>&nbsp;Match No</th>
						<th>&nbsp;Book</th>
						<th>&nbsp;Market Name</th>
						<th>&nbsp;Reference No</th>
						<th>&nbsp;Feed Status</th>
					</tr>'
	
	Select @strDetail=@strDetail + 
	'<tr>
		   <td>&nbsp;'  + 'Future' + '</td>'
		+ '<td>&nbsp;' + ISNULL(CONVERT(VARCHAR,intMatchNo),'') + '</td>'
		+ '<td>&nbsp;' + ISNULL(strBook,'') + '</td>'
		+ '<td>&nbsp;' + ISNULL(strFutMarketName,'') + '</td>'
		+ '<td>&nbsp;' + ISNULL(strReferenceNo,'') + '</td>'
		+ '<td>&nbsp;' + ISNULL(strStatus,'') + '</td>
	</tr>'
	From tblRKStgMatchPnS 
	WHERE ISNULL(strStatus, '') = 'Awt Ack'
	--AND dtmFeedCreated > CONVERT(DATE, GETDATE() - 1)

	Select @strDetail=@strDetail + 
	'<tr>
		   <td>&nbsp;'  + 'Option' + '</td>'
		+ '<td>&nbsp;' + ISNULL(CONVERT(VARCHAR,intMatchNo),'') + '</td>'
		+ '<td>&nbsp;' + ISNULL(strBook,'') + '</td>'
		+ '<td>&nbsp;' + ISNULL(strFutMarketName,'') + '</td>'
		+ '<td>&nbsp;' + ISNULL(strReferenceNo,'') + '</td>'
		+ '<td>&nbsp;' + ISNULL(strStatus,'') + '</td>
	</tr>'
	From tblRKStgOptionMatchPnS 
	WHERE ISNULL(strStatus, '') = 'Awt Ack'
	--AND dtmFeedCreated > CONVERT(DATE, GETDATE() - 1)
End

If @strMessageType='Failure'
Begin
	SET @strHeader = '<tr>
						<th>&nbsp;Log Id</th>
						<th>&nbsp;Info 1</th>
						<th>&nbsp;Info 2</th>
						<th>&nbsp;Message</th>
					</tr>'
	
	Select @strDetail=@strDetail + 
	'<tr>
		   <td>&nbsp;' + ISNULL(CONVERT(VARCHAR,intLogId),'') + '</td>'
		+ '<td>&nbsp;' + ISNULL(strInfo1,'') + '</td>'
		+ '<td>&nbsp;' + ISNULL(strInfo2,'') + '</td>'
		+ '<td>&nbsp;' + ISNULL(strMessage,'') + '</td>
	</tr>'
	FROM tblIPLog
	WHERE dtmDate >= DATEADD(hh, -1, GETDATE())
		AND ISNULL(strMessage, '') <> 'Success'

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
