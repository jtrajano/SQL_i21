﻿CREATE PROC uspRKGetContractDetail
	@intCommodityId int
	, @intLocationId int = NULL
	, @intSeqId int

AS

DECLARE @tblTemp TABLE (intContractDetailId int
	, strLocationName nvarchar(50) COLLATE Latin1_General_CI_AS
	, strContractNumber nvarchar(50) COLLATE Latin1_General_CI_AS
	, intContractSeq int
	, strEntityName nvarchar(100) COLLATE Latin1_General_CI_AS
	, dtmEndDate datetime
	, Comments nvarchar(500) COLLATE Latin1_General_CI_AS
	, strShipVia nvarchar(500) COLLATE Latin1_General_CI_AS
	, dblCashPrice numeric(24,10)
	, strPricingType nvarchar(50) COLLATE Latin1_General_CI_AS
	, strCurrency nvarchar(50) COLLATE Latin1_General_CI_AS
	, dblTotal numeric(24,10)
	, intCommodityId int)

IF @intSeqId = 1
BEGIN
	IF ISNULL(@intLocationId, 0) <> 0
	BEGIN
		INSERT INTO @tblTemp (intContractDetailId
			, strLocationName
			, strContractNumber
			, intContractSeq
			, strEntityName
			, dtmEndDate
			, Comments
			, strShipVia
			, dblCashPrice
			, strPricingType
			, strCurrency
			, dblTotal
			, intCommodityId)
		SELECT CD.intContractDetailId
			, CD.strLocationName
			, CD.strContractNumber
			, CD.intContractSeq
			, strEntityName
			, CD.dtmEndDate
			, CD.strRemark as Comments
			, strFreightTerm as strShipVia
			, isnull(dblCashPrice,0) dblCashPrice
			, strPricingType
			, strCurrency
			, isnull(CD.dblBalance,0) AS dblTotal
			, intCommodityId
		FROM vyuCTContractDetailView CD
		WHERE CD.intContractTypeId = 1 and CD.intContractStatusId <> 3  AND CD.intPricingTypeId IN (1)
			and CD.intCommodityId = @intCommodityId AND CD.intCompanyLocationId = @intLocationId
	END
	ELSE
	BEGIN
		INSERT INTO @tblTemp (intContractDetailId
			, strLocationName
			, strContractNumber
			, intContractSeq
			, strEntityName
			, dtmEndDate
			, Comments
			, strShipVia
			, dblCashPrice
			, strPricingType
			, strCurrency
			, dblTotal
			, intCommodityId)
		SELECT CD.intContractDetailId
			, CD.strLocationName
			, CD.strContractNumber
			, CD.intContractSeq
			, strEntityName
			, CD.dtmEndDate
			, CD.strRemark as Comments
			, strFreightTerm as strShipVia
			, isnull(dblCashPrice,0) dblCashPrice
			, strPricingType
			, strCurrency
			, isnull(CD.dblBalance,0) AS dblTotal
			, intCommodityId
		FROM vyuCTContractDetailView CD
		WHERE CD.intContractTypeId = 1 and CD.intContractStatusId <> 3 AND CD.intPricingTypeId IN (1)
			AND CD.intCommodityId = @intCommodityId
	END
END
ELSE IF @intSeqId = 2
BEGIN
	IF ISNULL(@intLocationId, 0) <> 0
	BEGIN
		INSERT INTO @tblTemp (intContractDetailId
			, strLocationName
			, strContractNumber
			, intContractSeq
			, strEntityName
			, dtmEndDate
			, Comments
			, strShipVia
			, dblCashPrice
			, strPricingType
			, strCurrency
			, dblTotal
			, intCommodityId)
		SELECT CD.intContractDetailId
			, CD.strLocationName
			, CD.strContractNumber
			, CD.intContractSeq
			, strEntityName
			, CD.dtmEndDate
			, CD.strRemark as Comments
			, strFreightTerm as strShipVia
			, isnull(dblCashPrice,0) dblCashPrice
			, strPricingType
			, strCurrency
			, isnull(CD.dblBalance,0) AS dblTotal
			, intCommodityId
		FROM vyuCTContractDetailView CD
		WHERE CD.intContractTypeId = 1 and CD.intContractStatusId <> 3 AND CD.intPricingTypeId IN (2)
			and CD.intCommodityId = @intCommodityId AND CD.intCompanyLocationId = @intLocationId
	END
	ELSE
	BEGIN
		INSERT INTO @tblTemp (intContractDetailId
			, strLocationName
			, strContractNumber
			, intContractSeq
			, strEntityName
			, dtmEndDate
			, Comments
			, strShipVia
			, dblCashPrice
			, strPricingType
			, strCurrency
			, dblTotal
			, intCommodityId)
		SELECT CD.intContractDetailId
			, CD.strLocationName
			, CD.strContractNumber
			, CD.intContractSeq
			, strEntityName
			, CD.dtmEndDate
			, CD.strRemark as Comments
			, strFreightTerm as strShipVia
			, isnull(dblCashPrice,0) dblCashPrice
			, strPricingType
			, strCurrency
			, isnull(CD.dblBalance,0) AS dblTotal
			, intCommodityId
		FROM vyuCTContractDetailView CD
		WHERE CD.intContractTypeId = 1 and CD.intContractStatusId <> 3 AND CD.intPricingTypeId IN (2)
			AND CD.intCommodityId = @intCommodityId
	END
