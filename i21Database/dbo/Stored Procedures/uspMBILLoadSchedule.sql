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
    WHERE intDriverEntityId = @intDriverId AND intLoadId NOT IN (SELECT intLoadId FROM tblMBILPickupHeader)

    DECLARE @tblLoadId AS TABLE(rownum int, intLoadId int, intEntityId int)

    INSERT INTO @tblLoadId
    SELECT ROW_NUMBER() OVER (ORDER BY intLoadId) rownum,intLoadId, intEntityId
    FROM vyuMBILLoadSchedule
    WHERE intDriverEntityId = @intDriverId AND intLoadId NOT in(Select intLoadId FROM tblMBILPickupHeader)
	Group by intLoadId, intEntityId

    WHILE (SELECT count(1) FROM @tblLoadId) <> 0     
BEGIN

        DECLARE @rownum AS int = (SELECT TOP 1 rownum FROM @tblLoadId ORDER BY rownum asc)
        --//INSERT PICKUP HEADER    
        INSERT INTO tblMBILPickupHeader
            (intLoadId,
            intDriverEntityId,
            strLoadNumber,
            strType,
            intEntityId,
            intEntityLocationId,
            intCompanyLocationId,
			intSellerId,
			intSalespersonId,
			strTerminalRefNo,
            dtmPickupFrom,
            dtmPickupTo,
            strPONumber)
        SELECT a.intLoadId,
            a.intDriverEntityId,
            a.strLoadNumber,
            a.strType,
            a.intEntityId,
            a.intEntityLocationId,
            a.intCompanyLocationId,
			a.intSellerId,
			a.intSalespersonId,
			a.strTerminalRefNo,
            a.dtmPickUpFrom,
            a.dtmPickUpTo,
            a.strPONumber
        FROM #loadSchedule a
		INNER JOIN @tblLoadId b on a.intLoadId = b.intLoadId and a.intEntityId = b.intEntityId 
        WHERE rownum = @rownum
        GROUP BY    a.intLoadId,    
					a.intDriverEntityId,    
					a.strLoadNumber,    
					a.strType,    
					a.intEntityId ,    
					a.intEntityLocationId ,    
					a.intCompanyLocationId,    
					a.dtmPickUpFrom,
					a.dtmPickUpTo,     
					a.strPONumber,
					a.intSellerId,
					a.intSalespersonId,
					a.strTerminalRefNo
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
			dtmDeliveryFrom,
			dtmDeliveryTo)
        SELECT a.intLoadId,
            intDriverEntityId,
            strLoadNumber,
            strType,
            intCustomerId ,
            intCustomerLocationId ,
            intCompanyDeliveryLocationId,
			dtmDeliveryFrom,
			dtmDeliveryTo
        FROM #loadSchedule a
		INNER JOIN @tblLoadId b on a.intLoadId = b.intLoadId
        WHERE rownum = @rownum
        GROUP BY a.intLoadId,    
                intDriverEntityId,    
                strLoadNumber,    
                strType,    
                intCustomerId ,    
                intCustomerLocationId ,    
                intCompanyDeliveryLocationId , 
				dtmDeliveryFrom,
				dtmDeliveryTo

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

        INSERT INTO @tblPickupDetail(intpickupheaderId,intEntityId,intEntityLocationId,intCompanyLocationId,intLoadId,intItemId,dblQuantity)
        SELECT @pickupheaderId,
            a.intEntityId,
            intEntityLocationId,
            intCompanyLocationId,
            a.intLoadId,
            intItemId,
            sum(dblQuantity)dblQuantity
        FROM  #loadSchedule a
		INNER JOIN @tblLoadId b on a.intLoadId = b.intLoadId and a.intEntityId = b.intEntityId 
        WHERE rownum = @rownum
        GROUP BY a.intEntityId,    
                 intEntityLocationId,    
                 intCompanyLocationId,    
                 a.intLoadId,    
                 intItemId
        WHILE (SELECT count(1) FROM @tblPickupDetail) <> 0    
		begin
            DECLARE @intItemId AS INT = (SELECT TOP 1 intItemId FROM @tblPickupDetail)
            INSERT INTO tblMBILPickupDetail (intPickupHeaderId,intItemId,dblQuantity)
            SELECT TOP 1 @pickupheaderId, intItemId, dblQuantity
            FROM @tblPickupDetail a
            WHERE intItemId = @intItemId

            --DECLARE @intPickupDetailId as int = (SELECT IDENT_CURRENT('tblMBILPickupDetail'))      
            DECLARE @intPickupDetailId AS INT = @@IDENTITY

            INSERT INTO tblMBILDeliveryDetail(
				   intDeliveryHeaderId,
				   intItemId,
				   dblQuantity,
				   intPickupDetailId)
            SELECT @intDeliveryHeaderId,
				   intItemId,
				   sum(dblQuantity)dblQuantity,
				   @intPickupDetailId
            FROM #loadSchedule a
			INNER JOIN @tblLoadId b on a.intLoadId = b.intLoadId and a.intEntityId = b.intEntityId 
			WHERE rownum = @rownum  AND intItemId = @intItemId
            GROUP BY a.intEntityId,    
					 intCustomerId,    
					 intCustomerLocationId,    
					 intCompanyDeliveryLocationId,    
					 a.intLoadId,    
					 intItemId

            DELETE FROM @tblPickupDetail WHERE intItemId = @intItemId
        END
        DELETE FROM @tblLoadId WHERE  rownum = @rownum
    END

END