CREATE PROCEDURE uspIPContractPropertyNotify
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

DECLARE @Data TABLE (
	intRecordId int identity(1,1)
	,strAllocationNumber NVARCHAR(50)
	,strPContractNumber NVARCHAR(50)
	,strSContractNumber NVARCHAR(50)
	,strName NVARCHAR(50)
	,strPValue NVARCHAR(50)
	,strSValue NVARCHAR(50)
	)

INSERT INTO @Data
SELECT strAllocationNumber
	,PH.strContractNumber + '/' + ltrim(P.intContractSeq)
	,SH.strContractNumber + '/' + ltrim(S.intContractSeq)
	,'Futures Market'
	,PF.strFutMarketName
	,SF.strFutMarketName
FROM dbo.tblLGAllocationDetail AD
JOIN tblLGAllocationHeader A ON A.intAllocationHeaderId = AD.intAllocationHeaderId
JOIN dbo.tblCTContractDetail P ON P.intContractDetailId = AD.intPContractDetailId
JOIN dbo.tblCTContractHeader PH ON PH.intContractHeaderId = P.intContractHeaderId
JOIN dbo.tblCTContractDetail S ON S.intContractDetailId = AD.intSContractDetailId
JOIN dbo.tblCTContractHeader SH ON SH.intContractHeaderId = S.intContractHeaderId
JOIN dbo.tblRKFutureMarket PF ON PF.intFutureMarketId = P.intFutureMarketId
JOIN dbo.tblRKFutureMarket SF ON SF.intFutureMarketId = S.intFutureMarketId
WHERE P.intFutureMarketId <> S.intFutureMarketId
	AND (
		P.intContractStatusId = 1
		OR S.intContractStatusId = 1
		)

INSERT INTO @Data
SELECT strAllocationNumber
	,PH.strContractNumber + '/' + ltrim(P.intContractSeq)
	,SH.strContractNumber + '/' + ltrim(S.intContractSeq)
	,'Futures Month'
	,PF.strFutureMonth
	,SF.strFutureMonth
FROM dbo.tblLGAllocationDetail AD
JOIN tblLGAllocationHeader A ON A.intAllocationHeaderId = AD.intAllocationHeaderId
JOIN dbo.tblCTContractDetail P ON P.intContractDetailId = AD.intPContractDetailId
JOIN dbo.tblCTContractHeader PH ON PH.intContractHeaderId = P.intContractHeaderId
JOIN dbo.tblCTContractDetail S ON S.intContractDetailId = AD.intSContractDetailId
JOIN dbo.tblCTContractHeader SH ON SH.intContractHeaderId = S.intContractHeaderId
JOIN dbo.tblRKFuturesMonth PF ON PF.intFutureMonthId = P.intFutureMonthId
JOIN dbo.tblRKFuturesMonth SF ON SF.intFutureMonthId = S.intFutureMonthId
WHERE P.intFutureMonthId <> S.intFutureMonthId
	AND (
		P.intContractStatusId = 1
		OR S.intContractStatusId = 1
		)

INSERT INTO @Data
SELECT strAllocationNumber
	,PH.strContractNumber + '/' + ltrim(P.intContractSeq)
	,SH.strContractNumber + '/' + ltrim(S.intContractSeq)
	,'Bundle Item'
	,I.strItemNo
	,I1.strItemNo