END
ELSE IF @intSeqId = 3
BEGIN
	IF ISNULL(@intLocationId, 0) <> 0
	BEGIN
		INSERT INTO @tblTemp (intContractDetailId
			, strLocationName
			, strContractNumber
			, intContractSeq
			, strEntityName
			, dtmEndDate
			, Comments
			, strShipVia
			, dblCashPrice
			, strPricingType
			, strCurrency
			, dblTotal
			, intCommodityId)
		SELECT CD.intContractDetailId
			, CD.strLocationName
			, CD.strContractNumber
			, CD.intContractSeq
			, strEntityName
			, CD.dtmEndDate
			, CD.strRemark as Comments
			, strFreightTerm as strShipVia
			, isnull(dblCashPrice,0) dblCashPrice
			, strPricingType
			, strCurrency
			, isnull(CD.dblBalance,0) AS dblTotal
			, intCommodityId
		FROM vyuCTContractDetailView CD
		WHERE CD.intContractTypeId = 1  AND CD.intPricingTypeId IN (3) and CD.intContractStatusId <> 3
			and CD.intCommodityId = @intCommodityId AND CD.intCompanyLocationId = @intLocationId
	END
	ELSE
	BEGIN
		INSERT INTO @tblTemp (intContractDetailId
			, strLocationName
			, strContractNumber
			, intContractSeq
			, strEntityName
			, dtmEndDate
			, Comments
			, strShipVia
			, dblCashPrice
			, strPricingType
			, strCurrency
			, dblTotal
			, intCommodityId)
		SELECT CD.intContractDetailId
			, CD.strLocationName
			, CD.strContractNumber
			, CD.intContractSeq
			, strEntityName
			, CD.dtmEndDate
			, CD.strRemark as Comments
			, strFreightTerm as strShipVia
			, isnull(dblCashPrice,0) dblCashPrice
			, strPricingType
			, strCurrency
			, isnull(CD.dblBalance,0) AS dblTotal
			, intCommodityId
		FROM vyuCTContractDetailView CD
		WHERE CD.intContractTypeId = 1 AND CD.intPricingTypeId IN (3) and CD.intContractStatusId <> 3
			AND CD.intCommodityId = @intCommodityId
	END
END
ELSE IF @intSeqId = 4
BEGIN
	IF ISNULL(@intLocationId, 0) <> 0
	BEGIN
		INSERT INTO @tblTemp (intContractDetailId
			, strLocationName
			, strContractNumber
			, intContractSeq
			, strEntityName
			, dtmEndDate
			, Comments
			, strShipVia
			, dblCashPrice
			, strPricingType
			, strCurrency
			, dblTotal
			, intCommodityId)
		SELECT CD.intContractDetailId
			, CD.strLocationName
			, CD.strContractNumber
			, CD.intContractSeq
			, strEntityName
			, CD.dtmEndDate
			, CD.strRemark as Comments
			, strFreightTerm as strShipVia
			, isnull(dblCashPrice,0) dblCashPrice
			, strPricingType
			, strCurrency
			, isnull(CD.dblBalance,0) AS dblTotal
			, intCommodityId
		FROM vyuCTContractDetailView CD
		WHERE CD.intContractTypeId = 2  AND CD.intPricingTypeId IN (1) and CD.intContractStatusId <> 3
			and CD.intCommodityId = @intCommodityId AND CD.intCompanyLocationId = @intLocationId
	END
	ELSE
	BEGIN
		INSERT INTO @tblTemp (intContractDetailId
			, strLocationName
			, strContractNumber
			, intContractSeq
			, strEntityName
			, dtmEndDate
			, Comments
			, strShipVia
			, dblCashPrice
			, strPricingType
			, strCurrency
			, dblTotal
			, intCommodityId)
		SELECT CD.intContractDetailId
			, CD.strLocationName
			, CD.strContractNumber
			, CD.intContractSeq
			, strEntityName
			, CD.dtmEndDate
			, CD.strRemark as Comments
			, strFreightTerm as strShipVia
			, isnull(dblCashPrice,0) dblCashPrice
			, strPricingType
			, strCurrency
			, isnull(CD.dblBalance,0) AS dblTotal
			, intCommodityId
		FROM vyuCTContractDetailView CD
		WHERE CD.intContractTypeId = 2 AND CD.intPricingTypeId IN (1) and CD.intContractStatusId <> 3
			AND CD.intCommodityId = @intCommodityId
	END
