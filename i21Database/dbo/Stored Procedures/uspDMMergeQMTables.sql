CREATE PROCEDURE [dbo].[uspDMMergeQMTables]
    @remoteDB NVARCHAR(MAX)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @SQLString NVARCHAR(MAX) = '';

BEGIN

    -- tblQMTicketDiscount
    SET @SQLString = N'MERGE tblQMTicketDiscount AS Target
        USING (SELECT * FROM REMOTEDBSERVER.' + @remoteDB + '.dbo.tblQMTicketDiscount) AS Source
        ON (Target.intTicketDiscountId = Source.intTicketDiscountId)
        WHEN MATCHED THEN
            UPDATE SET Target.intConcurrencyId = Source.intConcurrencyId, Target.dblGradeReading = Source.dblGradeReading, Target.strCalcMethod = Source.strCalcMethod, Target.strShrinkWhat = Source.strShrinkWhat, Target.dblShrinkPercent = Source.dblShrinkPercent, Target.dblDiscountAmount = Source.dblDiscountAmount, Target.dblDiscountDue = Source.dblDiscountDue, Target.dblDiscountPaid = Source.dblDiscountPaid, Target.ysnGraderAutoEntry = Source.ysnGraderAutoEntry, Target.intDiscountScheduleCodeId = Source.intDiscountScheduleCodeId, Target.dtmDiscountPaidDate = Source.dtmDiscountPaidDate, Target.intTicketId = Source.intTicketId, Target.intTicketFileId = Source.intTicketFileId, Target.strSourceType = Source.strSourceType, Target.intSort = Source.intSort, Target.strDiscountChargeType = Source.strDiscountChargeType
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intTicketDiscountId, intConcurrencyId, dblGradeReading, strCalcMethod, strShrinkWhat, dblShrinkPercent, dblDiscountAmount, dblDiscountDue, dblDiscountPaid, ysnGraderAutoEntry, intDiscountScheduleCodeId, dtmDiscountPaidDate, intTicketId, intTicketFileId, strSourceType, intSort, strDiscountChargeType)
            VALUES (Source.intTicketDiscountId, Source.intConcurrencyId, Source.dblGradeReading, Source.strCalcMethod, Source.strShrinkWhat, Source.dblShrinkPercent, Source.dblDiscountAmount, Source.dblDiscountDue, Source.dblDiscountPaid, Source.ysnGraderAutoEntry, Source.intDiscountScheduleCodeId, Source.dtmDiscountPaidDate, Source.intTicketId, Source.intTicketFileId, Source.strSourceType, Source.intSort, Source.strDiscountChargeType)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET IDENTITY_INSERT tblQMTicketDiscount ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblQMTicketDiscount OFF

END