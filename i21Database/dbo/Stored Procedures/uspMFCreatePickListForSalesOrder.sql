CREATE PROCEDURE [dbo].[uspMFCreatePickListForSalesOrder]
(
	@intSalesOrderId int
)
AS

DECLARE @intLocationId			INT
	  , @intMinItem				INT
	  , @intItemId				INT
	  , @dblRequiredQty			NUMERIC(38, 20)
	  , @dblItemRequiredQty		NUMERIC(38, 20)
	  , @strLotTracking			NVARCHAR(50)
	  , @intItemUOMId			INT
	  , @intMinLot				INT
	  , @intLotId				INT
	  , @dblAvailableQty		NUMERIC(38, 20)
	  , @intPickListId			INT
	  , @dblDefaultResidueQty	NUMERIC(38, 20)
	  , @intSubLocationId		INT
	  , @intStorageLocationId	INT
	  , @dblPickedQty			NUMERIC(38, 20)

DECLARE @tblInputItem TABLE (intRowNo			  INT IDENTITY(1, 1)
						   , intItemId			  INT
						   , dblQty				  NUMERIC(38, 20)
						   , intItemUOMId		  INT
						   , strLotTracking		  NVARCHAR(50)
						   , intSubLocationId	  INT
						   , intStorageLocationId INT)

DECLARE @tblInputItemCopy TABLE (intItemId		INT
							   , dblQty			NUMERIC(38,20)
							   , intItemUOMId   INT
							   , strLotTracking NVARCHAR(50))

DECLARE @tblLot TABLE (intRowNo				INT IDENTITY
					 , intLotId				INT
					 , intItemId			INT
					 , dblQty				NUMERIC(38, 20)
					 , intItemUOMId			INT
					 , intLocationId		INT
					 , intSubLocationId		INT
					 , intStorageLocationId INT)

DECLARE @tblPickedLot TABLE(intRowNo			 INT IDENTITY
						  , intLotId			 INT
						  , intItemId			 INT
						  , dblQty				 NUMERIC(38, 20)
						  , intItemUOMId		 INT
						  , intLocationId		 INT
						  , intSubLocationId	 INT
						  , intStorageLocationId INT
						  , dblItemRequiredQty	 NUMERIC(38, 20))

SELECT TOP 1 @dblDefaultResidueQty = ISNULL(dblDefaultResidueQty, 0.00001) 
FROM tblMFCompanyPreference

INSERT INTO @tblInputItem (intItemId
						 , dblQty
						 , intItemUOMId
						 , strLotTracking
						 , intSubLocationId
						 , intStorageLocationId)
SELECT SalesOrderDetail.intItemId
	 , SUM(SalesOrderDetail.dblQtyOrdered)
	 , SalesOrderDetail.intItemUOMId
	 , Item.strLotTracking
	 , SalesOrderDetail.intSubLocationId
	 , SalesOrderDetail.intStorageLocationId 
FROM tblSOSalesOrderDetail AS SalesOrderDetail
JOIN tblICItem AS Item ON SalesOrderDetail.intItemId = Item.intItemId 
WHERE intSalesOrderId = @intSalesOrderId AND Item.strType NOT IN ('Comment', 'Other Charge') 
GROUP BY SalesOrderDetail.intItemId
	   , SalesOrderDetail.intItemUOMId
	   , Item.strLotTracking
	   , SalesOrderDetail.intSubLocationId
	   , SalesOrderDetail.intStorageLocationId


IF EXISTS (SELECT 1 FROM tblMFPickList WHERE intSalesOrderId = @intSalesOrderId)
	BEGIN
		INSERT INTO @tblInputItemCopy(intItemId
									, dblQty
									, intItemUOMId
									, strLotTracking)
		SELECT intItemId
			 , dblQty
			 , intItemUOMId
			 , strLotTracking 
		FROM @tblInputItem

		DELETE FROM @tblInputItem;

		SELECT TOP 1 @intPickListId = intPickListId FROM tblMFPickList WHERE intSalesOrderId = @intSalesOrderId;

		/* Remaining Qty to pick. */
		INSERT INTO @tblInputItem(intItemId
								, dblQty
								, intItemUOMId
								, strLotTracking)
		SELECT InputItem.intItemId
			 , ISNULL(InputItem.dblQty, 0) - ISNULL(Temp.dblQty, 0)
			 , InputItem.intItemUOMId
			 , InputItem.strLotTracking
		FROM @tblInputItemCopy AS InputItem 
		LEFT JOIN (SELECT pld.intItemId
						, SUM(pld.dblPickQuantity) AS dblQty 
						, SUM(ISNULL(pld.dblShippedQty, 0)) AS dblShippedQty 
						, pld.intItemUOMId
				   FROM tblMFPickListDetail pld 
				   WHERE intPickListId = @intPickListId
				   GROUP BY pld.intItemId
						  , pld.intItemUOMId) AS Temp ON InputItem.intItemId = Temp.intItemId AND Temp.intItemUOMId = InputItem.intItemUOMId 
		WHERE ISNULL(Temp.dblShippedQty, 0) = 0 OR Temp.dblShippedQty IS NULL


		DELETE FROM @tblInputItem WHERE ISNULL(dblQty, 0) <= 0
	END

