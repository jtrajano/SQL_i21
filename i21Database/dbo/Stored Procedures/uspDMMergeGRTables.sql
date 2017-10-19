CREATE PROCEDURE [dbo].[uspDMMergeGRTables]
    @remoteDB NVARCHAR(MAX)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @SQLString NVARCHAR(MAX) = '';

BEGIN

   -- tblGRStorageType
    SET @SQLString = N'MERGE tblGRStorageType AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblGRStorageType]) AS Source
        ON (Target.intStorageScheduleTypeId = Source.intStorageScheduleTypeId)
        WHEN MATCHED THEN
            UPDATE SET Target.strStorageTypeDescription = Source.strStorageTypeDescription, Target.strStorageTypeCode = Source.strStorageTypeCode, Target.ysnReceiptedStorage = Source.ysnReceiptedStorage, Target.intConcurrencyId = Source.intConcurrencyId, Target.strOwnedPhysicalStock = Source.strOwnedPhysicalStock, Target.ysnDPOwnedType = Source.ysnDPOwnedType, Target.ysnGrainBankType = Source.ysnGrainBankType, Target.ysnActive = Source.ysnActive, Target.ysnCustomerStorage = Source.ysnCustomerStorage
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblGRStorageScheduleLocationUse
    SET @SQLString = N'MERGE tblGRStorageScheduleLocationUse AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblGRStorageScheduleLocationUse]) AS Source
        ON (Target.intStorageScheduleLocationUseId = Source.intStorageScheduleLocationUseId)
        WHEN MATCHED THEN
            UPDATE SET Target.intStorageScheduleId = Source.intStorageScheduleId, Target.intCompanyLocationId = Source.intCompanyLocationId, Target.ysnStorageScheduleLocationActive = Source.ysnStorageScheduleLocationActive, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblGRStorageSchedulePeriod
    SET @SQLString = N'MERGE tblGRStorageSchedulePeriod AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblGRStorageSchedulePeriod]) AS Source
        ON (Target.intStorageSchedulePeriodId = Source.intStorageSchedulePeriodId)
        WHEN MATCHED THEN
            UPDATE SET Target.intConcurrencyId = Source.intConcurrencyId, Target.intStorageScheduleRule = Source.intStorageScheduleRule, Target.strPeriodType = Source.strPeriodType, Target.dtmEffectiveDate = Source.dtmEffectiveDate, Target.dtmEndingDate = Source.dtmEndingDate, Target.intNumberOfDays = Source.intNumberOfDays, Target.dblStorageRate = Source.dblStorageRate, Target.strFeeDescription = Source.strFeeDescription, Target.intSort = Source.intSort
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblGRStorageScheduleRule
    SET @SQLString = N'MERGE tblGRStorageScheduleRule AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblGRStorageScheduleRule]) AS Source
        ON (Target.intStorageScheduleRuleId = Source.intStorageScheduleRuleId)
        WHEN MATCHED THEN
            UPDATE SET Target.intConcurrencyId = Source.intConcurrencyId, Target.strScheduleDescription = Source.strScheduleDescription, Target.intStorageType = Source.intStorageType, Target.intCommodity = Source.intCommodity, Target.intAllowanceDays = Source.intAllowanceDays, Target.dtmEffectiveDate = Source.dtmEffectiveDate, Target.dtmTerminationDate = Source.dtmTerminationDate, Target.intCurrencyID = Source.intCurrencyID, Target.strScheduleId = Source.strScheduleId, Target.strStorageRate = Source.strStorageRate, Target.strFirstMonth = Source.strFirstMonth, Target.strLastMonth = Source.strLastMonth, Target.strAllowancePeriod = Source.strAllowancePeriod, Target.dtmAllowancePeriodFrom = Source.dtmAllowancePeriodFrom, Target.dtmAllowancePeriodTo = Source.dtmAllowancePeriodTo
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblGRDiscountSchedule
    SET @SQLString = N'MERGE tblGRDiscountSchedule AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblGRDiscountSchedule]) AS Source
        ON (Target.intDiscountScheduleId = Source.intDiscountScheduleId)
        WHEN MATCHED THEN
            UPDATE SET Target.intCurrencyId = Source.intCurrencyId, Target.intCommodityId = Source.intCommodityId, Target.strDiscountDescription = Source.strDiscountDescription, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblGRDiscountScheduleCode
    SET @SQLString = N'MERGE tblGRDiscountScheduleCode AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblGRDiscountScheduleCode]) AS Source
        ON (Target.intDiscountScheduleCodeId = Source.intDiscountScheduleCodeId)
        WHEN MATCHED THEN
            UPDATE SET Target.intDiscountScheduleId = Source.intDiscountScheduleId, Target.intDiscountCalculationOptionId = Source.intDiscountCalculationOptionId, Target.intShrinkCalculationOptionId = Source.intShrinkCalculationOptionId, Target.ysnZeroIsValid = Source.ysnZeroIsValid, Target.dblMinimumValue = Source.dblMinimumValue, Target.dblMaximumValue = Source.dblMaximumValue, Target.dblDefaultValue = Source.dblDefaultValue, Target.ysnQualityDiscount = Source.ysnQualityDiscount, Target.ysnDryingDiscount = Source.ysnDryingDiscount, Target.dtmEffectiveDate = Source.dtmEffectiveDate, Target.dtmTerminationDate = Source.dtmTerminationDate, Target.intConcurrencyId = Source.intConcurrencyId, Target.intSort = Source.intSort, Target.strDiscountChargeType = Source.strDiscountChargeType, Target.intItemId = Source.intItemId
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblGRDiscountScheduleLine
    SET @SQLString = N'MERGE tblGRDiscountScheduleLine AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblGRDiscountScheduleLine]) AS Source
        ON (Target.intDiscountScheduleLineId = Source.intDiscountScheduleLineId)
        WHEN MATCHED THEN
            UPDATE SET Target.intDiscountScheduleCodeId = Source.intDiscountScheduleCodeId, Target.dblRangeStartingValue = Source.dblRangeStartingValue, Target.dblRangeEndingValue = Source.dblRangeEndingValue, Target.dblIncrementValue = Source.dblIncrementValue, Target.dblDiscountValue = Source.dblDiscountValue, Target.dblShrinkValue = Source.dblShrinkValue, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblGRDiscountCalculationOption
    SET @SQLString = N'MERGE tblGRDiscountCalculationOption AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblGRDiscountCalculationOption]) AS Source
        ON (Target.intDiscountCalculationOptionId  = Source.intDiscountCalculationOptionId )
        WHEN MATCHED THEN
            UPDATE SET Target.strDiscountCalculationOption = Source.strDiscountCalculationOption, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblGRDiscountCrossReference
    SET @SQLString = N'MERGE tblGRDiscountCrossReference AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblGRDiscountCrossReference]) AS Source
        ON (Target.intDiscountCrossReferenceId = Source.intDiscountCrossReferenceId)
        WHEN MATCHED THEN
            UPDATE SET Target.intDiscountId = Source.intDiscountId, Target.intDiscountScheduleId = Source.intDiscountScheduleId, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblGRDiscountId
    SET @SQLString = N'MERGE tblGRDiscountId AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblGRDiscountId]) AS Source
        ON (Target.intDiscountId = Source.intDiscountId)
        WHEN MATCHED THEN
            UPDATE SET Target.intCurrencyId = Source.intCurrencyId, Target.strDiscountId = Source.strDiscountId, Target.strDiscountDescription = Source.strDiscountDescription, Target.ysnDiscountIdActive = Source.ysnDiscountIdActive, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblGRDiscountLocationUse
    SET @SQLString = N'MERGE tblGRDiscountLocationUse AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblGRDiscountLocationUse]) AS Source
        ON (Target.intDiscountLocationUseId = Source.intDiscountLocationUseId)
        WHEN MATCHED THEN
            UPDATE SET Target.intDiscountId = Source.intDiscountId, Target.intCompanyLocationId = Source.intCompanyLocationId, Target.ysnDiscountLocationActive = Source.ysnDiscountLocationActive, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

END