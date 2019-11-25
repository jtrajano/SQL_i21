CREATE PROCEDURE [dbo].[uspCTFeedNotSentEmailMessage]

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

	BEGIN
		SET @strHeader = '<tr>  
		  <th>&nbsp;Contract No</th>  
		  <th>&nbsp;Record Id</th>  
		  <th>&nbsp;Feed Status</th>  
		 </tr>'

		SELECT @strDetail = @strDetail + '<tr>  
		 <td>&nbsp;' + ISNULL(TR.strTransactionNo, '') + '</td>' + '<td>&nbsp;' + ISNULL(LTRIM(TR.intRecordId), '') + '</td>'
		 + '<td>&nbsp;' + ' ' + '</td>
	 </tr>'
		FROM tblSMTransaction TR WITH (NOLOCK)
		LEFT JOIN tblCTContractFeed FD WITH (NOLOCK) ON FD.intContractHeaderId = TR.intRecordId
		WHERE TR.intScreenId = 11
			AND ISNULL(TR.ysnOnceApproved, 0) = 1
			AND FD.intContractFeedId IS NULL
			AND TR.strTransactionNo NOT LIKE 'CP%'
			AND intTransactionId <> 58191

		Select @strDetail=@strDetail + 
		'<tr>
			   <td>&nbsp;' + ISNULL(CF.strContractNumber,'') + '</td>'
			+ '<td>&nbsp;' + ISNULL(LTRIM(CF.intContractHeaderId), '') + '</td>'
			+ '<td>&nbsp;' + ISNULL(CF.strFeedStatus,'') + '</td>
		</tr>'
		FROM tblCTContractFeed CF WITH (NOLOCK)
		WHERE ISNULL(CF.strFeedStatus, '') = 'Awt Ack'
			AND CF.strRowState <> 'Delete'
			AND GETDATE() > DATEADD(MI, 15, CF.dtmFeedCreated)
	END

	SET @strHtml = REPLACE(@strHtml, '@header', @strHeader)
	SET @strHtml = REPLACE(@strHtml, '@detail', @strDetail)
	SET @strMessage = @strStyle + @strHtml

	IF ISNULL(@strDetail, '') = ''
		SET @strMessage = ''

	SELECT @strMessage AS strMessage
