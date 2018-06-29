/*
Usage: 
This will update the cost of bill based on the provided contract.
Posted bill are not going to update.
*/
CREATE PROCEDURE [dbo].[uspAPUpdateBillContractPrice]
	@contractHeaderId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

UPDATE A
	SET A.dblCost = ISNULL(B2.dblCashPrice,0)
FROM tblAPBillDetail A
INNER JOIN tblAPBill C ON A.intBillId = C.intBillId
INNER JOIN (tblCTContractHeader B1 INNER JOIN tblCTContractDetail B2 ON B1.intContractHeaderId = B2.intContractHeaderId)
	ON A.intContractDetailId = B2.intContractDetailId
WHERE B1.intContractHeaderId = @contractHeaderId
AND C.ysnPosted = 0 AND A.intContractDetailId IS NOT NULL