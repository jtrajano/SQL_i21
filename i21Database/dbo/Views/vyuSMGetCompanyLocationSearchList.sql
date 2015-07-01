CREATE VIEW [dbo].[vyuSMGetCompanyLocationSearchList]
	AS SELECT compLoc.*, ISNULL(acctSgmt.strCode, '') strCode
		FROM tblSMCompanyLocation compLoc
		LEFT OUTER JOIN dbo.tblGLAccountSegment acctSgmt
		ON compLoc.intProfitCenter = acctSgmt.intAccountSegmentId
