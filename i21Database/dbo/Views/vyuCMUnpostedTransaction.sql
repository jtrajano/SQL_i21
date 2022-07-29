CREATE VIEW [dbo].[vyuCMUnpostedTransaction]
AS 
SELECT 
intTransactionId
,strTransactionId
,strTransactionType = (SELECT strBankTransactionTypeName FROM tblCMBankTransactionType WHERE intBankTransactionTypeId = BT.intBankTransactionTypeId)
,dtmDate
,strMemo as strDescription
,strUserName = (SELECT strName from tblEMEntity where intEntityId = BT.intEntityId)
,intEntityId
FROM tblCMBankTransaction BT
WHERE ISNULL(ysnPosted,0) = 0 and  ISNULL(ysnCheckVoid,0) = 0
UNION
SELECT 
intTransactionId,
strTransactionId,
strTransactionType = (SELECT strBankTransactionTypeName FROM tblCMBankTransactionType WHERE intBankTransactionTypeId = BTransfer.intBankTransactionTypeId),
CASE WHEN intBankTransferTypeId = 3 THEN dtmAccrual ELSE dtmDate END dtmDate,
strDescription,
strUserName = (SELECT strName from tblEMEntity where intEntityId = BTransfer.intEntityId),
intEntityId
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
intEntityId
FROM tblCMBankTransfer BTransfer
WHERE ISNULL( ysnPosted, 0) = 0
AND intBankTransferTypeId > 1