FROM dbo.tblLGAllocationDetail AD
JOIN tblLGAllocationHeader A ON A.intAllocationHeaderId = AD.intAllocationHeaderId
JOIN dbo.tblCTContractDetail P ON P.intContractDetailId = AD.intPContractDetailId
JOIN dbo.tblCTContractHeader PH ON PH.intContractHeaderId = P.intContractHeaderId
JOIN dbo.tblCTContractDetail S ON S.intContractDetailId = AD.intSContractDetailId
JOIN dbo.tblCTContractHeader SH ON SH.intContractHeaderId = S.intContractHeaderId
JOIN dbo.tblICItemBundle PF ON PF.intItemBundleId = P.intItemBundleId
JOIN dbo.tblICItem I ON I.intItemId = PF.intBundleItemId
JOIN dbo.tblICItemBundle SF ON SF.intItemBundleId = S.intItemBundleId
JOIN dbo.tblICItem I1 ON I1.intItemId = SF.intBundleItemId
WHERE P.intItemBundleId <> S.intItemBundleId
	AND (
		P.intContractStatusId = 1
		OR S.intContractStatusId = 1
		)

INSERT INTO @Data
SELECT strAllocationNumber
	,PH.strContractNumber + '/' + ltrim(P.intContractSeq)
	,SH.strContractNumber + '/' + ltrim(S.intContractSeq)
	,'Item'
	,I.strItemNo
	,I1.strItemNo
FROM dbo.tblLGAllocationDetail AD
JOIN tblLGAllocationHeader A ON A.intAllocationHeaderId = AD.intAllocationHeaderId
JOIN dbo.tblCTContractDetail P ON P.intContractDetailId = AD.intPContractDetailId
JOIN dbo.tblCTContractHeader PH ON PH.intContractHeaderId = P.intContractHeaderId
JOIN dbo.tblCTContractDetail S ON S.intContractDetailId = AD.intSContractDetailId
JOIN dbo.tblCTContractHeader SH ON SH.intContractHeaderId = S.intContractHeaderId
JOIN dbo.tblICItem I ON I.intItemId = P.intItemId
JOIN dbo.tblICItem I1 ON I1.intItemId = S.intItemId
WHERE P.intItemId <> S.intItemId
	AND (
		P.intContractStatusId = 1
		OR S.intContractStatusId = 1
		)

INSERT INTO @Data
SELECT strAllocationNumber
	,PH.strContractNumber + '/' + ltrim(P.intContractSeq)
	,SH.strContractNumber + '/' + ltrim(S.intContractSeq)
	,'Position'
	,PP.strPosition
	,SP.strPosition
FROM dbo.tblLGAllocationDetail AD
JOIN tblLGAllocationHeader A ON A.intAllocationHeaderId = AD.intAllocationHeaderId
JOIN dbo.tblCTContractDetail P ON P.intContractDetailId = AD.intPContractDetailId
JOIN dbo.tblCTContractHeader PH ON PH.intContractHeaderId = P.intContractHeaderId
JOIN dbo.tblCTContractDetail S ON S.intContractDetailId = AD.intSContractDetailId
JOIN dbo.tblCTContractHeader SH ON SH.intContractHeaderId = S.intContractHeaderId
JOIN dbo.tblCTPosition PP ON PP.intPositionId = PH.intPositionId
JOIN dbo.tblCTPosition SP ON SP.intPositionId = SH.intPositionId
WHERE PH.intPositionId <> SH.intPositionId
	AND (
		P.intContractStatusId = 1
		OR S.intContractStatusId = 1
		)

INSERT INTO @Data
SELECT strAllocationNumber
	,PH.strContractNumber + '/' + ltrim(P.intContractSeq)
	,SH.strContractNumber + '/' + ltrim(S.intContractSeq)
	,'Start Date'
	,Convert(char(10),P.dtmStartDate,126)
	,Convert(char(10),S.dtmStartDate,126)
FROM dbo.tblLGAllocationDetail AD
JOIN tblLGAllocationHeader A ON A.intAllocationHeaderId = AD.intAllocationHeaderId
JOIN dbo.tblCTContractDetail P ON P.intContractDetailId = AD.intPContractDetailId
JOIN dbo.tblCTContractHeader PH ON PH.intContractHeaderId = P.intContractHeaderId
JOIN dbo.tblCTContractDetail S ON S.intContractDetailId = AD.intSContractDetailId
JOIN dbo.tblCTContractHeader SH ON SH.intContractHeaderId = S.intContractHeaderId
WHERE P.dtmStartDate <> S.dtmStartDate
	AND (
		P.intContractStatusId = 1
		OR S.intContractStatusId = 1
		)

