CREATE TRIGGER [dbo].[trgICItemPricingDateChanged]
    ON [dbo].[tblICItemPricing]
   AFTER INSERT, UPDATE
AS 
BEGIN
    SET NOCOUNT ON;

   UPDATE tblICItemPricing
      SET tblICItemPricing.dtmDateChanged = GETDATE()
     FROM   inserted
    WHERE tblICItemPricing.intItemPricingId = inserted.intItemPricingId
END