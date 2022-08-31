CREATE PROCEDURE [dbo].[uspHDSyncCoworkerSuperVisor]
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN
	DELETE FROM tblHDCoworkerSuperVisor
	WHERE intEntityId IN ( 
		SELECT CoworkerSuperVisor.intEntityId 
		FROM tblHDCoworkerSuperVisor CoworkerSuperVisor
			LEFT JOIN tblHDCoworkerGoal CoworkerGoal
		ON CoworkerGoal.intReportsToId = CoworkerSuperVisor.intEntityId
		WHERE CoworkerGoal.intReportsToId IS NULL
		GROUP BY CoworkerSuperVisor.intEntityId 
	) AND [ysnAutoAdded] = CONVERT(BIT, 1)

	INSERT INTO tblHDCoworkerSuperVisor
	(
		 [intEntityId]
	    ,[ysnAutoAdded]
		,[intConcurrencyId]
	)
	SELECT [intEntityId]	  = [intReportsToId]
	      ,[ysnAutoAdded]	  = CONVERT(BIT, 1)
		  ,[intConcurrencyId] = 1
	FROM tblHDCoworkerGoal CoworkerGoal
		LEFT JOIN tblHDCoworkerSuperVisor CoworkerSuperVisor
	ON CoworkerSuperVisor.intEntityId = CoworkerGoal.intReportsToId
	WHERE CoworkerGoal.intReportsToId IS NOT NULL AND CoworkerSuperVisor.intEntityId IS NULL
	GROUP BY [intReportsToId]

END
GO