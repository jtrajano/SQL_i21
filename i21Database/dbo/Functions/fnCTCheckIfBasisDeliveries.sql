﻿CREATE FUNCTION [dbo].[fnCTCheckIfBasisDeliveries](
	@intContractDetailId INT -- Contract Detail Id
	, @intTransactionRecordId INT -- Inventory Receipt Item Id or Inventory Shipment Item Id
	, @strBucketType NVARCHAR(50) --  Purchase Basis Deliveries or Sales Basis Deliveries
)
RETURNS BIT
AS
BEGIN



IF EXISTS(SELECT TOP 1 * FROM tblRKSummaryLog
	WHERE intContractDetailId = @intContractDetailId
	AND strBucketType = @strBucketType
	AND @intTransactionRecordId = (case when strTransactionType = 'Settle Storage' then intTransactionRecordHeaderId else intTransactionRecordId end))--AND intTransactionRecordId  = @intTransactionRecordId )
BEGIN

	RETURN 1

END

RETURN 0

END