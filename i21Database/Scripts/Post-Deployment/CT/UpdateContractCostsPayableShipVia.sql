PRINT('CT - UpdateContractCostsPayableShipVia Started')

IF EXISTS (
    SELECT TOP 1 1
    FROM tblAPVoucherPayable VP
    INNER JOIN vyuCTContractCostView CC
        ON VP.intContractHeaderId = CC.intContractHeaderId
    WHERE VP.intShipViaId = 0
)
BEGIN
    UPDATE VP
    SET VP.intShipViaId = NULL
    FROM tblAPVoucherPayable VP
    INNER JOIN vyuCTContractCostView CC
        ON VP.intContractHeaderId = CC.intContractHeaderId
    WHERE VP.intShipViaId = 0
END

PRINT('CT - UpdateContractCostsPayableShipVia Ended')

GO