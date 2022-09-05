CREATE VIEW [dbo].[vyuHDExemptedAgent]
AS
	SELECT   intEntityId  = Agent.intEntityId
	FROM
	(
		SELECT   intEntityId   = CoworkerSuperVisor.intEntityId
		FROM tblHDCoworkerSuperVisor CoworkerSuperVisor

		UNION ALL

		SELECT intEntityId   = CoworkerGoal.intEntityId
		FROM tblHDCoworkerGoal CoworkerGoal
		WHERE ysnActive = CONVERT(bit, 0) AND strFiscalYear = DATEPART(YEAR, GETDATE())
	) Agent
	GROUP BY Agent.intEntityId
GO