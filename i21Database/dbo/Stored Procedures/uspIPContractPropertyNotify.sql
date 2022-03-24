CREATE PROCEDURE uspIPContractPropertyNotify
AS
DECLARE @strStyle NVARCHAR(MAX)
	,@strHtml NVARCHAR(MAX)
	,@strHeader NVARCHAR(MAX)
	,@strDetail NVARCHAR(MAX) = ''
	,@strHeader2 NVARCHAR(MAX)
	,@strDetail2 NVARCHAR(MAX) = ''
	,@strMessage NVARCHAR(MAX)
	,@intBookId INT
	,@dtmProcessedDate DATETIME

SELECT @dtmProcessedDate = Convert(DATETIME, Convert(CHAR, Getdate(), 101))

IF EXISTS (
		SELECT *
		FROM tblIPContractPropertyNotify
		WHERE dtmProcessedDate = @dtmProcessedDate
		)
BEGIN
	SET @strMessage = ''

	SELECT @strMessage AS strMessage

	RETURN
END
ELSE
BEGIN
	INSERT INTO tblIPContractPropertyNotify (dtmProcessedDate)
	SELECT @dtmProcessedDate
END

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
							@header2
							@detail2
						</tbody>
					</table>
					<br>
					<br>
					<br>
					<br>
					<br>
					<table class="GeneratedTable">
						<tbody>
							@header
							@detail
						</tbody>
					</table>

					</body>
				</html>'

DECLARE @Data TABLE (
	intRecordId INT identity(1, 1)
	,strAllocationNumber NVARCHAR(50)
	,strPContractNumber NVARCHAR(50)
	,strSContractNumber NVARCHAR(50)
	,strName NVARCHAR(50)
	,strPValue NVARCHAR(50)
	,strSValue NVARCHAR(50)
	,strBook NVARCHAR(50)
	)
DECLARE @Data2 TABLE (
	intRecordId INT identity(1, 1)
	,strSContractNumber NVARCHAR(50)
	,strName NVARCHAR(50)
	,strPValue NVARCHAR(50)
	,strSValue NVARCHAR(50)
	,strBook NVARCHAR(50)
	)

SELECT @intBookId = intBookId
FROM tblIPMultiCompany
WHERE ysnPandSContractPositionSame = 0

INSERT INTO @Data
SELECT strAllocationNumber
	,PH.strContractNumber + '/' + ltrim(P.intContractSeq)
	,SH.strContractNumber + '/' + ltrim(S.intContractSeq)
	,'Futures Market'
	,PF.strFutMarketName
	,SF.strFutMarketName
	,B.strBook
FROM dbo.tblLGAllocationDetail AD
JOIN tblLGAllocationHeader A ON A.intAllocationHeaderId = AD.intAllocationHeaderId
JOIN dbo.tblCTContractDetail P ON P.intContractDetailId = AD.intPContractDetailId
JOIN dbo.tblCTContractHeader PH ON PH.intContractHeaderId = P.intContractHeaderId
JOIN dbo.tblCTContractDetail S ON S.intContractDetailId = AD.intSContractDetailId
JOIN dbo.tblCTContractHeader SH ON SH.intContractHeaderId = S.intContractHeaderId
JOIN dbo.tblRKFutureMarket PF ON PF.intFutureMarketId = P.intFutureMarketId
JOIN dbo.tblRKFutureMarket SF ON SF.intFutureMarketId = S.intFutureMarketId
JOIN tblCTBook B ON B.intBookId = SH.intBookId
WHERE P.intFutureMarketId <> S.intFutureMarketId
	AND (
		P.intContractStatusId = 1
		OR S.intContractStatusId = 1
		)
	AND IsNULL(PH.ysnMaxPrice, 0) <> 1

INSERT INTO @Data
SELECT strAllocationNumber
	,PH.strContractNumber + '/' + ltrim(P.intContractSeq)
	,SH.strContractNumber + '/' + ltrim(S.intContractSeq)
	,'Futures Month'
	,PF.strFutureMonth
	,SF.strFutureMonth
	,B.strBook
