﻿CREATE PROC uspRKGetCollateralDetail
	@intCommodityId int
	, @intLocationId int = NULL
	, @strCollateralType nvarchar(20)

AS

DECLARE @tblTemp TABLE (intCollateralId int
	, strLocationName nvarchar(50) COLLATE Latin1_General_CI_AS
	, strCustomer nvarchar(50) COLLATE Latin1_General_CI_AS
	, strReceiptNo nvarchar(50) COLLATE Latin1_General_CI_AS
	, strContractNumber nvarchar(100) COLLATE Latin1_General_CI_AS
	, dtmOpenDate datetime
	, dblOriginalQuantity  numeric(24,10)
	, dblRemainingQuantity numeric(24,10)
	, intCommodityId int)

IF @strCollateralType ='Sale'
BEGIN
	IF ISNULL(@intLocationId, 0) <> 0
	BEGIN
		INSERT INTO @tblTemp (intCollateralId
			, strLocationName
			, strCustomer
			, strReceiptNo
			, strContractNumber
			, dtmOpenDate
			, dblOriginalQuantity
			, dblRemainingQuantity
			, intCommodityId)
		SELECT c.intCollateralId
			, cl.strLocationName
			, c.strCustomer
			, c.strReceiptNo
			, ch.strContractNumber
			, c.dtmOpenDate
			, isnull(c.dblOriginalQuantity,0.0) dblOriginalQuantity,isnull(c.dblRemainingQuantity,0.0) as dblRemainingQuantity,c.intCommodityId
		FROM tblRKCollateral c
		LEFT JOIN tblCTContractHeader ch on c.intContractHeaderId=ch.intContractHeaderId
		JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=c.intLocationId
		WHERE strType = 'Sale' and c.intCommodityId=@intCommodityId AND c.intLocationId = @intLocationId
	END
	ELSE
	BEGIN
		INSERT INTO @tblTemp (intCollateralId
			, strLocationName
			, strCustomer
			, strReceiptNo
			, strContractNumber
			, dtmOpenDate
			, dblOriginalQuantity
			, dblRemainingQuantity
			, intCommodityId)
		SELECT c.intCollateralId
			, cl.strLocationName
			, c.strCustomer
			, c.strReceiptNo
			, ch.strContractNumber
			, c.dtmOpenDate
			, isnull(c.dblOriginalQuantity,0) dblOriginalQuantity,c.dblRemainingQuantity,c.intCommodityId
		FROM tblRKCollateral c
		LEFT JOIN tblCTContractHeader ch on c.intContractHeaderId=ch.intContractHeaderId
		JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=c.intLocationId
		WHERE strType = 'Sale' and c.intCommodityId=@intCommodityId
	END
END
ELSE
BEGIN
	IF ISNULL(@intLocationId, 0) <> 0
	BEGIN
		INSERT INTO @tblTemp (intCollateralId
			, strLocationName
			, strCustomer
			, strReceiptNo
			, strContractNumber
			, dtmOpenDate
			, dblOriginalQuantity
			, dblRemainingQuantity
			, intCommodityId)
		SELECT c.intCollateralId
			, cl.strLocationName
			, c.strCustomer
			, c.strReceiptNo
			, ch.strContractNumber
			, c.dtmOpenDate
			, isnull(c.dblOriginalQuantity,0.0) dblOriginalQuantity,isnull(c.dblRemainingQuantity,0.0) as dblRemainingQuantity,c.intCommodityId
		FROM tblRKCollateral c
		LEFT JOIN tblCTContractHeader ch on c.intContractHeaderId=ch.intContractHeaderId
		JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=c.intLocationId
		WHERE strType = 'Purchase' and c.intCommodityId=@intCommodityId AND c.intLocationId = @intLocationId
	END
	ELSE
	BEGIN
		INSERT INTO @tblTemp (intCollateralId
			, strLocationName
			, strCustomer
			, strReceiptNo
			, strContractNumber
			, dtmOpenDate
			, dblOriginalQuantity
			, dblRemainingQuantity
			, intCommodityId)
		SELECT c.intCollateralId
			, cl.strLocationName
			, c.strCustomer
			, c.strReceiptNo
			, ch.strContractNumber
			, c.dtmOpenDate
			, isnull(c.dblOriginalQuantity,0) dblOriginalQuantity,c.dblRemainingQuantity,c.intCommodityId
		FROM tblRKCollateral c
		LEFT JOIN tblCTContractHeader ch on c.intContractHeaderId=ch.intContractHeaderId
		JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=c.intLocationId
		WHERE strType = 'Purchase' and c.intCommodityId=@intCommodityId
	END
END

SELECT intCollateralId
	, strLocationName
	, strCustomer
	, strReceiptNo
	, strContractNumber
	, dtmOpenDate
	, dblOriginalQuantity
	, dblRemainingQuantity
FROM @tblTemp