SELECT @intLocationId = intCompanyLocationId 
FROM tblSOSalesOrder 
WHERE intSalesOrderId = @intSalesOrderId

SELECT @intMinItem = MIN(intRowNo) 
FROM @tblInputItem

WHILE @intMinItem IS NOT NULL
	BEGIN
		SET @intSubLocationId = NULL
		SET @intStorageLocationId = NULL

		SELECT @intItemId			 = intItemId
			 , @dblRequiredQty		 = dblQty
			 , @dblItemRequiredQty   = dblQty
			 , @intItemUOMId		 = intItemUOMId
			 , @strLotTracking		 = strLotTracking
			 , @intSubLocationId	 = intSubLocationId
			 , @intStorageLocationId =	intStorageLocationId 
		FROM @tblInputItem 
		WHERE intRowNo = @intMinItem;

		IF @intSubLocationId IS NULL
			BEGIN
				SELECT @intSubLocationId = intSubLocationId 
				FROM tblICStorageLocation 
				WHERE intStorageLocationId = @intStorageLocationId;
			END

		DELETE FROM @tblLot;

		IF @strLotTracking = 'No'
			BEGIN
				INSERT INTO @tblLot (intLotId
								   , intItemId
								   , dblQty
								   , intItemUOMId
								   , intLocationId
								   , intSubLocationId
								   , intStorageLocationId)
				SELECT 0
					 , StockDetail.intItemId
					 , dbo.fnMFConvertQuantityToTargetItemUOM(StockDetail.intItemUOMId, @intItemUOMId, StockDetail.dblAvailableQty)
					 , @intItemUOMId
					 , StockDetail.intLocationId
					 , ISNULL(@intSubLocationId, StockDetail.intSubLocationId)
					 , ISNULL(@intStorageLocationId, StockDetail.intStorageLocationId)
				FROM vyuMFGetItemStockDetail AS StockDetail 
				WHERE StockDetail.intItemId = @intItemId 
				  AND StockDetail.dblAvailableQty > @dblDefaultResidueQty 
				  AND StockDetail.intLocationId = @intLocationId 
				  AND ISNULL(StockDetail.ysnStockUnit, 0) = 1 
				ORDER BY StockDetail.intItemStockUOMId;
			END
		
		ELSE
			BEGIN
			
				INSERT INTO @tblLot (intLotId
								   , intItemId
								   , dblQty
								   , intItemUOMId
								   , intLocationId
								   , intSubLocationId
								   , intStorageLocationId)
				SELECT intLotId
					 , intItemId
					 , dblQty
					 , intItemUOMId
					 , intLocationId
					 , intSubLocationId
					 , intStorageLocationId
				FROM (SELECT L.intLotId
						   , L.intItemId
						   , dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId, @intItemUOMId, L.dblQty) - (SELECT ISNULL(SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(sr.intItemUOMId, @intItemUOMId, sr.dblQty), 0)), 0) 
																												FROM tblICStockReservation sr 
																												WHERE sr.intLotId = L.intLotId AND ISNULL(sr.ysnPosted, 0) = 0) AS dblQty
						   , @intItemUOMId AS intItemUOMId
						   , L.intLocationId
						   , L.intSubLocationId
						   , L.intStorageLocationId
						   , CASE WHEN L.intStorageLocationId = @intStorageLocationId THEN 0 ELSE 1 END AS intOrderById
						   , L.dtmDateCreated
					  FROM tblICLot L
					  JOIN tblICLotStatus LS ON L.intLotStatusId = LS.intLotStatusId
					  WHERE L.intItemId = @intItemId AND L.intLocationId = @intLocationId AND LS.strPrimaryStatus IN ('Active')
						AND (L.dtmExpiryDate IS NULL OR L.dtmExpiryDate >= GETDATE())
						AND L.dblQty > @dblDefaultResidueQty) t 
				ORDER BY t.intOrderById,t.dtmDateCreated
			END

		DELETE FROM @tblLot WHERE dblQty < @dblDefaultResidueQty

		SELECT @intMinLot = MIN(intRowNo) 
		FROM @tblLot;

		WHILE @intMinLot IS NOT NULL
			BEGIN
				SELECT @intLotId = intLotId
					 , @dblAvailableQty = dblQty 
				FROM @tblLot 
				WHERE intRowNo = @intMinLot

				IF @dblAvailableQty >= @dblRequiredQty 
					BEGIN
						INSERT INTO @tblPickedLot(intLotId
												, intItemId
												, dblQty
												, intItemUOMId
												, intLocationId
												, intSubLocationId
												, intStorageLocationId
												, dblItemRequiredQty)
						SELECT @intLotId
							 , @intItemId
							 , @dblRequiredQty
							 , intItemUOMId
							 , intLocationId
							 , intSubLocationId
							 , intStorageLocationId
							 , @dblRequiredQty 
						FROM @tblLot 
						WHERE intRowNo=@intMinLot

						GOTO NEXT_ITEM
					END
				ELSE	
					BEGIN
						/* Set Available Qty same as Required Qty if item Negative Invetory is Yes. */
						IF (SELECT intAllowNegativeInventory FROM tblICItemLocation WHERE intItemId = @intItemId AND intLocationId = @intLocationId) = 1
							BEGIN
								SET @dblPickedQty = @dblRequiredQty;
							END
						ELSE
							BEGIN
								SET @dblPickedQty = @dblAvailableQty;
							END

						INSERT INTO @tblPickedLot(intLotId
												, intItemId
												, dblQty
												, intItemUOMId
												, intLocationId
												, intSubLocationId
												, intStorageLocationId
												, dblItemRequiredQty)
						SELECT @intLotId
							 , @intItemId
							 , @dblPickedQty
							 , intItemUOMId
							 , intLocationId
							 , intSubLocationId
							 , intStorageLocationId
							 , @dblAvailableQty 
						FROM @tblLot 
						WHERE intRowNo=@intMinLot

						SET @dblRequiredQty = @dblRequiredQty - @dblAvailableQty
					END

				SELECT @intMinLot = MIN(intRowNo) 
				FROM @tblLot 
				WHERE intRowNo>@intMinLot
			END

		IF ISNULL(@dblRequiredQty, 0) > 0
			BEGIN
				/* Set Available Qty same as Required Qty if item Negative Invetory is Yes. */
				IF (SELECT intAllowNegativeInventory FROM tblICItemLocation WHERE intItemId = @intItemId AND intLocationId = @intLocationId) = 1
					BEGIN
						SET @dblPickedQty = @dblRequiredQty;
					END
				ELSE
					BEGIN
						SET @dblPickedQty = @dblAvailableQty;
					END

				INSERT INTO @tblPickedLot(intLotId
										, intItemId
										, dblQty
										, intItemUOMId
										, intLocationId
										, intSubLocationId
										, intStorageLocationId
										, dblItemRequiredQty)
				Select 0
					 , @intItemId
					 , @dblPickedQty
					 , @intItemUOMId
					 , @intLocationId
					 , 0
					 , 0
					 , @dblRequiredQty
			END

		NEXT_ITEM:
		
		SELECT @intMinItem = MIN(intRowNo) 
		FROM @tblInputItem 
		WHERE intRowNo>@intMinItem
	END

