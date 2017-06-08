 IF(EXISTS(SELECT NULL FROM sys.tables WHERE name = N'tblARInvoice') AND EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intEntityContactId' AND [object_id] = OBJECT_ID(N'tblARInvoice')))
 BEGIN
  
 UPDATE 
     tblARInvoice   
 SET 
     [intEntityContactId] = [dbo].[fnARGetCustomerDefaultContact](intEntityCustomerId)
 WHERE
     ISNULL([intEntityContactId], 0) = 0
 
 END