END
ELSE IF @intSeqId = 5
BEGIN
	IF ISNULL(@intLocationId, 0) <> 0
	BEGIN
		INSERT INTO @tblTemp (intContractDetailId
			, strLocationName
			, strContractNumber
			, intContractSeq
			, strEntityName
			, dtmEndDate
			, Comments
			, strShipVia
			, dblCashPrice
			, strPricingType
			, strCurrency
			, dblTotal
			, intCommodityId)
		SELECT CD.intContractDetailId
			, CD.strLocationName
			, CD.strContractNumber
			, CD.intContractSeq
			, strEntityName
			, CD.dtmEndDate
			, CD.strRemark as Comments
			, strFreightTerm as strShipVia
			, isnull(dblCashPrice,0) dblCashPrice
			, strPricingType
			, strCurrency
			, isnull(CD.dblBalance,0) AS dblTotal
			, intCommodityId
		FROM vyuCTContractDetailView CD
		WHERE CD.intContractTypeId = 2  AND CD.intPricingTypeId IN (2) and CD.intContractStatusId <> 3
			and CD.intCommodityId = @intCommodityId AND CD.intCompanyLocationId = @intLocationId
	END
	ELSE
	BEGIN
		INSERT INTO @tblTemp (intContractDetailId
			, strLocationName
			, strContractNumber
			, intContractSeq
			, strEntityName
			, dtmEndDate
			, Comments
			, strShipVia
			, dblCashPrice
			, strPricingType
			, strCurrency
			, dblTotal
			, intCommodityId)
		SELECT CD.intContractDetailId
			, CD.strLocationName
			, CD.strContractNumber
			, CD.intContractSeq
			, strEntityName
			, CD.dtmEndDate
			, CD.strRemark as Comments
			, strFreightTerm as strShipVia
			, isnull(dblCashPrice,0) dblCashPrice
			, strPricingType
			, strCurrency
			, isnull(CD.dblBalance,0) AS dblTotal
			, intCommodityId
		FROM vyuCTContractDetailView CD
		WHERE CD.intContractTypeId = 2 AND CD.intPricingTypeId IN (2) and CD.intContractStatusId <> 3
			AND CD.intCommodityId = @intCommodityId
	END
END
ELSE IF @intSeqId = 6
BEGIN
	IF ISNULL(@intLocationId, 0) <> 0
	BEGIN
		INSERT INTO @tblTemp (intContractDetailId
			, strLocationName
			, strContractNumber
			, intContractSeq
			, strEntityName
			, dtmEndDate
			, Comments
			, strShipVia
			, dblCashPrice
			, strPricingType
			, strCurrency
			, dblTotal
			, intCommodityId)
		SELECT CD.intContractDetailId
			, CD.strLocationName
			, CD.strContractNumber
			, CD.intContractSeq
			, strEntityName
			, CD.dtmEndDate
			, CD.strRemark as Comments
			, strFreightTerm as strShipVia
			, isnull(dblCashPrice,0) dblCashPrice
			, strPricingType
			, strCurrency
			, isnull(CD.dblBalance,0) AS dblTotal
			, intCommodityId
		FROM vyuCTContractDetailView CD
		WHERE CD.intContractTypeId = 2  AND CD.intPricingTypeId IN (3) and CD.intContractStatusId <> 3
			and CD.intCommodityId = @intCommodityId AND CD.intCompanyLocationId = @intLocationId
	END
	ELSE
	BEGIN
		INSERT INTO @tblTemp (intContractDetailId
			, strLocationName
			, strContractNumber
			, intContractSeq
			, strEntityName
			, dtmEndDate
			, Comments
			, strShipVia
			, dblCashPrice
			, strPricingType
			, strCurrency
			, dblTotal
			, intCommodityId)
		SELECT CD.intContractDetailId
			, CD.strLocationName
			, CD.strContractNumber
			, CD.intContractSeq
			, strEntityName
			, CD.dtmEndDate
			, CD.strRemark as Comments
			, strFreightTerm as strShipVia
			, isnull(dblCashPrice,0) dblCashPrice
			, strPricingType
			, strCurrency
			, isnull(CD.dblBalance,0) AS dblTotal
			, intCommodityId
		FROM vyuCTContractDetailView CD
		WHERE CD.intContractTypeId = 2 AND CD.intPricingTypeId IN (3) and CD.intContractStatusId <> 3
			AND CD.intCommodityId = @intCommodityId
	END
END

SELECT intContractDetailId
	, strLocationName
	, strContractNumber
	, intContractSeq
	, strEntityName
	, dtmEndDate
	, Comments
	, strShipVia
	, dblCashPrice
	, strPricingType
	, strCurrency
	, dblTotal
FROM @tblTemp