CREATE PROCEDURE [dbo].[uspMBILLoadSchedule]
    @intDriverId AS INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
BEGIN
    DELETE FROM tblMBILPickupDetail
    DELETE FROM tblMBILDeliveryDetail
    DELETE FROM tblMBILPickupHeader
    DELETE FROM tblMBILDeliveryHeader

    SELECT *
    INTO #loadSchedule
    FROM vyuMBILLoadSchedule
    WHERE intDriverEntityId = @intDriverId AND intLoadId NOT IN (SELECT intLoadId
        FROM tblMBILPickupHeader)

    DECLARE @tblLoadId AS TABLE(intLoadId int)

    INSERT INTO @tblLoadId
    SELECT DISTINCT intLoadId
    FROM #loadSchedule
    WHERE intDriverEntityId = @intDriverId AND intLoadId NOT in(Select intLoadId
        FROM tblMBILPickupHeader)

    WHILE (SELECT count(1)
    FROM @tblLoadId) <> 0     
BEGIN

        DECLARE @intLoadId AS int = (SELECT TOP 1
            intLoadId
        FROM @tblLoadId
        ORDER BY 1 asc)
        --//INSERT PICKUP HEADER    

        INSERT INTO tblMBILPickupHeader
            (intLoadId,
            intDriverEntityId,
            strLoadNumber,
            strType,
            intEntityId,
            intEntityLocationId,
            intCompanyLocationId,
            dtmSchedulePullDate,
            dtmStartTime,
            dtmEndTime,
            strPONumber)
        SELECT intLoadId,
            intDriverEntityId,
            strLoadNumber,
            strType,
            intEntityId,
            intEntityLocationId,
            intCompanyLocationId,
            dtmSchedulePullDate,
            NULL dtmStartTime,
            NULL dtmEndTime,
            strPONumber
        FROM #loadSchedule
        WHERE intLoadId = @intLoadId
        GROUP BY    intLoadId,    
    intDriverEntityId,    
    strLoadNumber,    
    strType,    
    intEntityId ,    
    intEntityLocationId ,    
    intCompanyLocationId,    
    dtmSchedulePullDate,      
    strPONumber
        --DECLARE @pickupheaderId as int = (SELECT IDENT_CURRENT('tblMBILPickupHeader'))      
        DECLARE @pickupheaderId AS int = @@IDENTITY

        --//INSERT  DELIVERY HEADER    
        INSERT INTO tblMBILDeliveryHeader
            (intLoadId,
            intDriverEntityId,
            strLoadNumber,
            strType,
            intEntityId,
            intEntityLocationId,
            intCompanyLocationId,
            dtmScheduleDeliveryDate)
        SELECT intLoadId,
            intDriverEntityId,
            strLoadNumber,
            strType,
            intCustomerId ,
            intCustomerLocationId ,
            intCompanyDeliveryLocationId,
            dtmDeliveryDate
        FROM #loadSchedule
        WHERE intLoadId = @intLoadId
        GROUP BY intLoadId,    
                intDriverEntityId,    
                strLoadNumber,    
                strType,    
                intCustomerId ,    
                intCustomerLocationId ,    
                intCompanyDeliveryLocationId ,    
                dtmDeliveryDate

        --DECLARE @intDeliveryHeaderId as int = (SELECT IDENT_CURRENT('tblMBILDeliveryHeader'))      
        DECLARE @intDeliveryHeaderId AS int = @@IDENTITY

        --//INSERT PICKUP DETAIL    
        DECLARE @tblPickupDetail AS TABLE    
        (
            intpickupheaderId int,
            intEntityId int,
            intEntityLocationId int,
            intCompanyLocationId int,
            intLoadId int,
            intItemId int ,
            dblQuantity numeric(18,6)    
        )

        INSERT INTO @tblPickupDetail
            (intpickupheaderId,intEntityId,intEntityLocationId,intCompanyLocationId,intLoadId,intItemId,dblQuantity)
        SELECT @pickupheaderId,
            intEntityId,
            intEntityLocationId,
            intCompanyLocationId,
            intLoadId,
            intItemId,
            sum(dblQuantity)dblQuantity
        FROM #loadSchedule
        WHERE intLoadId = @intLoadId
        GROUP BY intEntityId,    
                 intEntityLocationId,    
                 intCompanyLocationId,    
                 intLoadId,    
                 intItemId
        WHILE (SELECT count(1)
        FROM @tblPickupDetail) <> 0    
 begin

            DECLARE @intItemId AS INT = (SELECT TOP 1
                intItemId
            FROM @tblPickupDetail)
            INSERT INTO tblMBILPickupDetail
                (intPickupHeaderId,intItemId,dblQuantity)
            SELECT TOP 1
                @pickupheaderId, intItemId, dblQuantity
            FROM @tblPickupDetail a
            WHERE intItemId = @intItemId

            --DECLARE @intPickupDetailId as int = (SELECT IDENT_CURRENT('tblMBILPickupDetail'))      
            DECLARE @intPickupDetailId AS INT = @@IDENTITY

            INSERT INTO tblMBILDeliveryDetail
                (intDeliveryHeaderId,intItemId,dblQuantity,intPickupDetailId)
            SELECT @intDeliveryHeaderId,
                intItemId,
                sum(dblQuantity)dblQuantity,
                @intPickupDetailId
            FROM #loadSchedule
            WHERE intLoadId = @intLoadId AND intItemId = @intItemId
            GROUP BY intEntityId,    
     intCustomerId,    
     intCustomerLocationId,    
     intCompanyDeliveryLocationId,    
     intLoadId,    
     intItemId



            DELETE FROM @tblPickupDetail WHERE intItemId = @intItemId
        END
        DELETE FROM @tblLoadId WHERE intLoadId = @intLoadId
    END

END