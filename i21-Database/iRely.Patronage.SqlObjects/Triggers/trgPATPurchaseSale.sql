CREATE TRIGGER [dbo].[trgPATPurchaseSale]
    ON [dbo].[tblPATPatronageCategory]
   FOR UPDATE
AS 

if (UPDATE (strPurchaseSale))   
BEGIN
    SET NOCOUNT ON;

   UPDATE tblPATRefundRateDetail
      SET strPurchaseSale = inserted.strPurchaseSale
     FROM   inserted
    WHERE tblPATRefundRateDetail.intPatronageCategoryId = inserted.intPatronageCategoryId
END