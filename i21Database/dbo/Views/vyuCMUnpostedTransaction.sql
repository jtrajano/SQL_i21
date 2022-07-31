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
	SELECT 
		intTransactionId,
		strTransactionId,
		strTransactionType = (SELECT strBankTransactionTypeName FROM tblCMBankTransactionType WHERE intBankTransactionTypeId = BTransfer.intBankTransactionTypeId),
		CASE WHEN intBankTransferTypeId = 3 THEN dtmAccrual ELSE dtmDate END dtmDate,
		strDescription,
		strUserName = (SELECT strName from tblEMEntity where intEntityId = BTransfer.intEntityId),
		intEntityId,
		intBankTransferTypeId,
		dblAmountFrom dblAmount
	FROM tblCMBankTransfer BTransfer
	WHERE ISNULL( CASE WHEN intBankTransferTypeId = 1 THEN ysnPosted ELSE ysnPostedInTransit END, 0) = 0
	UNION ALL
	SELECT 
		intTransactionId,
		strTransactionId,
		strTransactionType = (SELECT strBankTransactionTypeName FROM tblCMBankTransactionType WHERE intBankTransactionTypeId = BTransfer.intBankTransactionTypeId),
		CASE WHEN intBankTransferTypeId = 3 THEN dtmDate ELSE dtmInTransit END dtmDate,
		strDescription,
		strUserName = (SELECT strName from tblEMEntity where intEntityId = BTransfer.intEntityId),
		intEntityId,
		intBankTransferTypeId,
		dblAmountTo dblAmount
	FROM tblCMBankTransfer BTransfer
	WHERE ISNULL( ysnPosted, 0) = 0
	AND intBankTransferTypeId > 1
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
UNION
SELECT 
intTransactionId,
strTransactionId,
'Bank Transfer' strTransactionType,
dtmDate,
strDescription,
strUserName,
intEntityId,
dblAmount
FROM BTransfer A 
-- ROSS APPLY(
-- 	SELECT strType FROM BTransferType WHERE intBankTransferTypeId = A.intBankTransferTypeId
-- )T