FROM dbo.tblLGAllocationDetail AD
JOIN tblLGAllocationHeader A ON A.intAllocationHeaderId = AD.intAllocationHeaderId
JOIN dbo.tblCTContractDetail P ON P.intContractDetailId = AD.intPContractDetailId
JOIN dbo.tblCTContractHeader PH ON PH.intContractHeaderId = P.intContractHeaderId
JOIN dbo.tblCTContractDetail S ON S.intContractDetailId = AD.intSContractDetailId
JOIN dbo.tblCTContractHeader SH ON SH.intContractHeaderId = S.intContractHeaderId
JOIN dbo.tblRKFuturesMonth PF ON PF.intFutureMonthId = P.intFutureMonthId
JOIN dbo.tblRKFuturesMonth SF ON SF.intFutureMonthId = S.intFutureMonthId
JOIN tblCTBook B ON B.intBookId = SH.intBookId
WHERE P.intFutureMonthId <> S.intFutureMonthId
	AND (
		P.intContractStatusId = 1
		OR S.intContractStatusId = 1
		)
	AND IsNULL(PH.ysnMaxPrice, 0) <> 1

INSERT INTO @Data
SELECT strAllocationNumber
	,PH.strContractNumber + '/' + ltrim(P.intContractSeq)
	,SH.strContractNumber + '/' + ltrim(S.intContractSeq)
	,'Bundle Item'
	,I.strItemNo
	,I1.strItemNo
	,B.strBook
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
JOIN tblCTBook B ON B.intBookId = SH.intBookId
WHERE P.intItemBundleId <> S.intItemBundleId
	AND (
		P.intContractStatusId = 1
		OR S.intContractStatusId = 1
		)
	AND IsNULL(PH.ysnMaxPrice, 0) <> 1

INSERT INTO @Data
SELECT strAllocationNumber
	,PH.strContractNumber + '/' + ltrim(P.intContractSeq)
	,SH.strContractNumber + '/' + ltrim(S.intContractSeq)
	,'Item'
	,I.strItemNo
	,I1.strItemNo
	,B.strBook
FROM dbo.tblLGAllocationDetail AD
JOIN tblLGAllocationHeader A ON A.intAllocationHeaderId = AD.intAllocationHeaderId
JOIN dbo.tblCTContractDetail P ON P.intContractDetailId = AD.intPContractDetailId
JOIN dbo.tblCTContractHeader PH ON PH.intContractHeaderId = P.intContractHeaderId
JOIN dbo.tblCTContractDetail S ON S.intContractDetailId = AD.intSContractDetailId
JOIN dbo.tblCTContractHeader SH ON SH.intContractHeaderId = S.intContractHeaderId
JOIN dbo.tblICItem I ON I.intItemId = P.intItemId
JOIN dbo.tblICItem I1 ON I1.intItemId = S.intItemId
JOIN tblCTBook B ON B.intBookId = SH.intBookId
WHERE P.intItemId <> S.intItemId
	AND (
		P.intContractStatusId = 1
		OR S.intContractStatusId = 1
		)
	AND IsNULL(PH.ysnMaxPrice, 0) <> 1

INSERT INTO @Data
SELECT strAllocationNumber
	,PH.strContractNumber + '/' + ltrim(P.intContractSeq)
	,SH.strContractNumber + '/' + ltrim(S.intContractSeq)
	,'Book'
	,IsNULL(PB.strBook, '')
	,IsNULL(SB.strBook, '')
	,B.strBook
FROM dbo.tblLGAllocationDetail AD
JOIN tblLGAllocationHeader A ON A.intAllocationHeaderId = AD.intAllocationHeaderId
JOIN dbo.tblCTContractDetail P ON P.intContractDetailId = AD.intPContractDetailId
JOIN dbo.tblCTContractHeader PH ON PH.intContractHeaderId = P.intContractHeaderId
JOIN dbo.tblCTContractDetail S ON S.intContractDetailId = AD.intSContractDetailId
JOIN dbo.tblCTContractHeader SH ON SH.intContractHeaderId = S.intContractHeaderId
LEFT JOIN dbo.tblCTBook PB ON PB.intBookId = P.intBookId
LEFT JOIN dbo.tblCTBook SB ON SB.intBookId = S.intBookId
JOIN tblCTBook B ON B.intBookId = SH.intBookId
WHERE P.intBookId <> S.intBookId
	AND (
		P.intContractStatusId = 1
		OR S.intContractStatusId = 1
		)
	AND IsNULL(PH.ysnMaxPrice, 0) <> 1

