CREATE PROCEDURE uspTRFreightCommissionDriverTotal
(
  @intDriverId INT,  
  @strDeliveryType NVARCHAR(100),
  @dtmRealDateFrom DATE,
  @dtmRealDateTo DATE,
  @dblFreightUnitCommissionPct INT,
  @dblOtherUnitCommissionPct INT,
  @intFreightCategoryId INT,
  @intFreightItemId INT,
  @strDriverName NVARCHAR(250),
  @intShipViaId INT
)

AS 
SET QUOTED_IDENTIFIER OFF    
SET ANSI_NULLS ON    
SET NOCOUNT ON    
SET XACT_ABORT ON    
SET ANSI_WARNINGS OFF    

BEGIN

DECLARE @dblTotalBilledUnits DECIMAL(18, 6) = 0 
DECLARE @dblTotalCommission DECIMAL(18, 6) = 0
DECLARE @tmpItemList TABLE
(intItemId INT, 
 intInvoiceId INT NULL,
 intLoadDistributionDetailId INT,
 dblUnits INT
)


-- Get list of items for driver
insert INTO @tmpItemList
SELECT intItemId, intInvoiceId, intLoadDistributionDetailId, dblUnits
from vyuTRGetFreightCommissionLine cl  
where ((cl.intDriverId =  @intDriverId))  
and (cl.strDeliveryType = @strDeliveryType   
  OR @strDeliveryType = 'All'   
  OR cl.strDeliveryType = 'Other Charge'
  OR (RTRIM(LTRIM(ISNULL(cl.strReceiptLink, ''))) = '' AND cl.intItemCategoryId = @intFreightCategoryId))  
AND (cl.dtmLoadDateTime >= @dtmRealDateFrom AND cl.dtmLoadDateTime <= @dtmRealDateTo)
AND (cl.intShipViaId = @intShipViaId OR @intShipViaId = 0)


DECLARE @MyCursor CURSOR;
DECLARE @curItemId INT;
DECLARE @curInvoiceId INT;
DECLARE @curLoadDistributionDetailId INT;
DECLARE @curUnits INT;

BEGIN
    SET @MyCursor = CURSOR FOR
    select * from @tmpItemList


    OPEN @MyCursor 
    FETCH NEXT FROM @MyCursor 
    INTO @curItemId, @curInvoiceId, @curLoadDistributionDetailId, @curUnits

    WHILE @@FETCH_STATUS = 0
    BEGIN

	print @curItemId
	print @curInvoiceId
	print @curLoadDistributionDetailId
	print '------'

	SET @dblTotalBilledUnits += @curUnits

	-- IF Terminal to Location (No Invoice)
	IF(@curInvoiceId IS NULL OR @curInvoiceId = 0)
	BEGIN
		-- Item
		SELECT @dblTotalCommission += (CONVERT(DECIMAL(18,6),((@dblFreightUnitCommissionPct/CONVERT(DECIMAL(18,6),100)) * (ldd.dblFreightUnit * ldd.dblFreightRate))) + 
			(((@dblOtherUnitCommissionPct/CONVERT(DECIMAL(18,6),100)) * ((ldd.dblFreightUnit * ldd.dblFreightRate) * (dblDistSurcharge/100)))))
		FROM tblTRLoadDistributionDetail ldd
		WHERE intLoadDistributionDetailId = @curLoadDistributionDetailId
			AND ISNULL(strReceiptLink, '') != ''

		-- Other Item
		SELECT
			@dblTotalCommission += ISNULL(ldd.dblPrice, 0)
		FROM tblTRLoadDistributionDetail ldd
		WHERE intLoadDistributionDetailId = @curLoadDistributionDetailId
			AND ISNULL(strReceiptLink, '') = ''
	END

	ELSE
	-- IF XX to Customer (Has Invoice)
	BEGIN
		select
			@dblTotalCommission += CONVERT(DECIMAL(18,6),CASE WHEN intItemId = @intFreightItemId THEN ((@dblFreightUnitCommissionPct/CONVERT(DECIMAL(18,6),100)) * dblTotal) ELSE ((@dblOtherUnitCommissionPct/CONVERT(DECIMAL(18,6),100)) * dblTotal) END)

		FROM vyuTRGetFreightCommissionFreight fcf
		WHERE intInvoiceId = @curInvoiceId
			AND (
				(intItemId = @intFreightItemId AND intCategoryId = @intFreightCategoryId AND intLoadDistributionDetailId = @curLoadDistributionDetailId)
				OR (intCategoryId = @intFreightCategoryId AND intItemId != @curItemId AND strBOLNumberDetail IS NULL AND intLoadDistributionDetailId = @curLoadDistributionDetailId)
				OR (intCategoryId = @intFreightCategoryId AND intItemId != @curItemId AND intLoadDistributionDetailId = @curLoadDistributionDetailId)
			)


	-- For Other Item Total
		select
			@dblTotalCommission += CONVERT(DECIMAL(18,6),((@dblOtherUnitCommissionPct/CONVERT(DECIMAL(18,6),100)) * dblTotal))

		FROM vyuTRGetFreightCommissionFreight fcf
		WHERE intInvoiceId = @curInvoiceId
			AND (
					(intItemId != @intFreightItemId 
						AND intCategoryId = @intFreightCategoryId 
						AND intLoadDistributionDetailId = @curLoadDistributionDetailId)
				)
			AND ISNULL(distributionDetailRL,'') = '' 
	END
	

	




      FETCH NEXT FROM @MyCursor 
      INTO @curItemId, @curInvoiceId, @curLoadDistributionDetailId, @curUnits
    END; 

    CLOSE @MyCursor ;
    DEALLOCATE @MyCursor;
END;

	print 'before end'
	print @dblTotalBilledUnits
	print @dblTotalCommission
	print @strDriverName

	SELECT 
		dblTotalBilledUnits = @dblTotalBilledUnits,
		dblTotalCommission = @dblTotalCommission,
		strDriverName = @strDriverName
END


