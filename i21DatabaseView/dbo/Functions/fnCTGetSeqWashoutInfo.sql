CREATE FUNCTION [dbo].[fnCTGetSeqWashoutInfo]
(
	@intContractDetailId	INT
)

RETURNS	@returntable	TABLE
(
     intWashoutId	    INT
    ,strSourceNumber    NVARCHAR(100)
    ,strWashoutNumber   NVARCHAR(100)
    ,dblSourceCashPrice NUMERIC(18,6)
    ,dblWTCashPrice	    NUMERIC(18,6)
    ,strBillInvoice	    NVARCHAR(100)
    ,intBillInvoiceId   INT
    ,strDocType			NVARCHAR(100)
    ,strAdjustmentType  NVARCHAR(100)
)

AS
BEGIN
    IF EXISTS(SELECT TOP 1 1 FROM tblCTWashout WHERE @intContractDetailId IN (intWashoutDetailId,intSourceDetailId))
    BEGIN
	   INSERT INTO @returntable
	   SELECT    WO.intWashoutId
				,WO.strSourceNumber
				,WO.strWashoutNumber
				,WO.dblCashPrice AS dblSourceCashPrice
				,WO.dblWTCashPrice
				,WO.strBillInvoice
				,WO.intBillInvoiceId
				,WO.strDocType
				,CASE WHEN ISNULL(WO.intWashoutId, 0) > 0THEN 'Washout'ELSE ''END AS strAdjustmentType
	   FROM		tblCTWashout WO
	   WHERE	@intContractDetailId IN (intWashoutDetailId,intSourceDetailId)
    END

    RETURN;
END