INSERT INTO @Data
SELECT strAllocationNumber
	,PH.strContractNumber + '/' + ltrim(P.intContractSeq)
	,SH.strContractNumber + '/' + ltrim(S.intContractSeq)
	,'Subbook'
	,isNULL(PSB.strSubBook, '')
	,IsNULL(SSB.strSubBook, '')
	,B.strBook
FROM dbo.tblLGAllocationDetail AD
JOIN tblLGAllocationHeader A ON A.intAllocationHeaderId = AD.intAllocationHeaderId
JOIN dbo.tblCTContractDetail P ON P.intContractDetailId = AD.intPContractDetailId
JOIN dbo.tblCTContractHeader PH ON PH.intContractHeaderId = P.intContractHeaderId
JOIN dbo.tblCTContractDetail S ON S.intContractDetailId = AD.intSContractDetailId
JOIN dbo.tblCTContractHeader SH ON SH.intContractHeaderId = S.intContractHeaderId
LEFT JOIN dbo.tblCTSubBook PSB ON PSB.intSubBookId = P.intSubBookId
LEFT JOIN dbo.tblCTSubBook SSB ON SSB.intSubBookId = S.intSubBookId
JOIN tblCTBook B ON B.intBookId = SH.intBookId
WHERE IsNULL(P.intSubBookId, 0) <> IsNULL(S.intSubBookId, 0)
	AND (
		P.intContractStatusId = 1
		OR S.intContractStatusId = 1
		)
	AND IsNULL(PH.ysnMaxPrice, 0) <> 1

INSERT INTO @Data
SELECT strAllocationNumber
	,PH.strContractNumber + '/' + ltrim(P.intContractSeq)
	,SH.strContractNumber + '/' + ltrim(S.intContractSeq)
	,'Position'
	,PP.strPosition
	,SP.strPosition
	,B.strBook
FROM dbo.tblLGAllocationDetail AD
JOIN tblLGAllocationHeader A ON A.intAllocationHeaderId = AD.intAllocationHeaderId
JOIN dbo.tblCTContractDetail P ON P.intContractDetailId = AD.intPContractDetailId
JOIN dbo.tblCTContractHeader PH ON PH.intContractHeaderId = P.intContractHeaderId
JOIN dbo.tblCTContractDetail S ON S.intContractDetailId = AD.intSContractDetailId
JOIN dbo.tblCTContractHeader SH ON SH.intContractHeaderId = S.intContractHeaderId
JOIN dbo.tblCTPosition PP ON PP.intPositionId = PH.intPositionId
JOIN dbo.tblCTPosition SP ON SP.intPositionId = SH.intPositionId
JOIN tblCTBook B ON B.intBookId = SH.intBookId
WHERE PH.intPositionId <> SH.intPositionId
	AND (
		P.intContractStatusId = 1
		OR S.intContractStatusId = 1
		)
	AND SH.intBookId <> @intBookId
	AND IsNULL(PH.ysnMaxPrice, 0) <> 1

INSERT INTO @Data
SELECT strAllocationNumber
	,PH.strContractNumber + '/' + ltrim(P.intContractSeq)
	,SH.strContractNumber + '/' + ltrim(S.intContractSeq)
	,'Start Date'
	,Convert(CHAR(10), P.dtmStartDate, 126)
	,Convert(CHAR(10), S.dtmStartDate, 126)
	,B.strBook
FROM dbo.tblLGAllocationDetail AD
JOIN tblLGAllocationHeader A ON A.intAllocationHeaderId = AD.intAllocationHeaderId
JOIN dbo.tblCTContractDetail P ON P.intContractDetailId = AD.intPContractDetailId
JOIN dbo.tblCTContractHeader PH ON PH.intContractHeaderId = P.intContractHeaderId
JOIN dbo.tblCTContractDetail S ON S.intContractDetailId = AD.intSContractDetailId
JOIN dbo.tblCTContractHeader SH ON SH.intContractHeaderId = S.intContractHeaderId
JOIN tblCTBook B ON B.intBookId = SH.intBookId
WHERE Convert(CHAR(10), P.dtmStartDate, 126) <> Convert(CHAR(10), S.dtmStartDate, 126)
	AND (
		P.intContractStatusId = 1
		OR S.intContractStatusId = 1
		)
	AND SH.intBookId <> @intBookId
	AND IsNULL(PH.ysnMaxPrice, 0) <> 1

