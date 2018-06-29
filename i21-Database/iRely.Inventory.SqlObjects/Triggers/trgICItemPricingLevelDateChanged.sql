CREATE TRIGGER [dbo].[trgICItemPricingLevelDateChanged]
    ON [dbo].[tblICItemPricingLevel]
   AFTER INSERT, UPDATE
AS 
BEGIN
    SET NOCOUNT ON;

   UPDATE tblICItemPricingLevel
      SET tblICItemPricingLevel.dtmDateChanged = GETDATE()
     FROM   inserted
    WHERE tblICItemPricingLevel.intItemPricingLevelId = inserted.intItemPricingLevelId
END