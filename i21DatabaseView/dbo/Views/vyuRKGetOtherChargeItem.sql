CREATE VIEW vyuRKGetOtherChargeItem
AS
SELECT intItemId,strItemNo,0 as intConcurrencyId FROM tblICItem where strType='Other Charge'
