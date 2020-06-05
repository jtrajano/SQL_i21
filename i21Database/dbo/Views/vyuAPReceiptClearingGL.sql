CREATE VIEW [dbo].[vyuAPReceiptClearingGL]    
AS     
    
SELECT DISTINCT * FROM (    
 SELECT       
 DISTINCT      
  ad.strAccountId      
  ,ad.intAccountId      
  ,t.strTransactionId      
  ,t.intTransactionDetailId   
  ,NULL AS intTransactionChargeId   
  ,t.intTransactionId      
  ,t.intItemId      
 FROM       
 tblICInventoryTransaction t       
 INNER JOIN tblGLDetail gd      
 ON t.strTransactionId = gd.strTransactionId      
 AND t.intInventoryTransactionId = gd.intJournalLineNo      
 INNER JOIN vyuGLAccountDetail ad      
 ON gd.intAccountId = ad.intAccountId      
 WHERE      
 --t.strTransactionId = receipt.strReceiptNumber      
 --AND t.intItemId = receiptItem.intItemId      
 ad.intAccountCategoryId = 45      
 AND t.ysnIsUnposted = 0       
 AND (gd.dblCredit != 0 OR gd.dblDebit != 0)    
 UNION ALL    
 SELECT DISTINCT      
   ad.strAccountId      
   ,ad.intAccountId      
   ,A.strReceiptNumber      
   ,B.intInventoryReceiptItemId     
   ,NULL AS intTransactionChargeId   
   ,A.intInventoryReceiptId      
   ,B.intItemId      
 FROM tblICInventoryReceipt A      
 INNER JOIN tblICInventoryReceiptItem  B ON A.intInventoryReceiptId = B.intInventoryReceiptId   
 INNER JOIN tblICItem item ON B.intItemId = item.intItemId   
 INNER JOIN tblGLDetail C       
  ON C.strTransactionId = A.strReceiptNumber      
   AND C.intJournalLineNo = B.intInventoryReceiptItemId      
 INNER JOIN vyuGLAccountDetail ad      
  ON ad.intAccountId = C.intAccountId      
 WHERE       
  ad.intAccountCategoryId = 45        
 AND C.ysnIsUnposted = 0         
 AND (C.dblCredit != 0 OR C.dblDebit != 0) 
 AND item.strType = 'Non-Inventory' 
 UNION ALL 
 --ADD THIS TO GET THE ACCOUNT OF CHARGE FROM IR-39345 (MCP)
 SELECT DISTINCT    
   ad.strAccountId    
   ,ad.intAccountId    
   ,A.strReceiptNumber    
   ,NULL AS intInventoryReceiptItemId  
   ,B.intInventoryReceiptChargeId  
   ,A.intInventoryReceiptId    
   ,B.intChargeId    
 FROM tblICInventoryReceipt A    
 INNER JOIN tblICInventoryReceiptCharge  B ON A.intInventoryReceiptId = B.intInventoryReceiptId    
 INNER JOIN tblGLDetail C     
  ON C.strTransactionId = A.strReceiptNumber    
   AND C.intJournalLineNo = B.intInventoryReceiptChargeId    
 INNER JOIN vyuGLAccountDetail ad    
  ON ad.intAccountId = C.intAccountId    
 WHERE     
  ad.intAccountCategoryId = 45      
 AND C.ysnIsUnposted = 0       
 AND (C.dblCredit != 0 OR C.dblDebit != 0)   
) tmp