INSERT INTO @Data
SELECT strAllocationNumber
	,PH.strContractNumber + '/' + ltrim(P.intContractSeq)
	,SH.strContractNumber + '/' + ltrim(S.intContractSeq)
	,'End Date'
	,Convert(CHAR(10), P.dtmEndDate, 126)
	,Convert(CHAR(10), S.dtmEndDate, 126)
	,B.strBook
FROM dbo.tblLGAllocationDetail AD
JOIN tblLGAllocationHeader A ON A.intAllocationHeaderId = AD.intAllocationHeaderId
JOIN dbo.tblCTContractDetail P ON P.intContractDetailId = AD.intPContractDetailId
JOIN dbo.tblCTContractHeader PH ON PH.intContractHeaderId = P.intContractHeaderId
JOIN dbo.tblCTContractDetail S ON S.intContractDetailId = AD.intSContractDetailId
JOIN dbo.tblCTContractHeader SH ON SH.intContractHeaderId = S.intContractHeaderId
JOIN tblCTBook B ON B.intBookId = SH.intBookId
WHERE Convert(CHAR(10), P.dtmEndDate, 126) <> Convert(CHAR(10), S.dtmEndDate, 126)
	AND (
		P.intContractStatusId = 1
		OR S.intContractStatusId = 1
		)
	AND SH.intBookId <> @intBookId
	AND IsNULL(PH.ysnMaxPrice, 0) <> 1

INSERT INTO @Data
SELECT strAllocationNumber
	,PH.strContractNumber + '/' + ltrim(P.intContractSeq)
	,SH.strContractNumber + '/' + ltrim(S.intContractSeq)
	,'Start Date'
	,Convert(CHAR(10), P.dtmStartDate, 126)
	,Convert(CHAR(10), S.dtmStartDate, 126)
	,B.strBook
FROM dbo.tblLGAllocationDetail AD
JOIN tblLGAllocationHeader A ON A.intAllocationHeaderId = AD.intAllocationHeaderId
JOIN dbo.tblCTContractDetail P ON P.intContractDetailId = AD.intPContractDetailId
JOIN dbo.tblCTContractHeader PH ON PH.intContractHeaderId = P.intContractHeaderId
JOIN dbo.tblCTContractDetail S ON S.intContractDetailId = AD.intSContractDetailId
JOIN dbo.tblCTContractHeader SH ON SH.intContractHeaderId = S.intContractHeaderId
JOIN tblCTBook B ON B.intBookId = SH.intBookId
WHERE Convert(CHAR(10), P.dtmStartDate, 126) <> Convert(CHAR(10), S.dtmStartDate, 126)
	AND (
		P.intContractStatusId = 1
		OR S.intContractStatusId = 1
		)
	AND SH.intBookId = @intBookId
	AND PH.intPositionId = SH.intPositionId
	AND IsNULL(PH.ysnMaxPrice, 0) <> 1

INSERT INTO @Data
SELECT strAllocationNumber
	,PH.strContractNumber + '/' + ltrim(P.intContractSeq)
	,SH.strContractNumber + '/' + ltrim(S.intContractSeq)
	,'End Date'
	,Convert(CHAR(10), P.dtmEndDate, 126)
	,Convert(CHAR(10), S.dtmEndDate, 126)
	,B.strBook
FROM dbo.tblLGAllocationDetail AD
JOIN tblLGAllocationHeader A ON A.intAllocationHeaderId = AD.intAllocationHeaderId
JOIN dbo.tblCTContractDetail P ON P.intContractDetailId = AD.intPContractDetailId
JOIN dbo.tblCTContractHeader PH ON PH.intContractHeaderId = P.intContractHeaderId
JOIN dbo.tblCTContractDetail S ON S.intContractDetailId = AD.intSContractDetailId
JOIN dbo.tblCTContractHeader SH ON SH.intContractHeaderId = S.intContractHeaderId
JOIN tblCTBook B ON B.intBookId = SH.intBookId
WHERE Convert(CHAR(10), P.dtmEndDate, 126) <> Convert(CHAR(10), S.dtmEndDate, 126)
	AND (
		P.intContractStatusId = 1
		OR S.intContractStatusId = 1
		)
	AND SH.intBookId = @intBookId
	AND PH.intPositionId = SH.intPositionId
	AND IsNULL(PH.ysnMaxPrice, 0) <> 1

