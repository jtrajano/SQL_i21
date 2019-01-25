﻿CREATE PROCEDURE [dbo].[uspMFGetTraceabilityContractDetail] @intContractId INT
	,@intDirectionId INT
AS
SET NOCOUNT ON;

SELECT 'Contract' AS strTransactionName
	,CD.intContractHeaderId intLotId
	,CH.strContractNumber strLotNumber
	,'' strLotAlias
	,i.intItemId
	,i.strItemNo
	,i.strDescription strDescription
	,0 intCategoryId
	,'' strCategoryCode
	,SUM(CD.dblQuantity) dblQuantity
	,'' strUOM
	,CH.dtmContractDate AS dtmTransactionDate
	,'' strVendor
	,2 AS intImageTypeId
	,'C' AS strType
FROM tblCTContractDetail CD
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
JOIN tblICItem i ON CD.intItemId = i.intItemId
WHERE CD.intContractHeaderId = @intContractId
GROUP BY CD.intContractHeaderId
	,CH.strContractNumber
	,i.intItemId
	,i.strItemNo
	,i.strDescription
	,CH.dtmContractDate
