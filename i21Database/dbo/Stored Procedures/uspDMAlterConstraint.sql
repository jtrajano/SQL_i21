CREATE PROCEDURE [dbo].[uspDMAlterConstraint]
    @checkType AS NVARCHAR(100) = 'NoCheck'
AS
BEGIN

    DECLARE @mi INT = 1
    DECLARE @mii INT = 1
    DECLARE @mainCount INT
    DECLARE @mainSql NVARCHAR(MAX)
    DECLARE @currentMainTableName NVARCHAR(100)
    DECLARE @mainTableNames TABLE (
        id INT IDENTITY(1, 1),
        name NVARCHAR(100)
    )

    INSERT INTO @mainTableNames (name) VALUES
        --('tblEMEntity'),
        --('tblEMEntityCredential'),
        --('tblEMEntityLocation'),
        --('tblSMUserSecurity'),
        --('tblGRStorageType'),
        ('tblGRStorageScheduleLocationUse'),
        ('tblGRStorageSchedulePeriod'),
        --('tblGRStorageScheduleRule'),
        ('tblGRDiscountSchedule'),
        ('tblGRDiscountScheduleCode'),
        ('tblGRDiscountScheduleLine'),
        --('tblGRDiscountCalculationOption'),
        ('tblGRDiscountCrossReference'),
        --('tblGRDiscountId'),
        ('tblGRDiscountLocationUse'),
        --('tblCTContractHeader'),
        --('tblCTContractDetail'),
        ('tblCTContractCost'),
        --('tblLGLoad'),
        ('tblLGLoadAllocationDetail'),
        ('tblLGLoadCost'),
        --('tblLGLoadDetail'),
        --('tblICItem'),
        --('tblICCommodity'),
        ('tblICCommodityAccount'),
        ('tblICCommodityAttribute'),
        ('tblICCommodityGroup'),
        ('tblICCommodityProductLine'),
        --('tblICCommodityUnitMeasure'),
        --('tblICStorageLocation'),
        ('tblICStorageLocationCategory'),
        ('tblICStorageLocationContainer'),
        ('tblICStorageLocationMeasurement'),
        ('tblICStorageLocationSku'),
        ('tblSCScaleSetup'),
        ('tblSCLastScaleSetup'),
        ('tblSCTicketType'),
        ('tblSCListTicketTypes'),
        ('tblSCUncompletedTicketAlert'),
        ('tblSCDeviceInterfaceFile'),
        ('tblSCDistributionOption'),
        ('tblSCScaleDevice'),
        ('tblSCTicket'),
        ('tblSCTicketDiscount'),
        ('tblSCTicketFormat'),
        ('tblSCTicketPool'),
        ('tblSCTicketPrintOption'),
        ('tblSCTicketSplit'),
        ('tblSCTicketStorageType'),
        ('tblSCTruckDriverReference'),
        ('tblSCTicketCost'),
        ('tblQMTicketDiscount');

    SELECT @mainCount = COUNT(*) FROM @mainTableNames

    WHILE @mi <= @mainCount
    BEGIN

        SET @currentMainTableName = (SELECT TOP 1 name FROM @mainTableNames WHERE id = @mi)

        DECLARE @fki INT = 1
        DECLARE @fkCount INT
        DECLARE @fkSql NVARCHAR(MAX)
        DECLARE @currentFKTableName NVARCHAR(100)
        DECLARE @FKTableNames TABLE (
            id INT IDENTITY(1, 1),
            name NVARCHAR(100)
        )

        INSERT INTO @FKTableNames (name)
            SELECT name FROM sys.tables WHERE object_id IN (
                SELECT referenced_object_id FROM sys.foreign_keys WHERE parent_object_id = (
                    SELECT TOP 1 object_id FROM sys.tables WHERE name = @currentMainTableName
                )
            )

        SELECT @fkCount = COUNT(*) FROM @FKTableNames

        WHILE @fki <= @fkCount
        BEGIN

            SET @currentFKTableName = (SELECT TOP 1 name FROM @FKTableNames WHERE id = @fki)

            SET @fkSql = (
                CASE WHEN @checkType = 'NoCheck'
                    THEN 'ALTER TABLE [' + @currentFKTableName + '] NOCHECK CONSTRAINT ALL'
                    ELSE 'ALTER TABLE [' + @currentFKTableName + '] WITH CHECK CHECK CONSTRAINT ALL'
                END
            )

            EXECUTE sp_executesql @fkSql

            SET @fki += 1

        END

        SET @mainSql = (
            CASE WHEN @checkType = 'NoCheck'
                THEN 'ALTER TABLE [' + @currentMainTableName + '] NOCHECK CONSTRAINT ALL'
                ELSE 'ALTER TABLE [' + @currentMainTableName + '] WITH CHECK CHECK CONSTRAINT ALL'
            END
        )

        EXECUTE sp_executesql @mainSql

        SET @mi += 1

    END

    -- IF @checkType = 'NoCheck'
    -- BEGIN

    --     WHILE @mii <= @mainCount
    --     BEGIN

    --         SET @currentMainTableName = (SELECT TOP 1 name FROM @mainTableNames WHERE id = @mii)

    --         EXECUTE uspDMTruncateTable @currentMainTableName

    --         SET @mii += 1

    --     END

    -- END

END