CREATE PROCEDURE [dbo].[uspAPLogVoucherDetailRisk]
	@voucherDetailIds AS Id,
	@remove BIT = 0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN

	DECLARE @rkSummaryLog AS RKSummaryLog;
	EXEC [dbo].[uspRKLogRiskPosition]
			@SummaryLogs = rkSummaryLog
			,@Rebuild = 0

END