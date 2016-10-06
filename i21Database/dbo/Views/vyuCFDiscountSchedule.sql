CREATE VIEW dbo.vyuCFDiscountSchedule
AS
SELECT   cfAccnt.intAccountId, cfDsd.intFromQty, cfDsd.intThruQty, cfDsd.dblRate, cfDsd.intDiscountScheduleId, cfDsd.intDiscountSchedDetailId
FROM         dbo.tblCFDiscountScheduleDetail AS cfDsd INNER JOIN
                         dbo.tblCFAccount AS cfAccnt ON cfAccnt.intDiscountScheduleId = cfDsd.intDiscountScheduleId