/* Existing Record / Pick List. */
IF EXISTS (SELECT 1 FROM tblMFPickList WHERE intSalesOrderId = @intSalesOrderId)
	BEGIN 
		SELECT pld.intPickListDetailId
			 , pld.intPickListId
			 , p.intSalesOrderId
			 , pld.intItemId
			 , i.strItemNo
			 , i.strDescription
			 , l.intLotId
			 , l.strLotNumber
			 , pld.intStorageLocationId
			 , sl.strName			AS strStorageLocationName
			 , CASE WHEN ISNULL(pld.dblShippedQty, 0) <> 0 THEN pld.dblShippedQty
					ELSE pld.dblQuantity 
			   END AS dblPickQuantity
			 , pld.intItemUOMId		AS intPickUOMId
			 , um.strUnitMeasure	AS strPickUOM
			 , pl.intParentLotId
			 , pld.intSubLocationId
			 , sbl.strSubLocationName
			 , pld.intLocationId
			 , i.strLotTracking
			 , CASE WHEN pld.dblShippedQty IS NOT NULL AND pld.dblShippedQty > pld.dblPickQuantity THEN pld.dblShippedQty
					WHEN pld.dblShippedQty IS NOT NULL AND pld.dblShippedQty > pld.dblPickQuantity THEN pld.dblShippedQty
					ELSE pld.dblPickQuantity 
			   END AS dblItemRequiredQty
		FROM tblMFPickListDetail pld 
		JOIN tblMFPickList p ON pld.intPickListId = p.intPickListId
		JOIN tblICItem i ON pld.intItemId = i.intItemId 
		LEFT JOIN tblICLot l ON pld.intLotId = l.intLotId
		LEFT JOIN tblICParentLot pl ON l.intParentLotId = pl.intParentLotId
		LEFT JOIN tblICStorageLocation sl ON pld.intStorageLocationId = sl.intStorageLocationId
		LEFT JOIN tblSMCompanyLocationSubLocation sbl ON pld.intSubLocationId = sbl.intCompanyLocationSubLocationId
		LEFT JOIN tblSMCompanyLocation cl ON pld.intLocationId = cl.intCompanyLocationId
		JOIN tblICItemUOM iu ON pld.intItemUOMId = iu.intItemUOMId
		JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
		WHERE p.intSalesOrderId = @intSalesOrderId
		UNION 
		/* Remaining Pick. */
		SELECT 0
			 , @intPickListId
			 , @intSalesOrderId
			 , p.intItemId
			 , i.strItemNo
			 , i.strDescription
			 , l.intLotId
			 , l.strLotNumber
			 , p.intStorageLocationId
			 , sl.strName			AS strStorageLocationName
			 , p.dblQty				AS dblPickQuantity
			 , p.intItemUOMId		AS intPickUOMId
			 , um.strUnitMeasure	AS strPickUOM
			 , pl.intParentLotId
			 , p.intSubLocationId
			 , sbl.strSubLocationName
			 , p.intLocationId
			 , i.strLotTracking
			 , p.dblItemRequiredQty
		FROM @tblPickedLot p 
		JOIN tblICItem i ON p.intItemId = i.intItemId 
		LEFT JOIN tblICLot l ON p.intLotId = l.intLotId
		LEFT JOIN tblICParentLot pl ON l.intParentLotId = pl.intParentLotId
		LEFT JOIN tblICStorageLocation sl ON p.intStorageLocationId = sl.intStorageLocationId
		LEFT JOIN tblSMCompanyLocationSubLocation sbl ON p.intSubLocationId = sbl.intCompanyLocationSubLocationId
		LEFT JOIN tblSMCompanyLocation cl ON p.intLocationId = cl.intCompanyLocationId
		JOIN tblICItemUOM iu ON p.intItemUOMId = iu.intItemUOMId
		JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
	END
