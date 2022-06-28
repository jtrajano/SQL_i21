CREATE VIEW vyuGLEliminateDetail
AS
SELECT 
	  GLED.[intEliminateDetailId]
	 ,GLE.[intEliminateId]
	 ,GLED.[intAccount1Id]
	 ,strAccount1Id				= GLA1.strAccountId
	 ,GLED.[intOffsetAccount1Id]
	 ,strOffsetAccount1Id		= GLAO1.strAccountId
	 ,GLED.[dblBalance1]
	 ,GLED.[intAccount2Id]
	 ,strAccount2Id				= GLA2.strAccountId
	 ,GLED.[intOffsetAccount2Id]
	 ,strOffsetAccount2Id		= GLAO2.strAccountId
	 ,GLED.[dblBalance2]
	 ,GLED.[dblDifference]
	 ,GLED.[intConcurrencyId]
FROM tblGLEliminateDetail GLED
INNER JOIN tblGLEliminate GLE ON GLED.[intEliminateId] = GLE.[intEliminateId]
INNER JOIN tblGLAccount GLA1 ON GLED.[intAccount1Id] = GLA1.[intAccountId]
LEFT JOIN tblGLAccount GLAO1 ON GLED.[intOffsetAccount1Id] = GLAO1.[intAccountId]
INNER JOIN tblGLAccount GLA2 ON GLED.[intAccount1Id] = GLA2.[intAccountId]
LEFT JOIN tblGLAccount GLAO2 ON GLED.[intOffsetAccount2Id] = GLAO2.[intAccountId]
