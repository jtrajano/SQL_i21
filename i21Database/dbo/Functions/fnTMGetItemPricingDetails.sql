CREATE FUNCTION [dbo].[fnTMGetItemPricingDetails]
(
	 @ItemId					INT
	,@CustomerId				INT	
	,@LocationId				INT
	,@ItemUOMId					INT
	,@CurrencyId				INT
	,@TransactionDate			DATETIME
	,@Quantity					NUMERIC(18,6)
	,@ContractHeaderId			INT
	,@ContractDetailId			INT
	,@ContractNumber			NVARCHAR(50)
	,@ContractSeq				INT
	,@AvailableQuantity			NUMERIC(18,6)
	,@UnlimitedQuantity			BIT
	,@OriginalQuantity			NUMERIC(18,6)
	,@CustomerPricingOnly		BIT
	,@ItemPricingOnly			BIT
	,@ExcludeContractPricing	BIT
	,@VendorId					INT
	,@SupplyPointId				INT
	,@LastCost					NUMERIC(18,6)
	,@ShipToLocationId			INT
	,@VendorLocationId			INT
	,@PricingLevelId			INT
	,@AllowQtyToExceed			BIT
	,@InvoiceType				NVARCHAR(200)
	,@TermId					INT
	,@GetAllAvailablePricing	BIT	
	,@CheckTMContract			BIT = 0
	,@intSiteId					INT
)
RETURNS @returntable TABLE
(
	 dblPrice				NUMERIC(18,6)
	,strPricing				NVARCHAR(250)
	,intContractDetailId	INT
)
AS
BEGIN
	IF(@CheckTMContract = 0)
	BEGIN
		INSERT @returntable(dblPrice
							,strPricing
							,intContractDetailId)

		SELECT dblPrice
			  ,strPricing
			  ,intContractDetailId
		FROM [dbo].[fnARGetItemPricingDetails](
			@ItemId				
			,@CustomerId				
			,@LocationId			
			,@ItemUOMId				
			,@CurrencyId			
			,@TransactionDate		
			,@Quantity				
			,@ContractHeaderId		
			,@ContractDetailId		
			,@ContractNumber		
			,@ContractSeq			
			,@AvailableQuantity		
			,@UnlimitedQuantity		
			,@OriginalQuantity		
			,@CustomerPricingOnly	
			,@ItemPricingOnly		
			,@ExcludeContractPricing
			,@VendorId				
			,@SupplyPointId			
			,@LastCost				
			,@ShipToLocationId		
			,@VendorLocationId		
			,@PricingLevelId		
			,@AllowQtyToExceed		
			,@InvoiceType			
			,@TermId				
			,@GetAllAvailablePricing)

	END
	ELSE
	BEGIN
			------Check Contracts
			DECLARE @strItemNo NVARCHAR(50)
			DECLARE @strItemClass NVARCHAR(50)
			DECLARE @intItemClass INT
			--DECLARE @strLocationNo NVARCHAR(10)
			DECLARE @strClassFill NVARCHAR(20)

			DECLARE @strContractNumber NVARCHAR(50)
			DECLARE @A4GLIdentity INT
			DECLARE @ysnMaxPrice BIT
			DECLARE @dblPrice NUMERIC(18,6)
			DECLARE @ItemTable TMCompactItem
			DECLARE @ContractTable TMCompactContract
			DECLARE @intItemId INT


				--- get site info
			SELECT TOP 1
				@strClassFill = strClassFillOption
				,@intItemId = intProduct 
			FROM tblTMSite WHERE intSiteID = @intSiteId

			---- get item info
			SELECT TOP 1 
				@strItemNo = strItemNo
				,@intItemClass = intCategoryId
			FROM tblICItem WHERE intItemId = @intItemId


		


			--SELECT TOP 1
			--	@strLocationNo = vwloc_loc_no COLLATE Latin1_General_CI_AS
			--FROM tblTMSite A
			--INNER JOIN vwlocmst B
			--	ON A.intLocationId = B.A4GLIdentity
			--WHERE  A.intSiteID = @intSiteId

			---Item
			INSERT INTO @ItemTable(
				[intItemId] 
				,[strItemNo] 
				,[strLocation] 
			)
			SELECT
				[intItemId] = A4GLIdentity
				,[strItemNo] = vwitm_no COLLATE Latin1_General_CI_AS
				,[strLocation] = vwitm_loc_no COLLATE Latin1_General_CI_AS 
			FROM vwitmmst
			WHERE vwitm_avail_tm = 'Y'
				--AND vwitm_loc_no = @strLocationNo

			--- Contract
			INSERT INTO @ContractTable(
				[intContractId] 
				,[strContractNumber]
				,[strLocation]
				,[strItemOrClass]
				,[strCustomerNumber]
			)
			SELECT 
				[intContractId] = A.A4GLIdentity
				,[strContractNumber] = A.vwcnt_cnt_no
				,[strLocation] = A.vwcnt_loc_no
				,[strItemOrClass] = A.vwcnt_itm_or_cls
				,[strCustomerNumber] = A.vwcnt_cus_no
			FROM vwcntmst A
			INNER JOIN vyuCTCustomerContract B
				ON A.A4GLIdentity = B.intContractDetailId
			INNER JOIN tblCTContractHeader C
				ON B.intContractHeaderId = C.intContractHeaderId
			WHERE vwcnt_loc_no <> '000'
				--AND vwcnt_loc_no = @strLocationNo
				AND vwcnt_due_rev_dt >= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0)
				AND vwcnt_un_bal > 0
				AND B.dblAvailableQty > @Quantity
				AND A4GLIdentity NOT IN (SELECT DISTINCT intContractID 
										FROM tblTMSiteLink
										WHERE intSiteID <> @intSiteId
											AND intContractID NOT IN (SELECT DISTINCT intContractID
																		FROM tblTMSiteLink
																		WHERE intSiteID = @intSiteId))
				AND B.intEntityCustomerId = @CustomerId

			---------------------------------------------------------------------------------------------
			--Linked Site to Contract with Same Item and Contract Item is Available for TM
			---------------------------------------------------------------------------------------------
			SELECT TOP 1
				@strContractNumber = A.vwcnt_cnt_no
				,@A4GLIdentity = A.A4GLIdentity
				,@ysnMaxPrice = A.ysnMaxPrice
				,@dblPrice = A.vwcnt_un_prc
			FROM tblTMSiteLink C
			INNER JOIN vwcntmst A
				ON A.A4GLIdentity = C.intContractID
			INNER JOIN vyuCTCustomerContract H
				ON A.A4GLIdentity = H.intContractDetailId
			INNER JOIN tblICItem B
				ON H.intItemId = B.intItemId
			INNER JOIN @ContractTable E
				ON A.A4GLIdentity = E.intContractId
			INNER JOIN tblTMSite G
				ON C.intSiteID = G.intSiteID
			INNER JOIN @ItemTable F
				ON G.intProduct =  F.intItemId
					AND B.intItemId = G.intProduct
			WHERE C.intSiteID = @intSiteId
		
			IF(@A4GLIdentity  IS NOT NULL)
			BEGIN
				GOTO INSERTANDRETURN
			END

			---------------------------------------------------------------------------------------------
			---------------------------------------------------------------------------------------------

			---------------------------------------------------------------------------------------------
			--Linked Site to Contract with Different Item and Contract Item is Available for TM
			---------------------------------------------------------------------------------------------

			SELECT TOP 1
				@strContractNumber = A.vwcnt_cnt_no
				,@A4GLIdentity = A.A4GLIdentity
				,@ysnMaxPrice = A.ysnMaxPrice
				,@dblPrice = A.vwcnt_un_prc
			FROM tblTMSiteLink C
			INNER JOIN vwcntmst A
				ON A.A4GLIdentity = C.intContractID
			INNER JOIN vyuCTCustomerContract H
				ON A.A4GLIdentity = H.intContractDetailId
			INNER JOIN tblICItem B
				ON H.intItemId = B.intItemId
			INNER JOIN @ContractTable E
				ON A.A4GLIdentity = E.intContractId
			WHERE C.intSiteID = @intSiteId
				AND B.ysnAvailableTM = 1

			IF(@A4GLIdentity  IS NOT NULL)
			BEGIN
				GOTO INSERTANDRETURN
			END
			---------------------------------------------------------------------------------------------
			---------------------------------------------------------------------------------------------

			---------------------------------------------------------------------------------------------
			---Linked Site to Contract with No Item for Product Class that Matches Site Item Class
			---------------------------------------------------------------------------------------------

			SELECT TOP 1
				@strContractNumber = A.vwcnt_cnt_no
				,@A4GLIdentity = A.A4GLIdentity
				,@ysnMaxPrice = A.ysnMaxPrice
				,@dblPrice = A.vwcnt_un_prc
			FROM vwcntmst A
			INNER JOIN tblTMSiteLink C
				ON A.A4GLIdentity = C.intContractID
			INNER JOIN @ContractTable E
				ON A.A4GLIdentity = E.intContractId
			INNER JOIN vyuCTCustomerContract F
				ON A.A4GLIdentity = F.intContractDetailId
			INNER JOIN tblICItem G
				ON F.intItemId = G.intItemId
			INNER JOIN tblICCategory H
				ON G.intCategoryId = H.intCategoryId
			WHERE C.intSiteID = @intSiteId
				AND H.intCategoryId = @intItemClass
			IF(@A4GLIdentity  IS NOT NULL)
			BEGIN
				GOTO INSERTANDRETURN
			END
			---------------------------------------------------------------------------------------------
			---------------------------------------------------------------------------------------------

			---------------------------------------------------------------------------------------------
			---Contract with Same Item and Contract Item is Available for TM	
			---------------------------------------------------------------------------------------------

			SELECT TOP 1
				@strContractNumber = A.vwcnt_cnt_no
				,@A4GLIdentity = A.A4GLIdentity
				,@ysnMaxPrice = A.ysnMaxPrice
				,@dblPrice = A.vwcnt_un_prc
			FROM vwcntmst A
			INNER JOIN vyuCTCustomerContract B
				ON A.A4GLIdentity = B.intContractDetailId
			INNER JOIN @ContractTable E
				ON A.A4GLIdentity = E.intContractId
			INNER JOIN tblTMSite G
				ON B.intItemId = G.intProduct
			INNER JOIN @ItemTable F
				ON G.intProduct =  F.intItemId
			WHERE G.intSiteID = @intSiteId
		
			IF(@A4GLIdentity  IS NOT NULL)
			BEGIN
				GOTO INSERTANDRETURN
			END
			---------------------------------------------------------------------------------------------
			---------------------------------------------------------------------------------------------


			---------------------------------------------------------------------------------------------
			---Contract with Different Item In Same Class and Site setup for Class Fill = Product Class and Contract Item is Available for TM
			---------------------------------------------------------------------------------------------
			IF(@strClassFill = 'Product Class')
			BEGIN
				SELECT TOP 1
					@strContractNumber = A.vwcnt_cnt_no
					,@A4GLIdentity = A.A4GLIdentity
					,@ysnMaxPrice = A.ysnMaxPrice
					,@dblPrice = A.vwcnt_un_prc
				FROM vwcntmst A
				INNER JOIN vyuCTCustomerContract B
					ON A.A4GLIdentity = B.intContractDetailId
				INNER JOIN @ContractTable E
					ON A.A4GLIdentity = E.intContractId
				INNER JOIN @ItemTable F
					ON B.intItemId =  F.intItemId
				INNER JOIN tblICItem G
					ON B.intItemId = G.intItemId
				WHERE G.intCategoryId = @intItemClass
		
				IF(@A4GLIdentity  IS NOT NULL)
				BEGIN
					GOTO INSERTANDRETURN
				END
			END
			---------------------------------------------------------------------------------------------
			---------------------------------------------------------------------------------------------

			---------------------------------------------------------------------------------------------
			---Contract with Different Item In Different Class and Site setup for Class Fill = Any Item and Contract Item is Available for TM
			---------------------------------------------------------------------------------------------
			IF(@strClassFill = 'Any Item')
			BEGIN
				SELECT TOP 1
					@strContractNumber = A.vwcnt_cnt_no
					,@A4GLIdentity = A.A4GLIdentity
					,@ysnMaxPrice = A.ysnMaxPrice
					,@dblPrice = A.vwcnt_un_prc
				FROM vwcntmst A
				INNER JOIN @ContractTable E
					ON A.A4GLIdentity = E.intContractId
						
		
				IF(@A4GLIdentity  IS NOT NULL)
				BEGIN
					GOTO INSERTANDRETURN
				END
			END
			---------------------------------------------------------------------------------------------
			---------------------------------------------------------------------------------------------

			---------------------------------------------------------------------------------------------
			---Contract with No item, but for Product Class that Matches Site Item Class
			---------------------------------------------------------------------------------------------
			SELECT TOP 1
				@strContractNumber = A.vwcnt_cnt_no
				,@A4GLIdentity = A.A4GLIdentity
				,@ysnMaxPrice = A.ysnMaxPrice
				,@dblPrice = A.vwcnt_un_prc
			FROM vwcntmst A
				INNER JOIN vyuCTCustomerContract B
					ON A.A4GLIdentity = B.intContractDetailId
				INNER JOIN @ContractTable E
					ON A.A4GLIdentity = E.intContractId
				INNER JOIN @ItemTable F
					ON B.intItemId =  F.intItemId
				INNER JOIN tblICItem G
					ON B.intItemId = G.intItemId
				WHERE G.intCategoryId = @intItemClass
		
			IF(@A4GLIdentity  IS NOT NULL)
			BEGIN
				GOTO INSERTANDRETURN
			END
			---------------------------------------------------------------------------------------------
			---------------------------------------------------------------------------------------------

			

			--------------------------------
			---------------------------------
			-------------------------------
			INSERT @returntable(dblPrice
							,strPricing
							,intContractDetailId)

			SELECT dblPrice
				  ,strPricing
				  ,intContractDetailId
			FROM [dbo].[fnARGetItemPricingDetails](
				@ItemId				
				,@CustomerId				
				,@LocationId			
				,@ItemUOMId				
				,@CurrencyId			
				,@TransactionDate		
				,@Quantity				
				,@ContractHeaderId		
				,@ContractDetailId		
				,@ContractNumber		
				,@ContractSeq			
				,@AvailableQuantity		
				,@UnlimitedQuantity		
				,@OriginalQuantity		
				,@CustomerPricingOnly	
				,@ItemPricingOnly		
				,1
				,@VendorId				
				,@SupplyPointId			
				,@LastCost				
				,@ShipToLocationId		
				,@VendorLocationId		
				,@PricingLevelId		
				,@AllowQtyToExceed		
				,@InvoiceType			
				,@TermId				
				,@GetAllAvailablePricing)


			RETURN
			INSERTANDRETURN:
			
			--------------------------------
			---------------------------------
			-------------------------------
			INSERT @returntable(dblPrice
							,strPricing
							,intContractDetailId)

			SELECT dblPrice
				  ,strPricing
				  ,intContractDetailId
			FROM [dbo].[fnARGetItemPricingDetails](
				@ItemId				
				,@CustomerId				
				,@LocationId			
				,@ItemUOMId				
				,@CurrencyId			
				,@TransactionDate		
				,@Quantity				
				,@ContractHeaderId		
				,@A4GLIdentity--@ContractDetailId		
				,@ContractNumber		
				,@ContractSeq			
				,@AvailableQuantity		
				,@UnlimitedQuantity		
				,@OriginalQuantity		
				,@CustomerPricingOnly	
				,@ItemPricingOnly		
				,@ExcludeContractPricing
				,@VendorId				
				,@SupplyPointId			
				,@LastCost				
				,@ShipToLocationId		
				,@VendorLocationId		
				,@PricingLevelId		
				,@AllowQtyToExceed		
				,@InvoiceType			
				,@TermId				
				,@GetAllAvailablePricing)
		END

	RETURN
END