INSERT INTO @Data
SELECT strAllocationNumber
	,PH.strContractNumber + '/' + ltrim(P.intContractSeq)
	,SH.strContractNumber + '/' + ltrim(S.intContractSeq)
	,'End Date'
	,Convert(char(10),P.dtmEndDate,126)
	,Convert(char(10),S.dtmEndDate,126)
FROM dbo.tblLGAllocationDetail AD
JOIN tblLGAllocationHeader A ON A.intAllocationHeaderId = AD.intAllocationHeaderId
JOIN dbo.tblCTContractDetail P ON P.intContractDetailId = AD.intPContractDetailId
JOIN dbo.tblCTContractHeader PH ON PH.intContractHeaderId = P.intContractHeaderId
JOIN dbo.tblCTContractDetail S ON S.intContractDetailId = AD.intSContractDetailId
JOIN dbo.tblCTContractHeader SH ON SH.intContractHeaderId = S.intContractHeaderId
WHERE P.dtmEndDate <> S.dtmEndDate
	AND (
		P.intContractStatusId = 1
		OR S.intContractStatusId = 1
		)

INSERT INTO @Data
SELECT strAllocationNumber
	,PH.strContractNumber + '/' + ltrim(P.intContractSeq)
	,SH.strContractNumber + '/' + ltrim(S.intContractSeq)
	,'Quantity'
	,[dbo].[fnRemoveTrailingZeroes](AD.dblSAllocatedQty)
	,[dbo].[fnRemoveTrailingZeroes](S.dblQuantity)
FROM dbo.tblLGAllocationDetail AD
JOIN tblLGAllocationHeader A ON A.intAllocationHeaderId = AD.intAllocationHeaderId
JOIN dbo.tblCTContractDetail P ON P.intContractDetailId = AD.intPContractDetailId
JOIN dbo.tblCTContractHeader PH ON PH.intContractHeaderId = P.intContractHeaderId
JOIN dbo.tblCTContractDetail S ON S.intContractDetailId = AD.intSContractDetailId
	AND S.intContractStatusId = 1
JOIN dbo.tblCTContractHeader SH ON SH.intContractHeaderId = S.intContractHeaderId
WHERE AD.dblSAllocatedQty <> S.dblQuantity

SET @strHeader = '<tr><th>&nbsp;SerialNo</th>
						<th>&nbsp;AllocationNumber</th>
						<th>&nbsp;P-ContractNumber</th>
						<th>&nbsp;S-ContractNumber</th>
						<th>&nbsp;Attribute</th>
						<th>&nbsp;P-Contract Value</th>
						<th>&nbsp;S-Contract Value</th>
					</tr>'

SELECT @strDetail = @strDetail + '<tr><td>&nbsp;' + ISNULL(CONVERT(NVARCHAR, intRecordId), '') + '</td>
			<td>&nbsp;' + ISNULL(CONVERT(NVARCHAR, strAllocationNumber), '') + '</td>' + '<td>&nbsp;' + ISNULL(strPContractNumber, '') + '</td>' + '<td>&nbsp;' + ISNULL(strSContractNumber, '') + '</td>' + '<td>&nbsp;' + strName + '</td>' + '<td>&nbsp;' + strPValue + '</td>' + '<td>&nbsp;' + strSValue + '</td> 
	</tr>'
FROM @Data
Order by intRecordId
SET @strHtml = REPLACE(@strHtml, '@header', @strHeader)
SET @strHtml = REPLACE(@strHtml, '@detail', @strDetail)
SET @strMessage = @strStyle + @strHtml

IF ISNULL(@strDetail, '') = ''
	SET @strMessage = ''

SELECT @strMessage AS strMessage

