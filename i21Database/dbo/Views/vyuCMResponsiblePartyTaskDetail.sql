CREATE VIEW [dbo].[vyuCMResponsiblePartyTaskDetail]      
AS      
SELECT     
A.*,    
BT.strTransactionId,
GL.strAccountId,    
BA.strBankAccountNo,    
EM.strName,    
isnull(BT.ysnPosted, 0) ysnPosted  
FROM tblCMResponsiblePartyTaskDetail A LEFT JOIN    
vyuCMBankAccount BA on BA.intBankAccountId = A.intBankAccountId    
left JOIN tblGLAccount GL on GL.intAccountId = A.intGLAccountId    
left JOIN tblEMEntity EM on EM.intEntityId = A.intEntityId    
LEFT JOIN tblCMBankTransaction BT on BT.intTransactionId = A.intTransactionId