INSERT INTO @Data2
SELECT SH.strContractNumber + '/' + ltrim(S.intContractSeq)
	,'Quantity'
	,IsNULL([dbo].[fnRemoveTrailingZeroes](SUM(AD.dblSAllocatedQty)), 0)
	,[dbo].[fnRemoveTrailingZeroes](MAX(S.dblQuantity))
	,B.strBook
FROM dbo.tblCTContractDetail S
JOIN dbo.tblCTContractHeader SH ON SH.intContractHeaderId = S.intContractHeaderId
LEFT JOIN tblLGAllocationDetail AD ON AD.intSContractDetailId = S.intContractDetailId
JOIN tblCTBook B ON B.intBookId = SH.intBookId
WHERE S.intContractStatusId = 1
	AND SH.intContractTypeId = 2
GROUP BY SH.strContractNumber + '/' + ltrim(S.intContractSeq)
	,B.strBook
HAVING IsNULL(SUM(AD.dblSAllocatedQty), 0) <> MAX(S.dblQuantity)

SET @strHeader2 = '<tr><th>&nbsp;SerialNo</th>
						<th>&nbsp;AllocationNumber</th>
						<th>&nbsp;P-ContractNumber</th>
						<th>&nbsp;S-ContractNumber</th>
						<th>&nbsp;Attribute</th>
						<th>&nbsp;P-Contract Value</th>
						<th>&nbsp;S-Contract Value</th>
						<th>&nbsp;Book</th>
					</tr>'

SELECT @strDetail2 = @strDetail2 + '<tr><td>&nbsp;' + ISNULL(CONVERT(NVARCHAR, intRecordId), '') + '</td>
			<td>&nbsp;' + ISNULL(CONVERT(NVARCHAR, strAllocationNumber), '') + '</td>' + '<td>&nbsp;' + ISNULL(strPContractNumber, '') + '</td>' + '<td>&nbsp;' + ISNULL(strSContractNumber, '') + '</td>' + '<td>&nbsp;' + strName + '</td>' + '<td>&nbsp;' + strPValue + '</td>' + '<td>&nbsp;' + strSValue + '</td>' + '<td>&nbsp;' + strBook + '</td> 
	</tr>'
FROM @Data
ORDER BY intRecordId

SET @strHtml = REPLACE(@strHtml, '@header2', @strHeader2)
SET @strHtml = REPLACE(@strHtml, '@detail2', @strDetail2)
SET @strHeader = '<tr><th>&nbsp;SerialNo</th>
						<th>&nbsp;S-ContractNumber</th>
						<th>&nbsp;Attribute</th>
						<th>&nbsp;Quantity</th>
						<th>&nbsp;Allocated Qty</th>
						<th>&nbsp;Book</th>
					</tr>'

SELECT @strDetail = @strDetail + '<tr><td>&nbsp;' + ISNULL(CONVERT(NVARCHAR, intRecordId), '') + '</td>
			<td>&nbsp;' + ISNULL(strSContractNumber, '') + '</td>' + '<td>&nbsp;' + strName + '</td>' + '<td>&nbsp;' + IsNULL(strPValue, '') + '</td>' + '<td>&nbsp;' + IsNULL(strSValue, '') + '</td>' + '<td>&nbsp;' + strBook + '</td>  
	</tr>'
FROM @Data2
ORDER BY intRecordId

SET @strHtml = REPLACE(@strHtml, '@header', @strHeader)
SET @strHtml = REPLACE(@strHtml, '@detail', @strDetail)
SET @strMessage = @strStyle + @strHtml

IF ISNULL(@strDetail, '') = ''
	AND ISNULL(@strDetail2, '') = ''
	SET @strMessage = ''

SELECT @strMessage AS strMessage
