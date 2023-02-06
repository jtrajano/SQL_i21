CREATE VIEW [dbo].[vyuCMUnpostedTransaction]
AS 

WITH BT AS(
	SELECT 
	intTransactionId
	,strTransactionId
	,strTransactionType = (SELECT strBankTransactionTypeName FROM tblCMBankTransactionType WHERE intBankTransactionTypeId = BT.intBankTransactionTypeId)
	,dtmDate
	,strMemo as strDescription
	,strUserName = (SELECT strName from tblEMEntity where intEntityId = BT.intEntityId)
	,intEntityId
	,dblAmount
	FROM tblCMBankTransaction BT
	WHERE ISNULL(ysnPosted,0) = 0 and  ISNULL(ysnCheckVoid,0) = 0
),
-- BTransferType AS(
-- 	SELECT intBankTransferTypeId = 1 , strType = 'Bank Transfer'  UNION
-- 	SELECT intBankTransferTypeId = 2 , strType = 'Bank Transfer With In transit' UNION
-- 	SELECT intBankTransferTypeId = 3 , strType = 'Bank Forward' UNION
-- 	SELECT intBankTransferTypeId = 4 , strType = 'Swap Short'  UNION
-- 	SELECT intBankTransferTypeId = 5 , strType = 'Swap Long'
-- ),
BTransfer AS(
	-- reg bank transfer
	SELECT 
		intTransactionId,
		strTransactionId,
		dtmInTransit dtmDate,
		strDescription,
		intEntityId,
		intBankTransferTypeId,
		dblAmountTo dblAmount
	FROM tblCMBankTransfer BTransfer
	WHERE ISNULL( ysnPosted, 0) = 0 and intBankTransferTypeId in( 2,4,5) UNION ALL
	SELECT 
		intTransactionId,
		strTransactionId,
		dtmDate,
		strDescription,
		intEntityId,
		intBankTransferTypeId,
		dblAmountTo dblAmount
	FROM tblCMBankTransfer BTransfer
	WHERE ISNULL( ysnPostedInTransit, 0) = 0
	AND intBankTransferTypeId IN (2,4,5) UNION ALL
	SELECT 
		intTransactionId,
		strTransactionId,
		dtmDate,
		strDescription,
		intEntityId,
		intBankTransferTypeId,
		dblAmountTo dblAmount
	FROM tblCMBankTransfer BTransfer
	WHERE ISNULL( ysnPosted, 0) = 0 AND intBankTransferTypeId in( 1,3) UNION  ALL
	-- bank intransit
	SELECT 
		intTransactionId,
		strTransactionId,
		dtmAccrual dtmDate,
		strDescription,
		intEntityId,
		intBankTransferTypeId,
		dblAmountTo dblAmount
	FROM tblCMBankTransfer BTransfer
	WHERE ISNULL( ysnPostedInTransit, 0) = 0
	AND intBankTransferTypeId = 3
)
SELECT 
intTransactionId,
strTransactionId,
strTransactionType,
dtmDate,
strDescription,
strUserName,
intEntityId,
dblAmount
FROM BT
UNION ALL
SELECT 
intTransactionId,
strTransactionId,
'Bank Transfer' strTransactionType,
MIN(dtmDate) dtmDate,
strDescription,
T.strName strUserName,
intEntityId,
dblAmount
FROM BTransfer A 
OUTER  APPLY(
 	SELECT TOP 1 strName from tblEMEntity where intEntityId = A.intEntityId
 )T
