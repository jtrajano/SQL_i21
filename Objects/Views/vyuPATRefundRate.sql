CREATE VIEW [dbo].[vyuPATRefundRate]
AS
SELECT	RR.intRefundTypeId,
		RR.strRefundType,
		RR.strRefundDescription,
		RR.ysnQualified,
		RR.intGeneralReserveId,
		strGeneralReserveId = GRID.strAccountId,
		RR.intAllocatedReserveId,
		strAllocatedReserveId = ARID.strAccountId,
		RR.intUndistributedEquityId,
		strUndistributedEquityId = UEID.strAccountId,
		RR.dblCashPayout,
		RR.intConcurrencyId
FROM tblPATRefundRate RR
LEFT JOIN tblGLAccount GRID
	ON GRID.intAccountId = RR.intGeneralReserveId
LEFT JOIN tblGLAccount ARID
	ON ARID.intAccountId = RR.intAllocatedReserveId
LEFT JOIN tblGLAccount UEID
	ON UEID.intAccountId = RR.intUndistributedEquityId