ELSE 
	BEGIN 
		/* New PickList. */
		SELECT p.intItemId
			 , i.strItemNo
			 , i.strDescription
			 , l.intLotId
			 , l.strLotNumber
			 , p.intStorageLocationId
			 , sl.strName				AS strStorageLocationName
			 , p.dblItemRequiredQty		AS dblPickQuantity
			 , p.intItemUOMId			AS intPickUOMId
			 , um.strUnitMeasure		AS strPickUOM
			 , pl.intParentLotId
			 , p.intSubLocationId
			 , sbl.strSubLocationName
			 , p.intLocationId
			 , i.strLotTracking
			 , p.dblItemRequiredQty
		FROM @tblPickedLot p 
		JOIN tblICItem i ON p.intItemId = i.intItemId 
		LEFT JOIN tblICLot l ON p.intLotId = l.intLotId
		LEFT JOIN tblICParentLot pl ON l.intParentLotId = pl.intParentLotId
		LEFT JOIN tblICStorageLocation sl ON p.intStorageLocationId = sl.intStorageLocationId
		LEFT JOIN tblSMCompanyLocationSubLocation sbl ON p.intSubLocationId = sbl.intCompanyLocationSubLocationId
		LEFT JOIN tblSMCompanyLocation cl ON p.intLocationId = cl.intCompanyLocationId
		JOIN tblICItemUOM iu ON p.intItemUOMId = iu.intItemUOMId
		JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
	END