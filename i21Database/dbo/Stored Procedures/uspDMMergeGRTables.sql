﻿CREATE PROCEDURE [dbo].[uspDMMergeGRTables]
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
            UPDATE SET  Target.strStorageTypeDescription = Source.strStorageTypeDescription
                        ,Target.strStorageTypeCode = Source.strStorageTypeCode
                        ,Target.ysnReceiptedStorage = Source.ysnReceiptedStorage
                        ,Target.intConcurrencyId = Source.intConcurrencyId
                        ,Target.strOwnedPhysicalStock = Source.strOwnedPhysicalStock
                        ,Target.ysnDPOwnedType = Source.ysnDPOwnedType
                        ,Target.ysnGrainBankType = Source.ysnGrainBankType
                        ,Target.ysnActive = Source.ysnActive
                        ,Target.ysnCustomerStorage = Source.ysnCustomerStorage
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                intStorageScheduleTypeId
                ,strStorageTypeDescription
                ,strStorageTypeCode
                ,ysnReceiptedStorage
                ,intConcurrencyId
                ,strOwnedPhysicalStock
                ,ysnDPOwnedType
                ,ysnGrainBankType
                ,ysnActive
                ,ysnCustomerStorage
            )
            VALUES (
                Source.intStorageScheduleTypeId
                ,Source.strStorageTypeDescription
                ,Source.strStorageTypeCode
                ,Source.ysnReceiptedStorage
                ,Source.intConcurrencyId
                ,Source.strOwnedPhysicalStock
                ,Source.ysnDPOwnedType
                ,Source.ysnGrainBankType
                ,Source.ysnActive
                ,Source.ysnCustomerStorage
            )
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblGRStorageScheduleLocationUse
    SET @SQLString = N'MERGE tblGRStorageScheduleLocationUse AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblGRStorageScheduleLocationUse]) AS Source
        ON (Target.intStorageScheduleLocationUseId = Source.intStorageScheduleLocationUseId)
        WHEN MATCHED THEN
            UPDATE SET  Target.intStorageScheduleId = Source.intStorageScheduleId
                        ,Target.intCompanyLocationId = Source.intCompanyLocationId
                        ,Target.ysnStorageScheduleLocationActive = Source.ysnStorageScheduleLocationActive
                        ,Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                intStorageScheduleLocationUseId
                ,intStorageScheduleId
                ,intCompanyLocationId
                ,ysnStorageScheduleLocationActive
                ,intConcurrencyId
            )
            VALUES (
                 Source.intStorageScheduleLocationUseId
                ,Source.intStorageScheduleId
                ,Source.intCompanyLocationId
                ,Source.ysnStorageScheduleLocationActive
                ,Source.intConcurrencyId
            )
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblGRStorageSchedulePeriod
    SET @SQLString = N'MERGE tblGRStorageSchedulePeriod AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblGRStorageSchedulePeriod]) AS Source
        ON (Target.intStorageSchedulePeriodId = Source.intStorageSchedulePeriodId)
        WHEN MATCHED THEN
            UPDATE SET  Target.intConcurrencyId = Source.intConcurrencyId
                        ,Target.intStorageScheduleRule = Source.intStorageScheduleRule
                        ,Target.strPeriodType = Source.strPeriodType
                        ,Target.dtmEffectiveDate = Source.dtmEffectiveDate
                        ,Target.dtmEndingDate = Source.dtmEndingDate
                        ,Target.intNumberOfDays = Source.intNumberOfDays
                        ,Target.dblStorageRate = Source.dblStorageRate
                        ,Target.strFeeDescription = Source.strFeeDescription
                        ,Target.intItemId = Source.intItemId
                        ,Target.dblFeeRate = Source.dblFeeRate
                        ,Target.strFeeType = Source.strFeeType
                        ,Target.intSort = Source.intSort
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                intStorageSchedulePeriodId
                ,intConcurrencyId
                ,intStorageScheduleRule
                ,strPeriodType
                ,dtmEffectiveDate
                ,dtmEndingDate
                ,intNumberOfDays
                ,dblStorageRate
                ,strFeeDescription
                ,intItemId
                ,dblFeeRate
                ,strFeeType
                ,intSort
            )
            VALUES (
                intStorageSchedulePeriodId
                ,Source.intConcurrencyId
                ,Source.intStorageScheduleRule
                ,Source.strPeriodType
                ,Source.dtmEffectiveDate
                ,Source.dtmEndingDate
                ,Source.intNumberOfDays
                ,Source.dblStorageRate
                ,Source.strFeeDescription
                ,Source.intItemId
                ,Source.dblFeeRate
                ,Source.strFeeType
                ,Source.intSort
            )                
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblGRStorageScheduleRule
    SET @SQLString = N'MERGE tblGRStorageScheduleRule AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblGRStorageScheduleRule]) AS Source
        ON (Target.intStorageScheduleRuleId = Source.intStorageScheduleRuleId)
        WHEN MATCHED THEN
            UPDATE SET  Target.intConcurrencyId = Source.intConcurrencyId
                        ,Target.strScheduleDescription = Source.strScheduleDescription
                        ,Target.intStorageType = Source.intStorageType
                        ,Target.intCommodity = Source.intCommodity
                        ,Target.intAllowanceDays = Source.intAllowanceDays
                        ,Target.dtmEffectiveDate = Source.dtmEffectiveDate
                        ,Target.dtmTerminationDate = Source.dtmTerminationDate
                        ,Target.intCurrencyID = Source.intCurrencyID
                        ,Target.strScheduleId = Source.strScheduleId
                        ,Target.strStorageRate = Source.strStorageRate
                        ,Target.strFirstMonth = Source.strFirstMonth
                        ,Target.strLastMonth = Source.strLastMonth
                        ,Target.strAllowancePeriod = Source.strAllowancePeriod
                        ,Target.dtmAllowancePeriodFrom = Source.dtmAllowancePeriodFrom
                        ,Target.dtmAllowancePeriodTo = Source.dtmAllowancePeriodTo
                        ,Target.intUnitMeasureId = Source.intUnitMeasureId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                intStorageScheduleRuleId
                ,intConcurrencyId
                ,strScheduleDescription
                ,intStorageType
                ,intCommodity
                ,intAllowanceDays
                ,dtmEffectiveDate
                ,dtmTerminationDate
                ,intCurrencyID
                ,strScheduleId
                ,strStorageRate
                ,strFirstMonth
                ,strLastMonth
                ,strAllowancePeriod
                ,dtmAllowancePeriodFrom
                ,dtmAllowancePeriodTo
                ,intUnitMeasureId
            )
            VALUES (
                Source.intStorageScheduleRuleId
                ,Source.intConcurrencyId
                ,Source.strScheduleDescription
                ,Source.intStorageType
                ,Source.intCommodity
                ,Source.intAllowanceDays
                ,Source.dtmEffectiveDate
                ,Source.dtmTerminationDate
                ,Source.intCurrencyID
                ,Source.strScheduleId
                ,Source.strStorageRate
                ,Source.strFirstMonth
                ,Source.strLastMonth
                ,Source.strAllowancePeriod
                ,Source.dtmAllowancePeriodFrom
                ,Source.dtmAllowancePeriodTo
                ,Source.intUnitMeasureId
            )                
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblGRDiscountSchedule
    SET @SQLString = N'MERGE tblGRDiscountSchedule AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblGRDiscountSchedule]) AS Source
        ON (Target.intDiscountScheduleId = Source.intDiscountScheduleId)
        WHEN MATCHED THEN
            UPDATE SET  Target.intCurrencyId = Source.intCurrencyId
                        ,Target.intCommodityId = Source.intCommodityId
                        ,Target.strDiscountDescription = Source.strDiscountDescription
                        ,Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                intDiscountScheduleId
                ,intCurrencyId
                ,intCommodityId
                ,strDiscountDescription
                ,intConcurrencyId
            )
            VALUES (
                Source.intDiscountScheduleId
                ,Source.intCurrencyId
                ,Source.intCommodityId
                ,Source.strDiscountDescription
                ,Source.intConcurrencyId
            )                
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblGRDiscountScheduleCode
    SET @SQLString = N'MERGE tblGRDiscountScheduleCode AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblGRDiscountScheduleCode]) AS Source
        ON (Target.intDiscountScheduleCodeId = Source.intDiscountScheduleCodeId)
        WHEN MATCHED THEN
            UPDATE SET  Target.intDiscountScheduleId = Source.intDiscountScheduleId
                        ,Target.intDiscountCalculationOptionId = Source.intDiscountCalculationOptionId
                        ,Target.intShrinkCalculationOptionId = Source.intShrinkCalculationOptionId
                        ,Target.ysnZeroIsValid = Source.ysnZeroIsValid
                        ,Target.dblMinimumValue = Source.dblMinimumValue
                        ,Target.dblMaximumValue = Source.dblMaximumValue
                        ,Target.dblDefaultValue = Source.dblDefaultValue
                        ,Target.ysnQualityDiscount = Source.ysnQualityDiscount
                        ,Target.ysnDryingDiscount = Source.ysnDryingDiscount
                        ,Target.dtmEffectiveDate = Source.dtmEffectiveDate
                        ,Target.dtmTerminationDate = Source.dtmTerminationDate
                        ,Target.intConcurrencyId = Source.intConcurrencyId
                        ,Target.intSort = Source.intSort
                        ,Target.strDiscountChargeType = Source.strDiscountChargeType
                        ,Target.intItemId = Source.intItemId
                        ,Target.intStorageTypeId = Source.intStorageTypeId
                        ,Target.intCompanyLocationId = Source.intCompanyLocationId
                        ,Target.intUnitMeasureId = Source.intUnitMeasureId
                        ,Target.intScalableItemId = Source.intScalableItemId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                intDiscountScheduleCodeId
                ,intDiscountScheduleId
                ,intDiscountCalculationOptionId
                ,intShrinkCalculationOptionId
                ,ysnZeroIsValid
                ,dblMinimumValue
                ,dblMaximumValue
                ,dblDefaultValue
                ,ysnQualityDiscount
                ,ysnDryingDiscount
                ,dtmEffectiveDate
                ,dtmTerminationDate
                ,intConcurrencyId
                ,intSort
                ,strDiscountChargeType
                ,intItemId
                ,intStorageTypeId
                ,intCompanyLocationId
                ,intUnitMeasureId
                ,intScalableItemId
            )
            VALUES (
                Source.intDiscountScheduleCodeId
                ,Source.intDiscountScheduleId
                ,Source.intDiscountCalculationOptionId
                ,Source.intShrinkCalculationOptionId
                ,Source.ysnZeroIsValid
                ,Source.dblMinimumValue
                ,Source.dblMaximumValue
                ,Source.dblDefaultValue
                ,Source.ysnQualityDiscount
                ,Source.ysnDryingDiscount
                ,Source.dtmEffectiveDate
                ,Source.dtmTerminationDate
                ,Source.intConcurrencyId
                ,Source.intSort
                ,Source.strDiscountChargeType
                ,Source.intItemId
                ,Source.intStorageTypeId
                ,Source.intCompanyLocationId
                ,Source.intUnitMeasureId
                ,Source.intScalableItemId
            )                
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblGRDiscountScheduleLine
    SET @SQLString = N'MERGE tblGRDiscountScheduleLine AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblGRDiscountScheduleLine]) AS Source
        ON (Target.intDiscountScheduleLineId = Source.intDiscountScheduleLineId)
        WHEN MATCHED THEN
            UPDATE SET  Target.intDiscountScheduleCodeId = Source.intDiscountScheduleCodeId
                        ,Target.dblRangeStartingValue = Source.dblRangeStartingValue
                        ,Target.dblRangeEndingValue = Source.dblRangeEndingValue
                        ,Target.dblIncrementValue = Source.dblIncrementValue
                        ,Target.dblDiscountValue = Source.dblDiscountValue
                        ,Target.dblShrinkValue = Source.dblShrinkValue
                        ,Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                intDiscountScheduleLineId
                ,intDiscountScheduleCodeId
                ,dblRangeStartingValue
                ,dblRangeEndingValue
                ,dblIncrementValue
                ,dblDiscountValue
                ,dblShrinkValue
                ,intConcurrencyId
            )
            VALUES (
                Source.intDiscountScheduleLineId
                ,Source.intDiscountScheduleCodeId
                ,Source.dblRangeStartingValue
                ,Source.dblRangeEndingValue
                ,Source.dblIncrementValue
                ,Source.dblDiscountValue
                ,Source.dblShrinkValue
                ,Source.intConcurrencyId
            )                
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblGRDiscountCalculationOption
    SET @SQLString = N'MERGE tblGRDiscountCalculationOption AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblGRDiscountCalculationOption]) AS Source
        ON (Target.intDiscountCalculationOptionId  = Source.intDiscountCalculationOptionId )
        WHEN MATCHED THEN
            UPDATE SET  Target.strDiscountCalculationOption = Source.strDiscountCalculationOption
                        ,Target.strDescription = Source.strDescription
                        ,Target.intConcurrencyId = Source.intConcurrencyId
                        ,Target.intOrderById = Source.intOrderById
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                intDiscountCalculationOptionId
                ,strDiscountCalculationOption
                ,strDescription
                ,intConcurrencyId
                ,intOrderById
            )
            VALUES (
                Source.intDiscountCalculationOptionId
                ,Source.strDiscountCalculationOption
                ,Source.strDescription
                ,Source.intConcurrencyId
                ,Source.intOrderById
            )
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblGRDiscountCrossReference
    SET @SQLString = N'MERGE tblGRDiscountCrossReference AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblGRDiscountCrossReference]) AS Source
        ON (Target.intDiscountCrossReferenceId = Source.intDiscountCrossReferenceId)
        WHEN MATCHED THEN
            UPDATE SET  Target.intDiscountId = Source.intDiscountId
                        ,Target.intDiscountScheduleId = Source.intDiscountScheduleId
                        ,Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                intDiscountCrossReferenceId
                ,intDiscountId
                ,intDiscountScheduleId
                ,intConcurrencyId
            )
            VALUES (
                Source.intDiscountCrossReferenceId
                ,Source.intDiscountId
                ,Source.intDiscountScheduleId
                ,Source.intConcurrencyId
            )
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblGRDiscountId
    SET @SQLString = N'MERGE tblGRDiscountId AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblGRDiscountId]) AS Source
        ON (Target.intDiscountId = Source.intDiscountId)
        WHEN MATCHED THEN
            UPDATE SET  Target.intCurrencyId = Source.intCurrencyId
                        ,Target.strDiscountId = Source.strDiscountId
                        ,Target.strDiscountDescription = Source.strDiscountDescription
                        ,Target.ysnDiscountIdActive = Source.ysnDiscountIdActive
                        ,Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                intDiscountId
                ,intCurrencyId
                ,strDiscountId
                ,strDiscountDescription
                ,ysnDiscountIdActive
                ,intConcurrencyId
            )
            VALUES (
                Source.intDiscountId
                ,Source.intCurrencyId
                ,Source.strDiscountId
                ,Source.strDiscountDescription
                ,Source.ysnDiscountIdActive
                ,Source.intConcurrencyId
            )
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblGRDiscountLocationUse
    SET @SQLString = N'MERGE tblGRDiscountLocationUse AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblGRDiscountLocationUse]) AS Source
        ON (Target.intDiscountLocationUseId = Source.intDiscountLocationUseId)
        WHEN MATCHED THEN
            UPDATE SET  Target.intDiscountId = Source.intDiscountId
                        ,Target.intCompanyLocationId = Source.intCompanyLocationId
                        ,Target.ysnDiscountLocationActive = Source.ysnDiscountLocationActive
                        ,Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                intDiscountLocationUseId
                ,intDiscountId
                ,intCompanyLocationId
                ,ysnDiscountLocationActive
                ,intConcurrencyId
            )
            VALUES (
                Source.intDiscountLocationUseId
                ,Source.intDiscountId
                ,Source.intCompanyLocationId
                ,Source.ysnDiscountLocationActive
                ,Source.intConcurrencyId
            )
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

END