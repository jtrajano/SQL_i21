﻿CREATE PROCEDURE [dbo].[uspARGetItemPrice]
	@ItemId					INT
	,@CustomerId			INT	
	,@LocationId			INT				= NULL
	,@ItemUOMId				INT				= NULL
	,@TransactionDate		DATETIME		= NULL
	,@Quantity				NUMERIC(18,6)
	,@Price					NUMERIC(18,6)	= NULL OUTPUT
	,@Pricing				NVARCHAR(250)	= NULL OUTPUT
	,@ContractHeaderId		INT				= NULL OUTPUT
	,@ContractDetailId		INT				= NULL OUTPUT
	,@ContractNumber		NVARCHAR(50)	= NULL OUTPUT
	,@ContractSeq			INT				= NULL OUTPUT
	,@AvailableQuantity     NUMERIC(18,6)   = NULL OUTPUT
	,@OriginalQuantity		NUMERIC(18,6)	= NULL
	,@CustomerPricingOnly	BIT				= 0
	,@VendorId				INT				= NULL
	,@SupplyPointId			INT				= NULL
	,@LastCost				NUMERIC(18,6)	= NULL
	,@ShipToLocationId      INT				= NULL
	,@VendorLocationId		INT				= NULL
AS	
	
	SELECT
		 @Price				= dblPrice
		,@Pricing			= strPricing
		,@ContractHeaderId	= intContractHeaderId
		,@ContractDetailId	= intContractDetailId
		,@ContractNumber	= strContractNumber
		,@ContractSeq		= intContractSeq
		,@AvailableQuantity = dblAvailableQty
	FROM
		[dbo].[fnARGetItemPricingDetails](
			 @ItemId
			,@CustomerId
			,@LocationId
			,@ItemUOMId
			,@TransactionDate
			,@Quantity
			,@ContractHeaderId
			,@ContractDetailId
			,@ContractNumber
			,@ContractSeq
			,@AvailableQuantity
			,@OriginalQuantity
			,@CustomerPricingOnly
			,@VendorId
			,@SupplyPointId
			,@LastCost
			,@ShipToLocationId
			,@VendorLocationId
		)

RETURN 0
